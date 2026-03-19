require('dotenv').config();
const http = require('http');
const { Server } = require('socket.io');
const Redis = require('ioredis');
const jwt = require('jsonwebtoken');
const axios = require('axios');

const PORT = process.env.SOCKET_PORT || 3001;
const REDIS_URL = process.env.REDIS_URL || 'redis://127.0.0.1:6379';
const API_URL = process.env.API_URL || 'http://127.0.0.1:8000/api';
const JWT_SECRET = process.env.JWT_SECRET || process.env.APP_KEY; 

const httpServer = http.createServer();
const io = new Server(httpServer, {
    cors: {
        origin: "*", // Adjust for production
        methods: ["GET", "POST"]
    }
});

// Redis connection for Pub/Sub
const redis = new Redis(REDIS_URL);
const subscriber = new Redis(REDIS_URL);

redis.on('connect', () => console.log('Redis Main Client: Connected'));
redis.on('error', (err) => console.error('Redis Main Client: Error', err));

subscriber.on('connect', () => console.log('Redis Subscriber: Connected'));
subscriber.on('error', (err) => console.error('Redis Subscriber: Error', err));

// Store online users: userId -> Set of socket IDs
const onlineUsers = new Map(); 
// Store user status: userId -> 'online' | 'away'
const userStatuses = new Map();
// Track disconnect timeouts: userId -> timeoutId
const disconnectTimeouts = new Map();

// Authentication Middleware
io.use((socket, next) => {
    const token = socket.handshake.auth.token || socket.handshake.headers['authorization'];
    const rawUserId = socket.handshake.auth.userId; 
    
    if (!token) {
        console.error('[AUTH] Connection rejected: Token missing');
        return next(new Error('Authentication error: Token missing'));
    }

    if (rawUserId) {
        const userId = String(rawUserId);
        socket.user = { id: userId };
        console.log(`[AUTH] User ${userId} authenticated from handshake`);
        return next();
    }

    // Fallback for older frontend sessions or tests
    const fallbackId = token.substring(0, 8);
    socket.user = { id: fallbackId }; 
    console.warn(`[AUTH] No userId in handshake, using fallback: ${fallbackId}`);
    next();
});

// Redis Subscription - Bridge from Laravel
// Subscribing to ALL patterns temporarily to debug channel names
subscriber.psubscribe('*', (err, count) => {
    if (err) console.error('Redis subscription error:', err);
    else console.log(`[REDIS] Subscribed to ALL channels (Wildcard enabled)`);
});

subscriber.on('pmessage', (pattern, channel, message) => {
    console.log(`[REDIS] Message on ${channel}: ${message.substring(0, 100)}...`);
    
    let data;
    try {
        data = JSON.parse(message);
    } catch (e) {
        console.error('Failed to parse Redis message', e);
        return;
    }

    const originalEvent = data.event;
    const payload = data.data;

    // Clean up event name (Protect specific names before popping namespaces)
    let event = originalEvent;
    if (originalEvent === 'block.updated' || originalEvent === 'block_updated') {
        event = 'block_updated';
    } else if (originalEvent.includes('\\')) {
        event = originalEvent.split('\\').pop();
    } else if (originalEvent.includes('.')) {
        event = originalEvent.split('.').pop();
    }
    
    // Normalize system.notification
    if (event === 'notification' || originalEvent === 'system.notification') {
        event = 'system.notification';
    }

    // Unwrap Laravel's nested 'data' if present
    let finalPayload = payload;
    if (payload && payload.data && typeof payload.data === 'object' && !payload.type) {
        finalPayload = { ...payload.data, ...payload };
    }

    // Detect userId from channel like "...user.123" or "...private-user.123"
    if (channel.toLowerCase().includes('user.')) {
        const parts = channel.split('.');
        if (parts.length >= 2) {
            const userId = parts[parts.length - 1];
            console.log(`[SOCKET] Relaying ${event} to user.${userId}`, finalPayload);
            io.to(`user.${userId}`).emit(event, finalPayload);
        }
    } else if (channel.endsWith('notifications')) {
        console.log(`[SOCKET] Broadcasting ${event} globally`);
        io.emit(event, finalPayload);
    }
});

io.on('connection', (socket) => {
    const userId = socket.user.id;
    console.log(`User connected: ${userId}`);

    // Track presence
    if (!onlineUsers.has(userId)) {
        onlineUsers.set(userId, new Set());
        userStatuses.set(userId, 'online'); // Default to online
    }
    onlineUsers.get(userId).add(socket.id);

    // Clear any pending offline broadcast for this user
    if (disconnectTimeouts.has(userId)) {
        clearTimeout(disconnectTimeouts.get(userId));
        disconnectTimeouts.delete(userId);
    }

    // Join personal channel
    socket.join(`user.${userId}`);

    // Fetch and join rooms
    const joinRooms = async () => {
        try {
            let token = socket.handshake.auth.token || socket.handshake.headers['authorization'];
            if (token && !token.startsWith('Bearer ')) token = `Bearer ${token}`;
            
            const response = await axios.get(`${API_URL}/rooms`, {
                headers: { 'Authorization': token }
            });
            const rooms = response.data;
            rooms.forEach(room => {
                socket.join(`room.${room.id}`);
                console.log(`[SOCKET] User ${userId} joined room ${room.id}`);
            });
        } catch (err) {
            console.error('[SOCKET] Failed to join rooms on connect', err.message);
        }
    };
    joinRooms();

    // Send the current online list to the new user
    const currentOnline = {};
    onlineUsers.forEach((sockets, uid) => {
        if (sockets.size > 0) currentOnline[uid] = userStatuses.get(uid) || 'online';
    });
    socket.emit('presence.state', currentOnline);

    // Handle status changes (Online -> Away, etc)
    socket.on('presence.status', ({ status }) => {
        if (['online', 'away'].includes(status)) {
            userStatuses.set(userId, status);
            console.log(`[PRESENT] User ${userId} is now ${status}`);
            io.emit('presence.update', { userId, status });
        }
    });

    // Broadcast to others that this user is online (only if it's their first active session)
    if (onlineUsers.get(userId).size === 1) {
        io.emit('presence.update', { userId, status: userStatuses.get(userId) || 'online' });
    }

    // --- Private Messaging ---
    socket.on('chat.private.send', async ({ receiverId, content, type, fileName, replyToId, isForwarded, linkMetadata }, callback) => {
        const parsedReceiverId = parseInt(receiverId);
        if (!parsedReceiverId || !content) {
            return callback({ status: 'error', message: 'Invalid private message payload' });
        }

        try {
            let token = socket.handshake.auth.token || socket.handshake.headers['authorization'];
            if (token && !token.startsWith('Bearer ')) token = `Bearer ${token}`;

            const response = await axios.post(`${API_URL}/messages`, {
                receiver_id: parsedReceiverId,
                content,
                type: type || 'text',
                file_name: fileName,
                reply_to_id: replyToId || null,
                is_forwarded: isForwarded || false,
                link_metadata: linkMetadata || null
            }, {
                headers: { 'Authorization': token, 'Accept': 'application/json' }
            });

            const savedMessage = response.data;
            const channel = `user.${parsedReceiverId}`;
            
            io.to(channel).emit('message.received', {
                ...savedMessage,
                id: savedMessage.id,
                senderId: userId,
                receiverId: parsedReceiverId,
                roomId: null,
                content: savedMessage.content,
                timestamp: savedMessage.created_at,
                is_read: false,
                reactions: []
            });

            if (callback) callback({ status: 'ok', timestamp: savedMessage.created_at, id: savedMessage.id });
        } catch (err) {
            const errorMsg = err.response ? JSON.stringify(err.response.data) : err.message;
            console.error('[PRIVATE] Failed to persist:', errorMsg);
            if (callback) callback({ status: 'error', message: `Failed to save private message: ${errorMsg}` });
        }
    });

    // --- Group Messaging ---
    socket.on('chat.poke', ({ receiverId }) => {
        if (!receiverId) return;
        console.log(`[SOCKET] User ${userId} pokes user ${receiverId}`);
        io.to(`user.${receiverId}`).emit('chat.poke', { senderId: userId });
    });

    socket.on('chat.group.send', async ({ roomId, content, type, fileName, replyToId, isForwarded, linkMetadata }, callback) => {
        const parsedRoomId = parseInt(roomId);
        if (!parsedRoomId || !content) {
            return callback({ status: 'error', message: 'Invalid group message payload' });
        }

        try {
            let token = socket.handshake.auth.token || socket.handshake.headers['authorization'];
            if (token && !token.startsWith('Bearer ')) token = `Bearer ${token}`;

            const response = await axios.post(`${API_URL}/messages`, {
                room_id: parsedRoomId,
                content,
                type: type || 'text',
                file_name: fileName,
                reply_to_id: replyToId || null,
                is_forwarded: isForwarded || false,
                link_metadata: linkMetadata || null
            }, {
                headers: { 'Authorization': token, 'Accept': 'application/json' }
            });

            const savedMessage = response.data;
            const channel = `room.${parsedRoomId}`;
            
            io.to(channel).emit('message.received', {
                ...savedMessage,
                id: savedMessage.id,
                senderId: userId,
                receiverId: null,
                roomId: parsedRoomId,
                content: savedMessage.content,
                timestamp: savedMessage.created_at,
                is_read: false,
                reactions: []
            });

            if (callback) callback({ status: 'ok', timestamp: savedMessage.created_at, id: savedMessage.id });
        } catch (err) {
            const errorMsg = err.response ? JSON.stringify(err.response.data) : err.message;
            console.error('[GROUP] Failed to persist:', errorMsg);
            if (callback) callback({ status: 'error', message: `Failed to save group message: ${errorMsg}` });
        }
    });

    // Legacy support (to avoid breaking the app immediately)
    socket.on('chat.send', async (data, callback) => {
        if (data.roomId) {
            socket.emit('chat.group.send', data, callback);
        } else {
            socket.emit('chat.private.send', data, callback);
        }
    });

    // --- Typing Indicators ---
    socket.on('chat.private.typing', ({ receiverId }) => {
        if (!receiverId) return;
        socket.to(`user.${parseInt(receiverId)}`).emit('chat.typing', { userId, receiverId: parseInt(receiverId) });
    });

    socket.on('chat.group.typing', ({ roomId }) => {
        if (!roomId) return;
        socket.to(`room.${parseInt(roomId)}`).emit('chat.typing', { userId, roomId: parseInt(roomId) });
    });

    // --- Read Receipts ---
    socket.on('chat.private.read', ({ receiverId }) => {
        if (!receiverId) return;
        socket.to(`user.${parseInt(receiverId)}`).emit('chat.read', { userId, receiverId: parseInt(receiverId) });
    });

    socket.on('chat.group.read', ({ roomId }) => {
        if (!roomId) return;
        socket.to(`room.${parseInt(roomId)}`).emit('chat.read', { userId, roomId: parseInt(roomId) });
    });

    // Legacy Typing/Read support
    socket.on('chat.typing', (data) => {
        if (data.roomId) socket.emit('chat.group.typing', data);
        else socket.emit('chat.private.typing', data);
    });

    socket.on('chat.read', (data) => {
        if (data.roomId) socket.emit('chat.group.read', data);
        else socket.emit('chat.private.read', data);
    });

    // --- WebRTC Signaling Events ---
    
    // 1. Initial Call Request (1-on-1)
    socket.on('call:initiate', ({ receiverId, type }) => {
        const rId = String(receiverId);
        const room = `user.${rId}`;
        const roomSize = io.sockets.adapter.rooms.get(room)?.size || 0;
        console.log(`[CALL] initiate: from ${userId} to ${rId}. Room ${room} size: ${roomSize}`);

        io.to(room).emit('call:incoming', { 
            senderId: userId, 
            type: type || 'video' 
        });
    });

    // 2. SDP Offer
    socket.on('call:offer', ({ receiverId, offer, type }) => {
        const rId = String(receiverId);
        console.log(`[CALL] offer: relay from ${userId} to ${rId}`);
        io.to(`user.${rId}`).emit('call:offer', { senderId: userId, offer, type });
    });

    // 3. SDP Answer
    socket.on('call:answer', ({ receiverId, answer }) => {
        const rId = String(receiverId);
        console.log(`[CALL] answer: relay from ${userId} to ${rId}`);
        io.to(`user.${rId}`).emit('call:answer', { senderId: userId, answer });
    });

    // 4. Call Accepted
    socket.on('call:accept', ({ receiverId }) => {
        const rId = String(receiverId);
        console.log(`[CALL] accept: from ${userId} for ${rId}`);
        io.to(`user.${rId}`).emit('call:accepted', { senderId: userId });
    });

    // 5. ICE Candidates
    socket.on('call:ice-candidate', ({ receiverId, candidate }) => {
        const rId = String(receiverId);
        io.to(`user.${rId}`).emit('call:ice-candidate', { senderId: userId, candidate });
    });

    // 6. Call Rejected
    socket.on('call:reject', ({ receiverId }) => {
        const rId = String(receiverId);
        console.log(`[CALL] reject: from ${userId} for ${rId}`);
        io.to(`user.${rId}`).emit('call:rejected', { senderId: userId });
    });

    // 7. Call Ended
    socket.on('call:end', ({ receiverId }) => {
        const rId = String(receiverId);
        console.log(`[CALL] end: from ${userId} for ${rId}`);
        io.to(`user.${rId}`).emit('call:ended', { senderId: userId });
    });

    // --- NEW: Group Call Room Events ---

    socket.on('call:join-room', ({ roomId }) => {
        const room = `call.room.${roomId}`;
        socket.join(room);
        console.log(`[CALL] user ${userId} joined room ${roomId}`);
        
        // Notify others in the room that a new user joined
        socket.to(room).emit('call:user-joined', { userId });
        
        // Return current participants to the joining user (optional, can be managed via room state)
        const participants = Array.from(io.sockets.adapter.rooms.get(room) || [])
            .map(sid => {
                const s = io.sockets.sockets.get(sid);
                return s ? s.user.id : null;
            })
            .filter(id => id && id !== userId);
        
        socket.emit('call:room-participants', { participants });
    });

    socket.on('call:leave-room', ({ roomId }) => {
        const room = `call.room.${roomId}`;
        socket.leave(room);
        console.log(`[CALL] user ${userId} left room ${roomId}`);
        io.to(room).emit('call:user-left', { userId });
    });

    // Targeted signaling for mesh network
    socket.on('call:signal', ({ to, signal }) => {
        console.log(`[CALL] signaling from ${userId} to ${to}`);
        io.to(`user.${to}`).emit('call:signal', { from: userId, signal });
    });

    socket.on('call:invite-group', ({ userIds, roomId, type }) => {
        console.log(`[CALL] group invite from ${userId} to ${userIds} for room ${roomId}`);
        userIds.forEach(rId => {
            io.to(`user.${rId}`).emit('call:incoming-group', { 
                senderId: userId, 
                roomId, 
                type: type || 'video' 
            });
        });
    });

    // --- Screen Sharing Signaling ---
    socket.on('screenshare:invite', ({ receiverId, passcode }) => {
        const rId = String(receiverId);
        console.log(`[SCREENSHARE] invite from ${userId} to ${rId}`);
        io.to(`user.${rId}`).emit('screenshare:incoming', { 
            senderId: userId, 
            senderName: socket.user?.name || 'User', 
            passcode 
        });
    });

    socket.on('screenshare:join-request', ({ senderId, passcode, username }) => {
        const sId = String(senderId);
        console.log(`[SCREENSHARE] join-request from ${userId} to ${sId}`);
        io.to(`user.${sId}`).emit('screenshare:join-attempt', { 
            receiverId: userId, 
            username, 
            passcode 
        });
    });

    socket.on('screenshare:join-accept', ({ receiverId }) => {
        const rId = String(receiverId);
        io.to(`user.${rId}`).emit('screenshare:accepted', { senderId: userId });
    });

    socket.on('screenshare:signal', ({ to, signal }) => {
        io.to(`user.${to}`).emit('screenshare:signal', { from: userId, signal });
    });

    socket.on('screenshare:end', ({ to }) => {
        io.to(`user.${to}`).emit('screenshare:ended', { senderId: userId });
    });

    socket.on('disconnect', () => {
        console.log(`User socket disconnected: ${userId} (${socket.id})`);
        
        const sessions = onlineUsers.get(userId);
        if (sessions) {
            sessions.delete(socket.id);
            if (sessions.size === 0) {
                // If no sessions left, wait 5 seconds before marking as offline
                // to account for page refreshes/reconnects
                const timeoutId = setTimeout(() => {
                    if (!onlineUsers.has(userId) || onlineUsers.get(userId).size === 0) {
                        console.log(`User ${userId} IS actually offline now`);
                        onlineUsers.delete(userId);
                        disconnectTimeouts.delete(userId);
                        io.emit('presence.update', { userId, status: 'offline' });
                    }
                }, 5000); // 5 second grace period
                disconnectTimeouts.set(userId, timeoutId);
            }
        }
    });
});

const VERSION = '1.0.2';
const HOST = process.env.SOCKET_HOST || '0.0.0.0';
httpServer.listen(PORT, HOST, () => {
    console.log(`Socket.io server v${VERSION} running on ${HOST}:${PORT}`);
});

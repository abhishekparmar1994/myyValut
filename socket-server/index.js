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

// Store online users
const onlineUsers = new Map(); // userId -> socketId

// Authentication Middleware
io.use((socket, next) => {
    const token = socket.handshake.auth.token || socket.handshake.headers['authorization'];
    const userId = socket.handshake.auth.userId; 
    
    if (!token) {
        return next(new Error('Authentication error: Token missing'));
    }

    if (userId) {
        socket.user = { id: String(userId) };
        return next();
    }

    // Fallback for older frontend sessions or tests
    socket.user = { id: token.substring(0, 8) }; 
    next();
});

// Redis Subscription - Bridge from Laravel (Unchanged)
subscriber.subscribe('laravel_database_user.*', 'laravel_database_notifications', (err, count) => {
    if (err) console.error('Redis subscription error:', err);
});

subscriber.on('message', (channel, message) => {
    console.log(`Received message from ${channel}: ${message}`);
    const data = JSON.parse(message);
    const event = data.event;
    const payload = data.data;

    if (channel.startsWith('laravel_database_user.')) {
        const userId = channel.split('.').pop();
        io.to(`user.${userId}`).emit(event, payload);
    } else if (channel === 'laravel_database_notifications') {
        io.emit(event, payload);
    }
});

io.on('connection', (socket) => {
    const userId = socket.user.id;
    console.log(`User connected: ${userId}`);

    // Track presence
    onlineUsers.set(userId, socket.id);

    // Join personal channel
    socket.join(`user.${userId}`);

    // Send the current online list to the new user
    const currentOnline = {};
    onlineUsers.forEach((sid, uid) => {
        currentOnline[uid] = 'online';
    });
    socket.emit('presence.state', currentOnline);

    // Broadcast to others that this user is online
    io.emit('presence.update', { userId, status: 'online' });

    // Handle incoming chat messages (Client to Client via Server)
    socket.on('chat.send', async ({ receiverId, content, type, fileName }, callback) => {
        if (!receiverId || !content) {
            return callback({ status: 'error', message: 'Invalid payload' });
        }

        const timestamp = new Date().toISOString()
        
        try {
            let token = socket.handshake.auth.token || socket.handshake.headers['authorization'];
            if (token && !token.startsWith('Bearer ')) {
                token = `Bearer ${token}`;
            }

            // Persist via Laravel API
            await axios.post(`${API_URL}/messages`, {
                receiver_id: receiverId,
                content,
                type: type || 'text',
                file_name: fileName
            }, {
                headers: { 
                    'Authorization': token,
                    'Accept': 'application/json'
                }
            })

            // Relay to receiver
            io.to(`user.${receiverId}`).emit('message.received', {
                senderId: userId,
                content,
                type: type || 'text',
                fileName,
                timestamp
            })

            if (callback) callback({ status: 'ok', timestamp })
        } catch (err) {
            console.error('Failed to persist message:', err.response?.data || err.message)
            if (callback) callback({ status: 'error', message: 'Failed to save message' })
        }
    })

    // Typing Indicators
    socket.on('chat.typing', (payload) => {
        socket.to(`user.${payload.receiverId}`).emit('chat.typing', { userId });
    });

    // Read Receipts
    socket.on('chat.read', (payload) => {
        socket.to(`user.${payload.receiverId}`).emit('chat.read', { userId });
    });

    socket.on('disconnect', () => {
        console.log(`User disconnected: ${userId}`);
        onlineUsers.delete(userId);
        io.emit('presence.update', { userId, status: 'offline' });
    });
});

const VERSION = '1.0.2';
httpServer.listen(PORT, () => {
    console.log(`Socket.io server v${VERSION} running on port ${PORT}`);
});

import { defineStore } from 'pinia'
import { io } from 'socket.io-client'
import { useAuthStore } from './auth'

export const useChatStore = defineStore('chat', () => {
    const auth = useAuthStore()
    const socket = ref(null)
    const messages = ref([])
    const presence = ref({})
    const typingUsers = ref({}) // { userId: timeoutId }
    const connected = ref(false)
    const loadingMessages = ref(false)
    const users = ref([])
    const blockedUsers = ref([])
    const pinnedMessage = ref(null)
    const replyTo = ref(null)
    const activeUserId = ref(null)
    const blockUpdateTrigger = ref(0)
    const notificationPermission = ref('default')
    const unreadCounts = ref({})
    const rooms = ref([])
    const activeRoomId = ref(null)

    const totalUnreadCount = computed(() => {
        return Object.values(unreadCounts.value).reduce((sum, count) => sum + (count || 0), 0)
    })

    const totalChatsUnread = computed(() => {
        return Object.entries(unreadCounts.value)
            .filter(([key]) => key.startsWith('user_'))
            .reduce((sum, [_, count]) => sum + (count || 0), 0)
    })

    const totalGroupsUnread = computed(() => {
        return Object.entries(unreadCounts.value)
            .filter(([key]) => key.startsWith('room_'))
            .reduce((sum, [_, count]) => sum + (count || 0), 0)
    })

    function init() {
        if (socket.value) return
        
        fetchUsers()
        fetchRooms()
        fetchBlockedUsers()
        fetchUnreadCounts()

        // Request notification permission if supported
        if (import.meta.client && 'Notification' in window) {
            notificationPermission.value = Notification.permission
            if (Notification.permission === 'default') {
                Notification.requestPermission().then(permission => {
                    notificationPermission.value = permission
                })
            }
        }

        // Watch for user to be available before connecting
        watch(() => auth.user, (user) => {
            if (user && !socket.value) {
                connect()
            } else if (!user && socket.value) {
                disconnect()
            }
        }, { immediate: true })
    }

    function connect() {
        if (socket.value || !auth.user?.id) return

        const config = useRuntimeConfig()
        socket.value = io(config.public.socketUrl, {
            auth: { 
                token: auth.token,
                userId: auth.user.id 
            },
            reconnection: true,
            reconnectionAttempts: 5,
            reconnectionDelay: 2000
        })

        socket.value.on('connect', () => {
            connected.value = true
            console.log('Connected to chat server')
        })

        socket.value.on('block.updated', (payload) => {
            // Signal a refresh might be needed for components watching this
            // We can just trigger fetchBlockedUsers to be safe, though it's the other way
            console.log('Block status updated by another user', payload)
            // Use a trigger ref that components can watch
            blockUpdateTrigger.value++
        })

        socket.value.on('connect_error', (err) => {
            console.error('Socket connect_error:', err)
            alert(`Socket connection failed: ${err.message}`)
        })

        socket.value.on('disconnect', () => {
            connected.value = false
            console.log('Disconnected from chat server')
        })

        socket.value.on('presence.state', (state) => {
            presence.value = { ...state }
        })

        socket.value.on('message.received', (message) => {
            // Only push if the message belongs to the active conversation
            const isMatch = message.roomId 
                ? String(message.roomId) === String(activeRoomId.value)
                : activeUserId.value && String(message.senderId) === String(activeUserId.value)

            if (isMatch) {
                // Check if we already have this message (deduplication)
                const exists = messages.value.some(m => String(m.id) === String(message.id))
                if (!exists) {
                    messages.value = [...messages.value, {
                        ...message,
                        isMe: String(message.senderId) === String(auth.user?.id)
                    }]
                }
            }
            
            // Update last message in users/rooms list
            updateLastMessage(message.roomId || message.senderId, message, !!message.roomId)

            // Increment unread count if it's not from me AND we're not currently looking at this chat
            const isFromOther = String(message.senderId) !== String(auth.user?.id)
            if (isFromOther) {
                if (!isMatch) {
                    const key = message.roomId ? `room_${message.roomId}` : `user_${message.senderId}`
                    unreadCounts.value[key] = (unreadCounts.value[key] || 0) + 1
                } else {
                    sendRead(message.senderId, message.roomId)
                }
            }

            // Show background notification (regardless of active chat)
            const isMe = String(message.senderId) === String(auth.user?.id)
            if (import.meta.client && document.visibilityState === 'hidden' && !isMe) {
                const sender = users.value.find(u => String(u.id) === String(message.senderId))
                const senderName = sender ? sender.name : `User ${message.senderId}`
                
                showNotification(`New message from ${senderName}`, {
                    body: message.content,
                    icon: '/favicon.ico'
                })
            }
        })

        socket.value.on('presence.update', ({ userId, status }) => {
            presence.value = { ...presence.value, [String(userId)]: status }
        })

        socket.value.on('chat.typing', ({ userId }) => {
            const uid = String(userId)
            
            // Clear existing timeout if any
            if (typingUsers.value[uid]) {
                clearTimeout(typingUsers.value[uid])
            }
            
            // Set a new timeout to clear typing status
            const timeout = setTimeout(() => {
                const newTyping = { ...typingUsers.value }
                delete newTyping[uid]
                typingUsers.value = newTyping
            }, 3000)

            typingUsers.value = { ...typingUsers.value, [uid]: timeout }
        })

        socket.value.on('chat.read', ({ userId, roomId }) => {
            const isMatch = roomId 
                ? String(roomId) === String(activeRoomId.value)
                : activeUserId.value && String(userId) === String(activeUserId.value)

            if (isMatch) {
                messages.value.forEach(m => {
                    const isSentByMe = m.senderId == auth.user?.id
                    const isRelevant = roomId ? m.roomId == roomId : m.receiverId == userId
                    if (isSentByMe && isRelevant) {
                        m.is_read = true
                    }
                })
            }
        })

        // Bridges from Laravel (Redis -> Socket -> Client)
        socket.value.on('message.sent', (payload) => {
            const message = payload.message
            const exists = messages.value.some(m => String(m.id) === String(message.id))
            if (!exists) {
                messages.value = [...messages.value, {
                    ...message,
                    senderId: message.sender_id, // Map for consistency
                    receiverId: message.receiver_id,
                    roomId: message.room_id,
                    isMe: String(message.sender_id) === String(auth.user?.id),
                    fromLaravel: true
                }]
            }

            // Update last message in users/rooms list
            const targetIdForUpdate = message.room_id || message.receiver_id
            updateLastMessage(targetIdForUpdate, message, !!message.room_id)

            // Increment unread count if it's not from me AND we're not currently looking at this chat
            const isFromOther = payload.message.sender_id != auth.user?.id
            const isCurrentChat = payload.message.room_id 
                ? String(payload.message.room_id) === String(activeRoomId.value)
                : String(payload.message.sender_id) === String(activeUserId.value)
            
            if (isFromOther) {
                if (!isCurrentChat) {
                    const key = payload.message.room_id ? `room_${payload.message.room_id}` : `user_${payload.message.sender_id}`
                    unreadCounts.value[key] = (unreadCounts.value[key] || 0) + 1
                } else {
                    sendRead(payload.message.sender_id, payload.message.room_id)
                }
            }
        })

        socket.value.on('system.notification', (payload) => {
            console.log('[CHAT STORE] System Notification Received:', payload)
            
            // Special handling for room membership/activity updates
            if (payload.type === 'message_received' && payload.room) {
                // Check if current user is still a member
                const isMember = payload.room.members?.some(m => String(m.id) === String(auth.user?.id))
                
                if (!isMember) {
                    // Remove room from local list if we are no longer a member (kicked or left)
                    rooms.value = rooms.value.filter(r => String(r.id) !== String(payload.room.id))
                    if (String(payload.room.id) === String(activeRoomId.value)) {
                        activeRoomId.value = null
                    }
                    console.log(`[CHAT STORE] Removed from room ${payload.room.id}`)
                    return
                }

                const idx = rooms.value.findIndex(r => String(r.id) === String(payload.room.id))
                if (idx !== -1) {
                    rooms.value[idx] = { ...rooms.value[idx], ...payload.room }
                } else {
                    // It's a new room for us (e.g., someone added us to a group)
                    rooms.value = [payload.room, ...rooms.value]
                }
                
                if (payload.message) {
                    const message = payload.message
                    const isMatch = String(message.roomId) === String(activeRoomId.value)
                    if (isMatch) {
                        const exists = messages.value.some(m => String(m.id) === String(message.id))
                        if (!exists) {
                            messages.value = [...messages.value, {
                                ...message,
                                isMe: String(message.senderId) === String(auth.user?.id)
                            }]
                        }
                    }
                    updateLastMessage(message.roomId, message, true)
                }
                return
            }

            // PartnerId check: Is this update relevant to the contact Alice is CURRENTLY talking to?
            const currentPartner = String(activeUserId.value)
            const incomingPartner = String(payload.partnerId || (payload.message ? payload.message.sender_id : ''))
            
            if (activeUserId.value && incomingPartner === currentPartner) {
                if (payload.type === 'reaction_updated') {
                    console.log('[CHAT STORE] Updating reactions for msg:', payload.messageId)
                    const msg = messages.value.find(m => String(m.id) === String(payload.messageId))
                    if (msg) msg.reactions = payload.reactions
                } else if (payload.type === 'pin_updated') {
                    pinnedMessage.value = payload.pinned
                } else if (payload.type === 'message_deleted_everyone') {
                    const msg = messages.value.find(m => String(m.id) === String(payload.messageId))
                    if (msg) msg.is_deleted_everyone = true
                } else if (payload.type === 'message_edited') {
                    const msg = messages.value.find(m => String(m.id) === String(payload.messageId))
                    if (msg) {
                        msg.content = payload.content
                        msg.is_edited = true
                    }
                    const partner = users.value.find(u => String(u.id) === String(payload.partnerId))
                    if (partner && String(partner.last_message_id) === String(payload.messageId)) {
                        partner.last_message = payload.content
                    }
                }
            } else if (activeRoomId.value && payload.roomId && String(payload.roomId) === String(activeRoomId.value)) {
                // Room specific updates (reactions, pins in groups)
                if (payload.type === 'reaction_updated') {
                    const msg = messages.value.find(m => String(m.id) === String(payload.messageId))
                    if (msg) msg.reactions = payload.reactions
                } else if (payload.type === 'pin_updated') {
                    pinnedMessage.value = payload.pinned
                } else if (payload.type === 'message_deleted_everyone') {
                    const msg = messages.value.find(m => String(m.id) === String(payload.messageId))
                    if (msg) msg.is_deleted_everyone = true
                }
            }
        })
    }

    async function fetchUsers() {
        const config = useRuntimeConfig()
        try {
            const data = await $fetch(`${config.public.apiBase}/users`, {
                headers: { Authorization: `Bearer ${auth.token}` }
            })
            users.value = data
        } catch (err) {
            console.error('Failed to fetch users', err)
        }
    }

    async function fetchRooms() {
        const config = useRuntimeConfig()
        try {
            const data = await $fetch(`${config.public.apiBase}/rooms`, {
                headers: { Authorization: `Bearer ${auth.token}` }
            })
            rooms.value = data
        } catch (err) {
            console.error('Failed to fetch rooms', err)
        }
    }

    function sendMessage(receiverId, content, type = 'text', fileName = null, replyToId = null, roomId = null) {
        if (!socket.value) {
            console.error('Socket not connected. Cannot send message.')
            return Promise.reject(new Error('Socket not connected'))
        }

        const isGroup = !!roomId
        const eventName = isGroup ? 'chat.group.send' : 'chat.private.send'
        const payload = isGroup 
            ? { roomId, content, type, fileName, replyToId } 
            : { receiverId, content, type, fileName, replyToId }

        console.log(`Emitting ${eventName} to ${isGroup ? 'room ' + roomId : 'user ' + receiverId}...`, payload)

        return new Promise((resolve, reject) => {
            socket.value.emit(eventName, payload, (response) => {
                console.log(`Received acknowledgment for ${eventName}:`, response)
                if (response.status === 'ok') {
                    // Only push if not already received via socket echo
                    const exists = messages.value.some(m => String(m.id) === String(response.id))
                    if (!exists) {
                        const newMsg = {
                            id: response.id,
                            senderId: auth.user.id,
                            receiverId: isGroup ? null : receiverId,
                            roomId: isGroup ? roomId : null,
                            content,
                            type,
                            fileName,
                            reply_to_id: replyToId,
                            reply_to: replyTo.value,
                            timestamp: response.timestamp,
                            isMe: true,
                            reactions: [],
                            sender: auth.user
                        }
                        messages.value = [...messages.value, newMsg]
                    }
                    updateLastMessage(roomId || receiverId, { content, type, timestamp: response.timestamp }, isGroup)
                    replyTo.value = null
                    resolve(response)
                } else {
                    reject(response)
                }
            })
        })
    }

    function sendTyping(receiverId, roomId = null) {
        if (!socket.value) return
        const eventName = roomId ? 'chat.group.typing' : 'chat.private.typing'
        socket.value.emit(eventName, { receiverId, roomId })
    }

    async function fetchHistory(id, isRoom = false) {
        const config = useRuntimeConfig()
        loadingMessages.value = true
        messages.value = [] 
        pinnedMessage.value = null
        
        if (isRoom) {
            activeRoomId.value = id
            activeUserId.value = null
        } else {
            activeUserId.value = id
            activeRoomId.value = null
        }
        
        try {
            const data = await $fetch(`${config.public.apiBase}/messages/${id}?is_room=${isRoom}`, {
                headers: { Authorization: `Bearer ${auth.token}` }
            })
            
            // Handle new response format { messages, pinned }
            const msgs = data.messages || []
            pinnedMessage.value = data.pinned || null

            const historical = msgs.map(m => ({
                id: m.id,
                senderId: m.sender_id,
                receiverId: m.receiver_id,
                roomId: m.room_id,
                content: m.content,
                type: m.type,
                fileName: m.file_name,
                timestamp: m.created_at,
                isMe: m.sender_id == auth.user?.id,
                is_read: m.is_read,
                reactions: m.reactions || [],
                reply_to: m.reply_to || null,
                reply_to_id: m.reply_to_id,
                sender: m.sender
            }))

            messages.value = historical
            
            // Mark these as read
            sendRead(activeUserId.value, activeRoomId.value)

        } catch (err) {
            console.error('Failed to fetch history', err)
        } finally {
            loadingMessages.value = false
        }
    }

    async function toggleReaction(messageId, emoji) {
        const config = useRuntimeConfig()
        try {
            const data = await $fetch(`${config.public.apiBase}/messages/react/${messageId}`, {
                method: 'POST',
                body: { emoji },
                headers: { Authorization: `Bearer ${auth.token}` }
            })
            // Update local message
            const msg = messages.value.find(m => m.id === messageId)
            if (msg) msg.reactions = data.reactions
        } catch (err) {
            console.error('Failed to toggle reaction', err)
        }
    }

    async function togglePin(messageId) {
        const config = useRuntimeConfig()
        try {
            const data = await $fetch(`${config.public.apiBase}/messages/pin/${messageId}`, {
                method: 'POST',
                headers: { Authorization: `Bearer ${auth.token}` }
            })
            pinnedMessage.value = data.pinned
            return data.status
        } catch (err) {
            console.error('Failed to toggle pin', err)
        }
    }

    async function deleteMessage(messageId, type = 'me') {
        const config = useRuntimeConfig()
        try {
            const res = await $fetch(`${config.public.apiBase}/messages/${messageId}`, {
                method: 'DELETE',
                body: { type },
                headers: { Authorization: `Bearer ${auth.token}` }
            })

            if (type === 'me') {
                // Remove from local list
                messages.value = messages.value.filter(m => String(m.id) !== String(messageId))
            } else {
                // Mark as deleted for everyone locally
                const msg = messages.value.find(m => String(m.id) === String(messageId))
                if (msg) msg.is_deleted_everyone = true
            }
            return res.status
        } catch (err) {
            console.error('Failed to delete message', err)
            throw err
        }
    }

    async function editMessage(messageId, content) {
        const config = useRuntimeConfig()
        try {
            const res = await $fetch(`${config.public.apiBase}/messages/${messageId}`, {
                method: 'PUT',
                body: { content },
                headers: { Authorization: `Bearer ${auth.token}` }
            })
            
            // Update local message
            const msg = messages.value.find(m => String(m.id) === String(messageId))
            if (msg) {
                msg.content = content
                msg.is_edited = true
            }
            return res.status
        } catch (err) {
            console.error('Failed to edit message', err)
            throw err
        }
    }

    function sendRead(receiverId, roomId = null) {
        if (!socket.value) return
        const eventName = roomId ? 'chat.group.read' : 'chat.private.read'
        socket.value.emit(eventName, { receiverId, roomId })

        // Reset local unread count
        const key = roomId ? `room_${roomId}` : `user_${receiverId}`
        if (unreadCounts.value[key]) {
            unreadCounts.value[key] = 0
        }
        // Also hit API to persist read status
        const config = useRuntimeConfig()
        const url = roomId ? `${config.public.apiBase}/messages/read/${roomId}?is_room=true` : `${config.public.apiBase}/messages/read/${receiverId}`
        $fetch(url, {
            method: 'POST',
            headers: { Authorization: `Bearer ${auth.token}` }
        }).catch(e => console.error('Failed to mark as read', e))
    }

    function showNotification(title, options) {
        if (notificationPermission.value === 'granted') {
            new Notification(title, options)
        }
    }

    function disconnect() {
        if (socket.value) {
            socket.value.disconnect()
            socket.value = null
            connected.value = false
        }
    }

    async function fetchBlockedUsers() {
        const config = useRuntimeConfig()
        try {
            const data = await $fetch(`${config.public.apiBase}/blocks`, {
                headers: { Authorization: `Bearer ${auth.token}` }
            })
            blockedUsers.value = data
        } catch (err) {
            console.error('Failed to fetch blocked users', err)
        }
    }

    async function toggleBlock(userId) {
        const config = useRuntimeConfig()
        try {
            const res = await $fetch(`${config.public.apiBase}/blocks/toggle`, {
                method: 'POST',
                body: { blocked_id: userId },
                headers: { Authorization: `Bearer ${auth.token}` }
            })
            
            await fetchBlockedUsers()
            return res.status
        } catch (err) {
            console.error('Failed to toggle block', err)
            throw err
        }
    }

    function isUserBlocked(userId) {
        return blockedUsers.value.some(u => String(u.id) === String(userId))
    }

    async function fetchUnreadCounts() {
        const config = useRuntimeConfig()
        try {
            const counts = await $fetch(`${config.public.apiBase}/messages/unread-counts`, {
                headers: { Authorization: `Bearer ${auth.token}` }
            })
            unreadCounts.value = counts || {}
        } catch (err) {
            console.error('Failed to fetch unread counts', err)
        }
    }

    function updateLastMessage(id, message, isRoom = false) {
        if (isRoom) {
            const room = rooms.value.find(r => String(r.id) === String(id))
            if (room) {
                room.last_message = message.content
                room.last_message_type = message.type
                room.last_message_time = message.timestamp || message.created_at
            }
        } else {
            const user = users.value.find(u => String(u.id) === String(id))
            if (user) {
                user.last_message = message.content
                user.last_message_type = message.type
                user.last_message_time = message.timestamp || message.created_at
            }
        }
    }

    async function updateRoom(roomId, name, description) {
        const config = useRuntimeConfig()
        try {
            const data = await $fetch(`${config.public.apiBase}/rooms/${roomId}`, {
                method: 'PUT',
                body: { name, description },
                headers: { Authorization: `Bearer ${auth.token}` }
            })
            const idx = rooms.value.findIndex(r => String(r.id) === String(roomId))
            if (idx !== -1) rooms.value[idx] = { ...rooms.value[idx], ...data }
            return data
        } catch (err) {
            console.error('Failed to update room', err)
            throw err
        }
    }

    async function addRoomMembers(roomId, userIds) {
        const config = useRuntimeConfig()
        try {
            const data = await $fetch(`${config.public.apiBase}/rooms/${roomId}/add-members`, {
                method: 'POST',
                body: { user_ids: userIds },
                headers: { Authorization: `Bearer ${auth.token}` }
            })
            const idx = rooms.value.findIndex(r => String(r.id) === String(roomId))
            if (idx !== -1) rooms.value[idx] = data
            return data
        } catch (err) {
            console.error('Failed to add members', err)
            throw err
        }
    }

    async function removeRoomMember(roomId, userId) {
        const config = useRuntimeConfig()
        try {
            const data = await $fetch(`${config.public.apiBase}/rooms/${roomId}/remove-member/${userId}`, {
                method: 'POST',
                headers: { Authorization: `Bearer ${auth.token}` }
            })
            const idx = rooms.value.findIndex(r => String(r.id) === String(roomId))
            if (idx !== -1) rooms.value[idx] = data.room
            return data
        } catch (err) {
            console.error('Failed to remove member', err)
            throw err
        }
    }

    async function leaveRoom(roomId) {
        const config = useRuntimeConfig()
        try {
            await $fetch(`${config.public.apiBase}/rooms/${roomId}/leave`, {
                method: 'POST',
                headers: { Authorization: `Bearer ${auth.token}` }
            })
            rooms.value = rooms.value.filter(r => String(r.id) !== String(roomId))
        } catch (err) {
            console.error('Failed to leave room', err)
            throw err
        }
    }

    return {
        socket,
        messages,
        presence,
        typingUsers,
        connected,
        loadingMessages,
        users,
        blockedUsers,
        pinnedMessage,
        replyTo,
        activeUserId,
        blockUpdateTrigger,
        notificationPermission,
        unreadCounts,
        totalUnreadCount,
        totalChatsUnread,
        totalGroupsUnread,
        rooms,
        activeRoomId,
        init,
        fetchUsers,
        fetchRooms,
        fetchBlockedUsers,
        fetchUnreadCounts,
        sendMessage,
        fetchHistory,
        sendRead,
        sendTyping,
        toggleBlock,
        toggleReaction,
        togglePin,
        deleteMessage,
        editMessage,
        updateRoom,
        addRoomMembers,
        removeRoomMember,
        leaveRoom,
        isUserBlocked,
        updateLastMessage,
        disconnect
    }
}
)

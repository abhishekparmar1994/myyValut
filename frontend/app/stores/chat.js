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

    const totalUnreadCount = computed(() => {
        return Object.values(unreadCounts.value).reduce((sum, count) => sum + (count || 0), 0)
    })

    function init() {
        if (socket.value) return
        
        fetchUsers()
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
            if (activeUserId.value && String(message.senderId) === String(activeUserId.value)) {
                messages.value = [...messages.value, message]
            }
            
            // Show background notification (regardless of active chat)
            if (import.meta.client && document.visibilityState === 'hidden') {
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

        socket.value.on('chat.read', ({ userId }) => {
            if (activeUserId.value && String(userId) === String(activeUserId.value)) {
                messages.value.forEach(m => {
                    if (m.senderId == auth.user?.id && m.receiverId == userId) {
                        m.is_read = true
                    }
                })
            }
        })

        // Bridges from Laravel (Redis -> Socket -> Client)
        socket.value.on('message.sent', (payload) => {
            messages.value = [...messages.value, {
                ...payload.message,
                fromLaravel: true
            }]

            // Increment unread count if it's not from me AND we're not currently looking at this chat
            const isFromOther = payload.message.sender_id != auth.user?.id
            const isCurrentChat = String(payload.message.sender_id) === String(activeUserId.value)
            
            if (isFromOther) {
                if (!isCurrentChat) {
                    unreadCounts.value[payload.message.sender_id] = (unreadCounts.value[payload.message.sender_id] || 0) + 1
                } else {
                    sendRead(payload.message.sender_id)
                }
            }
        })

        socket.value.on('system.notification', (payload) => {
            console.log('[CHAT STORE] System Notification Received:', payload)
            
            // PartnerId check: Is this update relevant to the contact Alice is CURRENTLY talking to?
            const currentPartner = String(activeUserId.value)
            const incomingPartner = String(payload.partnerId)
            
            if (!activeUserId.value || incomingPartner !== currentPartner) {
                console.log(`[CHAT STORE] Ignored notification: Active(${currentPartner}) vs Payload(${incomingPartner})`)
                return
            }

            if (payload.type === 'reaction_updated') {
                console.log('[CHAT STORE] Updating reactions for msg:', payload.messageId)
                // Use type-agnostic comparison for message IDs
                const msg = messages.value.find(m => String(m.id) === String(payload.messageId))
                if (msg) {
                    msg.reactions = payload.reactions
                } else {
                    console.warn('[CHAT STORE] Message not found for reaction update:', payload.messageId)
                }
            } else if (payload.type === 'pin_updated') {
                console.log('[CHAT STORE] Updating pinned message:', payload.pinned?.id)
                pinnedMessage.value = payload.pinned
            } else if (payload.type === 'message_deleted_everyone') {
                console.log('[CHAT STORE] Message deleted for everyone:', payload.messageId)
                const msg = messages.value.find(m => String(m.id) === String(payload.messageId))
                if (msg) {
                    msg.is_deleted_everyone = true
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

    function sendMessage(receiverId, content, type = 'text', fileName = null, replyToId = null) {
        if (!socket.value) {
            console.error('Socket not connected. Cannot send message.')
            return Promise.reject(new Error('Socket not connected'))
        }

        console.log(`Emitting chat.send to ${receiverId}...`, { content, type, fileName, replyToId })

        return new Promise((resolve, reject) => {
            socket.value.emit('chat.send', { receiverId, content, type, fileName, replyToId }, (response) => {
                console.log('Received acknowledgment for chat.send:', response)
                if (response.status === 'ok') {
                    // We'll let the event echo or just push local
                    const newMsg = {
                        id: response.id,
                        senderId: auth.user.id,
                        receiverId,
                        content,
                        type,
                        fileName,
                        reply_to_id: replyToId,
                        reply_to: replyTo.value, // Local preview
                        timestamp: response.timestamp,
                        isMe: true,
                        reactions: []
                    }
                    messages.value = [...messages.value, newMsg]
                    replyTo.value = null // Clear after send
                    resolve(response)
                } else {
                    reject(response)
                }
            })
        })
    }

    function sendTyping(receiverId) {
        if (!socket.value) return
        socket.value.emit('chat.typing', { receiverId })
    }

    async function fetchHistory(receiverId) {
        const config = useRuntimeConfig()
        loadingMessages.value = true
        messages.value = [] 
        pinnedMessage.value = null
        activeUserId.value = receiverId
        
        try {
            const data = await $fetch(`${config.public.apiBase}/messages/${receiverId}`, {
                headers: { Authorization: `Bearer ${auth.token}` }
            })
            
            // Handle new response format { messages, pinned }
            const msgs = data.messages || []
            pinnedMessage.value = data.pinned || null

            const historical = msgs.map(m => ({
                id: m.id,
                senderId: m.sender_id,
                receiverId: m.receiver_id,
                content: m.content,
                type: m.type,
                fileName: m.file_name,
                timestamp: m.created_at,
                isMe: m.sender_id == auth.user?.id,
                is_read: m.is_read,
                reactions: m.reactions || [],
                reply_to: m.reply_to || null,
                reply_to_id: m.reply_to_id
            }))

            messages.value = historical
            
            // Mark these as read
            sendRead(receiverId)

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

    function sendRead(receiverId) {
        if (!socket.value) return
        socket.value.emit('chat.read', { receiverId })

        // Reset local unread count
        if (unreadCounts.value[receiverId]) {
            unreadCounts.value[receiverId] = 0
        }
        // Also hit API to persist read status
        const config = useRuntimeConfig()
        $fetch(`${config.public.apiBase}/messages/read/${receiverId}`, {
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

    return {
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
        init,
        fetchUsers,
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
        isUserBlocked,
        disconnect
    }
})

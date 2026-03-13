import { defineStore } from 'pinia'
import { io } from 'socket.io-client'
import { useAuthStore } from './auth'

export const useChatStore = defineStore('chat', () => {
    const auth = useAuthStore()
    const socket = ref(null)
    const messages = ref([])
    const presence = ref({})
    const typingUsers = ref(new Set())
    const connected = ref(false)
    const loadingMessages = ref(false)
    const users = ref([])
    const notificationPermission = ref('default')

    function init() {
        if (socket.value) return
        
        fetchUsers()

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

        socket.value = io('http://localhost:3001', {
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
            messages.value = [...messages.value, message]
            
            // Show background notification
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
            presence.value = { ...presence.value, [userId]: status }
        })

        socket.value.on('chat.typing', ({ userId }) => {
            typingUsers.value.add(String(userId))
            setTimeout(() => typingUsers.value.delete(String(userId)), 3000)
        })

        socket.value.on('chat.read', ({ userId }) => {
            messages.value.forEach(m => {
                if (m.senderId == auth.user?.id && m.receiverId == userId) {
                    m.is_read = true
                }
            })
        })

        // Bridges from Laravel (Redis -> Socket -> Client)
        socket.value.on('message.sent', (payload) => {
            messages.value = [...messages.value, {
                ...payload.message,
                fromLaravel: true
            }]
        })

        socket.value.on('system.notification', (payload) => {
            console.log('System Notification:', payload)
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

    function sendMessage(receiverId, content, type = 'text', fileName = null) {
        if (!socket.value) {
            console.error('Socket not connected. Cannot send message.')
            return Promise.reject(new Error('Socket not connected'))
        }

        console.log(`Emitting chat.send to ${receiverId}...`, { content, type, fileName })

        return new Promise((resolve, reject) => {
            socket.value.emit('chat.send', { receiverId, content, type, fileName }, (response) => {
                console.log('Received acknowledgment for chat.send:', response)
                if (response.status === 'ok') {
                    messages.value = [...messages.value, {
                        senderId: auth.user.id,
                        receiverId,
                        content,
                        type,
                        fileName,
                        timestamp: response.timestamp,
                        isMe: true
                    }]
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
        // Optional: clear current messages to show fresh load, 
        // but only if we want "per-user" isolation in history view.
        messages.value = [] 
        
        try {
            const data = await $fetch(`${config.public.apiBase}/messages/${receiverId}`, {
                headers: { Authorization: `Bearer ${auth.token}` }
            })
            
            const historical = data.map(m => ({
                id: m.id,
                senderId: m.sender_id,
                receiverId: m.receiver_id,
                content: m.content,
                type: m.type,
                fileName: m.file_name,
                timestamp: m.created_at,
                isMe: m.sender_id == auth.user?.id,
                is_read: m.is_read
            }))

            // Add only if not already in store
            historical.forEach(h => {
                const exists = messages.value.some(m => m.id === h.id || (m.timestamp === h.timestamp && m.content === h.content))
                if (!exists) messages.value.push(h)
            })
            
            // Sort by timestamp
            messages.value.sort((a, b) => new Date(a.timestamp) - new Date(b.timestamp))

            // Mark these as read
            sendRead(receiverId)

        } catch (err) {
            console.error('Failed to fetch history', err)
        } finally {
            loadingMessages.value = false
        }
    }

    function sendRead(receiverId) {
        if (!socket.value) return
        socket.value.emit('chat.read', { receiverId })
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

    return {
        messages,
        presence,
        typingUsers,
        connected,
        loadingMessages,
        users,
        notificationPermission,
        init,
        fetchUsers,
        sendMessage,
        fetchHistory,
        sendRead,
        sendTyping,
        disconnect
    }
})

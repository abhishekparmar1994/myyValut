import { defineStore } from 'pinia'
import { ref, computed, watch } from 'vue'
import { useAuthStore } from './auth'
import { useChatStore } from './chat'

export const useNotificationStore = defineStore('notification', () => {
    const auth = useAuthStore()
    const notifications = ref([])
    const unreadCount = ref(0)
    const loading = ref(false)
    const pagination = ref({
        current_page: 1,
        last_page: 1
    })

    const chatStore = useChatStore()
    const { socket } = chatStore

    // Listen for real-time notifications via socket
    watch(socket, (newSocket) => {
        if (newSocket) {
            newSocket.on('BroadcastNotificationCreated', (payload) => {
                console.log('[NOTIFICATION STORE] Real-time notification received:', payload)
                
                if (payload.unread_count !== undefined) {
                    unreadCount.value = payload.unread_count
                } else {
                    unreadCount.value++
                }
                
                // Add to list if it's new
                const note = {
                    id: payload.id,
                    type: payload.type,
                    data: payload.data,
                    created_at: new Date().toISOString(),
                    read_at: null
                }
                notifications.value = [note, ...notifications.value]
            })
        }
    }, { immediate: true })

    async function fetchNotifications(page = 1) {
        const config = useRuntimeConfig()
        loading.value = true
        try {
            const data = await $fetch(`${config.public.apiBase}/notifications?page=${page}`, {
                headers: { Authorization: `Bearer ${auth.token}` }
            })
            if (page === 1) {
                notifications.value = data.data
            } else {
                notifications.value = [...notifications.value, ...data.data]
            }
            pagination.value = {
                current_page: data.current_page,
                last_page: data.last_page
            }
            // Update unread count after fetching
            await fetchUnreadCount()
        } catch (err) {
            console.error('Failed to fetch notifications', err)
        } finally {
            loading.value = false
        }
    }

    async function fetchUnreadCount() {
        if (!auth.isLoggedIn) return
        const config = useRuntimeConfig()
        try {
            const data = await $fetch(`${config.public.apiBase}/notifications/unread-count`, {
                headers: { Authorization: `Bearer ${auth.token}` }
            })
            unreadCount.value = data.count
        } catch (err) {
            console.error('Failed to fetch unread count', err)
        }
    }

    async function markAsRead(id) {
        const config = useRuntimeConfig()
        try {
            await $fetch(`${config.public.apiBase}/notifications/${id}/mark-read`, {
                method: 'POST',
                headers: { Authorization: `Bearer ${auth.token}` }
            })
            const note = notifications.value.find(n => n.id === id)
            if (note && !note.read_at) {
                note.read_at = new Date().toISOString()
                unreadCount.value = Math.max(0, unreadCount.value - 1)
            }
        } catch (err) {
            console.error('Failed to mark notification as read', err)
        }
    }

    async function markAllAsRead() {
        const config = useRuntimeConfig()
        try {
            await $fetch(`${config.public.apiBase}/notifications/mark-all-read`, {
                method: 'POST',
                headers: { Authorization: `Bearer ${auth.token}` }
            })
            notifications.value.forEach(n => {
                if (!n.read_at) n.read_at = new Date().toISOString()
            })
            unreadCount.value = 0
        } catch (err) {
            console.error('Failed to mark all as read', err)
        }
    }

    async function deleteNotification(id) {
        const config = useRuntimeConfig()
        try {
            await $fetch(`${config.public.apiBase}/notifications/${id}`, {
                method: 'DELETE',
                headers: { Authorization: `Bearer ${auth.token}` }
            })
            const idx = notifications.value.findIndex(n => n.id === id)
            if (idx !== -1) {
                if (!notifications.value[idx].read_at) {
                    unreadCount.value = Math.max(0, unreadCount.value - 1)
                }
                notifications.value.splice(idx, 1)
            }
        } catch (err) {
            console.error('Failed to delete notification', err)
        }
    }

    return {
        notifications,
        unreadCount,
        loading,
        pagination,
        fetchNotifications,
        fetchUnreadCount,
        markAsRead,
        markAllAsRead,
        deleteNotification
    }
})

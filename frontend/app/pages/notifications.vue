<template>
  <BContainer class="py-5">
    <!-- Header -->
    <BRow class="mb-4 align-items-center">
      <BCol md="8" class="mb-3 mb-md-0 d-flex align-items-center">
        <BellIcon :size="32" class="text-primary me-3" />
        <div>
          <h1 class="fw-bold mb-0 text-main">Notifications</h1>
          <p class="text-muted mb-0">Stay updated with latest activities and alerts</p>
        </div>
      </BCol>
      <BCol md="4" class="text-md-end">
        <div class="d-flex gap-2 justify-content-md-end">
          <BButton v-if="notificationStore.notifications.length > 0" variant="outline-primary" size="sm" @click="notificationStore.markAllAsRead" class="fw-bold d-flex align-items-center gap-2">
            <CheckIcon :size="16" /> Mark all read
          </BButton>
          <BButton v-if="notificationStore.notifications.length > 0" variant="outline-danger" size="sm" @click="notificationStore.deleteAll" class="fw-bold d-flex align-items-center gap-2">
            <Trash2Icon :size="16" /> Clear all
          </BButton>
        </div>
      </BCol>
    </BRow>

    <div v-if="notificationStore.loading" class="text-center py-5">
      <BSpinner variant="primary" />
      <p class="text-muted mt-2">Loading alerts...</p>
    </div>

    <div v-else-if="notificationStore.notifications.length === 0" class="text-center py-5">
      <div class="mb-3 text-muted opacity-25">
        <InboxIcon :size="80" class="mx-auto" />
      </div>
      <h4 class="fw-bold text-main">No notifications</h4>
      <p class="text-muted">You're all caught up! New alerts will appear here.</p>
    </div>

    <div v-else class="notification-list">
      <BCard v-for="notif in notificationStore.notifications" :key="notif.id" 
        class="mb-3 border-0 shadow-sm notification-card position-relative overflow-hidden"
        :class="{ 'unread border-start border-4 border-primary': !notif.read_at }">
        <div class="d-flex gap-3">
          <div class="notif-icon-wrapper rounded-circle p-2 d-flex align-items-center justify-content-center flex-shrink-0"
            :class="getIconData(notif.type).bg" style="width: 42px; height: 42px;">
            <component :is="getIconData(notif.type).icon" :size="20" :class="getIconData(notif.type).text" />
          </div>
          
          <div class="flex-grow-1">
            <div class="d-flex justify-content-between align-items-start">
              <div>
                <h6 class="fw-bold mb-1" :class="!notif.read_at ? 'text-primary' : 'text-main'">{{ notif.title }}</h6>
                <p class="text-muted small mb-2 lh-sm">{{ notif.message }}</p>
                <div class="d-flex align-items-center gap-1 text-muted small" style="font-size: 0.75rem;">
                  <ClockIcon :size="12" /> {{ formatTime(notif.created_at) }}
                </div>
              </div>
              
              <div class="d-flex gap-2 ms-3">
                <BButton v-if="!notif.read_at" size="sm" variant="link" class="p-1 px-2 text-primary hover-bg" @click="notificationStore.markAsRead(notif.id)" title="Mark as read">
                  <CheckIcon :size="18" />
                </BButton>
                <BButton size="sm" variant="link" class="p-1 px-2 text-danger hover-bg" @click="notificationStore.deleteNotification(notif.id)" title="Delete">
                  <Trash2Icon :size="18" />
                </BButton>
              </div>
            </div>
          </div>
        </div>
      </BCard>
    </div>
  </BContainer>
</template>

<script setup>
import { 
  Bell as BellIcon, 
  Inbox as InboxIcon, 
  Users as UsersIcon, 
  MessageSquare as MessageSquareIcon, 
  Clock as ClockIcon, 
  FileText as FileTextIcon, 
  CircleDollarSign as CircleDollarSignIcon, 
  Check as CheckIcon, 
  Trash2 as Trash2Icon, 
  Settings as SettingsIcon, 
  Info as InfoIcon, 
  AlertTriangle as AlertTriangleIcon 
} from 'lucide-vue-next'
import { useNotificationStore } from '~/stores/notification'

definePageMeta({ middleware: 'auth' })

const notificationStore = useNotificationStore()

function getIconData(type) {
  const iconMap = {
    'user':    { icon: UsersIcon,         bg: 'bg-primary bg-opacity-10',  text: 'text-primary' },
    'message': { icon: MessageSquareIcon, bg: 'bg-info bg-opacity-10',     text: 'text-info'    },
    'system':  { icon: SettingsIcon,      bg: 'bg-secondary bg-opacity-10',text: 'text-secondary'},
    'bill':    { icon: CircleDollarSignIcon, bg: 'bg-danger bg-opacity-10', text: 'text-danger'  },
    'doc':     { icon: FileTextIcon,      bg: 'bg-success bg-opacity-10',  text: 'text-success' },
    'alert':   { icon: AlertTriangleIcon, bg: 'bg-warning bg-opacity-10',  text: 'text-warning' },
  }
  return iconMap[type] || { icon: BellIcon, bg: 'bg-light', text: 'text-dark' }
}

function formatTime(d) {
  if (!d) return ''
  return new Date(d).toLocaleString('en-IN', { 
    day: 'numeric', month: 'short', 
    hour: '2-digit', minute: '2-digit', 
    hour12: true 
  })
}

onMounted(() => {
  notificationStore.fetchNotifications(1)
})
</script>

<style scoped>
.text-main { color: #2c3338; }
.unread {
  background-color: rgba(13, 110, 253, 0.02) !important;
}
.notification-card {
  transition: all 0.2s ease;
}
.notification-card:hover {
  transform: translateX(4px);
  box-shadow: 0 4px 12px rgba(0,0,0,0.08) !important;
}
.hover-bg:hover {
  background-color: rgba(0,0,0,0.05);
  border-radius: 6px;
}
</style>

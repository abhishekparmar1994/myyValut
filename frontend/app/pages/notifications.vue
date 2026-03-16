<template>
  <BContainer class="py-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
      <div>
        <h2 class="fw-bold mb-1">Notifications</h2>
        <p class="text-muted">Manage your alerts and activity updates</p>
      </div>
      <div v-if="notificationStore.notifications.length > 0" class="d-flex gap-2">
        <BButton variant="outline-primary" size="sm" @click="notificationStore.markAllAsRead" :disabled="notificationStore.unreadCount === 0">
          Mark all as read
        </BButton>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="notificationStore.loading && notificationStore.notifications.length === 0" class="text-center py-5">
      <BSpinner variant="primary" label="Loading notifications..." />
    </div>

    <!-- Empty State -->
    <div v-else-if="notificationStore.notifications.length === 0" class="text-center py-5 bg-white rounded-4 shadow-sm border border-dashed">
      <div class="fs-1 mb-3">📭</div>
      <h5 class="fw-bold">No notifications yet</h5>
      <p class="text-muted">We'll let you know when something important happens.</p>
    </div>

    <!-- Notification List -->
    <div v-else class="notification-list shadow-sm rounded-4 overflow-hidden bg-white border">
      <div 
        v-for="note in notificationStore.notifications" 
        :key="note.id" 
        class="notification-item p-4 d-flex align-items-start gap-3 transition-all border-bottom position-relative"
        :class="{ 'bg-primary-subtle bg-opacity-10 unread': !note.read_at }"
        @click="handleNotificationClick(note)"
      >
        <div class="flex-shrink-0">
          <div class="icon-circle rounded-circle d-flex align-items-center justify-content-center border shadow-sm" style="width: 3.5rem; height: 3.5rem;" :class="getTypeClass(note.type)">
             <span class="fs-4">{{ getIcon(note.type) }}</span>
          </div>
        </div>
        
        <div class="flex-grow-1">
          <div class="d-flex justify-content-between align-items-start">
            <div>
              <h6 class="mb-1 fw-bold" :class="{ 'text-primary': !note.read_at }">
                {{ formatType(note.type) }}
              </h6>
              <div class="notification-content text-dark mb-1">
                {{ getNotificationText(note) }}
              </div>
              <small class="text-muted">{{ formatDate(note.created_at) }}</small>
            </div>
            
            <div class="actions d-flex gap-1" @click.stop>
               <BDropdown variant="link" size="sm" no-caret toggle-class="p-0 text-muted shadow-none border-0">
                  <template #button-content><span class="fs-5">⋮</span></template>
                  <BDropdownItem v-if="!note.read_at" @click="notificationStore.markAsRead(note.id)">✔️ Mark as read</BDropdownItem>
                  <BDropdownItem @click="notificationStore.deleteNotification(note.id)" class="text-danger">🗑️ Delete</BDropdownItem>
               </BDropdown>
            </div>
          </div>
        </div>

        <!-- Unread Indicator -->
        <div v-if="!note.read_at" class="unread-dot position-absolute top-50 start-0 translate-middle" style="left: 10px !important;">
          <div class="bg-primary rounded-circle" style="width: 8px; height: 8px;"></div>
        </div>
      </div>

      <!-- Load More -->
      <div v-if="notificationStore.pagination.current_page < notificationStore.pagination.last_page" class="p-4 text-center border-top">
         <BButton variant="link" @click="notificationStore.fetchNotifications(notificationStore.pagination.current_page + 1)" :disabled="notificationStore.loading">
            <BSpinner small v-if="notificationStore.loading" class="me-2" />
            Load older notifications
         </BButton>
      </div>
    </div>
  </BContainer>
</template>

<script setup>
import { useNotificationStore } from '~/stores/notification'
import dayjs from 'dayjs'
import relativeTime from 'dayjs/plugin/relativeTime'

dayjs.extend(relativeTime)

const notificationStore = useNotificationStore()
const router = useRouter()

onMounted(() => {
  notificationStore.fetchNotifications(1)
})

function handleNotificationClick(note) {
  if (!note.read_at) {
    notificationStore.markAsRead(note.id)
  }
  
  // Logic to navigate based on type
  const type = note.type.split('\\').pop().toLowerCase().replace('notification', '')
  const data = JSON.parse(note.data || '{}')

  if (type.includes('message') || type.includes('room')) {
     router.push('/chat')
  } else if (type.includes('reminder')) {
     router.push('/reminders')
  } else if (type.includes('document')) {
     router.push('/documents')
  }
}

function getTypeClass(typeString) {
  const type = typeString.split('\\').pop().toLowerCase()
  if (type.includes('error') || type.includes('alert')) return 'bg-danger-subtle text-danger'
  if (type.includes('success') || type.includes('added')) return 'bg-success-subtle text-success'
  if (type.includes('warning') || type.includes('reminder')) return 'bg-warning-subtle text-warning'
  return 'bg-primary-subtle text-primary'
}

function getIcon(typeString) {
  const type = typeString.split('\\').pop().toLowerCase()
  if (type.includes('room') || type.includes('group')) return '👥'
  if (type.includes('message')) return '💬'
  if (type.includes('reminder')) return '⏳'
  if (type.includes('document')) return '📄'
  if (type.includes('bill')) return '💰'
  return '🔔'
}

function formatType(typeString) {
  const type = typeString.split('\\').pop()
  return type.replace(/([A-Z])/g, ' $1').trim()
}

function getNotificationText(note) {
  try {
     const data = typeof note.data === 'string' ? JSON.parse(note.data) : note.data
     return data.message || data.content || 'You have a new update.'
  } catch (e) {
     return 'New notification'
  }
}

function formatDate(date) {
  return dayjs(date).fromNow()
}
</script>

<style scoped>
.notification-item {
  cursor: pointer;
  border-left: 4px solid transparent;
}
.notification-item:hover {
  background-color: #f8f9fa;
}
.notification-item.unread {
  border-left-color: var(--bs-primary);
}
.icon-circle {
  transition: transform 0.2s;
}
.notification-item:hover .icon-circle {
  transform: scale(1.05);
}
.transition-all {
  transition: all 0.2s ease-in-out;
}
</style>

<template>
  <BContainer fluid class="chat-container px-4 py-3">
    <BRow class="chat-wrapper shadow-lg rounded-4 overflow-hidden border bg-white">
      <!-- Users List -->
      <BCol md="4" lg="3" class="bg-white border-end d-flex flex-column h-100">
        <div class="p-4 border-bottom bg-light">
          <h4 class="fw-bold mb-0 text-primary">Messages</h4>
          <small class="text-muted" v-if="chat.connected">🟢 Connected</small>
          <small class="text-danger" v-else>🔴 Disconnected</small>
        </div>
        <div class="flex-grow-1 overflow-auto p-2">
          <div v-if="chat.loading" class="text-center py-4"><BSpinner variant="primary" /></div>
          
          <!-- Online Users -->
          <div v-if="onlineUsers.length > 0">
            <small class="text-uppercase fw-bold text-muted px-3 mb-2 d-block" style="font-size: 0.75rem;">Online</small>
            <div 
              v-for="user in onlineUsers" 
              :key="user.id" 
              class="user-item p-3 mb-2 rounded-3 d-flex align-items-center gap-3 cursor-pointer transition-all"
              :class="{ 'bg-primary-subtle border-primary': activeUser?.id === user.id }"
              @click="activeUser = user"
            >
              <div class="position-relative">
                <BAvatar 
                  v-if="user.profile_image"
                  :src="getProfileImageUrl(user)"
                  variant="info" 
                />
                <BAvatar v-else variant="info" :text="user.name.charAt(0)" />
                <span class="position-absolute bottom-0 end-0 bg-success border border-white rounded-circle p-1" style="width: 12px; height: 12px;"></span>
              </div>
              <div class="flex-grow-1 overflow-hidden">
                <h6 class="mb-0 fw-bold">{{ user.name }}</h6>
                <small class="text-muted text-truncate d-block" v-if="chat.typingUsers.has(String(user.id))">typing...</small>
                <small class="text-muted text-truncate d-block" v-else>Active now</small>
              </div>
            </div>
          </div>

          <!-- Offline Users -->
          <div v-if="offlineUsers.length > 0" class="mt-4">
            <small class="text-uppercase fw-bold text-muted px-3 mb-2 d-block" style="font-size: 0.75rem;">Offline</small>
            <div 
              v-for="user in offlineUsers" 
              :key="user.id" 
              class="user-item p-3 mb-2 rounded-3 d-flex align-items-center gap-3 cursor-pointer transition-all opacity-75"
              :class="{ 'bg-primary-subtle border-primary': activeUser?.id === user.id }"
              @click="activeUser = user"
            >
              <BAvatar 
                v-if="user.profile_image"
                :src="getProfileImageUrl(user)"
                variant="secondary" 
              />
              <BAvatar v-else variant="secondary" :text="user.name.charAt(0)" />
              <div class="flex-grow-1 overflow-hidden">
                <h6 class="mb-0 fw-bold">{{ user.name }}</h6>
                <small class="text-muted text-truncate d-block">Offline</small>
              </div>
            </div>
          </div>

          <div v-if="onlineUsers.length === 0 && offlineUsers.length === 0" class="text-center py-5 text-muted">
             <small>No contacts found</small>
          </div>
        </div>
      </BCol>

      <!-- Chat Area -->
      <BCol md="8" class="bg-white d-flex flex-column h-100">
        <template v-if="activeUser">
          <div class="p-4 border-bottom d-flex align-items-center justify-content-between bg-white">
            <div class="d-flex align-items-center gap-3">
              <BAvatar 
                v-if="activeUser.profile_image"
                :src="getProfileImageUrl(activeUser)"
                variant="info" 
              />
              <BAvatar v-else variant="info" :text="activeUser.name.charAt(0)" />
              <div>
                <h5 class="mb-0 fw-bold">{{ activeUser.name }}</h5>
                <small class="text-success" v-if="chat.presence[activeUser.id] === 'online'">Active Now</small>
                <small class="text-muted" v-else>Offline</small>
              </div>
            </div>
            <BButton variant="light" size="sm" class="rounded-circle">ℹ️</BButton>
          </div>

          <!-- Messages -->
          <div class="flex-grow-1 overflow-auto p-4 d-flex flex-column gap-3 bg-light scroll-smooth" ref="messageContainer">
            <!-- Loading State -->
            <div v-if="chat.loadingMessages" class="d-flex flex-column align-items-center justify-content-center h-100 opacity-50">
              <BSpinner variant="primary" label="Loading messages..." />
              <p class="mt-2 small">Loading your conversation...</p>
            </div>

            <template v-else>
              <div 
                v-for="(msg, i) in filteredMessages" 
              :key="i"
              class="message-wrapper d-flex"
              :class="msg.senderId === auth.user?.id ? 'justify-content-end' : 'justify-content-start'"
            >
              <div 
                class="message px-3 py-2 rounded-4 shadow-sm max-w-75"
                :class="msg.senderId === auth.user?.id ? 'bg-primary text-white' : 'bg-white border text-dark'"
              >
                <!-- Render Content based on Type -->
                <div v-if="msg.type === 'image'" class="media-content mb-1">
                   <img :src="msg.content" class="img-fluid rounded-3 cursor-pointer" @click="openImage(msg.content)" style="max-height: 300px; object-fit: cover;" />
                </div>
                <div v-else class="content">{{ msg.content }}</div>
                
                <div class="text-end mt-1" style="font-size: 0.65rem; opacity: 0.8">
                  {{ formatTime(msg.timestamp) }}
                  <span v-if="msg.senderId === auth.user?.id" :class="msg.is_read ? 'text-info' : 'text-white-50'"> ✓✓</span>
                </div>
              </div>
            </div>
            
            <div v-if="!filteredMessages.length" class="d-flex flex-column align-items-center justify-content-center h-100 opacity-50 text-center p-5">
              <div class="display-4 mb-3">💬</div>
              <p>No messages yet. Say hello!</p>
            </div>
          </template>
        </div>

          <!-- Input -->
          <div class="p-4 bg-white border-top">
            <BForm @submit.prevent="handleSend" class="d-flex gap-2 align-items-center">
              <div class="media-upload">
                <input type="file" ref="fileInput" class="d-none" accept="image/*" @change="onFileSelected" />
                <BButton variant="light" @click="$refs.fileInput.click()" class="rounded-circle p-2" :disabled="uploading">
                  <BSpinner small v-if="uploading" />
                  <span v-else>📷</span>
                </BButton>
              </div>
              <BFormInput 
                v-model="newMessage" 
                placeholder="Type a message..." 
                class="flex-grow-1 rounded-pill border-0 bg-light px-4 py-2 shadow-none"
                @input="handleTyping"
              />
              <BButton type="submit" variant="primary" class="rounded-circle d-flex align-items-center justify-content-center p-2" style="width: 44px; height: 44px;">
                ✈️
              </BButton>
            </BForm>
          </div>
        </template>

        <div v-else class="h-100 d-flex flex-column align-items-center justify-content-center text-center p-5 text-muted">
           <div class="display-1 mb-3">💬</div>
           <h4 class="fw-bold">Your Messages</h4>
           <p>Select a contact to start your distraction-free conversation.</p>
        </div>
      </BCol>
    </BRow>
  </BContainer>
</template>

<script setup>
import { useChatStore } from '~/stores/chat'
import { useAuthStore } from '~/stores/auth'

definePageMeta({ middleware: 'auth' })

const chat = useChatStore()
const auth = useAuthStore()
const config = useRuntimeConfig()

const newMessage = ref('')
const activeUser = ref(null)
const messageContainer = ref(null)

watch(activeUser, async (newVal) => {
    if (newVal) {
        await chat.fetchHistory(newVal.id)
        scrollToBottom()
    }
})

// Use store-managed users
const onlineUsers = computed(() => {
    return chat.users.filter(u => chat.presence[u.id] === 'online' && u.id !== auth.user?.id)
})

const offlineUsers = computed(() => {
    return chat.users.filter(u => (!chat.presence[u.id] || chat.presence[u.id] === 'offline') && u.id !== auth.user?.id)
})

const uploading = ref(false)
const fileInput = ref(null)

async function onFileSelected(event) {
    const file = event.target.files[0]
    if (!file || !activeUser.value) return

    uploading.value = true
    const formData = new FormData()
    formData.append('file', file)

    try {
        const data = await $fetch(`${config.public.apiBase}/messages/upload`, {
            method: 'POST',
            body: formData,
            headers: authHeaders()
        })
        
        // Send as image message
        await chat.sendMessage(activeUser.value.id, data.url, 'image')
        scrollToBottom()
    } catch (err) {
        console.error('Upload failed', err)
    } finally {
        uploading.value = false
        if (fileInput.value) fileInput.value.value = ''
    }
}

function openImage(url) {
    if (import.meta.client) {
        window.open(url, '_blank')
    }
}

function authHeaders() {
    return { Authorization: `Bearer ${auth.token}` }
}

function getProfileImageUrl(user) {
    if (!user || !user.profile_image) return null
    // Assuming backend serves storage via /storage/ prefix on the base domain
    const baseUrl = config.public.apiBase.replace('/api', '')
    return `${baseUrl}/storage/${user.profile_image}`
}

const filteredMessages = computed(() => {
    if (!activeUser.value) return []
    return chat.messages.filter(m => 
        (m.senderId == activeUser.value.id && m.receiverId == auth.user?.id) ||
        (m.senderId == auth.user?.id && m.receiverId == activeUser.value.id)
    )
})

async function handleSend() {
    if (!newMessage.value.trim() || !activeUser.value) return
    
    try {
        await chat.sendMessage(activeUser.value.id, newMessage.value)
        newMessage.value = ''
        scrollToBottom()
    } catch (err) {
        console.error('Failed to send', err)
    }
}

let typingTimeout = null
function handleTyping() {
    if (!activeUser.value) return
    chat.sendTyping(activeUser.value.id)
}

function scrollToBottom() {
    nextTick(() => {
        if (messageContainer.value) {
            messageContainer.value.scrollTop = messageContainer.value.scrollHeight
        }
    })
}

function formatTime(ts) {
    if (!ts) return ''
    return new Date(ts).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
}

onMounted(() => {
    chat.init()
})

// Auto-refresh user list if a new user connects
watch(() => chat.presence, (newPresence) => {
    const presenceIds = Object.keys(newPresence)
    const knownIds = chat.users.map(u => String(u.id))
    
    if (presenceIds.some(id => !knownIds.includes(id))) {
        chat.fetchUsers()
    }
}, { deep: true })

watch(filteredMessages, () => {
    scrollToBottom()
    if (activeUser.value) {
        chat.sendRead(activeUser.value.id)
    }
}, { deep: true })
</script>

<style scoped>
.chat-container {
    height: calc(100vh - 60px); /* Adjust based on navbar height */
    max-height: calc(100vh - 60px);
    overflow: hidden;
}

.chat-wrapper {
    height: 100%;
    margin: 0;
}

.user-item:hover {
    background-color: var(--bs-light);
}

.max-w-75 {
    max-width: 75%;
}

.cursor-pointer {
    cursor: pointer;
}

.transition-all {
    transition: all 0.2s ease-in-out;
}

.rounded-4 { border-radius: 1.25rem !important; }

.scroll-smooth { scroll-behavior: smooth; }

/* Custom Scrollbar */
::-webkit-scrollbar {
    width: 6px;
}
::-webkit-scrollbar-track {
    background: transparent;
}
::-webkit-scrollbar-thumb {
    background: #e0e0e0;
    border-radius: 10px;
}
::-webkit-scrollbar-thumb:hover {
    background: #d0d0d0;
}
</style>

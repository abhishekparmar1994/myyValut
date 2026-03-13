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
                <small class="text-primary text-truncate d-block fw-bold" v-if="chat.typingUsers[String(user.id)]">typing...</small>
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
                <small class="text-primary fw-bold blink" v-if="chat.typingUsers[String(activeUser.id)]">typing...</small>
                <small class="text-success" v-else-if="chat.presence[String(activeUser.id)] === 'online'">Active Now</small>
                <small class="text-muted" v-else>Offline</small>
              </div>
            </div>
            <div class="d-flex align-items-center gap-2">
              <BDropdown variant="light" size="sm" no-caret rounded="circle">
                <template #button-content>
                  <span class="fs-5">⋮</span>
                </template>
                <BDropdownItem @click="handleToggleBlock">
                   <span v-if="isBlockedByMe">🔓 Unblock User</span>
                   <span v-else class="text-danger">🚫 Block User</span>
                </BDropdownItem>
                <BDropdownDivider />
                <BDropdownItem>ℹ️ User Info</BDropdownItem>
              </BDropdown>
            </div>
          </div>

          <!-- Pinned Message Bar -->
          <div v-if="chat.pinnedMessage" class="px-4 py-2 bg-primary-subtle border-bottom d-flex align-items-center justify-content-between">
            <div class="d-flex align-items-center gap-2 overflow-hidden">
               <span class="fs-5">📌</span>
               <div class="flex-grow-1 overflow-hidden">
                 <div class="small fw-bold text-primary mb-0">Pinned Message</div>
                 <div class="d-flex align-items-center gap-2">
                   <img v-if="chat.pinnedMessage.type === 'image'" :src="chat.pinnedMessage.content" class="rounded" style="width: 24px; height: 24px; object-fit: cover;" />
                   <span v-else-if="chat.pinnedMessage.type === 'file'">{{ getFileIcon(chat.pinnedMessage.fileName) }}</span>
                   <div class="small text-muted text-truncate">
                     {{ chat.pinnedMessage.type === 'image' ? 'Image' : (chat.pinnedMessage.type === 'file' ? chat.pinnedMessage.fileName : chat.pinnedMessage.content) }}
                  </div>
                </div>
              </div>

            </div>
            <BButton variant="link" size="sm" class="text-decoration-none text-muted p-0 px-2" @click="scrollToMessage(chat.pinnedMessage.id)">
               View
            </BButton>
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
                :id="`msg-${msg.id}`"
                class="message-wrapper d-flex mb-3 group"
                :class="msg.senderId === auth.user?.id ? 'justify-content-end' : 'justify-content-start'"
              >
                <div 
                  class="message px-3 py-2 shadow-sm max-w-75 position-relative group"
                  :class="msg.senderId === auth.user?.id ? 'message-me bg-slate shadow-blue' : 'message-them bg-white border text-dark'"
                >
                  <div class="message-actions-overlay position-absolute top-0 end-0 p-1 message-action-trigger transition-all">
                    <BDropdown variant="link" size="sm" no-caret toggle-class="p-0 text-muted-custom">
                      <template #button-content><span class="fs-6 d-flex align-items-center justify-content-center" style="width: 24px; height: 24px;">⋮</span></template>
                      <BDropdownItem @click="chat.replyTo = msg">↩️ Reply</BDropdownItem>
                      <BDropdownItem @click="chat.togglePin(msg.id)">📌 Pin Message</BDropdownItem>
                      <BDropdownItem v-if="!msg.is_deleted_everyone" @click="messageToDelete = msg; showDeleteModal = true" class="text-danger">🗑️ Delete Message</BDropdownItem>
                      <BDropdownDivider />
                      <div class="px-2 pb-1 d-flex justify-content-around gap-2">
                        <span v-for="e in ['👍','❤️','😂','🔥']" :key="e" class="cursor-pointer action-btn" @click="chat.toggleReaction(msg.id, e)">{{ e }}</span>
                      </div>
                    </BDropdown>
                  </div>

                  <!-- Reply Preview inside message -->
                  <div v-if="msg.reply_to" class="mb-2 p-2 rounded-3 bg-black bg-opacity-10 border-start border-3" :class="msg.senderId === auth.user?.id ? 'border-light-subtle' : 'border-primary'" style="cursor: pointer" @click="scrollToMessage(msg.reply_to_id)">
                    <small class="fw-bold d-block">{{ msg.reply_to.sender_id === auth.user?.id ? 'You' : (activeUser.name || 'User') }}</small>
                    <small class="text-truncate d-block opacity-75">{{ msg.reply_to.content }}</small>
                  </div>
                  <!-- Message Content -->
                  <div v-if="msg.is_deleted_everyone" class="fst-italic small d-flex align-items-center gap-2 py-1" :class="msg.senderId === auth.user?.id ? 'text-white-50' : 'text-muted'">
                     <span class="opacity-50">🚫</span> This message was deleted
                  </div>
                  <template v-else>
                    <div v-if="msg.type === 'text'" class="message-text">{{ msg.content }}</div>
                    <div v-else-if="msg.type === 'image'" class="message-image mb-1">
                      <img :src="msg.content" class="img-fluid rounded-2 cursor-pointer" @click="openPreview(msg.content, msg.fileName)" style="max-height: 300px; object-fit: cover;" />
                    </div>
                    <div v-else-if="msg.type === 'file'" class="message-file p-2 rounded-2 bg-black bg-opacity-5 d-flex align-items-center gap-3">
                      <div class="file-icon fs-3">{{ getFileIcon(msg.fileName) }}</div>
                      <div class="flex-grow-1 overflow-hidden">
                        <div class="fw-bold text-truncate small">{{ msg.fileName }}</div>
                        <div class="d-flex gap-2 mt-1">
                            <BButton variant="link" size="sm" class="p-0 text-decoration-none small fw-bold" @click="openPreview(msg.content, msg.fileName)">Preview</BButton>
                            <BButton variant="link" size="sm" class="p-0 text-decoration-none small fw-bold text-success" @click="downloadFile(msg.content, msg.fileName)">Download</BButton>
                        </div>
                      </div>
                    </div>
                  </template>
                  
                  <div class="text-end mt-1 d-flex align-items-center justify-content-end gap-1" style="font-size: 0.65rem; opacity: 0.8">
                    {{ formatTime(msg.timestamp) }}
                    <span v-if="msg.senderId === auth.user?.id" :class="msg.is_read ? 'text-info' : 'text-white-50'"> ✓✓</span>
                  </div>

                  <!-- Reactions Display -->
                  <div v-if="msg.reactions && msg.reactions.length" class="reactions-container mt-1 d-flex gap-1 flex-wrap">
                    <span v-for="(emoji, group) in groupReactions(msg.reactions)" :key="group" class="badge rounded-pill bg-light text-dark border shadow-sm px-2 py-1" style="font-size: 0.7rem; cursor: pointer" @click="chat.toggleReaction(msg.id, group)">
                      {{ group }} {{ emoji.count }}
                    </span>
                  </div>
                </div>
              </div>

              <!-- Typing Animation -->
              <div v-if="chat.typingUsers[String(activeUser.id)]" class="message-wrapper d-flex justify-content-start mt-2">
                <div class="message px-3 py-2 rounded-4 shadow-sm bg-white border text-dark d-flex align-items-center gap-2">
                  <div class="typing-dots">
                     <span></span><span></span><span></span>
                  </div>
                  <small class="text-muted fw-bold">typing</small>
                </div>
              </div>
            </template>
          </div>
          <!-- Input Area -->
          <div class="p-4 bg-white border-top">
              <div v-if="blockStatus.is_blocked" class="text-center p-3 rounded-3 bg-light border dashed">
                <span class="text-muted small fw-bold">
                   <span v-if="blockStatus.blocked_by_me">You have blocked this user. Unblock them to send messages.</span>
                   <span v-else>This user has blocked you or communication is unavailable.</span>
                </span>
              </div>
              
              <!-- Reply Preview -->
              <div v-if="chat.replyTo" class="mx-0 mb-2 p-2 rounded-3 bg-light border-start border-primary border-4 d-flex justify-content-between align-items-center">
                <div class="overflow-hidden">
                  <small class="fw-bold text-primary d-block">Replying to {{ chat.replyTo.senderId === auth.user?.id ? 'yourself' : activeUser.name }}</small>
                  <small class="text-muted text-truncate d-block">{{ chat.replyTo.content }}</small>
                </div>
                <BButton variant="link" size="sm" class="text-decoration-none text-danger p-0 px-2" @click="chat.replyTo = null">✕</BButton>
              </div>

              <BForm v-if="!blockStatus.is_blocked" @submit.prevent="handleSend" class="d-flex gap-2 align-items-center position-relative">
                <div class="emoji-picker-container" v-if="showEmojiPicker">
                  <EmojiPicker :native="true" @select="onSelectEmoji" theme="light" />
                </div>
                
                <div class="d-flex gap-2">
                  <BButton variant="light" @click="showEmojiPicker = !showEmojiPicker" class="rounded-circle p-2 shadow-none border-0">
                    <span>😊</span>
                  </BButton>

                  <div class="media-upload">
                    <input type="file" ref="fileInput" class="d-none" @change="onFileSelected" />
                    <BButton variant="light" @click="$refs.fileInput.click()" class="rounded-circle p-2 shadow-none border-0" :disabled="uploading">
                      <BSpinner small v-if="uploading" />
                      <span v-else>📎</span>
                    </BButton>
                  </div>
                </div>

                <BFormInput 
                  v-model="newMessage" 
                  placeholder="Type a message..." 
                  class="flex-grow-1 rounded-pill border-0 bg-light px-4 py-2 shadow-none"
                  @input="handleTyping"
                  @focus="showEmojiPicker = false"
                />
                <BButton type="submit" variant="primary" class="rounded-circle d-flex align-items-center justify-content-center p-2 shadow-none" style="width: 44px; height: 44px;">
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

  <!-- Document Preview Modal -->
  <BModal v-model="showPreview" :title="previewName" size="xl" hide-footer centered body-class="p-0 overflow-hidden">
    <div class="preview-body bg-light d-flex align-items-center justify-content-center" style="min-height: 80vh;">
      <div v-if="previewLoading" class="text-center p-5">
        <BSpinner variant="primary" style="width: 3rem; height: 3rem;" />
        <p class="mt-3 text-muted">Preparing document preview...</p>
      </div>
      <ClientOnly v-else>
        <VueOfficePdf 
          v-if="previewType === 'pdf' && previewUrl" 
          :src="previewUrl" 
          class="w-100 h-100"
          style="height: 80vh !important;"
        />
        <VueOfficeExcel 
          v-else-if="previewType === 'excel' && previewUrl" 
          :src="previewUrl" 
          class="w-100 h-100"
          style="height: 80vh !important;"
        />
        <VueOfficeDocx 
          v-else-if="previewType === 'docx' && previewUrl" 
          :src="previewUrl" 
          class="w-100 h-100"
          style="height: 80vh !important;"
        />
        <div v-else-if="previewType === 'image'" class="p-4 text-center">
          <img :src="previewUrl" class="img-fluid rounded shadow-lg" style="max-height: 75vh; object-fit: contain;" />
        </div>
        <div v-else class="text-center p-5">
          <div class="fs-1 mb-3">📁</div>
          <h5>Preview not available for this file type</h5>
          <BButton variant="primary" class="mt-3" @click="downloadFile(previewUrl, previewName)">
            Download to View
          </BButton>
        </div>
      </ClientOnly>
    </div>
  </BModal>

  <!-- Message Deletion Modal (WhatsApp Style) -->
  <BModal v-model="showDeleteModal" title="Delete Message?" centered hide-footer header-bg-variant="light" header-text-variant="primary" body-class="p-4">
    <div class="text-center mb-4">
      <p class="text-muted">Are you sure you want to delete this message?</p>
    </div>
    <div class="d-grid gap-2">
      <BButton variant="outline-danger" class="rounded-3 py-2 fw-bold" @click="confirmingDeleteMessage('me')">
        🗑️ Delete for me
      </BButton>
      <BButton v-if="messageToDelete?.senderId === auth.user?.id" variant="danger" class="rounded-3 py-2 fw-bold" @click="confirmingDeleteMessage('everyone')">
        🚮 Delete for everyone
      </BButton>
      <BButton variant="light" class="rounded-3 py-2 mt-2" @click="showDeleteModal = false">
        Cancel
      </BButton>
    </div>
  </BModal>
</template>

<script setup>
import { ref, onMounted, computed, watch, nextTick } from 'vue'
import { useAuthStore } from '~/stores/auth'
import { useChatStore } from '~/stores/chat'

// Import document viewers
import VueOfficePdf from '@vue-office/pdf'
import VueOfficeExcel from '@vue-office/excel'
import VueOfficeDocx from '@vue-office/docx'

// Import Emoji Picker
import EmojiPicker from 'vue3-emoji-picker'
import 'vue3-emoji-picker/css'

// Import styles
import '@vue-office/excel/lib/index.css'
import '@vue-office/docx/lib/index.css'

definePageMeta({ middleware: 'auth' })

const chat = useChatStore()
const auth = useAuthStore()
const config = useRuntimeConfig()

// State for Document Preview
const showPreview = ref(false)
const previewUrl = ref('')
const previewType = ref('')
const previewName = ref('')

const newMessage = ref('')
const activeUser = ref(null)
const messageContainer = ref(null)
const showEmojiPicker = ref(false)
const blockStatus = ref({ blocked_by_me: false, has_blocked_me: false, is_blocked: false })

// State for Message Deletion
const showDeleteModal = ref(false)
const messageToDelete = ref(null)

async function confirmingDeleteMessage(type) {
    if (!messageToDelete.value) return
    try {
        await chat.deleteMessage(messageToDelete.value.id, type)
        showDeleteModal.value = false
        messageToDelete.value = null
    } catch (err) {
        alert('Failed to delete message: ' + (err.response?._data?.error || err.message))
    }
}

async function checkBlockStatus() {
    if (!activeUser.value) return
    console.log(`Checking block status with user ${activeUser.value.id}...`)
    try {
        const data = await $fetch(`${config.public.apiBase}/blocks/check/${activeUser.value.id}`, {
            headers: authHeaders()
        })
        console.log('Block status received:', data)
        blockStatus.value = data
    } catch (err) {
        console.error('Failed to check block status', err)
    }
}

const isBlockedByMe = computed(() => {
    return chat.isUserBlocked(activeUser.value?.id)
})

async function handleToggleBlock() {
    if (!activeUser.value) return
    try {
        await chat.toggleBlock(activeUser.value.id)
        await checkBlockStatus() // Refresh local status
    } catch (err) {
        console.error('Block toggle failed', err)
    }
}

function onSelectEmoji(emoji) {
  newMessage.value += emoji.i
}

watch(() => chat.blockUpdateTrigger, () => {
    console.log('Block update signal received from socket!')
    checkBlockStatus()
})

watch(activeUser, async (newVal) => {
    if (newVal) {
        chat.activeUserId = newVal.id
        await chat.fetchHistory(newVal.id)
        await checkBlockStatus()
        scrollToBottom()
    } else {
        chat.activeUserId = null
    }
})

// Use store-managed users
const onlineUsers = computed(() => {
    return chat.users.filter(u => chat.presence[String(u.id)] === 'online' && String(u.id) !== String(auth.user?.id))
})

const offlineUsers = computed(() => {
    return chat.users.filter(u => (!chat.presence[String(u.id)] || chat.presence[String(u.id)] === 'offline') && String(u.id) !== String(auth.user?.id))
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
        
        // Send as appropriate message type
        await chat.sendMessage(activeUser.value.id, data.url, data.type, data.name)
        scrollToBottom()
    } catch (err) {
        console.error('Upload failed', err)
    } finally {
        uploading.value = false
        if (fileInput.value) fileInput.value.value = ''
    }
}

const previewLoading = ref(false)

async function openPreview(url, fileName) {
    if (!url) return
    
    previewName.value = fileName || 'Document'
    const ext = (fileName || url).split('.').pop().toLowerCase()
    
    if (ext === 'pdf') {
        previewType.value = 'pdf'
    } else if (['xls', 'xlsx'].includes(ext)) {
        previewType.value = 'excel'
    } else if (['doc', 'docx'].includes(ext)) {
        previewType.value = 'docx'
    } else if (['jpg', 'jpeg', 'png', 'webp'].includes(ext)) {
        previewType.value = 'image'
    } else {
        if (import.meta.client) window.open(url, '_blank')
        return
    }

    showPreview.value = true
    
    // For non-images, fetch as ArrayBuffer via proxy to ensure CORS compliance
    if (previewType.value !== 'image') {
        previewLoading.value = true
        previewUrl.value = '' // Clear previous
        
        // Transform direct storage URL to proxy URL to bypass CORS
        let fetchUrl = url
        if (url.includes('/storage/')) {
            const path = url.split('/storage/').pop()
            fetchUrl = `${config.public.apiBase}/messages/file/${path}`
        }

        try {
            const response = await fetch(fetchUrl, {
                headers: authHeaders()
            })
            const buffer = await response.arrayBuffer()
            previewUrl.value = buffer
        } catch (err) {
            console.error('Failed to load preview data', err)
            previewUrl.value = url // Fallback
        } finally {
            previewLoading.value = false
        }
    } else {
        previewUrl.value = url
        previewLoading.value = false
    }
}

function getFileIcon(fileName) {
    if (!fileName) return '📄'
    const ext = fileName.split('.').pop().toLowerCase()
    if (ext === 'pdf') return '📕'
    if (['doc', 'docx'].includes(ext)) return '📘'
    if (['xls', 'xlsx', 'csv'].includes(ext)) return '📗'
    if (ext === 'zip') return '📦'
    if (ext === 'txt') return '📝'
    return '📄'
}

function downloadFile(url, fileName) {
    if (import.meta.client) {
        const link = document.createElement('a')
        link.href = url
        link.download = fileName || 'download'
        link.target = '_blank'
        document.body.appendChild(link)
        link.click()
        document.body.removeChild(link)
    }
}

function authHeaders() {
    return { Authorization: `Bearer ${auth.token}` }
}

function getProfileImageUrl(user) {
    if (!user) return null
    return user.profile_image_url || null
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
        const replyToId = chat.replyTo?.id
        await chat.sendMessage(activeUser.value.id, newMessage.value, 'text', null, replyToId)
        newMessage.value = ''
        scrollToBottom()
    } catch (err) {
        console.error('Failed to send', err)
    }
}

function scrollToMessage(messageId) {
    if (!messageId) return
    const index = chat.messages.findIndex(m => m.id === messageId)
    if (index === -1) return
    
    // Simple way: browser scroll into view if elements exist
    nextTick(() => {
        const elements = document.querySelectorAll('.message-wrapper')
        // We need to find the specific element. 
        // Better: use an ID on the message element
        const target = document.getElementById(`msg-${messageId}`)
        if (target) {
            target.scrollIntoView({ behavior: 'smooth', block: 'center' })
            target.classList.add('highlight-pulse')
            setTimeout(() => target.classList.remove('highlight-pulse'), 2000)
        }
    })
}

function groupReactions(reactions) {
    if (!reactions) return {}
    return reactions.reduce((acc, r) => {
        acc[r.emoji] = acc[r.emoji] || { count: 0, users: [] }
        acc[r.emoji].count++
        acc[r.emoji].users.push(r.user_id)
        return acc
    }, {})
}

let lastTypingTime = 0
function handleTyping() {
    if (!activeUser.value) return
    
    const now = Date.now()
    if (now - lastTypingTime > 2000) {
        chat.sendTyping(activeUser.value.id)
        lastTypingTime = now
    }
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
.chat-container {
    background: #f8fafc;
    min-height: calc(100vh - 80px);
}

.chat-wrapper {
    height: calc(100vh - 120px);
    background: #ffffff;
}

/* Glassmorphism Header */
.glass-header {
    background: rgba(255, 255, 255, 0.8) !important;
    backdrop-filter: blur(10px);
    -webkit-backdrop-filter: blur(10px);
    border-bottom: 1px solid rgba(0, 0, 0, 0.05) !important;
}

/* Message Bubble Geometry */
.message {
    font-size: 0.95rem;
    line-height: 1.5;
    transition: transform 0.2s ease;
}

.message-me {
    color: white;
    border-radius: 18px 18px 4px 18px;
}

.message-them {
    border-radius: 18px 18px 18px 4px;
}

.bg-slate {
    background: linear-gradient(135deg, #475569 0%, #1e293b 100%) !important;
}

.shadow-blue {
    box-shadow: 0 4px 15px rgba(30, 41, 59, 0.2) !important;
}

/* Integrated Actions */
.message-action-trigger {
    opacity: 0.15;
    z-index: 10;
}

.message-wrapper:hover .message-action-trigger {
    opacity: 1 !important;
}

.text-muted-custom {
    color: rgba(255, 255, 255, 0.6) !important;
}

.message-them .text-muted-custom {
    color: rgba(0, 0, 0, 0.3) !important;
}

/* Pinned Bar Glassmorphism */
.pinned-bar {
    background: rgba(241, 245, 249, 0.9) !important;
    backdrop-filter: blur(5px);
}

/* Scrollbar Refinement */
::-webkit-scrollbar {
    width: 5px;
}
::-webkit-scrollbar-track {
    background: transparent;
}
::-webkit-scrollbar-thumb {
    background: #cbd5e1;
    border-radius: 10px;
}
::-webkit-scrollbar-thumb:hover {
    background: #94a3b8;
}

.emoji-picker-container {
    position: absolute;
    bottom: 100%;
    left: 0;
    margin-bottom: 0.5rem;
    z-index: 1000;
    box-shadow: 0 10px 25px rgba(0,0,0,0.1);
    border-radius: 12px;
    overflow: hidden;
}

:deep(.v3-emoji-picker) {
    border: none !important;
}

.typing-dots {
  display: flex;
  gap: 3px;
}

.typing-dots span {
  width: 5px;
  height: 5px;
  background-color: var(--bs-primary);
  border-radius: 50%;
  animation: typing 1.4s infinite ease-in-out both;
}

@keyframes typing {
  0%, 80%, 100% { transform: scale(0); opacity: 0.3; }
  40% { transform: scale(1.0); opacity: 1; }
}

.highlight-pulse {
  animation: highlight-pulse 2s ease-out;
}

@keyframes highlight-pulse {
  0% { background-color: rgba(71, 85, 105, 0.2); }
  100% { background-color: transparent; }
}

.max-w-75 {
  max-width: 80%;
}
</style>

<template>
  <BContainer fluid class="chat-container px-4 py-3">
    <BRow class="chat-wrapper shadow-lg rounded-4 overflow-hidden border bg-white m-0">
      <!-- Users List -->
      <BCol md="4" lg="3" class="bg-white border-end d-flex flex-column h-100">
        <div class="p-4 border-bottom bg-light">
          <h4 class="fw-bold mb-0 text-primary">Messages</h4>
          <small class="text-muted" v-if="chat.connected">🟢 Connected</small>
          <small class="text-danger" v-else>🔴 Disconnected</small>
        </div>
        <div class="px-2 pt-3 mb-2">
          <div class="d-flex mb-2 gap-1 bg-light p-1 rounded-pill border">
            <button 
              class="btn btn-sm flex-grow-1 rounded-pill py-2 fw-bold transition-all" 
              :class="sidebarMode === 'users' ? 'bg-primary text-white shadow-sm' : 'text-muted'"
              @click="sidebarMode = 'users'"
            >
              Chats
            </button>
            <button 
              class="btn btn-sm flex-grow-1 rounded-pill py-2 fw-bold transition-all" 
              :class="sidebarMode === 'groups' ? 'bg-primary text-white shadow-sm' : 'text-muted'"
              @click="sidebarMode = 'groups'"
            >
              Groups
            </button>
          </div>
        </div>

        <div class="flex-grow-1 overflow-auto p-2">
          <div v-if="chat.loading" class="text-center py-4"><BSpinner variant="primary" /></div>
          
          <template v-if="sidebarMode === 'users'">
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
                <div class="d-flex justify-content-between align-items-center">
                  <h6 class="mb-0 fw-bold">{{ user.name }}</h6>
                  <BBadge v-if="chat.unreadCounts[user.id] > 0" variant="danger" pill style="font-size: 0.7rem;">
                    {{ chat.unreadCounts[user.id] }}
                  </BBadge>
                </div>
                <small class="text-primary text-truncate d-block fw-bold" v-if="chat.typingUsers[String(user.id)]">typing...</small>
                <div v-else class="d-flex justify-content-between align-items-center">
                  <small class="text-muted text-truncate d-block flex-grow-1">{{ getLastMessagePreview(user) }}</small>
                  <small class="text-muted flex-shrink-0" style="font-size: 0.65rem;">{{ formatTime(user.last_message_time) }}</small>
                </div>
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
                <div class="d-flex justify-content-between align-items-center">
                  <h6 class="mb-0 fw-bold">{{ user.name }}</h6>
                  <BBadge v-if="chat.unreadCounts[user.id] > 0" variant="danger" pill style="font-size: 0.7rem;">
                    {{ chat.unreadCounts[user.id] }}
                  </BBadge>
                </div>
                <div class="d-flex justify-content-between align-items-center">
                  <small class="text-muted text-truncate d-block flex-grow-1">{{ getLastMessagePreview(user) }}</small>
                  <small class="text-muted flex-shrink-0" style="font-size: 0.65rem;">{{ formatTime(user.last_message_time) }}</small>
                </div>
              </div>
            </div>
          </div>

          <div v-if="onlineUsers.length === 0 && offlineUsers.length === 0" class="text-center py-5 text-muted">
             <small>No contacts found</small>
          </div>
        </template>

        <template v-else>
          <!-- Groups List -->
          <div v-if="chat.rooms.length > 0">
            <div 
              v-for="room in chat.rooms" 
              :key="room.id" 
              class="user-item p-3 mb-2 rounded-3 d-flex align-items-center gap-3 cursor-pointer transition-all"
              :class="{ 'bg-primary-subtle border-primary': chat.activeRoomId === room.id }"
              @click="selectRoom(room)"
            >
              <BAvatar :text="room.name.charAt(0)" variant="info" />
              <div class="flex-grow-1 overflow-hidden">
                <div class="d-flex justify-content-between align-items-center">
                  <h6 class="mb-0 fw-bold">{{ room.name }}</h6>
                  <BBadge v-if="chat.unreadCounts['room_' + room.id] > 0" variant="danger" pill style="font-size: 0.7rem;">
                    {{ chat.unreadCounts['room_' + room.id] }}
                  </BBadge>
                </div>
                <small class="text-muted d-block">{{ room.members.length }} members</small>
              </div>
            </div>
          </div>
          <div v-else class="text-center py-5 text-muted">
            <small>No groups found</small>
          </div>
          <div class="p-2">
            <BButton variant="outline-primary" class="w-100 rounded-pill py-2 border-dashed" @click="showNewGroupModal = true">
              + Create New Group
            </BButton>
          </div>
        </template>
      </div>
    </BCol>

      <!-- Chat Area -->
      <BCol md="8" class="bg-white d-flex flex-column h-100">
        <template v-if="activeUser || activeRoom">
          <div class="p-4 border-bottom d-flex align-items-center justify-content-between bg-white">
            <div class="d-flex align-items-center gap-3">
              <template v-if="chat.activeRoomId">
                <BAvatar :text="activeRoom?.name?.charAt(0)" variant="info" />
                <div>
                  <h5 class="mb-0 fw-bold">{{ activeRoom?.name }}</h5>
                  <small class="text-muted">{{ activeRoom?.members?.length }} members</small>
                </div>
              </template>
              <template v-else-if="activeUser">
                <BAvatar 
                  v-if="activeUser.profile_image"
                  :src="getProfileImageUrl(activeUser)"
                  variant="info" 
                />
                <BAvatar v-else variant="info" :text="activeUser.name?.charAt(0)" />
                <div>
                  <h5 class="mb-0 fw-bold">{{ activeUser.name }}</h5>
                  <small class="text-primary fw-bold blink" v-if="chat.typingUsers[String(activeUser.id)]">typing...</small>
                  <small class="text-success" v-else-if="chat.presence[String(activeUser.id)] === 'online'">Active Now</small>
                  <small class="text-muted" v-else>Offline</small>
                </div>
              </template>
            </div>
            <div class="d-flex align-items-center gap-2">
              <template v-if="!chat.activeRoomId && activeUser">
                <BButton variant="light" size="sm" class="rounded-circle p-2" @click="initiateCall('audio')">
                  <span>📞</span>
                </BButton>
                <BButton variant="light" size="sm" class="rounded-circle p-2" @click="initiateCall('video')">
                  <span>📹</span>
                </BButton>
              </template>
              <BDropdown variant="light" size="sm" no-caret rounded="circle">
                <template #button-content>
                  <span class="fs-5">⋮</span>
                </template>
                <template v-if="!chat.activeRoomId && activeUser">
                  <BDropdownItem @click="handleToggleBlock">
                     <span v-if="isBlockedByMe">🔓 Unblock User</span>
                     <span v-else class="text-danger">🚫 Block User</span>
                  </BDropdownItem>
                  <BDropdownDivider />
                  <BDropdownItem @click="showUserInfoModal = true">ℹ️ User Info</BDropdownItem>
                </template>
                <template v-else-if="chat.activeRoomId">
                    <BDropdownItem @click="showRoomInfoModal = true">ℹ️ Group Info</BDropdownItem>
                </template>
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
                class="message-wrapper d-flex mb-3 group align-items-end gap-2"
                :class="msg.senderId === auth.user?.id ? 'flex-row-reverse' : 'flex-row'"
              >
                <!-- Message Avatar -->
                <BAvatar 
                  size="2.5rem" 
                  :src="msg.senderId === auth.user?.id ? getProfileImageUrl(auth.user) : (msg.roomId ? getProfileImageUrl(msg.sender) : getProfileImageUrl(activeUser))" 
                  :text="msg.senderId === auth.user?.id ? auth.user?.name?.charAt(0) : (msg.roomId ? msg.sender?.name?.charAt(0) : activeUser?.name?.charAt(0))"
                  variant="light"
                  class="flex-shrink-0 shadow-sm border border-white mb-1"
                />

                <div 
                  class="message px-3 py-2 shadow-sm max-w-75 position-relative group"
                  :style="msg.senderId === auth.user?.id ? 'border-radius: 1.25rem 1.25rem 0.25rem 1.25rem;' : 'border-radius: 1.25rem 1.25rem 1.25rem 0.25rem;'"
                  :class="msg.senderId === auth.user?.id ? 'message-me bg-slate shadow-blue' : 'message-them bg-white border text-dark'"
                >
                  <div v-if="msg.roomId && msg.senderId !== auth.user?.id" class="small fw-bold mb-1 text-primary">
                    {{ msg.sender?.name }}
                  </div>
                  <div class="message-actions-overlay position-absolute top-0 end-0 p-1 message-action-trigger transition-all">
                    <BDropdown variant="link" size="sm" no-caret toggle-class="p-0 text-muted-custom">
                      <template #button-content><span class="fs-6 d-flex align-items-center justify-content-center" style="width: 24px; height: 24px;">⋮</span></template>
                       <BDropdownItem @click="chat.replyTo = msg">↩️ Reply</BDropdownItem>
                       <BDropdownItem v-if="canEdit(msg)" @click="startEditing(msg)">✏️ Edit Message</BDropdownItem>
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
                    <div v-if="msg.type === 'text'">
                        <div v-if="editingMessageId === msg.id" class="edit-container mt-1">
                            <BFormTextarea v-model="editingContent" rows="2" class="mb-2 bg-light shadow-none border-0" />
                            <div class="d-flex gap-2 justify-content-end">
                                <BButton size="sm" variant="light" @click="cancelEditing">Cancel</BButton>
                                <BButton size="sm" variant="primary" :disabled="editingLoading" @click="saveEdit(msg.id)">
                                    <BSpinner small v-if="editingLoading" />
                                    Save
                                </BButton>
                            </div>
                        </div>
                        <div v-else class="message-text">{{ msg.content }}</div>
                    </div>
                    <div v-else-if="msg.type === 'call'" class="message-call d-flex align-items-center gap-2 py-1" :class="{ 'text-danger fw-bold': msg.content.includes('Missed') || msg.content.includes('Rejected') }">
                      <span class="fs-5">{{ msg.content.includes('Video') ? '📹' : '📞' }}</span>
                      <span class="fw-bold">{{ msg.content }}</span>
                    </div>
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
                    <span v-if="msg.is_edited" class="fst-italic opacity-75">edited • </span>
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
              <div v-if="chat.typingUsers[String(activeUser.id)]" class="message-wrapper d-flex justify-content-start align-items-end gap-2 mt-2">
                <BAvatar 
                  size="2.5rem" 
                  :src="getProfileImageUrl(activeUser)" 
                  :text="activeUser.name?.charAt(0)"
                  variant="light"
                  class="flex-shrink-0 shadow-sm border border-white mb-1"
                />
                <div class="message px-3 py-2 shadow-sm bg-white border text-dark d-flex align-items-center gap-2" style="border-radius: 1.25rem 1.25rem 1.25rem 0.25rem;">
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

  <!-- WebRTC Call Components -->
  <ChatCallOverlay 
    :is-open="isCallActive"
    :user-name="activeCallUser?.name"
    :local-stream="localStream"
    :remote-streams="remoteStreams"
    :active-call-type="activeCallType"
    :call-duration="callDuration"
    :current-room-id="currentRoomId"
    status-text="In call..."
    @hangup="endCall"
    @mute="toggleMute"
    @camera="toggleVideo"
  />

  <BModal v-model="showIncomingCall" title="Incoming Call" centered hide-footer no-close-on-backdrop>
    <div class="text-center p-4">
      <BAvatar size="5rem" variant="info" :text="incomingCallerName?.charAt(0) || 'U'" class="mb-4 shadow" />
      <h4 class="fw-bold mb-2">{{ incomingCallerName }}</h4>
      <p class="text-muted mb-4">Incoming {{ incomingCallType === 'video' ? 'Video' : 'Voice' }} Call...</p>
      
      <div class="d-flex justify-content-center gap-3">
        <BButton variant="danger" class="rounded-pill px-4 py-2" @click="rejectCall">
          Hang Up
        </BButton>
        <BButton variant="success" class="rounded-pill px-4 py-2" @click="acceptCall">
          Accept
        </BButton>
      </div>
    </div>
  </BModal>

  <BModal v-model="showUserInfoModal" title="User Information" centered hide-footer header-bg-variant="primary" header-text-variant="white">
    <div v-if="activeUser" class="text-center p-4">
      <div class="position-relative d-inline-block mb-4">
        <BAvatar 
          v-if="activeUser.profile_image"
          :src="getProfileImageUrl(activeUser)"
          size="8rem"
          variant="info"
          class="shadow-lg border border-3 border-white"
        />
        <BAvatar v-else variant="info" :text="activeUser.name.charAt(0)" size="8rem" class="shadow-lg border border-3 border-white" />
        <span 
          class="position-absolute bottom-0 end-0 rounded-circle border border-2 border-white p-2" 
          :class="chat.presence[String(activeUser.id)] === 'online' ? 'bg-success' : 'bg-secondary'"
          style="width: 24px; height: 24px;"
        ></span>
      </div>
      
      <h3 class="fw-bold mb-1">{{ activeUser.name }}</h3>
      <p class="text-primary fw-bold mb-4">{{ activeUser.email }}</p>
      
      <div class="d-flex flex-column gap-2 text-start bg-light p-3 rounded-4">
        <div class="d-flex justify-content-between align-items-center">
          <span class="text-muted small">Status</span>
          <BBadge :variant="chat.presence[String(activeUser.id)] === 'online' ? 'success' : 'secondary'" pill>
            {{ chat.presence[String(activeUser.id)] === 'online' ? 'Online' : 'Offline' }}
          </BBadge>
        </div>
        <div class="d-flex justify-content-between align-items-center">
          <span class="text-muted small">Joined</span>
          <span class="small fw-bold">{{ formatDate(activeUser.created_at) }}</span>
        </div>
      </div>

      <div class="mt-4 pt-3 border-top">
        <BButton variant="outline-primary" class="rounded-pill px-4 w-100 fw-bold" @click="showUserInfoModal = false">
          Close
        </BButton>
      </div>
    </div>
  </BModal>

  <!-- Group Call Invite Modal -->
  <BModal v-model="showGroupInviteModal" title="👥 Start Group Call" centered hide-footer scrollable>
    <div class="p-2">
      <p class="text-muted small mb-3">Select participants to invite to the call</p>
      <div class="user-selection-list mb-4" style="max-height: 300px; overflow-y: auto;">
        <div v-for="user in chat.users" :key="user.id" 
          class="d-flex align-items-center gap-3 p-2 rounded-3 cursor-pointer user-item-select mb-2 border transition-all"
          :class="{ 'bg-primary-subtle border-primary': selectedGroupUsers.includes(user.id) }"
          @click="toggleUserSelection(user.id)"
        >
          <BFormCheckbox :model-value="selectedGroupUsers.includes(user.id)" @change="toggleUserSelection(user.id)" />
          <BAvatar :src="user.profile_image ? `${config.public.apiBase.replace('/api', '')}/storage/${user.profile_image}` : null" :text="user.name.charAt(0)" size="2.5rem" />
          <div class="flex-grow-1">
            <div class="fw-bold">{{ user.name }}</div>
            <div class="small" :class="chat.presence[user.id] ? 'text-success' : 'text-muted'">{{ chat.presence[user.id] ? 'Online' : 'Offline' }}</div>
          </div>
        </div>
      </div>
      <div class="d-flex gap-2">
        <BButton variant="light" class="flex-grow-1 rounded-pill" @click="showGroupInviteModal = false">Cancel</BButton>
        <BButton variant="primary" class="flex-grow-1 rounded-pill fw-bold" @click="initGroupCall" :disabled="selectedGroupUsers.length === 0">
          🚀 Start Group Call
        </BButton>
      </div>
    </div>
  </BModal>

  <!-- Incoming Group Call Modal -->
  <BModal v-model="showIncomingGroupCall" title="👥 Incoming Group Call" centered hide-footer no-close-on-backdrop>
    <div class="text-center p-4">
      <BAvatar size="5rem" variant="primary" text="👥" class="mb-4 shadow" />
      <h4 class="fw-bold mb-2">Group Call Room</h4>
      <p class="text-muted mb-4">You have been invited to a group {{ groupCallType === 'video' ? 'Video' : 'Voice' }} Call.</p>
      
      <div class="d-flex justify-content-center gap-3">
        <BButton variant="danger" class="rounded-pill px-4 py-2" @click="showIncomingGroupCall = false">
          Reject
        </BButton>
        <BButton variant="success" class="rounded-pill px-4 py-2" @click="acceptGroupCall">
          Join Call
        </BButton>
      </div>
    </div>
  </BModal>

  <!-- Screen Share Initiation Modal (Initiator) -->
  <BModal v-model="showScreenShareInvite" title="🖥️ Secure Screen Sharing" centered hide-footer no-close-on-backdrop>
    <div class="text-center p-4">
      <div class="display-1 mb-3">🖥️</div>
      <h5 class="fw-bold mb-3">Your Screen Sharing Session is Ready</h5>
      <p class="text-muted small mb-4">Share this passcode and your username with the other user to allow them to join securely.</p>
      
      <div class="bg-light p-3 rounded-4 mb-4 border dashed">
        <small class="text-uppercase fw-bold text-muted d-block mb-1">Secure Passcode</small>
        <div class="display-6 fw-bold text-primary tracking-widest">{{ screenPasscode }}</div>
      </div>
      
      <BButton variant="danger" class="rounded-pill px-5 fw-bold" @click="endScreenShare">
        Stop Sharing
      </BButton>
    </div>
  </BModal>

  <!-- Screen Share Join Modal (Receiver) -->
  <BModal v-model="showScreenShareJoin" title="🖥️ Join Screen Share" centered hide-footer no-close-on-backdrop>
    <div class="p-4">
      <div class="text-center mb-4">
        <div class="display-4 mb-2">🖥️</div>
        <h5 class="fw-bold">Incoming Screen Share</h5>
        <p class="text-muted small">Enter the passcode and your name to join the session from <strong>{{ incomingScreenSender?.senderName }}</strong>.</p>
      </div>
      
      <BFormGroup label="Passcode" class="mb-3 fw-bold">
        <BFormInput v-model="enteredPasscode" placeholder="6-digit passcode" class="rounded-3 shadow-none bg-light border-0 py-2" />
      </BFormGroup>
      
      <BFormGroup label="Your Name" class="mb-4 fw-bold">
        <BFormInput v-model="enteredUsername" placeholder="Enter your username" class="rounded-3 shadow-none bg-light border-0 py-2" />
      </BFormGroup>
      
      <div class="d-flex gap-2">
        <BButton variant="light" class="flex-grow-1 rounded-pill" @click="showScreenShareJoin = false">Cancel</BButton>
        <BButton variant="success" class="flex-grow-1 rounded-pill fw-bold" @click="submitJoinRequest" :disabled="!enteredPasscode || !enteredUsername">
          Join Now
        </BButton>
      </div>
    </div>
  </BModal>

  <!-- Screen Share Viewer Overlay (Full Screen) -->
  <transition name="fade">
    <div v-if="isScreenSharing || isScreenViewing" class="screen-share-overlay position-fixed top-0 start-0 w-100 h-100 bg-black d-flex flex-column" style="z-index: 2000;">
      <!-- Overlay Header -->
      <div class="p-3 bg-dark bg-opacity-75 text-white d-flex justify-content-between align-items-center border-bottom border-dark">
        <div class="d-flex align-items-center gap-2">
            <span class="badge bg-danger pulse-red">LIVE</span>
            <strong v-if="isScreenSharing">Sharing your screen...</strong>
            <strong v-else>Viewing {{ incomingScreenSender?.senderName }}'s screen</strong>
        </div>
        <BButton variant="danger" size="sm" class="rounded-pill px-3 fw-bold shadow" @click="endScreenShare">
            Stop session
        </BButton>
      </div>
      
      <!-- Video Container -->
      <div class="flex-grow-1 d-flex align-items-center justify-content-center overflow-hidden p-4">
        <video 
           v-if="isScreenViewing" 
           ref="remoteScreenVideo" 
           :srcObject="remoteScreenStream" 
           autoplay 
           playsinline 
           class="max-w-100 max-h-100 shadow-lg rounded-4 border border-secondary"
           style="background: #111; object-fit: contain;"
        ></video>
        <div v-else class="text-center text-white opacity-50">
           <div class="display-1 mb-3">🖥️</div>
           <h4>Sharing in progress</h4>
           <p>Minimize this window to focus on your workspace</p>
        </div>
      </div>
    </div>
  </transition>

  <!-- New Group Modal -->
  <BModal v-model="showNewGroupModal" title="Create New Group" @ok="createGroup">
    <BFormGroup label="Group Name" label-for="group-name-input" class="mb-3">
      <BFormInput id="group-name-input" v-model="newGroupName" placeholder="Enter group name" required />
    </BFormGroup>
    
    <BFormGroup label="Select Members" class="mb-0">
      <div class="members-selection-list overflow-auto custom-scrollbar" style="max-height: 250px;">
        <div 
          v-for="user in chat.users" 
          :key="user.id" 
          class="d-flex align-items-center gap-3 p-2 rounded-3 cursor-pointer hover-bg-light"
          @click="toggleMemberSelection(user.id)"
        >
          <BFormCheckbox 
            :checked="selectedMembersForNewGroup.includes(user.id)" 
            @change="toggleMemberSelection(user.id)" 
          />
          <BAvatar :src="getProfileImageUrl(user)" :text="user.name.charAt(0)" size="sm" />
          <span>{{ user.name }}</span>
        </div>
      </div>
    </BFormGroup>
    
    <template #modal-footer="{ ok, cancel }">
      <BButton variant="light" @click="cancel()">Cancel</BButton>
      <BButton variant="primary" :disabled="!newGroupName.trim() || selectedMembersForNewGroup.length === 0" @click="ok()">
        Create Group
      </BButton>
    </template>
  </BModal>
</template>

<script setup>
import { ref, onMounted, computed, watch, nextTick } from 'vue'
import { useAuthStore } from '~/stores/auth'
import { useChatStore } from '~/stores/chat'
import { useWebRTC } from '~/composables/useWebRTC'
import { useScreenShare } from '~/composables/useScreenShare'

// Import document viewers

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
const { show: showToast } = useToast()

const sidebarMode = ref('users') // 'users' or 'groups'
const showNewGroupModal = ref(false)
const showRoomInfoModal = ref(false)
const newGroupName = ref('')
const selectedMembersForNewGroup = ref([])

// State for Document Preview
const showPreview = ref(false)
const previewUrl = ref('')
const previewType = ref('')
const previewName = ref('')

const newMessage = ref('')
const activeUser = computed(() => {
    return chat.users.find(u => String(u.id) === String(chat.activeUserId)) || null
})
const activeRoom = computed(() => {
    return chat.rooms.find(r => String(r.id) === String(chat.activeRoomId)) || null
})
const messageContainer = ref(null)
const showEmojiPicker = ref(false)
const blockStatus = ref({ blocked_by_me: false, has_blocked_me: false, is_blocked: false })

// State for User Info Modal
const showUserInfoModal = ref(false)

// Edit message state
const editingMessageId = ref(null)
const editingContent = ref('')
const editingLoading = ref(false)

// Group Call State
const showGroupInviteModal = ref(false)
const showIncomingGroupCall = ref(false)
const selectedGroupUsers = ref([])
const groupCallRoomId = ref('')
const groupCallType = ref('video')

function toggleMemberSelection(userId) {
    const idx = selectedMembersForNewGroup.value.indexOf(userId)
    if (idx > -1) selectedMembersForNewGroup.value.splice(idx, 1)
    else selectedMembersForNewGroup.value.push(userId)
}

// --- WebRTC Call Logic ---
const { 
  localStream, 
  remoteStreams, 
  isCalling: isCallActive, 
  activeCallType, 
  remoteUserId,
  currentRoomId,
  isConnected,
  callDuration,
  startTime,
  startCall, 
  joinGroupCall,
  leaveGroupCall,
  handleOffer, 
  handleAnswer, 
  handleIceCandidate, 
  endCall: endWebRTCCall,
  resetTimer,
  toggleMute,
  toggleVideo
} = useWebRTC()

// --- Screen Sharing Logic ---
const {
    localScreenStream,
    remoteScreenStream,
    isSharing: isScreenSharing,
    isViewing: isScreenViewing,
    screenPasscode,
    startSharing: startScreenSharingCore,
    joinSharing,
    handleJoinAttempt,
    handleSignal: handleScreenSignal,
    endScreenShare: endScreenShareCore
} = useScreenShare()

const showScreenShareInvite = ref(false)
const showScreenShareJoin = ref(false)
const enteredPasscode = ref('')
const enteredUsername = ref('')
const incomingScreenSender = ref(null)
const remoteScreenVideo = ref(null)

const startScreenSharing = async () => {
    if (!activeUser.value) return
    try {
        await startScreenSharingCore(activeUser.value.id)
        showScreenShareInvite.value = true
    } catch (err) {
        showToast({ title: 'Screen Share Error', body: err.message || 'Failed to start screen share', variant: 'danger' })
    }
}

const submitJoinRequest = async () => {
    if (!enteredPasscode.value || !enteredUsername.value || !incomingScreenSender.value) return
    await joinSharing(incomingScreenSender.value.senderId, enteredPasscode.value, enteredUsername.value)
    showScreenShareJoin.value = false
}

const showIncomingCall = ref(false)
const incomingCallerId = ref(null)
const incomingCallerName = ref('')
const incomingCallType = ref('video')
const activeCallUser = ref(null)

const initiateCall = async (type) => {
    if (!activeUser.value) return
    activeCallUser.value = activeUser.value
    console.log(`[CALL] initiateCall: Current User (Me): ${auth.user?.id}, Calling User: ${activeUser.value.id}, Type: ${type}`)
    // Notify receiver first (Signaling only)
    console.log(`[CALL] Emitting call:initiate to ${activeUser.value.id} (${type})`)
    chat.socket?.emit('call:initiate', { receiverId: activeUser.value.id, type })
    
    isCallActive.value = true 
    activeCallType.value = type
}

const acceptCall = async () => {
    console.log(`[CALL] acceptCall: Accepting call from ${incomingCallerId.value}`)
    showIncomingCall.value = false
    const caller = chat.users.find(u => String(u.id) === String(incomingCallerId.value))
    activeCallUser.value = caller
    
    // Notify caller that we accepted
    chat.socket?.emit('call:accept', { receiverId: incomingCallerId.value })
    
    // Now we Wait for their 'call:offer'
}

const rejectCall = () => {
    console.log(`[CALL] rejectCall: Rejecting call from ${incomingCallerId.value}`)
    const partnerId = incomingCallerId.value
    showIncomingCall.value = false
    chat.socket?.emit('call:reject', { receiverId: incomingCallerId.value })
    
    // Log rejection locally
    if (partnerId) {
        const type = incomingCallType.value
        const content = `${type.charAt(0).toUpperCase() + type.slice(1)} Call Rejected`
        chat.sendMessage(partnerId, content, 'call')
    }
    
    incomingCallerId.value = null
}

const endCall = async (reason = 'ended') => {
    console.log(`[CALL] endCall: Terminating active call session (Reason: ${reason})`)
    const duration = callDuration.value
    const type = activeCallType.value
    const partnerId = activeCallUser.value?.id || incomingCallerId.value
    const wasConnected = isConnected.value

    endWebRTCCall()
    showIncomingCall.value = false // Ensure incoming modal also closes
    showIncomingGroupCall.value = false

    if (partnerId && !currentRoomId.value) {
        // Log the call in history
        let content = ''
        if (reason === 'rejected') {
            content = `${type.charAt(0).toUpperCase() + type.slice(1)} Call Rejected`
        } else if (!wasConnected) {
            content = `Missed ${type.charAt(0).toUpperCase() + type.slice(1)} Call`
        } else {
            content = `${type.charAt(0).toUpperCase() + type.slice(1)} Call (${duration})`
        }

        try {
            await chat.sendMessage(partnerId, content, 'call')
        } catch (err) {
            console.error('Failed to log call history', err)
        }
    }
    
    activeCallUser.value = null
    incomingCallerId.value = null
    resetTimer()
}

const openGroupCallInvite = () => {
    selectedGroupUsers.value = []
    if (activeUser.value) selectedGroupUsers.value.push(activeUser.value.id)
    showGroupInviteModal.value = true
}

const toggleUserSelection = (userId) => {
    const idx = selectedGroupUsers.value.indexOf(userId)
    if (idx > -1) selectedGroupUsers.value.splice(idx, 1)
    else selectedGroupUsers.value.push(userId)
}

const initGroupCall = () => {
    const roomId = 'room_' + Math.random().toString(36).substr(2, 9)
    groupCallRoomId.value = roomId
    showGroupInviteModal.value = false
    
    // Join the room myself
    try {
        joinGroupCall(roomId, 'video')
    } catch (err) {
        showToast({ title: 'Group Call Error', body: err.message || 'Failed to join group call', variant: 'danger' })
    }
    
    // Invite others
    chat.socket.emit('call:invite-group', {
        roomId,
        participants: selectedGroupUsers.value,
        type: 'video'
    })
}

const acceptGroupCall = () => {
    showIncomingGroupCall.value = false
    try {
        joinGroupCall(groupCallRoomId.value, groupCallType.value)
    } catch (err) {
        showToast({ title: 'Group Call Error', body: err.message || 'Failed to join group call', variant: 'danger' })
    }
}

// Setup Socket Listeners for Calls
watch(() => chat.socket, (socket) => {
    if (!socket) return

    socket.on('call:incoming', ({ senderId, type }) => {
        console.log(`[CALL] Received call:incoming from ${senderId} (${type})`)
        // Fallback alert to be absolutely sure we know if it arrived
        // window.alert(`DEBUG: Incoming call from ${senderId}`)
        
        const caller = chat.users.find(u => String(u.id) === String(senderId))
        incomingCallerId.value = senderId
        incomingCallerName.value = caller?.name || 'Unknown User'
        incomingCallType.value = type
        showIncomingCall.value = true
        
        console.log('[CALL] showIncomingCall set to true')
    })

    socket.on('call:accepted', async ({ senderId }) => {
        console.log('[CALL] Receiver accepted call, starting WebRTC...')
        try {
            await startCall(senderId, activeCallType.value)
        } catch (err) {
            showToast({ title: 'Call Error', body: err.message || 'Failed to start call', variant: 'danger' })
        }
    })

    socket.on('call:offer', async ({ senderId, offer, type }) => {
        try {
            await handleOffer(senderId, offer, type)
        } catch (err) {
            showToast({ title: 'Call Error', body: err.message || 'Failed to handle incoming call', variant: 'danger' })
        }
    })

    socket.on('call:answer', async ({ senderId, answer }) => {
        await handleAnswer(senderId, answer)
    })

    socket.on('call:ice-candidate', async ({ senderId, candidate }) => {
        await handleIceCandidate(senderId, candidate)
    })

    socket.on('call:rejected', () => {
        console.log('[CALL] Remote user rejected the call')
        endCall('rejected')
    })

    socket.on('call:ended', () => {
        console.log('[CALL] Remote user ended the call')
        endCall()
    })

    socket.on('call:invite-group', ({ roomId, type }) => {
        console.log('[CALL] Received group call invitation', roomId)
        groupCallRoomId.value = roomId
        groupCallType.value = type
        showIncomingGroupCall.value = true
    })

    // --- Screen Share Signaling ---
    socket.on('screenshare:incoming', (data) => {
        console.log('[SCREENSHARE] Incoming invitation', data)
        incomingScreenSender.value = data
        showScreenShareJoin.value = true
    })

    socket.on('screenshare:join-attempt', async ({ receiverId, username, passcode }) => {
        console.log(`[SCREENSHARE] ${username} attempting to join with passcode: ${passcode}`)
        const valid = await handleJoinAttempt(receiverId, passcode)
        if (valid) {
            alert(`User ${username} joined your screen share!`)
        } else {
            console.warn('[SCREENSHARE] Invalid passcode attempt from', username)
        }
    })

    socket.on('screenshare:accepted', ({ senderId }) => {
        console.log('[SCREENSHARE] Join accepted by initiator')
        // We wait for the offer signal now
    })

    socket.on('screenshare:signal', ({ from, signal }) => {
        handleScreenSignal(from, signal)
    })

    socket.on('screenshare:ended', () => {
        console.log('[SCREENSHARE] Remote user ended sharing')
        endScreenShareCore()
    })
}, { immediate: true })
// --- End WebRTC Call Logic ---

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

watch([() => chat.activeUserId, () => chat.activeRoomId], async ([newUserId, newRoomId]) => {
    if (newUserId || newRoomId) {
        if (!newRoomId) await checkBlockStatus()
        scrollToBottom()
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
    if (!chat.activeUserId && !chat.activeRoomId) return []
    
    if (chat.activeRoomId) {
        return chat.messages.filter(m => String(m.roomId) === String(chat.activeRoomId))
    }
    
    return chat.messages.filter(m => 
        (String(m.senderId) === String(chat.activeUserId) && String(m.receiverId) === String(auth.user?.id)) ||
        (String(m.senderId) === String(auth.user?.id) && String(m.receiverId) === String(chat.activeUserId))
    )
})

async function handleSend() {
    if (!newMessage.value.trim() || (!activeUser.value && !activeRoom.value)) return
    
    try {
        const replyToId = chat.replyTo?.id
        await chat.sendMessage(
            chat.activeUserId, 
            newMessage.value, 
            'text', 
            null, 
            replyToId, 
            chat.activeRoomId
        )
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
    if (!activeUser.value && !activeRoom.value) return
    
    const now = Date.now()
    if (now - lastTypingTime > 2000) {
        chat.sendTyping(chat.activeUserId, chat.activeRoomId)
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

function formatDate(ts) {
    if (!ts) return 'Unknown'
    return new Date(ts).toLocaleDateString([], { day: 'numeric', month: 'short', year: 'numeric' })
}

function getLastMessagePreview(user) {
    if (!user.last_message) return 'No messages yet'
    
    let prefix = ''
    if (user.last_message_type === 'image') prefix = '📷 Photo'
    else if (user.last_message_type === 'file') prefix = '📄 File'
    else if (user.last_message_type === 'call') {
        const content = user.last_message
        if (content.includes('Video')) return '📹 Video Call'
        if (content.includes('Audio')) return '📞 Audio Call'
        return '📞 Call'
    }
    
    if (prefix) return prefix
    return user.last_message
}

function canEdit(msg) {
  if (msg.senderId !== auth.user?.id || msg.type !== 'text' || msg.is_deleted_everyone) return false
  const msgTime = new Date(msg.timestamp || msg.created_at).getTime()
  const now = new Date().getTime()
  const diffInHours = (now - msgTime) / (1000 * 60 * 60)
  return diffInHours < 1
}

function startEditing(msg) {
  editingMessageId.value = msg.id
  editingContent.value = msg.content
}

function cancelEditing() {
  editingMessageId.value = null
  editingContent.value = ''
}

async function saveEdit(messageId) {
  if (!editingContent.value.trim()) return
  editingLoading.value = true
  try {
    await chat.editMessage(messageId, editingContent.value)
    cancelEditing()
  } catch (err) {
    console.error('Failed to edit message', err)
    alert(err.response?._data?.error || 'Failed to edit message')
  } finally {
    editingLoading.value = false
  }
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
    height: calc(100vh - 110px); /* Account for navbar + main padding */
    max-height: calc(100vh - 110px);
    overflow: hidden;
    background: #f8fafc;
    padding-top: 0 !important;
    padding-bottom: 0 !important;
}

.chat-wrapper {
    height: 100%;
    background: #ffffff;
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
.screen-share-overlay {
  z-index: 2000;
  backdrop-filter: blur(10px);
}

.pulse-red {
  animation: pulse-red 2s infinite;
}

@keyframes pulse-red {
  0% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(220, 53, 69, 0.7); }
  70% { transform: scale(1); box-shadow: 0 0 0 10px rgba(220, 53, 69, 0); }
  100% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(220, 53, 69, 0); }
}

.tracking-widest {
  letter-spacing: 0.5rem;
}

.fade-enter-active, .fade-leave-active {
  transition: opacity 0.3s ease;
}
.fade-enter-from, .fade-leave-to {
  opacity: 0;
}
</style>

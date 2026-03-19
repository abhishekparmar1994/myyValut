<template>
  <BContainer fluid class="chat-container p-0" :class="{ 'earthquake-shake': chat.isShaking }">
    <!-- Poke Overlay -->
    <div v-if="chat.isShaking" class="poke-overlay">
       <div class="poke-text">ATTENTION!</div>
    </div>
    <BRow class="chat-wrapper overflow-hidden border-top bg-white m-0" style="min-height: calc(100vh - 72px);">
      <!-- Users List -->
      <BCol :md="4" :lg="3" class="bg-surface border-end d-flex flex-column h-100" :class="{ 'd-none d-md-flex': chat.activeUserId || chat.activeRoomId }">
        <div class="p-4 border-bottom bg-surface-secondary">
          <div class="d-flex justify-content-between align-items-center mb-2">
            <div class="d-flex align-items-center gap-2">
              <h4 class="fw-bold mb-0 text-primary">Messages</h4>
            </div>
            <div class="status-indicator">
              <small class="text-muted" v-if="chat.connected">🟢 Connected</small>
              <small class="text-danger" v-else>🔴 Disconnected</small>
            </div>
          </div>
          <div class="search-container mt-2">
            <BFormInput 
              v-model="userSearch" 
              placeholder="Search contacts or groups..." 
              size="sm" 
              class="rounded-pill border-0 bg-white px-3 shadow-none"
            />
          </div>
        </div>
        <div class="px-2 pt-3 mb-2">
          <div class="d-flex mb-2 gap-0 bg-surface-secondary p-1 rounded-pill border chat-sidebar-tabs" :style="auth.theme === 'chatvibe' ? 'background: transparent !important; border: none !important; border-bottom: 1px solid var(--border-color) !important; border-radius: 0 !important;' : ''">
            <button 
              class="btn btn-sm flex-grow-1 rounded-pill py-2 fw-bold transition-all position-relative" 
              :class="{ 'bg-primary text-white shadow-sm active': sidebarMode === 'users', 'text-muted': sidebarMode !== 'users' }"
              @click="sidebarMode = 'users'"
            >
                All
                <BBadge v-if="chat.totalChatsUnread > 0" variant="danger" pill class="ms-1 px-1" style="font-size: 0.65rem;">
                  {{ chat.totalChatsUnread }}
                </BBadge>
              </button>
            <button 
              class="btn btn-sm flex-grow-1 rounded-pill py-2 fw-bold transition-all position-relative" 
              :class="{ 'bg-primary text-white shadow-sm active': sidebarMode === 'groups', 'text-muted': sidebarMode !== 'groups' }"
              @click="sidebarMode = 'groups'"
            >
                Groups
                <BBadge v-if="chat.totalGroupsUnread > 0" variant="danger" pill class="ms-1 px-1" style="font-size: 0.65rem;">
                  {{ chat.totalGroupsUnread }}
                </BBadge>
              </button>
            <button 
              class="btn btn-sm flex-grow-1 rounded-pill py-2 fw-bold transition-all position-relative" 
              :class="{ 'bg-primary text-white shadow-sm active': sidebarMode === 'unread', 'text-muted': sidebarMode !== 'unread' }"
              @click="sidebarMode = 'unread'"
            >
                Unread
                <BBadge v-if="unreadList.length > 0" variant="danger" pill class="ms-1 px-1" style="font-size: 0.65rem;">
                  {{ unreadList.length }}
                </BBadge>
              </button>
            <button 
              class="btn btn-sm flex-grow-1 rounded-pill py-2 fw-bold transition-all position-relative" 
              :class="{ 'bg-primary text-white shadow-sm active': sidebarMode === 'archived', 'text-muted': sidebarMode !== 'archived' }"
              @click="sidebarMode = 'archived'"
            >
                Archived
              </button>
          </div>
        </div>

        <div class="flex-grow-1 overflow-auto overflow-x-hidden p-2">
          
          <template v-if="sidebarMode === 'users'">
            <!-- Online Users -->
            <div v-if="onlineUsers.length > 0">
              <small class="text-uppercase fw-bold text-muted px-3 mb-2 d-block" style="font-size: 0.75rem;">Online</small>
            <div 
              v-for="user in onlineUsers" 
              :key="user.id" 
              class="user-item p-3 mb-2 rounded-3 d-flex align-items-center gap-3 cursor-pointer transition-all"
              :class="{ 'bg-primary-subtle border-primary': activeUser?.id === user.id }"
              @click="selectUser(user)"
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
              <div class="flex-grow-1 overflow-hidden d-flex flex-column">
                <div class="d-flex justify-content-between align-items-center mb-1">
                  <div class="d-flex align-items-center gap-1 overflow-hidden">
                    <h6 class="mb-0 fw-bold text-truncate text-main">{{ user.name }}</h6>
                    <HeartIcon v-if="user.is_favourite" size="12" class="text-danger flex-shrink-0" />
                  </div>
                  <small class="text-muted flex-shrink-0 xx-small">{{ formatTime(user.last_message_time) }}</small>
                </div>
                <div class="d-flex justify-content-between align-items-center">
                  <small class="text-primary text-truncate d-block fw-bold" v-if="chat.typingUsers[String(user.id)]">typing...</small>
                  <small v-else class="text-muted text-truncate d-block">{{ getLastMessagePreview(user) }}</small>
                  
                  <BBadge v-if="chat.unreadCounts['user_' + user.id] > 0 || user.is_unread_manual" variant="danger" pill class="ms-2 flex-shrink-0" style="font-size: 0.65rem; min-width: 1.2rem;">
                    {{ chat.unreadCounts['user_' + user.id] || 1 }}
                  </BBadge>
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
              @click="selectUser(user)"
            >
              <BAvatar 
                v-if="user.profile_image"
                :src="getProfileImageUrl(user)"
                variant="secondary" 
              />
              <BAvatar v-else variant="secondary" :text="user.name.charAt(0)" />
              <div class="flex-grow-1 overflow-hidden d-flex flex-column">
                <div class="d-flex justify-content-between align-items-center mb-1">
                  <div class="d-flex align-items-center gap-1 overflow-hidden">
                    <h6 class="mb-0 fw-bold text-truncate text-main">{{ user.name }}</h6>
                    <HeartIcon v-if="user.is_favourite" size="12" class="text-danger flex-shrink-0" />
                  </div>
                  <small class="text-muted flex-shrink-0 xx-small">{{ formatTime(user.last_message_time) }}</small>
                </div>
                <div class="d-flex justify-content-between align-items-center">
                  <small class="text-muted text-truncate d-block">{{ getLastMessagePreview(user) }}</small>
                  <BBadge v-if="chat.unreadCounts['user_' + user.id] > 0 || user.is_unread_manual" variant="danger" pill class="ms-2 flex-shrink-0" style="font-size: 0.65rem; min-width: 1.2rem;">
                    {{ chat.unreadCounts['user_' + user.id] || 1 }}
                  </BBadge>
                </div>
              </div>
            </div>
          </div>

          <div v-if="onlineUsers.length === 0 && offlineUsers.length === 0" class="text-center py-5 text-muted">
             <small>No contacts found</small>
          </div>
        </template>

        <template v-else-if="sidebarMode === 'groups'">
          <!-- Groups List -->
          <div v-if="filteredRooms.length > 0">
            <div 
              v-for="room in filteredRooms" 
              :key="room.id" 
              class="user-item p-3 mb-2 rounded-3 d-flex align-items-center gap-3 cursor-pointer transition-all"
              :class="{ 'active bg-primary-subtle border-primary': chat.activeRoomId === room.id }"
              @click="selectRoom(room)"
            >
              <BAvatar :text="room.name.charAt(0)" variant="info" />
              <div class="flex-grow-1 overflow-hidden d-flex flex-column">
                <div class="d-flex justify-content-between align-items-center mb-1">
                  <div class="d-flex align-items-center gap-1 overflow-hidden">
                    <h6 class="mb-0 fw-bold text-truncate text-main">{{ room.name }}</h6>
                    <HeartIcon v-if="room.is_favourite" size="12" class="text-danger flex-shrink-0" />
                  </div>
                  <BBadge v-if="chat.unreadCounts['room_' + room.id] > 0 || room.is_unread_manual" variant="danger" pill class="flex-shrink-0" style="font-size: 0.65rem; min-width: 1.2rem;">
                    {{ chat.unreadCounts['room_' + room.id] || 1 }}
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

        <template v-else-if="sidebarMode === 'archived'">
          <!-- Archived List -->
          <div v-if="archivedList.length > 0">
            <div 
              v-for="item in archivedList" 
              :key="item.isUser ? 'u' + item.id : 'r' + item.id" 
              class="user-item p-3 mb-2 rounded-3 d-flex align-items-center gap-3 cursor-pointer transition-all"
              @click="item.isUser ? selectUser(item) : selectRoom(item)"
            >
              <BAvatar v-if="item.isUser" :src="getProfileImageUrl(item)" :text="item.name.charAt(0)" variant="secondary" />
              <BAvatar v-else :text="item.name.charAt(0)" variant="info" />
              <div class="flex-grow-1 overflow-hidden">
                <h6 class="mb-0 fw-bold text-truncate text-main">{{ item.name }}</h6>
                <small class="text-muted">Archived Chat</small>
              </div>
            </div>
          </div>
          <div v-else class="text-center py-5 text-muted">
            <small>No archived chats</small>
          </div>
        </template>

        <template v-else-if="sidebarMode === 'unread'">
           <!-- Unread Filtered List -->
           <div v-if="unreadList.length > 0">
              <div 
                v-for="item in unreadList" 
                :key="item.id" 
                class="user-item p-3 mb-2 rounded-3 d-flex align-items-center gap-3 cursor-pointer transition-all"
                :class="{ 'active bg-primary-subtle border-primary': (item.isUser && activeUser?.id === item.id) || (!item.isUser && chat.activeRoomId === item.id) }"
                @click="item.isUser ? selectUser(item) : selectRoom(item)"
              >
                <BAvatar v-if="item.isUser && item.profile_image" :src="getProfileImageUrl(item)" variant="info" />
                <BAvatar v-else :text="item.name.charAt(0)" variant="info" />
                <div class="flex-grow-1 overflow-hidden">
                  <div class="d-flex justify-content-between align-items-center">
                    <h6 class="mb-0 fw-bold">{{ item.name }}</h6>
                    <BBadge variant="danger" pill style="font-size: 0.7rem;">
                      {{ chat.unreadCounts[item.isUser ? 'user_' + item.id : 'room_' + item.id] }}
                    </BBadge>
                  </div>
                  <small class="text-muted d-block text-truncate">{{ item.isUser ? getLastMessagePreview(item) : `${item.members.length} members` }}</small>
                </div>
              </div>
           </div>
           <div v-else class="text-center py-5 text-muted">
              <small>No unread messages</small>
           </div>
        </template>
      </div>
    </BCol>

      <!-- Chat Area -->
      <BCol :md="8" :lg="9" class="bg-surface d-flex flex-column h-100" :class="{ 'd-none d-md-flex': !chat.activeUserId && !chat.activeRoomId }">
        <template v-if="chat.activeUserId || chat.activeRoomId">
          <div class="p-4 border-bottom d-flex align-items-center justify-content-between bg-surface px-3 px-md-4">
            <div class="d-flex align-items-center gap-2 gap-md-3 overflow-hidden">
              <!-- Back Button (Mobile Only) -->
              <BButton variant="light" size="sm" class="d-md-none rounded-circle p-2 me-1" @click="chat.activeUserId = null; chat.activeRoomId = null">
                <ArrowLeftIcon size="18" />
              </BButton>
              <template v-if="chat.activeRoomId">
                <BAvatar :text="activeRoom?.name?.charAt(0)" variant="info" />
                <div :class="{ 'cursor-pointer': isAdmin }" @click="isAdmin ? openManageGroup() : null">
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
              <!-- Search Messages Button -->
              <BButton 
                variant="light" 
                size="sm" 
                class="rounded-circle p-2" 
                :class="{ 'bg-primary text-white': showSearchMessages }"
                @click="showSearchMessages = !showSearchMessages; if(!showSearchMessages) messageSearch = ''"
                v-b-tooltip.hover.bottom="'Search in conversation'"
              >
                <SearchIcon size="18" />
              </BButton>

              <template v-if="!chat.activeRoomId && activeUser">
                <BButton variant="light" size="sm" class="rounded-circle p-2" @click="initiateCall('audio')" v-b-tooltip.hover.bottom="'Audio Call'">
                  <PhoneIcon size="18" />
                </BButton>
                <BButton variant="light" size="sm" class="rounded-circle p-2" @click="initiateCall('video')" v-b-tooltip.hover.bottom="'Video Call'">
                  <VideoIcon size="18" />
                </BButton>
                <!-- Poke Button -->
                <BButton variant="warning" size="sm" class="rounded-circle p-2 shadow-sm" @click="chat.sendPoke(activeUser.id)" :disabled="chat.isShaking" v-b-tooltip.hover.bottom="'Poke User'">
                  <ZapIcon size="18" />
                </BButton>
              </template>
              <BDropdown variant="light" size="sm" no-caret rounded="circle">
                <template #button-content>
                  <MoreVerticalIcon size="18" />
                </template>
                <template v-if="!chat.activeRoomId && activeUser">
                  <BDropdownItem @click="handleToggleBlock" :class="{ 'text-danger': !isBlockedByMe }">
                    <BanIcon size="16" class="me-2" /> {{ isBlockedByMe ? 'Unblock User' : 'Block User' }}
                  </BDropdownItem>
                  <BDropdownItem @click="showUserInfoModal = true">
                    <InfoIcon size="16" class="me-2 text-primary" /> User Info
                  </BDropdownItem>
                </template>
                <template v-else-if="chat.activeRoomId">
                    <BDropdownItem @click="showRoomInfoModal = true">
                      <InfoIcon size="16" class="me-2 text-primary" /> Group Info
                    </BDropdownItem>
                    <BDropdownItem v-if="isAdmin" @click="openManageGroup">
                      <SettingsIcon size="16" class="me-2 text-primary" /> Manage Group
                    </BDropdownItem>
                    <BDropdownDivider />
                    <BDropdownItem @click="handleLeaveGroup" class="text-danger">
                      <LogOutIcon size="16" class="me-2" /> Leave Group
                    </BDropdownItem>
                </template>
              </BDropdown>
            </div>
          </div>

          <!-- Pinned Message Bar -->
          <div v-if="chat.pinnedMessage" class="px-4 py-2 bg-primary-subtle border-bottom d-flex align-items-center justify-content-between">
            <div class="d-flex align-items-center gap-2 overflow-hidden">
               <PinIcon size="18" class="text-primary me-2" />
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

          <!-- Search Messages Bar (Collapsible) -->
          <transition name="slide-fade">
            <div v-if="showSearchMessages" class="bg-white border-bottom p-3 shadow-sm">
              <BFormInput 
                v-model="messageSearch" 
                placeholder="Find in this conversation..." 
                class="rounded-pill border-0 bg-light px-4 py-2 shadow-none"
                autofocus
              />
            </div>
          </transition>

          <!-- Messages -->
          <div 
             class="flex-grow-1 overflow-auto overflow-x-hidden p-4 d-flex flex-column gap-3 bg-surface-secondary scroll-smooth" 
             ref="messageContainer" 
             @scroll="handleScroll"
          >
            <!-- Loading State -->
            <div v-if="chat.loadingMessages && chat.messages.length === 0" class="d-flex flex-column align-items-center justify-content-center h-100 opacity-50">
              <BSpinner variant="primary" label="Loading messages..." />
              <p class="mt-2 small">Loading your conversation...</p>
            </div>

            <template v-else>
              <div v-if="chat.isLoadingMore" class="text-center py-2">
                 <BSpinner small variant="primary" />
              </div>

              <!-- Empty State: No Messages -->
              <div v-if="filteredMessages.length === 0" class="d-flex flex-column align-items-center justify-content-center h-100 py-5 text-center">
                <div class="bg-white rounded-circle shadow-sm p-4 mb-4" style="width: 100px; height: 100px; display: flex; align-items: center; justify-content: center;">
                  <span class="fs-1">💬</span>
                </div>
                <h4 class="fw-bold mb-2">No messages here yet</h4>
                <p class="text-muted px-4" style="max-width: 300px;">
                  Send a message to start a conversation with <strong>{{ activeUser?.name || activeRoom?.name }}</strong>
                </p>
              </div>

              <template v-else v-for="msg in filteredMessages" :key="msg.id">
                <!-- System/Activity Message -->
                <div v-if="msg.type === 'system'" class="d-flex justify-content-center my-3 w-100">
                  <span class="badge bg-light text-muted border py-2 px-3 rounded-pill fw-normal shadow-sm">
                    {{ msg.content }}
                  </span>
                </div>

                <!-- Regular Message -->
                <div 
                  v-else
                  :id="`msg-${msg.id}`"
                  v-memo="[msg.id, msg.content, msg.is_read, msg.reactions?.length, msg.is_edited, msg.is_deleted_everyone, chat.activeUserId]"
                  class="message-wrapper d-flex mb-3 group align-items-end gap-2"
                  :class="String(msg.senderId) === String(auth.user?.id) ? 'flex-row-reverse' : 'flex-row'"
                >
                  <!-- Message Avatar -->
                  <BAvatar 
                    size="2.5rem" 
                    :src="String(msg.senderId) === String(auth.user?.id) ? getProfileImageUrl(auth.user) : (msg.roomId ? getProfileImageUrl(msg.sender) : (activeUser ? getProfileImageUrl(activeUser) : null))" 
                    :text="String(msg.senderId) === String(auth.user?.id) ? auth.user?.name?.charAt(0) : (msg.roomId ? msg.sender?.name?.charAt(0) : (activeUser ? activeUser.name?.charAt(0) : 'U'))"
                    variant="light"
                    class="flex-shrink-0 shadow-sm border border-white mb-1"
                  />
  
                  <div 
                    class="message px-3 py-2 shadow-sm max-w-75 position-relative group"
                    :class="String(msg.senderId) === String(auth.user?.id) ? 'message-me bg-slate shadow-blue text-white' : 'message-them border text-dark'"
                    :style="String(msg.senderId) === String(auth.user?.id) ? 'border-radius: 1.25rem 1.25rem 0.25rem 1.25rem;' : 'border-radius: 1.25rem 1.25rem 1.25rem 0.25rem;'"
                  >
                    <div v-if="msg.roomId && String(msg.senderId) !== String(auth.user?.id)" class="small fw-bold mb-1" :style="{ color: getUserColor(msg.sender?.name) }">
                      {{ msg.sender?.name }}
                    </div>
                    <!-- ChatVibe Style Message Actions -->
                    <div class="message-actions-overlay position-absolute top-0 start-50 opacity-0 invisible transition-all shadow rounded-pill bg-white border p-1 d-flex gap-1 no-wrap" 
                         style="z-index: 1000; transform: translateY(-110%) translateX(-50%); pointer-events: auto; white-space: nowrap; min-width: max-content;">
                        <BButton variant="link" size="sm" class="p-1 px-2 text-muted hover-primary border-0 shadow-none" v-b-tooltip.hover.top="'Forward'" @click="openForwardModal(msg)">
                          <ForwardIcon size="16" />
                        </BButton>
                        <BButton variant="link" size="sm" class="p-1 px-2 text-muted hover-primary border-0 shadow-none" v-b-tooltip.hover.top="'Reply'" @click="chat.replyTo = msg">
                          <ReplyIcon size="16" />
                        </BButton>
                        <BButton variant="link" size="sm" class="p-1 px-2 text-muted hover-primary border-0 shadow-none" v-b-tooltip.hover.top="'Copy Content'" @click="copyToClipboard(msg.content)">
                          <CopyIcon size="16" />
                        </BButton>
                        <BButton v-if="canEdit(msg)" variant="link" size="sm" class="p-1 px-2 text-muted hover-primary border-0 shadow-none" v-b-tooltip.hover.top="'Edit Message'" @click="startEditing(msg)">
                          <EditIcon size="16" />
                        </BButton>
                        <BButton v-if="!msg.is_deleted_everyone" variant="link" size="sm" class="p-1 px-2 text-muted hover-danger border-0 shadow-none" v-b-tooltip.hover.top="'Delete'" @click="messageToDelete = msg; showDeleteModal = true">
                          <TrashIcon size="16" />
                        </BButton>
                        
                        <BDropdown variant="link" size="sm" no-caret toggle-class="p-1 px-2 text-muted hover-primary border-0 shadow-none">
                          <template #button-content>
                            <MoreVerticalIcon size="16" />
                          </template>
                          <BDropdownItem @click="chat.togglePin(msg.id)">
                            <PinIcon size="14" class="me-2" /> {{ chat.pinnedMessage?.id === msg.id ? 'Unpin' : 'Pin' }}
                          </BDropdownItem>
                          <BDropdownItem @click="markAsUnread(msg)">
                            <MailOpenIcon size="14" class="me-2" /> Mark As Unread
                          </BDropdownItem>
                          <BDropdownItem @click="archiveChat(msg)">
                            <HistoryIcon size="14" class="me-2" /> Archive
                          </BDropdownItem>
                          <BDropdownItem @click="addToFavourites(msg)">
                            <HeartIcon size="14" class="me-2" /> Add To Favourites
                          </BDropdownItem>
                          <BDropdownDivider />
                          <div class="px-2 pb-1 d-flex justify-content-around gap-2">
                             <span v-for="e in ['👍','❤️','😂','🔥']" :key="e" class="cursor-pointer action-btn p-1 rounded hover-bg" @click="chat.toggleReaction(msg.id, e)">{{ e }}</span>
                          </div>
                        </BDropdown>
                    </div>

                  <!-- Reply Preview inside message -->
                  <div v-if="msg.reply_to" class="mb-2 p-2 rounded-3 bg-black bg-opacity-10 border-start border-3" :class="msg.senderId === auth.user?.id ? 'border-light-subtle' : 'border-primary'" style="cursor: pointer" @click="scrollToMessage(msg.reply_to_id)">
                    <small class="fw-bold d-block">{{ msg.reply_to.sender_id === auth.user?.id ? 'You' : (msg.reply_to.sender?.name || (activeUser ? activeUser.name : 'User')) }}</small>
                    <small class="text-truncate d-block opacity-75">{{ msg.reply_to.content }}</small>
                  </div>
                  <!-- Message Content -->
                  <div v-if="msg.is_deleted_everyone" class="fst-italic small d-flex align-items-center gap-2 py-1" :class="msg.senderId === auth.user?.id ? 'text-white-50' : 'text-muted'">
                     <span class="opacity-50">🚫</span> This message was deleted
                  </div>
                  <template v-else>
                    <!-- Forward Indicator -->
                    <div v-if="msg.is_forwarded" class="fst-italic opacity-75 mb-1 d-flex gap-1 align-items-center" style="font-size: 0.7rem;">
                      <span>⏩</span> <span>Forwarded</span>
                    </div>
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
                        <template v-else>
                          <!-- Link Preview -->
                          <div v-if="msg.link_metadata && (msg.link_metadata.title || msg.link_metadata.image || msg.link_metadata.description)" class="link-preview mb-2 rounded-3 overflow-hidden border bg-white text-dark" style="max-width: 100%;">
                            <a :href="msg.link_metadata.url" target="_blank" class="text-decoration-none d-block">
                              <div v-if="msg.link_metadata.image" class="preview-image overflow-hidden bg-light d-flex align-items-center justify-content-center" style="min-height: 100px;">
                                <img :src="msg.link_metadata.image" class="w-100" style="max-height: 200px; object-fit: cover;" @error="msg.link_metadata.image = null" />
                              </div>
                              <div class="p-2">
                                <div v-if="msg.link_metadata.title" class="fw-bold extra-small text-truncate mb-1">{{ msg.link_metadata.title }}</div>
                                <div v-if="msg.link_metadata.description" class="text-muted extra-small text-truncate-2 mb-1" style="font-size: 0.65rem;">{{ msg.link_metadata.description }}</div>
                                <div class="text-primary text-truncate opacity-75 mt-0 d-flex align-items-center gap-1" style="font-size: 0.6rem;">
                                  <span>🔗</span> {{ msg.link_metadata.url }}
                                </div>
                              </div>
                            </a>
                          </div>
                          <div class="message-text" :class="{ 'link-only': msg.content === msg.link_metadata?.url }">{{ msg.content }}</div>
                        </template>
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

                  <!-- Reactions Display (ChatVibe Style) -->
                  <div v-if="msg.reactions && msg.reactions.length" class="reactions-container position-absolute bottom-0 d-flex gap-1 flex-wrap shadow-sm" 
                       :style="String(msg.senderId) === String(auth.user?.id) ? 'left: 0; transform: translateY(50%) translateX(-10%);' : 'right: 0; transform: translateY(50%) translateX(10%);'"
                       style="z-index: 50;">
                    <span v-for="(emoji, group) in groupReactions(msg.reactions)" :key="group" class="badge rounded-pill bg-white text-dark border px-2 py-1 pulse-subtle" style="font-size: 0.7rem; cursor: pointer" @click="chat.toggleReaction(msg.id, group)">
                      {{ group }} <span v-if="emoji.count > 1" class="ms-1 fw-bold">{{ emoji.count }}</span>
                    </span>
                  </div>
                </div>
              </div>
            </template>

               <!-- Typing Animation (only in 1-to-1 chat when activeUser exists) -->
              <div v-if="activeUser && chat.typingUsers[String(activeUser.id)]" class="message-wrapper d-flex justify-content-start align-items-end gap-2 mt-2">
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
          <div class="p-3 p-md-4 input-area-premium">
              <div v-if="blockStatus.is_blocked" class="text-center p-3 rounded-3 bg-light border dashed">
                <span class="text-muted small fw-bold">
                   <span v-if="blockStatus.blocked_by_me">You have blocked this user. Unblock them to send messages.</span>
                   <span v-else>This user has blocked you or communication is unavailable.</span>
                </span>
              </div>
              
              <!-- Reply Preview -->
              <div v-if="chat.replyTo" class="mx-0 mb-2 p-2 rounded-3 bg-light border-start border-primary border-4 d-flex justify-content-between align-items-center">
                <div class="overflow-hidden">
                  <small class="fw-bold text-primary d-block">Replying to {{ chat.replyTo.senderId === auth.user?.id ? 'yourself' : (chat.replyTo.sender?.name || (activeUser ? activeUser.name : 'Unknown')) }}</small>
                  <small class="text-muted text-truncate d-block">{{ chat.replyTo.content }}</small>
                </div>
                <BButton variant="link" size="sm" class="text-decoration-none text-danger p-0 px-2" @click="chat.replyTo = null">✕</BButton>
              </div>

              <!-- Input Link Preview -->
              <div v-if="inputLinkPreview" class="mx-0 mb-2 p-2 rounded-3 bg-white border d-flex gap-3 align-items-center position-relative shadow-sm overflow-hidden">
                  <div v-if="inputLinkPreview.loading" class="d-flex align-items-center justify-content-center bg-light rounded" style="width: 60px; height: 60px;">
                      <BSpinner small variant="primary" />
                  </div>
                  <div v-else-if="inputLinkPreview.image" class="rounded overflow-hidden flex-shrink-0" style="width: 60px; height: 60px;">
                      <img :src="inputLinkPreview.image" class="w-100 h-100" style="object-fit: cover;" @error="inputLinkPreview.image = null" />
                  </div>
                  <div class="flex-grow-1 overflow-hidden">
                      <div class="fw-bold small text-truncate mb-0">
                        {{ inputLinkPreview.loading ? 'Fetching link preview...' : (inputLinkPreview.title || 'Link Preview') }}
                      </div>
                      <div class="text-muted extra-small text-truncate mb-0">{{ inputLinkPreview.url }}</div>
                  </div>
                  <BButton variant="light" size="sm" class="rounded-circle p-1 ms-2" @click="inputLinkPreview = null">✕</BButton>
              </div>

              <BForm v-if="!blockStatus.is_blocked" @submit.prevent="handleSend" class="d-flex gap-2 align-items-center position-relative">
                <div class="emoji-picker-container" v-if="showEmojiPicker">
                  <EmojiPicker :native="true" @select="onSelectEmoji" theme="light" />
                </div>
                
                <div class="d-flex gap-2">
                  <BButton variant="light" @click="showEmojiPicker = !showEmojiPicker" class="rounded-circle p-2 shadow-none border-0 text-muted hover-primary">
                    <SmileIcon size="20" />
                  </BButton>

                  <div class="media-upload">
                    <input type="file" ref="fileInput" class="d-none" @change="onFileSelected" />
                    <BButton variant="light" @click="$refs.fileInput.click()" class="rounded-circle p-2 shadow-none border-0 text-muted hover-primary" :disabled="uploading">
                      <BSpinner small v-if="uploading" />
                      <PaperclipIcon v-else size="20" />
                    </BButton>
                  </div>
                </div>

                <BFormInput 
                  ref="newMessageInput"
                  v-model="newMessage" 
                  placeholder="Type a message..." 
                  class="flex-grow-1 rounded-pill border-0 bg-surface-secondary px-4 py-2 shadow-none"
                  @input="handleTyping"
                  @focus="showEmojiPicker = false"
                />
                <BButton type="submit" variant="primary" class="rounded-circle d-flex align-items-center justify-content-center p-0 shadow-sm transition-all hover-bounce" style="width: 44px; height: 44px;">
                  <SendHorizontalIcon size="20" class="ms-1" />
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
  <BModal v-model="showPreview" :title="previewName" size="xl" :hide-footer="true" centered body-class="p-0 overflow-hidden">
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
  <BModal 
    v-model="showDeleteModal" 
    title="Delete message?" 
    centered 
    :hide-footer="true" 
    footer-class="d-none"
    dialog-class="modal-zoom-in"
    header-class="border-0 pb-0" 
    body-class="p-4" 
    size="sm"
  >
    <template #modal-footer></template>
    <div class="mb-4">
      <p class="text-muted small">Are you sure you want to delete this message?</p>
    </div>
    <div class="d-flex flex-column gap-2">
      <BButton variant="outline-danger" class="rounded-3 py-2 fw-bold w-100 whatsapp-btn" @click="confirmingDeleteMessage('me')">
        Delete for me
      </BButton>
      <BButton v-if="messageToDelete?.senderId === auth.user?.id" variant="danger" class="rounded-3 py-2 fw-bold w-100 whatsapp-btn" @click="confirmingDeleteMessage('everyone')">
        Delete for everyone
      </BButton>
      <BButton variant="light" class="rounded-3 py-2 mt-1 w-100 whatsapp-btn" @click="showDeleteModal = false">
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

  <BModal v-model="showIncomingCall" title="Incoming Call" centered :hide-footer="true" no-close-on-backdrop>
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

  <BModal v-model="showUserInfoModal" title="User Information" centered :hide-footer="true" footer-class="d-none" header-bg-variant="primary" header-text-variant="white">
    <template #modal-footer></template>
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

  <!-- Manage Group Modal -->
  <BModal v-model="showManageGroupModal" title="Manage Group" centered :hide-footer="true" footer-class="d-none" size="lg" scrollable>
    <template #modal-header>
      <div class="d-flex align-items-center gap-2">
        <SettingsIcon size="20" class="text-primary" />
        <h5 class="mb-0 fw-bold">Manage Group</h5>
      </div>
      <BButton variant="link" class="ms-auto p-0 border-0 text-muted" @click="showManageGroupModal = false">
        <XIcon size="20" />
      </BButton>
    </template>
    <template #modal-footer></template>
    <div v-if="activeRoom" class="p-3">
      <!-- Edit Name Section -->
      <div class="mb-4">
        <label class="form-label fw-bold">Group Name</label>
        <div class="d-flex gap-2">
          <BFormInput v-model="editedGroupName" placeholder="Enter group name" class="rounded-pill px-3" />
          <BButton variant="primary" class="rounded-pill px-4 fw-bold" @click="handleUpdateGroup" :disabled="!editedGroupName.trim() || editedGroupName === activeRoom.name">
            Save
          </BButton>
        </div>
      </div>

      <hr />

      <!-- Members Section -->
      <div class="mb-4">
        <div class="d-flex justify-content-between align-items-center mb-3">
          <h6 class="fw-bold mb-0">Group Members ({{ activeRoom.members.length }})</h6>
        </div>
        
        <div class="user-list-inline mb-3 border rounded-4 p-2 bg-light" style="max-height: 250px; overflow-y: auto;">
          <div v-for="member in activeRoom.members" :key="member.id" class="d-flex align-items-center justify-content-between p-2 hover-bg rounded-3">
            <div class="d-flex align-items-center gap-3">
              <BAvatar :src="getProfileImageUrl(member)" :text="member.name.charAt(0)" size="2.5rem" />
              <div>
                <div class="fw-bold fw-bold">{{ member.name }}</div>
                <small class="text-muted">{{ member.pivot?.role }}</small>
              </div>
            </div>
            <BButton 
              v-if="member.id !== auth.user?.id && isAdmin" 
              variant="outline-danger" 
              size="sm" 
              class="rounded-pill px-3"
              @click="handleRemoveMember(member.id)"
            >
              Remove
            </BButton>
            <BBadge v-else-if="member.id === auth.user?.id" variant="secondary" pill>You</BBadge>
          </div>
        </div>

        <div v-if="isAdmin" class="mt-4 pt-3 border-top">
          <h6 class="fw-bold mb-3">Add New Members</h6>
          <div class="user-selection-list mb-3" style="max-height: 200px; overflow-y: auto;">
             <div 
               v-for="user in availableUsersToAdd" 
               :key="user.id" 
               class="d-flex align-items-center gap-3 p-2 rounded-3 cursor-pointer mb-1 transition-all"
               @click="toggleAddMember(user.id)"
               :class="membersToAdd.includes(user.id) ? 'bg-primary-subtle' : 'hover-bg'"
             >
               <BFormCheckbox :model-value="membersToAdd.includes(user.id)" />
               <BAvatar :src="getProfileImageUrl(user)" :text="user.name.charAt(0)" size="2rem" />
               <span class="fw-bold small">{{ user.name }}</span>
             </div>
          </div>
          <BButton 
            variant="success" 
            class="w-100 rounded-pill fw-bold py-2 d-flex align-items-center justify-content-center gap-2 shadow-sm" 
            @click="handleAddMembers" 
            :disabled="membersToAdd.length === 0"
          >
            <UserPlusIcon size="18" /> Add Selected Members
          </BButton>
        </div>
      </div>

      <div class="mt-4 pt-3 border-top d-flex gap-2">
        <BButton variant="outline-danger" class="flex-grow-1 rounded-pill fw-bold" @click="handleLeaveGroup">
          <LogOutIcon size="18" class="me-2" /> Leave Group
        </BButton>
        <BButton variant="secondary" class="flex-grow-1 rounded-pill" @click="showManageGroupModal = false">
          Close
        </BButton>
      </div>
    </div>
  </BModal>

  <!-- Group Info Modal (For all members) -->
  <BModal v-model="showRoomInfoModal" title="Group Info" centered :hide-footer="true" footer-class="d-none" scrollable>
    <template #modal-footer></template>
    <div v-if="activeRoom" class="p-3">
      <div class="text-center mb-4">
        <BAvatar :text="activeRoom.name.charAt(0)" variant="primary" size="6rem" class="shadow mb-3" />
        <h4 class="fw-bold mb-1">{{ activeRoom.name }}</h4>
        <p class="text-muted small">{{ activeRoom.members.length }} members</p>
      </div>

      <div v-if="activeRoom.description" class="mb-4 bg-light p-3 rounded-4">
        <small class="text-uppercase fw-bold text-muted d-block mb-1" style="font-size: 0.7rem;">Description</small>
        <p class="mb-0">{{ activeRoom.description }}</p>
      </div>

      <h6 class="fw-bold mb-3">Participants</h6>
      <div class="user-list-inline mb-4 border rounded-4 p-2 bg-light" style="max-height: 300px; overflow-y: auto;">
        <div v-for="member in activeRoom.members" :key="member.id" class="d-flex align-items-center justify-content-between p-2">
          <div class="d-flex align-items-center gap-3">
            <BAvatar :src="getProfileImageUrl(member)" :text="member.name.charAt(0)" size="2.5rem" />
            <div>
              <div class="fw-bold small">{{ member.name }}</div>
              <small class="text-muted">{{ member.pivot?.role }}</small>
            </div>
          </div>
          <BBadge v-if="member.id === auth.user?.id" variant="secondary" pill>You</BBadge>
        </div>
      </div>

      <div class="d-grid gap-2">
        <BButton variant="outline-danger" class="rounded-pill fw-bold" @click="handleLeaveGroup">
          <LogOutIcon size="18" class="me-2" /> Leave Group
        </BButton>
        <BButton variant="light" class="rounded-pill" @click="showRoomInfoModal = false">
          Close
        </BButton>
      </div>
    </div>
  </BModal>

  <!-- Group Call Invite Modal -->
  <BModal v-model="showGroupInviteModal" title="Start Group Call" centered hide-footer scrollable>
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
  <BModal v-model="showScreenShareInvite" title="Secure Screen Sharing" centered :hide-footer="true" no-close-on-backdrop>
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
  <BModal v-model="showScreenShareJoin" title="Join Screen Share" centered :hide-footer="true" no-close-on-backdrop>
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
  
  <!-- Vault Encryption Modal -->
  <BModal v-model="showVaultModal" title="Message Vault" :hide-footer="true" footer-class="d-none" centered header-bg-variant="primary" header-text-variant="white">
    <div class="p-3 text-center">
      <div class="mb-4">
        <div class="bg-primary-subtle rounded-circle d-inline-flex p-4 mb-3">
          <span class="fs-1">🔒</span>
        </div>
        <h5 class="fw-bold">Setup End-to-End Encryption</h5>
        <p class="text-muted small">Enter a secret key to encrypt your messages. This key never leaves your browser.</p>
      </div>

      <BFormGroup label="Passphrase / Key" class="text-start fw-bold mb-4">
        <BFormInput 
          v-model="tempVaultKey" 
          type="password" 
          placeholder="Enter secret key..." 
          class="rounded-3 py-2 px-3 border-0 bg-light shadow-none"
        />
        <small class="text-muted mt-1 d-block fw-normal">Messages will be encrypted/decrypted using this key.</small>
      </BFormGroup>

      <div class="d-grid gap-2">
        <BButton variant="primary" size="lg" pill class="fw-bold" @click="saveVaultKey">
          {{ chat.vaultKey ? 'Update Key' : 'Enable Encryption' }}
        </BButton>
        <BButton v-if="chat.vaultKey" variant="link" class="text-danger" @click="chat.clearVaultKey(); showVaultModal = false">
          Disable Encryption
        </BButton>
        <BButton variant="light" pill @click="showVaultModal = false">Close</BButton>
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

  <!-- Forward Message Modal -->
  <BModal v-model="showForwardModal" title="Forward Message" :hide-footer="true" centered>
    <div class="p-3">
      <BFormInput 
        v-model="forwardSearch" 
        placeholder="Search contacts or groups..." 
        class="mb-3 rounded-pill bg-light border-0 shadow-none px-3 py-2"
      />
      <div style="max-height: 350px; overflow-y: auto;" class="custom-scrollbar pr-2">
        <template v-if="forwardFilteredUsers.length > 0">
          <h6 class="text-muted small fw-bold mb-2">Users</h6>
          <div 
            v-for="user in forwardFilteredUsers" 
            :key="'user-'+user.id" 
            class="d-flex justify-content-between align-items-center mb-2 p-2 rounded hover-bg-light cursor-pointer border"
            @click="toggleForwardSelection(user.id, false)"
          >
            <div class="d-flex align-items-center gap-2">
              <BFormCheckbox 
                  :checked="isTargetSelected(user.id, false)" 
                  @change="toggleForwardSelection(user.id, false)" 
                  @click.stop 
               />
              <BAvatar :src="getProfileImageUrl(user)" :text="user.name.charAt(0)" size="sm" variant="info" />
              <span class="fw-bold">{{ user.name }}</span>
            </div>
          </div>
        </template>
        
        <template v-if="forwardFilteredRooms.length > 0">
          <h6 class="text-muted small fw-bold mt-4 mb-2">Groups</h6>
          <div 
            v-for="room in forwardFilteredRooms" 
            :key="'room-'+room.id" 
            class="d-flex justify-content-between align-items-center mb-2 p-2 rounded hover-bg-light cursor-pointer border"
            @click="toggleForwardSelection(room.id, true)"
          >
            <div class="d-flex align-items-center gap-2">
              <BFormCheckbox 
                  :checked="isTargetSelected(room.id, true)" 
                  @change="toggleForwardSelection(room.id, true)" 
                  @click.stop 
               />
              <div class="bg-primary bg-opacity-10 text-primary d-flex align-items-center justify-content-center rounded-circle" style="width: 30px; height: 30px; flex-shrink: 0;">
                <span class="fw-bold">{{ room.name.charAt(0).toUpperCase() }}</span>
              </div>
              <span class="fw-bold">{{ room.name }}</span>
            </div>
          </div>
        </template>

        <div v-if="forwardFilteredUsers.length === 0 && forwardFilteredRooms.length === 0" class="text-center text-muted p-4">
            No contacts or groups found.
        </div>
      </div>
      
      <div v-if="selectedForwardTargets.length > 0" class="mt-3 pt-3 border-top text-end">
         <BButton variant="primary" pill class="fw-bold px-4 shadow-sm" @click="forwardToSelected" :disabled="forwarding">
             <BSpinner small v-if="forwarding" class="me-1" />
             Send to {{ selectedForwardTargets.length }} {{ selectedForwardTargets.length === 1 ? 'chat' : 'chats' }}
         </BButton>
      </div>
    </div>
  </BModal>
</template>

<script setup>
import { 
  ref, onMounted, computed, watch, nextTick 
} from 'vue'
import { 
  Search as SearchIcon, 
  Phone as PhoneIcon, 
  Video as VideoIcon, 
  Zap as ZapIcon, 
  Forward as ForwardIcon, 
  Reply as ReplyIcon, 
  Copy as CopyIcon, 
  Edit as EditIcon, 
  Trash as TrashIcon,
  MoreVertical as MoreVerticalIcon,
  Pin as PinIcon,
  MailOpen as MailOpenIcon,
  History as HistoryIcon,
  Heart as HeartIcon,
  ArrowLeft as ArrowLeftIcon,
  LogOut as LogOutIcon,
  Monitor as MonitorIcon,
  Shield as ShieldIcon,
  Users as UsersIcon,
  Info as InfoIcon,
  Ban as BanIcon,
  Settings as SettingsIcon,
  UserPlus as UserPlusIcon,
  X as XIcon,
  Smile as SmileIcon,
  Paperclip as PaperclipIcon,
  SendHorizontal as SendHorizontalIcon
} from 'lucide-vue-next'
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

const sidebarMode = ref('users') // 'users', 'groups', 'unread'
const showNewGroupModal = ref(false)
const groupName = ref('')
const selectedGroupMembers = ref([])

const unreadList = computed(() => {
  const users = chat.users.filter(u => chat.unreadCounts['user_' + u.id] > 0 || u.is_unread_manual).map(u => ({ ...u, isUser: true }))
  const rooms = chat.rooms.filter(r => chat.unreadCounts['room_' + r.id] > 0 || r.is_unread_manual).map(r => ({ ...r, isUser: false }))
  return [...users, ...rooms]
})

const archivedList = computed(() => {
  const users = chat.users.filter(u => u.is_archived).map(u => ({ ...u, isUser: true }))
  const rooms = chat.rooms.filter(r => r.is_archived).map(r => ({ ...r, isUser: false }))
  return [...users, ...rooms]
})

const showRoomInfoModal = ref(false)
const newGroupName = ref('')
const selectedMembersForNewGroup = ref([])

const showVaultModal = ref(false)
const tempVaultKey = ref('')

function saveVaultKey() {
    if (!tempVaultKey.value.trim()) {
        showToast({ title: 'Error', body: 'Please enter a valid key.', variant: 'danger' })
        return
    }
    chat.setVaultKey(tempVaultKey.value)
    showVaultModal.value = false
    tempVaultKey.value = ''
    showToast({ title: 'Vault Updated', body: 'Your encryption key has been set securely.', variant: 'success' })
}

// State for Document Preview
const showPreview = ref(false)
const previewUrl = ref('')
const previewType = ref('')
const previewName = ref('')

const newMessage = ref('')
const userSearch = ref('')
const messageSearch = ref('')
const showSearchMessages = ref(false)
const inputLinkPreview = ref(null)
const linkDetectionTimeout = ref(null)
const currentRequestId = ref(0) // To prevent race conditions

// Forward State
const showForwardModal = ref(false)
const forwardMessageItem = ref(null)
const forwardSearch = ref('')
const selectedForwardTargets = ref([]) // Array of { id, isRoom }
const forwarding = ref(false)

const forwardFilteredUsers = computed(() => {
    let s = forwardSearch.value.toLowerCase();
    const allUsers = chat.users.filter(u => String(u.id) !== String(auth.user?.id));
    if(!s) return allUsers;
    return allUsers.filter(u => u.name.toLowerCase().includes(s));
});

const forwardFilteredRooms = computed(() => {
    let s = forwardSearch.value.toLowerCase();
    if(!s) return chat.rooms;
    return chat.rooms.filter(r => r.name.toLowerCase().includes(s));
});

function openForwardModal(msg) {
    forwardMessageItem.value = msg;
    forwardSearch.value = '';
    selectedForwardTargets.value = [];
    showForwardModal.value = true;
}

function isTargetSelected(id, isRoom) {
    return selectedForwardTargets.value.some(t => String(t.id) === String(id) && t.isRoom === isRoom);
}

function toggleForwardSelection(id, isRoom) {
    const idx = selectedForwardTargets.value.findIndex(t => String(t.id) === String(id) && t.isRoom === isRoom);
    if (idx !== -1) {
        selectedForwardTargets.value.splice(idx, 1);
    } else {
        selectedForwardTargets.value.push({ id, isRoom });
    }
}

async function forwardToSelected() {
    if(!forwardMessageItem.value || selectedForwardTargets.value.length === 0) return;
    
    forwarding.value = true;
    
    try {
        const msg = forwardMessageItem.value;
        const promises = selectedForwardTargets.value.map(target => {
            const recipientId = target.isRoom ? null : target.id;
            const roomId = target.isRoom ? target.id : null;
            
            return chat.sendMessage(
                recipientId, 
                msg.content, 
                msg.type, 
                msg.fileName, 
                null, // Do not preserve reply-to reference when forwarding
                roomId,
                true // isForwarded
            );
        });
        
        await Promise.all(promises);
        
        showToast({ title: 'Success', body: `Message forwarded to ${selectedForwardTargets.value.length} chats.`, variant: 'success' });
        showForwardModal.value = false;
    } catch(err) {
        console.error('Failed to forward', err);
        showToast({ title: 'Error', body: 'Some forwards failed.', variant: 'danger' });
    } finally {
        forwarding.value = false;
    }
}

const activeUser = computed(() => {
    return chat.users.find(u => String(u.id) === String(chat.activeUserId)) || null
})
const activeRoom = computed(() => chat.rooms.find(r => r.id === chat.activeRoomId))

const copyToClipboard = async (text) => {
  if (navigator.clipboard && window.isSecureContext) {
    try {
      await navigator.clipboard.writeText(text)
      showToast({ title: 'Copied', body: 'Message copied to clipboard', variant: 'success' })
      return
    } catch (err) {
      console.error('Clipboard API failed, trying fallback', err)
    }
  }
  
  // Fallback for non-secure context
  const textArea = document.createElement("textarea")
  textArea.value = text
  textArea.style.position = "fixed"
  textArea.style.left = "-9999px"
  textArea.style.top = "0"
  document.body.appendChild(textArea)
  textArea.focus()
  textArea.select()
  
  try {
    const successful = document.execCommand('copy')
    if (successful) {
      showToast({ title: 'Copied', body: 'Message copied to clipboard', variant: 'success' })
    } else {
      showToast({ title: 'Error', body: 'Copy command failed', variant: 'danger' })
    }
  } catch (err) {
    showToast({ title: 'Error', body: 'Fallback copy failed', variant: 'danger' })
  }
  document.body.removeChild(textArea)
}

const markAsUnread = async () => {
    const isRoom = !!chat.activeRoomId
    const targetId = chat.activeRoomId || chat.activeUserId
    if (!targetId) return
    
    // Determine current status
    let currentStatus = false
    if (isRoom) {
        const room = chat.rooms.find(r => String(r.id) === String(targetId))
        currentStatus = room?.is_unread_manual || false
    } else {
        const user = chat.users.find(u => String(u.id) === String(targetId))
        currentStatus = user?.is_unread_manual || false
    }

    const newStatus = !currentStatus
    await chat.toggleUnread(targetId, isRoom, newStatus)
    showToast({ 
        title: newStatus ? 'Marked Unread' : 'Marked Read', 
        body: newStatus ? 'Conversation marked as unread' : 'Conversation marked as read', 
        variant: 'info' 
    })
}

const archiveChat = async () => {
    const isRoom = !!chat.activeRoomId
    const targetId = chat.activeRoomId || chat.activeUserId
    if (!targetId) return
    
    const res = await chat.toggleArchive(targetId, isRoom)
    showToast({ 
        title: res ? 'Archived' : 'Unarchived', 
        body: res ? 'Chat moved to archive' : 'Chat restored from archive', 
        variant: 'info' 
    })
    
    if (res) {
        // Deselect chat if archived
        activeUser.value = null
        chat.activeRoomId = null
    }
}

const addToFavourites = async () => {
    const isRoom = !!chat.activeRoomId
    const targetId = chat.activeRoomId || chat.activeUserId
    if (!targetId) return
    
    const res = await chat.toggleFavourite(targetId, isRoom)
    showToast({ 
        title: 'Favourites', 
        body: res ? 'Added to favourites' : 'Removed from favourites', 
        variant: res ? 'success' : 'info' 
    })
}

// Placeholder removed - using real forward modal

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

// Group Management State
const showManageGroupModal = ref(false)
const editedGroupName = ref('')
const editedGroupDescription = ref('')
const membersToAdd = ref([])

const isAdmin = computed(() => {
    if (!activeRoom.value) return false
    const me = activeRoom.value.members.find(m => String(m.id) === String(auth.user?.id))
    return me?.pivot?.role === 'admin'
})

const availableUsersToAdd = computed(() => {
    if (!activeRoom.value) return []
    const memberIds = activeRoom.value.members.map(m => m.id)
    return chat.users.filter(u => !memberIds.includes(u.id))
})

function openManageGroup() {
    if (!activeRoom.value) return
    editedGroupName.value = activeRoom.value.name
    editedGroupDescription.value = activeRoom.value.description || ''
    membersToAdd.value = []
    showManageGroupModal.value = true
}

async function handleUpdateGroup() {
    try {
        await chat.updateRoom(chat.activeRoomId, editedGroupName.value, editedGroupDescription.value)
    } catch (err) {
        alert('Failed to update group: ' + err.message)
    }
}

function toggleAddMember(userId) {
    const idx = membersToAdd.value.indexOf(userId)
    if (idx > -1) membersToAdd.value.splice(idx, 1)
    else membersToAdd.value.push(userId)
}

async function handleAddMembers() {
    try {
        await chat.addRoomMembers(chat.activeRoomId, membersToAdd.value)
        membersToAdd.value = []
    } catch (err) {
        alert('Failed to add members: ' + err.message)
    }
}

async function handleRemoveMember(userId) {
    if (!confirm('Are you sure you want to remove this member?')) return
    try {
        await chat.removeRoomMember(chat.activeRoomId, userId)
    } catch (err) {
        alert('Failed to remove member: ' + err.message)
    }
}

async function handleLeaveGroup() {
    if (!confirm('Are you sure you want to leave this group?')) return
    try {
        await chat.leaveRoom(chat.activeRoomId)
        showManageGroupModal.value = false
        chat.activeRoomId = null
    } catch (err) {
        alert('Failed to leave group: ' + err.message)
    }
}

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
    endScreenShare
} = useScreenShare()

const showScreenShareInvite = ref(false)
const showScreenShareJoin = ref(false)
const enteredPasscode = ref('')
const enteredUsername = ref('')
const incomingScreenSender = ref(null)
const remoteScreenVideo = ref(null)

async function selectUser(user) {
    chat.activeUserId = user.id
    chat.activeRoomId = null
    sidebarMode.value = 'users'
    await chat.fetchHistory(user.id)
    scrollToBottom()
}

async function selectRoom(room) {
    chat.activeRoomId = room.id
    chat.activeUserId = null
    sidebarMode.value = 'groups'
    await chat.fetchHistory(room.id, true)
    scrollToBottom()
}

async function createGroup() {
    if (!newGroupName.value.trim() || selectedMembersForNewGroup.value.length === 0) return
    
    try {
        const config = useRuntimeConfig()
        const data = await $fetch(`${config.public.apiBase}/rooms`, {
            method: 'POST',
            body: {
                name: newGroupName.value,
                member_ids: selectedMembersForNewGroup.value,
                description: ''
            },
            headers: authHeaders()
        })
        
        await chat.fetchRooms()
        showNewGroupModal.value = false
        newGroupName.value = ''
        selectedMembersForNewGroup.value = []
        
        // Select the new room
        const newRoom = chat.rooms.find(r => r.id === data.id)
        if (newRoom) selectRoom(newRoom)
        
    } catch (err) {
        console.error('Failed to create group', err)
        alert('Failed to create group: ' + (err.response?._data?.message || err.message))
    }
}

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

// Scroll handler for infinite loading
async function handleScroll(e) {
    if (e.target.scrollTop === 0 && chat.hasMoreHistory && !chat.isLoadingMore) {
        // Save current scroll height to adjust after loading older messages
        const prevHeight = e.target.scrollHeight
        await chat.loadMoreHistory()
        
        nextTick(() => {
            const newHeight = e.target.scrollHeight
            e.target.scrollTop = newHeight - prevHeight
        })
    }
}

// Use store-managed users
const onlineUsers = computed(() => {
    return chat.users
        .filter(u => {
            const isOnline = chat.presence[String(u.id)] === 'online' && String(u.id) !== String(auth.user?.id)
            const matchesSearch = !userSearch.value || u.name.toLowerCase().includes(userSearch.value.toLowerCase())
            return isOnline && matchesSearch && !u.is_archived
        })
        .sort((a, b) => (b.is_favourite ? 1 : 0) - (a.is_favourite ? 1 : 0))
})

const offlineUsers = computed(() => {
    return chat.users
        .filter(u => {
            const isOffline = (!chat.presence[String(u.id)] || chat.presence[String(u.id)] === 'offline') && String(u.id) !== String(auth.user?.id)
            const matchesSearch = !userSearch.value || u.name.toLowerCase().includes(userSearch.value.toLowerCase())
            return isOffline && matchesSearch && !u.is_archived
        })
        .sort((a, b) => (b.is_favourite ? 1 : 0) - (a.is_favourite ? 1 : 0))
})

const filteredRooms = computed(() => {
    return chat.rooms
        .filter(r => {
            const matchesSearch = !userSearch.value || r.name.toLowerCase().includes(userSearch.value.toLowerCase())
            return matchesSearch && !r.is_archived
        })
        .sort((a, b) => (b.is_favourite ? 1 : 0) - (a.is_favourite ? 1 : 0))
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
        const targetId = chat.activeRoomId || activeUser.value.id
        await chat.sendMessage(
            chat.activeRoomId ? null : activeUser.value.id, 
            data.url, 
            data.type, 
            data.name, 
            null, 
            chat.activeRoomId
        )
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

function getUserColor(name) {
    if (!name) return '#000000'
    const colors = [
        '#1f2937', '#1d4ed8', '#7e22ce', '#be185d', 
        '#b91c1c', '#c2410c', '#15803d', '#0369a1'
    ]
    let hash = 0
    for (let i = 0; i < name.length; i++) {
        hash = name.charCodeAt(i) + ((hash << 5) - hash)
    }
    return colors[Math.abs(hash) % colors.length]
}

const filteredMessages = computed(() => {
    if (!chat.activeUserId && !chat.activeRoomId) return []
    
    let msgs = chat.messages

    if (showSearchMessages.value && messageSearch.value) {
        return msgs.filter(m => m.content?.toLowerCase().includes(messageSearch.value.toLowerCase()))
    }

    return msgs
})

async function handleSend() {
    if (!newMessage.value.trim() || (!activeUser.value && !activeRoom.value)) return
    
    try {
        const replyToId = chat.replyTo?.id
        const content = newMessage.value // local copy
        let linkMetadata = null
        if (inputLinkPreview.value && !inputLinkPreview.value.loading && inputLinkPreview.value.success !== false) {
            // Clone and strip flags
            linkMetadata = { ...inputLinkPreview.value }
            delete linkMetadata.loading
            delete linkMetadata.success
        }
        
        newMessage.value = '' // Clear early for better UX
        inputLinkPreview.value = null // Reset preview
        if (linkDetectionTimeout.value) clearTimeout(linkDetectionTimeout.value)

        await chat.sendMessage(
            chat.activeRoomId ? null : chat.activeUserId, 
            content, 
            'text', 
            null, 
            replyToId, 
            chat.activeRoomId,
            false, // isForwarded
            linkMetadata
        )
        scrollToBottom()
    } catch (err) {
        console.error('Failed to send', err)
    }
}

// Watch for links in input
watch(newMessage, (val) => {
    if (linkDetectionTimeout.value) clearTimeout(linkDetectionTimeout.value)
    
    if (!val || val.length < 5) {
        inputLinkPreview.value = null
        return
    }

    linkDetectionTimeout.value = setTimeout(async () => {
        const urlRegex = /(https?:\/\/[^\s]+)/i
        const match = val.match(urlRegex)
        
        if (match) {
            const url = match[0]
            if (inputLinkPreview.value?.url === url && !inputLinkPreview.value.loading) return
            
            const reqId = ++currentRequestId.value
            inputLinkPreview.value = { url, loading: true }

            // Safety timeout: if it takes > 10s, clear it
            const safetyTimeout = setTimeout(() => {
                if (currentRequestId.value === reqId && inputLinkPreview.value?.loading) {
                    inputLinkPreview.value = null
                }
            }, 10000)

            try {
                const data = await chat.fetchLinkMetadata(url)
                clearTimeout(safetyTimeout)

                if (currentRequestId.value === reqId) {
                    if (data && data.success !== false) {
                        inputLinkPreview.value = { ...data, loading: false }
                    } else {
                        inputLinkPreview.value = null
                    }
                }
            } catch (e) {
                if (currentRequestId.value === reqId) inputLinkPreview.value = null
            }
        } else {
            inputLinkPreview.value = null
        }
    }, 800)
})

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
    height: calc(100vh - 72px); 
    max-height: calc(100vh - 72px);
    overflow: hidden;
    background: #f1f5f9;
    box-shadow: inset 0 2px 10px rgba(0, 0, 0, 0.05); /* Inset shade for corners */
}

@media (max-width: 767.98px) {
    .chat-container {
        height: calc(100vh - 80px);
        max-height: calc(100vh - 80px);
        padding-left: 0 !important;
        padding-right: 0 !important;
    }
    .chat-wrapper {
        border-radius: 0 !important;
        border: none !important;
    }
}

.chat-wrapper {
    height: 100%;
    background: #ffffff;
    margin: 0;
    box-shadow: 0 0 30px rgba(0,0,0,0.04);
}

.input-area-premium {
    background: #ffffff;
    border-top: 1px solid rgba(0,0,0,0.06);
    box-shadow: 0 -5px 15px rgba(0,0,0,0.02);
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
    word-break: break-all;
    overflow-wrap: anywhere;
}

.message-me {
    color: white;
    border-radius: 18px 18px 4px 18px;
}

.message-them {
    border-radius: 18px 18px 18px 4px;
    background-color: #e2e8f0 !important;
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
  0%, 60%, 100% { transform: translateY(0); }
  30% { transform: translateY(-4px); }
}

.extra-small {
    font-size: 0.75rem;
}

.text-truncate-2 {
    display: -webkit-box;
    -webkit-line-clamp: 2;
    line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
}

.link-preview {
    transition: transform 0.2s ease;
    box-shadow: 0 1px 3px rgba(0,0,0,0.1);
}

.link-preview:hover {
    transform: translateY(-1px);
    box-shadow: 0 4px 6px rgba(0,0,0,0.1);
}

.highlight-pulse {
  animation: highlight-pulse 2s ease-out;
}

@keyframes highlight-pulse {
  0% { background-color: rgba(71, 85, 105, 0.2); }
  100% { background-color: transparent; }
}

.message:hover .message-actions-overlay {
  opacity: 1 !important;
  visibility: visible !important;
}

.hover-primary:hover {
  color: var(--primary) !important;
  background: var(--bg-surface-secondary);
}

.hover-danger:hover {
  color: var(--danger) !important;
  background: #fff5f5;
}

.link-preview {
  max-width: 300px;
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
.hover-bg:hover {
  background-color: rgba(0,0,0,0.05) !important;
}

.cursor-pointer {
  cursor: pointer;
}

/* Earthquake Shake Animation */
.earthquake-shake {
  animation: earthquake 0.1s infinite !important;
  background-color: rgba(220, 53, 69, 0.05) !important;
}

@keyframes earthquake {
  0% { transform: translate(0, 0) rotate(0); }
  20% { transform: translate(-10px, 5px) rotate(-1deg); }
  40% { transform: translate(10px, -5px) rotate(1deg); }
  60% { transform: translate(-10px, -2px) rotate(-0.5deg); }
  80% { transform: translate(10px, 2px) rotate(0.5deg); }
  100% { transform: translate(0, 0) rotate(0); }
}

.poke-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(220, 53, 69, 0.15);
  z-index: 9999;
  pointer-events: none;
  display: flex;
  align-items: center;
  justify-content: center;
  backdrop-filter: blur(2px);
}

.poke-text {
  font-size: 5rem;
  font-weight: 900;
  /* color: #dc3545; */
  text-shadow: 0 0 20px rgba(0,0,0,0.5), 0 0 40px rgba(220, 53, 69, 0.8);
  animation: poke-zoom 0.5s infinite;
  font-family: 'Inter', sans-serif;
}

@keyframes poke-zoom {
  0% { transform: scale(0.8); opacity: 0.8; }
  50% { transform: scale(1.2); opacity: 1; }
  100% { transform: scale(0.8); opacity: 0.8; }
}

/* Slide-Fade Transition for Search Message Bar */
.slide-fade-enter-active {
  transition: all 0.3s ease-out;
}
.slide-fade-leave-active {
  transition: all 0.2s cubic-bezier(1, 0.5, 0.8, 1);
}
.slide-fade-enter-from,
.slide-fade-leave-to {
  transform: translateY(-20px);
  opacity: 0;
}

/* Link Preview Styles */
.link-preview {
    transition: transform 0.2s ease, box-shadow 0.2s ease;
    cursor: pointer;
    background: #fff;
}

.link-preview:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 16px rgba(0,0,0,0.1);
}

.extra-small {
    font-size: 0.75rem;
}

.text-truncate-2 {
    display: -webkit-box;
    -webkit-line-clamp: 2;
    line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
}

.message-text.link-only {
    font-size: 0.85rem;
    opacity: 0.8;
    text-decoration: underline;
    text-underline-offset: 3px;
    word-break: break-all;
}

.preview-image img {
    background-color: #f1f5f9;
}

/* Modal Animations */
.modal-zoom-in .modal-content {
  animation: modal-zoom 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
}

@keyframes modal-zoom {
  from { opacity: 0; transform: scale(0.8); }
  to { opacity: 1; transform: scale(1); }
}

.whatsapp-btn {
  transition: all 0.2s ease-in-out;
}

.whatsapp-btn:hover {
  transform: scale(1.02);
  filter: brightness(0.95);
}

.whatsapp-btn:active {
  transform: scale(0.98);
}
</style>

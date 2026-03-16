<template>
  <div>
    <BNavbar toggleable="lg" variant="white" class="navbar sticky-top">
      <BContainer class="d-flex align-items-center">
        <BNavbarBrand as="NuxtLink" to="/" class="fw-bold text-primary d-flex align-items-center me-auto">
          <div class="bg-primary rounded-circle me-2" style="width: 1rem; height: 1rem;"></div> MyVault
        </BNavbarBrand>

        <BNavbarToggle target="nav-collapse" class="border-0 ms-2" />

        <BCollapse id="nav-collapse" is-nav>
          <BNavbarNav class="ms-auto align-items-center">
            <template v-if="!auth.isLoggedIn">
              <NuxtLink to="/login" class="nav-link me-2">Login</NuxtLink>
              <BButton as="NuxtLink" to="/register" variant="primary" size="sm" class="px-4 fw-bold">Register</BButton>
            </template>
            <template v-else>
              <NuxtLink to="/home" class="nav-link me-2">Dashboard</NuxtLink>
              <BNavItemDropdown text="Features" right class="me-2">
                <BDropdownItem as="NuxtLink" to="/reminders">🔔 Reminders</BDropdownItem>
                <BDropdownItem as="NuxtLink" to="/documents">📄 Documents</BDropdownItem>
                <BDropdownItem as="NuxtLink" to="/medicines">💊 Medicines</BDropdownItem>
                <BDropdownItem as="NuxtLink" to="/bills">💡 Bills</BDropdownItem>
                <BDropdownItem as="NuxtLink" to="/notes">📋 Notes & To-Dos</BDropdownItem>
                <BDropdownItem as="NuxtLink" to="/vehicles">🚗 Vehicles</BDropdownItem>
                <BDropdownItem as="NuxtLink" to="/budget">📊 Budget</BDropdownItem>
                <BDropdownItem as="NuxtLink" to="/chat" class="d-flex align-items-center justify-content-between">
                  <span>💬 Live Chat</span>
                  <BBadge v-if="chat.totalUnreadCount > 0" variant="danger" pill class="ms-2">
                    {{ chat.totalUnreadCount }}
                  </BBadge>
                </BDropdownItem>
              </BNavItemDropdown>

              <NuxtLink to="/notifications" class="nav-link me-3 position-relative">
                <span class="fs-5">🔔</span>
                <BBadge v-if="notificationStore.unreadCount > 0" variant="danger" pill class="position-absolute top-0 start-100 translate-middle-x" style="font-size: 0.6rem; padding: 0.3em 0.5em;">
                  {{ notificationStore.unreadCount > 99 ? '99+' : notificationStore.unreadCount }}
                </BBadge>
              </NuxtLink>

              <BNavItemDropdown right>
                <template #button-content>
                  <span class="me-2">
                    <img
                      v-if="auth.profileImageUrl"
                      :src="auth.profileImageUrl"
                      alt="Profile"
                      class="rounded-circle"
                      style="width:2rem;height:2rem;object-fit:cover;border:2px solid #dee2e6;"
                    />
                    <BAvatar
                      v-else
                      variant="info"
                      size="2rem"
                      :text="auth.user?.name?.charAt(0)"
                    />
                  </span>
                  <span class="d-none d-md-inline">{{ auth.user?.name }}</span>
                </template>
                <BDropdownItem as="NuxtLink" to="/profile">👤 My Profile</BDropdownItem>
                <BDropdownDivider />
                <BDropdownItem @click="auth.logout()">🚪 Logout</BDropdownItem>
              </BNavItemDropdown>
            </template>
          </BNavbarNav>
        </BCollapse>
      </BContainer>
    </BNavbar>

    <main class="py-4">
      <slot />
    </main>

    <BToastOrchestrator />

    <!-- <footer class="bg-white py-5 mt-auto border-top">
      <BContainer class="text-center text-muted">
        <p class="mb-0">MyVault &copy; 2026. Your personal manager.</p>
      </BContainer>
    </footer> -->
  </div>
</template>

<script setup>
import { useAuthStore } from '~/stores/auth'
import { useChatStore } from '~/stores/chat'
import { useNotificationStore } from '~/stores/notification'

const auth = useAuthStore()
const chat = useChatStore()
const notificationStore = useNotificationStore()

onMounted(() => {
  auth.initialize()
  chat.init()
  notificationStore.fetchUnreadCount()
})
</script>

<template>
  <div class="app-wrapper min-vh-100 bg-light">
    <BNavbar toggleable="lg" variant="white" class="navbar sticky-top shadow-sm py-2">
      <BContainer fluid class="d-flex align-items-center px-md-5">
        <BNavbarBrand as="NuxtLink" to="/" class="fw-black text-primary d-flex align-items-center me-auto brand-logo">
          <div class="brand-pill me-2"></div> 
          <span>MyVault</span>
        </BNavbarBrand>

        <BNavbarToggle target="nav-collapse" class="border-0 ms-2" />

        <BCollapse id="nav-collapse" is-nav>
          <BNavbarNav class="ms-auto align-items-center gap-1">
            <template v-if="!auth.isLoggedIn">
              <NuxtLink to="/login" class="nav-link px-3 fw-semibold text-main">Login</NuxtLink>
              <BButton as="NuxtLink" to="/register" variant="primary" size="sm" class="px-4 fw-bold rounded-pill shadow-sm ms-2">Register</BButton>
            </template>
            <template v-else>
              <NuxtLink to="/home" class="nav-link px-3 fw-semibold d-flex align-items-center gap-2 hover-primary h-100">
                 <LayoutDashboardIcon size="18" />
                 <span class="lh-1">Dashboard</span>
              </NuxtLink>
              <BNavItemDropdown right class="me-2 fw-semibold d-flex align-items-center">
                <template #button-content>
                   <div class="d-flex align-items-center gap-2 lh-1">
                      <ZapIcon size="18" />
                      <span>Features</span>
                   </div>
                </template>
                <BDropdownItem as="NuxtLink" to="/reminders" class="d-flex align-items-center gap-2 py-2">
                   <BellIcon size="16" class="text-warning" /> <span>Reminders</span>
                </BDropdownItem>
                <BDropdownItem as="NuxtLink" to="/documents" class="d-flex align-items-center gap-2 py-2">
                   <FileTextIcon size="16" class="text-primary" /> <span>Documents</span>
                </BDropdownItem>
                <BDropdownItem as="NuxtLink" to="/medicines" class="d-flex align-items-center gap-2 py-2">
                   <PillIcon size="16" class="text-danger" /> <span>Medicines</span>
                </BDropdownItem>
                <BDropdownItem as="NuxtLink" to="/bills" class="d-flex align-items-center gap-2 py-2">
                   <CreditCardIcon size="16" class="text-success" /> <span>Bills</span>
                </BDropdownItem>
                <BDropdownItem as="NuxtLink" to="/notes" class="d-flex align-items-center gap-2 py-2">
                   <ClipboardListIcon size="16" class="text-info" /> <span>Notes & To-Dos</span>
                </BDropdownItem>
                <BDropdownItem as="NuxtLink" to="/vehicles" class="d-flex align-items-center gap-2 py-2">
                   <CarIcon size="16" class="text-secondary" /> <span>Vehicles</span>
                </BDropdownItem>
                <BDropdownItem as="NuxtLink" to="/budget" class="d-flex align-items-center gap-2 py-2">
                   <TrendingUpIcon size="16" class="text-primary" /> <span>Budget</span>
                </BDropdownItem>
                <BDropdownDivider />
                <BDropdownItem as="NuxtLink" to="/chat" class="d-flex align-items-center justify-content-between py-2">
                  <div class="d-flex align-items-center gap-2">
                     <MessageSquareIcon size="16" class="text-primary" />
                     <span>Live Chat</span>
                  </div>
                  <BBadge v-if="chat.totalUnreadCount > 0" variant="danger" pill class="ms-2">
                    {{ chat.totalUnreadCount }}
                  </BBadge>
                  <div v-else class="heartbeat ms-2"></div>
                </BDropdownItem>
              </BNavItemDropdown>

              <NuxtLink to="/notifications" class="nav-link px-3 position-relative text-muted hover-primary me-2 d-flex align-items-center h-100">
                <BellIcon size="20" />
                <BBadge v-if="notificationStore.unreadCount > 0" variant="danger" pill class="position-absolute top-0 start-100 translate-middle-x badge-overlap">
                  {{ notificationStore.unreadCount > 99 ? '99+' : notificationStore.unreadCount }}
                </BBadge>
              </NuxtLink>

              <BNavItemDropdown right no-caret>
                <template #button-content>
                  <div class="d-flex align-items-center gap-2 profile-trigger px-2 py-1 rounded-pill transition-all">
                    <img
                      v-if="auth.profileImageUrl"
                      :src="auth.profileImageUrl"
                      alt="Profile"
                      class="rounded-circle border"
                      style="width:2.2rem;height:2.2rem;object-fit:cover;"
                    />
                    <BAvatar
                      v-else
                      variant="info"
                      size="2.2rem"
                      class="shadow-sm"
                      :text="auth.user?.name?.charAt(0)"
                    />
                    <span class="d-none d-md-inline fw-bold text-main small">{{ auth.user?.name }}</span>
                    <ChevronDownIcon size="14" class="text-muted" />
                  </div>
                </template>
                <BDropdownItem as="NuxtLink" to="/profile" class="d-flex align-items-center gap-2 py-2">
                   <UserIcon size="16" /> <span>My Profile</span>
                </BDropdownItem>
                <BDropdownDivider />
                <BDropdownItem @click="auth.logout()" class="d-flex align-items-center gap-2 py-2 text-danger">
                   <LogOutIcon size="16" /> <span>Logout</span>
                </BDropdownItem>
              </BNavItemDropdown>
            </template>
          </BNavbarNav>
        </BCollapse>
      </BContainer>
    </BNavbar>

    <main class="content-area">
      <slot />
    </main>

    <BToastOrchestrator />
  </div>
</template>

<script setup>
import { 
  Bell as BellIcon,
  FileText as FileTextIcon,
  Pill as PillIcon,
  CreditCard as CreditCardIcon,
  ClipboardList as ClipboardListIcon,
  Car as CarIcon,
  TrendingUp as TrendingUpIcon,
  MessageSquare as MessageSquareIcon,
  User as UserIcon,
  LogOut as LogOutIcon,
  ChevronDown as ChevronDownIcon,
  LayoutDashboard as LayoutDashboardIcon,
  Zap as ZapIcon
} from 'lucide-vue-next'
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

<style>
  .fw-black { font-weight: 900; }
  .text-main { color: #1e293b; }
  .brand-logo { font-size: 1.4rem; letter-spacing: -0.04em; }
  .brand-logo:hover { color: var(--bs-primary) !important; text-decoration: none !important; }
  .brand-pill { background: var(--bs-primary); height: 1.25rem; width: 0.4rem; border-radius: 20px; transition: all 0.3s ease; }
  .brand-logo:hover .brand-pill { transform: scaleY(1.5); }
  .badge-overlap { font-size: 0.6rem; padding: 0.3em 0.55em; transform: translate(-30%, 10%) !important; border: 2px solid white; }
  .profile-trigger:hover { background: rgba(0,0,0,0.04); }
  .heartbeat { width: 8px; height: 8px; background: #10b981; border-radius: 50%; box-shadow: 0 0 0 rgba(16, 185, 129, 0.4); animation: pulse 2s infinite; }
  @keyframes pulse { 0% { box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.4); } 70% { box-shadow: 0 0 0 10px rgba(16, 185, 129, 0); } 100% { box-shadow: 0 0 0 0 rgba(16, 185, 129, 0); } }
  .hover-primary:hover { color: var(--bs-primary) !important; text-decoration: none !important; }
  .transition-all { transition: all 0.2s ease-in-out; }
  .nav-link { color: #64748b !important; display: flex; align-items: center; }
  .nav-link:hover { color: var(--bs-primary) !important; }
  .navbar-nav .nav-link { padding-top: 0 !important; padding-bottom: 0 !important; height: 100%; }
  .dropdown-toggle::after { vertical-align: middle !important; margin-left: 0.35rem !important; }
  .profile-trigger img, .profile-trigger .b-avatar { flex-shrink: 0; }
  .lh-1 { line-height: 1 !important; }
</style>

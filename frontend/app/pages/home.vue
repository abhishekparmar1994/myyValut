<template>
  <BContainer fluid class="px-md-5 py-5">
    <!-- Header Section -->
    <BRow class="mb-5 align-items-center animate-fadeIn">
      <BCol>
        <h1 class="fw-black text-main mb-1 text-uppercase tracking-tight">
          Welcome back, <span class="text-primary">{{ auth.user?.name }}</span>
        </h1>
        <p class="text-muted lead">Your personal dashboard — documents, reminders, and more.</p>
      </BCol>
    </BRow>

    <!-- Upcoming Reminders Panel (top) -->
    <BRow class="mb-4">
      <BCol>
        <BCard class="border-0 shadow-sm overflow-hidden">
          <template #header>
            <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center py-1">
              <h3 class="h6 fw-bold mb-2 mb-md-0 d-flex align-items-center gap-2 text-uppercase">
                <AlertTriangleIcon v-if="upcomingAlerts.length > 0" size="18" class="text-warning" />
                <span>Upcoming Alerts</span>
                <span class="text-muted fw-normal ms-1">(next 7 days)</span>
              </h3>
              <div class="d-flex align-items-center gap-2 text-muted small">
                 <BellIcon size="14" />
                 <span>Reminders · Bills · Vehicles · Medicines</span>
              </div>
            </div>
          </template>

          <div v-if="loadingReminders" class="text-center py-4">
            <BSpinner variant="primary" class="me-2" /> Loading...
          </div>

          <div v-else-if="upcomingAlerts.length === 0" class="d-flex align-items-center gap-3 py-3 justify-content-center text-muted">
             <CheckCircleIcon size="20" class="text-success" />
             <span class="fw-semibold">🎉 Nothing urgent in the next 7 days. All clear!</span>
          </div>

          <div v-else class="d-flex flex-wrap gap-3 py-1">
            <div
              v-for="alert in upcomingAlerts"
              :key="alert.key"
              :class="[
                'd-flex align-items-center gap-3 border rounded-3 px-3 py-3 position-relative transition-all hover-shadow',
                alert.days === 0 ? 'urgent-reminder' : 'bg-light hover-bg-white border-light'
              ]"
              style="min-width: 220px; flex: 1 1 240px;"
            >
              <div class="p-2 rounded-circle bg-white text-primary shadow-sm border border-light">
                 <component :is="alert.iconComp" size="20" />
              </div>
              <div class="flex-grow-1">
                <p class="fw-bold mb-0 text-main">{{ alert.title }}</p>
                <p class="text-muted mb-0 xx-small">{{ alert.subtitle }}</p>
              </div>
              <BBadge
                :variant="alert.days === 0 ? 'danger' : alert.days <= 3 ? 'warning' : 'info'"
                pill class="px-2"
              >
                {{ alert.days === 0 ? 'Today!' : `${alert.days}d` }}
              </BBadge>
            </div>
          </div>
        </BCard>
      </BCol>
    </BRow>

    <!-- Stats Section -->
    <BRow class="mb-5">
      <BCol md="3" sm="6" class="mb-4">
        <BCard class="text-center shadow-sm h-100 border-0 bg-white hover-up overflow-hidden">
          <div class="p-3 mb-3 bg-primary bg-opacity-10 text-primary rounded-circle d-inline-block mx-auto">
             <FileTextIcon size="24" />
          </div>
          <p class="text-uppercase text-secondary small fw-bold mb-1">Total Documents</p>
          <h2 class="fw-black text-primary mb-0">
            <BSpinner v-if="loadingStats" small />
            <span v-else>{{ stats.documents }}</span>
          </h2>
        </BCard>
      </BCol>
      <BCol md="3" sm="6" class="mb-4">
        <BCard class="text-center shadow-sm h-100 border-0 bg-white hover-up overflow-hidden">
          <div class="p-3 mb-3 bg-warning bg-opacity-10 text-warning rounded-circle d-inline-block mx-auto">
             <BellIcon size="24" />
          </div>
          <p class="text-uppercase text-secondary small fw-bold mb-1">Total Reminders</p>
          <h2 class="fw-black text-primary mb-0">
            <BSpinner v-if="loadingStats" small />
            <span v-else>{{ stats.reminders }}</span>
          </h2>
        </BCard>
      </BCol>
      <BCol md="3" sm="6" class="mb-4">
        <BCard class="text-center shadow-sm h-100 border-0 bg-white hover-up overflow-hidden">
          <div class="p-3 mb-3 bg-danger bg-opacity-10 text-danger rounded-circle d-inline-block mx-auto">
             <AlertCircleIcon size="24" />
          </div>
          <p class="text-uppercase text-secondary small fw-bold mb-1">Due This Week</p>
          <h2 class="fw-black mb-0" :class="stats.upcoming > 0 ? 'text-danger' : 'text-primary'">
            <BSpinner v-if="loadingStats" small />
            <span v-else>{{ stats.upcoming }}</span>
          </h2>
        </BCard>
      </BCol>
      <BCol md="3" sm="6" class="mb-4">
        <BCard class="text-center shadow-sm h-100 border-0 bg-white hover-up overflow-hidden">
          <div class="p-3 mb-3 bg-success bg-opacity-10 text-success rounded-circle d-inline-block mx-auto">
             <ActivityIcon size="24" />
          </div>
          <p class="text-uppercase text-secondary small fw-bold mb-1">Activities</p>
          <h2 class="fw-black text-primary mb-0">
            <BSpinner v-if="loadingStats" small />
            <span v-else>{{ stats.activities }}</span>
          </h2>
        </BCard>
      </BCol>
    </BRow>

    <!-- Main Content Section -->
    <BRow>
      <BCol lg="8" class="mb-4">
        <BCard class="shadow-sm border-0 h-100 overflow-hidden">
          <template #header>
            <div class="d-flex justify-content-between align-items-center py-2">
              <h3 class="h5 fw-bold mb-0 d-flex align-items-center gap-2">
                 <HistoryIcon size="20" class="text-primary" />
                 <span>Recent Activity</span>
              </h3>
              <NuxtLink to="/activities" class="btn btn-sm btn-link text-decoration-none p-0 fw-semibold">View All ›</NuxtLink>
            </div>
          </template>

          <div v-if="loadingActivity" class="text-center py-5">
            <BSpinner variant="primary" small class="me-2" /> Loading activity...
          </div>

          <div v-else-if="activities.length === 0" class="text-center py-5">
            <div class="p-4 bg-light rounded-circle d-inline-block mb-3">
               <InboxIcon size="48" class="text-muted opacity-50" />
            </div>
            <p class="text-muted fw-semibold">No activity yet. Your actions will appear here!</p>
          </div>

          <BListGroup v-else flush>
            <BListGroupItem v-for="activity in activities" :key="activity.id" class="py-3 px-0 border-light bg-transparent transition-all">
              <div class="d-flex align-items-center">
                <div class="p-3 rounded-circle bg-surface-secondary me-3 border shadow-xs d-flex align-items-center justify-content-center text-primary">
                  <component :is="getActivityIcon(activity.description)" size="20" />
                </div>
                <div class="flex-grow-1">
                  <h4 class="h6 fw-bold mb-1 text-main">{{ activity.description }}</h4>
                  <p class="text-muted xx-small mb-0 d-flex align-items-center gap-1">
                     <ClockIcon size="12" /> {{ activity.created_at }}
                  </p>
                </div>
              </div>
            </BListGroupItem>
          </BListGroup>
          <div v-if="activities.length > 5" class="text-center mt-3 pt-3 border-top">
             <NuxtLink to="/activities" class="text-primary small fw-bold text-decoration-none">View older activities</NuxtLink>
          </div>
        </BCard>
      </BCol>

      <BCol lg="4">
        <BCard variant="primary" bg-variant="primary" text-variant="white" class="mb-4 border-0 shadow gradient-bg">
          <h3 class="h5 fw-bold mb-4 d-flex align-items-center gap-2">
             <ZapIcon size="24" />
             <span>Quick Links</span>
          </h3>
          <div class="d-grid gap-3">
            <NuxtLink to="/reminders" class="quick-link-btn">
              <div class="d-flex align-items-center gap-2">
                 <BellIcon size="18" />
                 <span>Reminders</span>
              </div>
              <ChevronRightIcon size="18" />
            </NuxtLink>
            <NuxtLink to="/documents" class="quick-link-btn">
              <div class="d-flex align-items-center gap-2">
                 <FileTextIcon size="18" />
                 <span>Documents</span>
              </div>
              <ChevronRightIcon size="18" />
            </NuxtLink>
            <NuxtLink to="/medicines" class="quick-link-btn">
              <div class="d-flex align-items-center gap-2">
                 <PillIcon size="18" />
                 <span>Medicines</span>
              </div>
              <ChevronRightIcon size="18" />
            </NuxtLink>
            <NuxtLink to="/bills" class="quick-link-btn">
              <div class="d-flex align-items-center gap-2">
                 <CreditCardIcon size="18" />
                 <span>Bills</span>
              </div>
              <ChevronRightIcon size="18" />
            </NuxtLink>
            <NuxtLink to="/notes" class="quick-link-btn">
              <div class="d-flex align-items-center gap-2">
                 <ClipboardListIcon size="18" />
                 <span>Notes & To-Dos</span>
              </div>
              <ChevronRightIcon size="18" />
            </NuxtLink>
            <NuxtLink to="/vehicles" class="quick-link-btn">
              <div class="d-flex align-items-center gap-2">
                 <CarIcon size="18" />
                 <span>Vehicles</span>
              </div>
              <ChevronRightIcon size="18" />
            </NuxtLink>
            <NuxtLink to="/budget" class="quick-link-btn">
              <div class="d-flex align-items-center gap-2">
                 <TrendingUpIcon size="18" />
                 <span>Budget</span>
              </div>
              <ChevronRightIcon size="18" />
            </NuxtLink>
            <NuxtLink to="/chat" class="quick-link-btn">
               <div class="d-flex align-items-center gap-2">
                  <MessageSquareIcon size="18" />
                  <span>Chat Messages</span>
               </div>
               <ChevronRightIcon size="18" />
             </NuxtLink>
          </div>
        </BCard>
      </BCol>
    </BRow>
  </BContainer>
</template>

<script setup>
import { 
  AlertTriangle as AlertTriangleIcon,
  Bell as BellIcon,
  CheckCircle as CheckCircleIcon,
  Cake as CakeIcon,
  Heart as HeartIcon,
  Smartphone as SmartphoneIcon,
  Calendar as CalendarIcon,
  Lightbulb as LightbulbIcon,
  ShieldCheck as ShieldCheckIcon,
  Leaf as LeafIcon,
  Wrench as WrenchIcon,
  Pill as PillIcon,
  FileText as FileTextIcon,
  AlertCircle as AlertCircleIcon,
  Activity as ActivityIcon,
  History as HistoryIcon,
  Inbox as InboxIcon,
  Clock as ClockIcon,
  Zap as ZapIcon,
  MessageSquare as MessageSquareIcon,
  ChevronRight as ChevronRightIcon,
  ClipboardList as ClipboardListIcon,
  Car as CarIcon,
  CreditCard as CreditCardIcon,
  TrendingUp as TrendingUpIcon,
  Package as PackageIcon,
  User as UserIcon,
  Plus as PlusIcon
} from 'lucide-vue-next'
import { useAuthStore } from '~/stores/auth'

const auth = useAuthStore()
const config = useRuntimeConfig()

definePageMeta({
  middleware: 'auth'
})

const stats = reactive({ documents: 0, reminders: 0, upcoming: 0, activities: 0 })
const loadingStats = ref(true)

const upcomingReminders = ref([])
const upcomingBills     = ref([])
const upcomingVehicles  = ref([])
const upcomingMedicines = ref([])
const loadingReminders  = ref(true)
const activities        = ref([])
const loadingActivity   = ref(true)

// Merge all upcoming items into one sorted list
const upcomingAlerts = computed(() => {
  const alerts = []

  // Reminders
  for (const r of upcomingReminders.value) {
    alerts.push({
      key:      `rem-${r.id}`,
      iconComp: typeIcon(r.type),
      title:    r.title,
      subtitle: formatDate(r.next_occurrence),
      days:     r.days_remaining,
    })
  }

  // Bills due within 7 days and not yet paid
  for (const b of upcomingBills.value) {
    if (!b.is_paid_this_month && b.days_until_due <= 7 && b.days_until_due >= 0) {
      alerts.push({
        key:      `bill-${b.id}`,
        iconComp: CreditCardIcon,
        title:    b.name,
        subtitle: `Bill due on ${ordinal(b.due_day)} of month`,
        days:     b.days_until_due,
      })
    }
  }

  // Vehicle expiries within 7 days
  for (const v of upcomingVehicles.value) {
    if (v.insurance_days !== null && v.insurance_days >= 0 && v.insurance_days <= 7) {
      alerts.push({ key: `veh-ins-${v.id}`, iconComp: ShieldCheckIcon, title: `${v.name} — Insurance`, subtitle: `Expires ${v.insurance_expiry}`, days: v.insurance_days })
    }
    if (v.puc_days !== null && v.puc_days >= 0 && v.puc_days <= 7) {
      alerts.push({ key: `veh-puc-${v.id}`, iconComp: LeafIcon, title: `${v.name} — PUC`, subtitle: `Expires ${v.puc_expiry}`, days: v.puc_days })
    }
    if (v.service_days !== null && v.service_days >= 0 && v.service_days <= 7) {
      alerts.push({ key: `veh-svc-${v.id}`, iconComp: WrenchIcon, title: `${v.name} — Service`, subtitle: `Due ${v.next_service_date}`, days: v.service_days })
    }
  }

  // Medicines ending within 7 days
  for (const m of upcomingMedicines.value) {
    if (m.end_date) {
      const days = Math.ceil((new Date(m.end_date) - new Date()) / 86400000)
      if (days >= 0 && days <= 7) {
        alerts.push({ key: `med-${m.id}`, iconComp: PillIcon, title: `${m.name} — Course ending`, subtitle: `Last dose: ${formatDate(m.end_date)}`, days })
      }
    }
  }

  // Sort: today first, then by soonest
  return alerts.sort((a, b) => a.days - b.days)
})

function typeIcon(type) {
  const icons = { birthday: CakeIcon, anniversary: HeartIcon, recharge: SmartphoneIcon, custom: CalendarIcon }
  return icons[type] || BellIcon
}

function getActivityIcon(desc) {
  const d = desc.toLowerCase()
  if (d.includes('document')) return FileTextIcon
  if (d.includes('reminder')) return BellIcon
  if (d.includes('bill')) return CreditCardIcon
  if (d.includes('medicine')) return PillIcon
  if (d.includes('vehicle')) return CarIcon
  if (d.includes('note')) return ClipboardListIcon
  if (d.includes('added')) return PlusIcon
  if (d.includes('user')) return UserIcon
  return PackageIcon
}

function ordinal(n) {
  const s = ['th', 'st', 'nd', 'rd'], v = n % 100
  return n + (s[(v - 20) % 10] || s[v] || s[0])
}

function formatDate(d) {
  return new Date(d).toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' })
}

async function fetchUpcomingReminders() {
  if (!auth.token) return
  const headers = { Authorization: `Bearer ${auth.token}` }
  try {
    const [reminders, bills, vehicles, medicines] = await Promise.all([
      $fetch(`${config.public.apiBase}/reminders/upcoming`, { headers }),
      $fetch(`${config.public.apiBase}/bills`, { headers }),
      $fetch(`${config.public.apiBase}/vehicles`, { headers }),
      $fetch(`${config.public.apiBase}/medicines/today`, { headers }),
    ])
    upcomingReminders.value = reminders
    upcomingBills.value     = bills
    upcomingVehicles.value  = vehicles
    upcomingMedicines.value = medicines
  } catch (e) {
    console.error('Failed to fetch upcoming data', e)
  } finally {
    loadingReminders.value = false
  }
}

async function fetchActivities() {
  if (!auth.token) return
  try {
    const data = await $fetch(`${config.public.apiBase}/activities`, {
      headers: { Authorization: `Bearer ${auth.token}` }
    })
    activities.value = data
  } catch (e) {
    console.error('Failed to fetch activities', e)
  } finally {
    loadingActivity.value = false
  }
}

async function fetchStats() {
  if (!auth.token) return
  try {
    const headers = { Authorization: `Bearer ${auth.token}` }
    const [docs, reminders, acts] = await Promise.all([
      $fetch(`${config.public.apiBase}/documents`, { headers }),
      $fetch(`${config.public.apiBase}/reminders`, { headers }),
      $fetch(`${config.public.apiBase}/activities`, { headers }),
    ])
    stats.documents  = docs.length
    stats.reminders  = reminders.length
    stats.upcoming   = upcomingReminders.value.length
    stats.activities = acts.length
  } catch (e) {
    console.error('Failed to fetch stats', e)
  } finally {
    loadingStats.value = false
  }
}

onMounted(() => {
  fetchUpcomingReminders().then(() => {
    stats.upcoming = upcomingReminders.value.length
  })
  fetchActivities()
  fetchStats()
})
</script>

<style scoped>
.fw-black { font-weight: 900; }
.xx-small { font-size: 0.75rem; }
.tracking-tight { letter-spacing: -0.05em; }
.border-dashed { border-style: dashed !important; }

.hover-shadow:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0,0,0,0.1);
  background: white !important;
}

.hover-up:hover {
  transform: translateY(-5px);
  transition: all 0.3s ease;
}

.quick-link-btn {
  background: rgba(255,255,255,0.15);
  border: 1px solid rgba(255,255,255,0.1);
  color: white;
  padding: 1rem;
  border-radius: 0.75rem;
  text-decoration: none;
  font-weight: 600;
  display: flex;
  justify-content: space-between;
  align-items: center;
  transition: all 0.2s ease;
}

.quick-link-btn:hover {
  background: white;
  color: var(--bs-primary);
  transform: translateX(5px);
}

.shadow-xs { box-shadow: 0 1px 2px rgba(0,0,0,0.05); }

/* Urgent blinking for reminders due today */
.urgent-reminder {
  background-color: rgba(var(--danger-rgb), 0.05) !important;
  border-color: rgba(var(--danger-rgb), 0.3) !important;
  animation: urgent-pulse 1.2s ease-in-out infinite;
}

@keyframes urgent-pulse {
  0%, 100% {
    box-shadow: 0 0 0 0 rgba(var(--danger-rgb, 220, 53, 69), 0.2);
  }
  50% {
    box-shadow: 0 0 0 8px rgba(var(--danger-rgb, 220, 53, 69), 0);
  }
}
</style>

<template>
  <BContainer class="py-5">
    <!-- Header Section -->
    <BRow class="mb-5 align-items-center">
      <BCol>
        <h1 class="fw-black text-dark mb-1">
          Welcome back, <span class="text-primary">{{ auth.user?.name }}</span>
        </h1>
        <p class="text-muted lead">Your personal dashboard — documents, reminders, and more.</p>
      </BCol>
    </BRow>

    <!-- Upcoming Reminders Panel (top) -->
    <BRow class="mb-4">
      <BCol>
        <BCard class="border-0 shadow-sm">
          <template #header>
            <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center py-1">
              <h3 class="h6 fw-bold mb-2 mb-md-0">⚠️ Upcoming Alerts <span class="text-muted fw-normal">(next 7 days)</span></h3>
              <span class="text-muted small">Reminders · Bills · Vehicles · Medicines</span>
            </div>
          </template>

          <div v-if="loadingReminders" class="text-center py-2">
            <BSpinner small variant="primary" class="me-2" /> Loading...
          </div>

          <div v-else-if="upcomingAlerts.length === 0" class="d-flex align-items-center gap-3 py-1">
            <span class="text-muted small">🎉 Nothing urgent in the next 7 days. All clear!</span>
          </div>

          <div v-else class="d-flex flex-wrap gap-3 py-1">
            <div
              v-for="alert in upcomingAlerts"
              :key="alert.key"
              :class="[
                'd-flex align-items-center gap-2 border rounded px-3 py-2',
                alert.days === 0 ? 'urgent-reminder' : 'bg-light'
              ]"
              style="min-width: 180px; flex: 1 1 200px; max-width: 100%;"
            >
              <span class="fs-5">{{ alert.icon }}</span>
              <div class="flex-grow-1">
                <p class="fw-semibold mb-0 small">{{ alert.title }}</p>
                <p class="text-muted mb-0" style="font-size: 0.72rem;">{{ alert.subtitle }}</p>
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
        <BCard class="text-center shadow-sm h-100 border-0 bg-white">
          <p class="text-uppercase text-secondary small fw-bold mb-2">Total Documents</p>
          <h2 class="fw-black text-primary mb-0">
            <BSpinner v-if="loadingStats" small />
            <span v-else>{{ stats.documents }}</span>
          </h2>
        </BCard>
      </BCol>
      <BCol md="3" sm="6" class="mb-4">
        <BCard class="text-center shadow-sm h-100 border-0 bg-white">
          <p class="text-uppercase text-secondary small fw-bold mb-2">Total Reminders</p>
          <h2 class="fw-black text-primary mb-0">
            <BSpinner v-if="loadingStats" small />
            <span v-else>{{ stats.reminders }}</span>
          </h2>
        </BCard>
      </BCol>
      <BCol md="3" sm="6" class="mb-4">
        <BCard class="text-center shadow-sm h-100 border-0 bg-white">
          <p class="text-uppercase text-secondary small fw-bold mb-2">Due This Week</p>
          <h2 class="fw-black mb-0" :class="stats.upcoming > 0 ? 'text-warning' : 'text-primary'">
            <BSpinner v-if="loadingStats" small />
            <span v-else>{{ stats.upcoming }}</span>
          </h2>
        </BCard>
      </BCol>
      <BCol md="3" sm="6" class="mb-4">
        <BCard class="text-center shadow-sm h-100 border-0 bg-white">
          <p class="text-uppercase text-secondary small fw-bold mb-2">Activities</p>
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
        <BCard class="shadow-sm border-0 h-100">
          <template #header>
            <div class="d-flex justify-content-between align-items-center py-2">
              <h3 class="h5 fw-bold mb-0">Recent Activity</h3>
            </div>
          </template>

          <div v-if="loadingActivity" class="text-center py-4">
            <BSpinner variant="primary" small class="me-2" /> Loading activity...
          </div>

          <div v-else-if="activities.length === 0" class="text-center py-5">
            <div class="display-4 mb-2">📭</div>
            <p class="text-muted">No activity yet. Start by adding a reminder!</p>
          </div>

          <BListGroup v-else flush>
            <BListGroupItem v-for="activity in activities" :key="activity.id" class="py-3 px-0 border-light">
              <div class="d-flex align-items-center">
                <div class="p-3 rounded-circle bg-light me-3 fs-5 lh-1">
                  {{ activity.icon }}
                </div>
                <div class="flex-grow-1">
                  <h4 class="h6 fw-bold mb-1">{{ activity.description }}</h4>
                  <p class="text-muted small mb-0">{{ activity.created_at }}</p>
                </div>
              </div>
            </BListGroupItem>
          </BListGroup>
        </BCard>
      </BCol>

      <BCol lg="4">
        <BCard variant="primary" bg-variant="primary" text-variant="white" class="mb-4 border-0 shadow gradient-bg">
          <h3 class="h5 fw-bold mb-4">Quick Links</h3>
          <div class="d-grid gap-2">
            <NuxtLink to="/reminders" class="btn btn-light text-start fw-semibold d-flex justify-content-between align-items-center shadow-sm">
              🔔 Reminders <span>›</span>
            </NuxtLink>
            <NuxtLink to="/documents" class="btn btn-light text-start fw-semibold d-flex justify-content-between align-items-center shadow-sm">
              📄 Documents <span>›</span>
            </NuxtLink>
            <NuxtLink to="/medicines" class="btn btn-light text-start fw-semibold d-flex justify-content-between align-items-center shadow-sm">
              💊 Medicines <span>›</span>
            </NuxtLink>
            <NuxtLink to="/bills" class="btn btn-light text-start fw-semibold d-flex justify-content-between align-items-center shadow-sm">
              💡 Bills <span>›</span>
            </NuxtLink>
            <NuxtLink to="/notes" class="btn btn-light text-start fw-semibold d-flex justify-content-between align-items-center shadow-sm">
              📋 Notes & To-Dos <span>›</span>
            </NuxtLink>
            <NuxtLink to="/vehicles" class="btn btn-light text-start fw-semibold d-flex justify-content-between align-items-center shadow-sm">
              🚗 Vehicles <span>›</span>
            </NuxtLink>
            <NuxtLink to="/budget" class="btn btn-light text-start fw-semibold d-flex justify-content-between align-items-center shadow-sm">
              📊 Budget <span>›</span>
            </NuxtLink>
          </div>
        </BCard>
      </BCol>
    </BRow>
  </BContainer>
</template>

<script setup>
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
      icon:     typeIcon(r.type),
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
        icon:     '💡',
        title:    b.name,
        subtitle: `Bill due on ${ordinal(b.due_day)} of month`,
        days:     b.days_until_due,
      })
    }
  }

  // Vehicle expiries within 7 days
  for (const v of upcomingVehicles.value) {
    if (v.insurance_days !== null && v.insurance_days >= 0 && v.insurance_days <= 7) {
      alerts.push({ key: `veh-ins-${v.id}`, icon: '🛡️', title: `${v.name} — Insurance`, subtitle: `Expires ${v.insurance_expiry}`, days: v.insurance_days })
    }
    if (v.puc_days !== null && v.puc_days >= 0 && v.puc_days <= 7) {
      alerts.push({ key: `veh-puc-${v.id}`, icon: '🌿', title: `${v.name} — PUC`, subtitle: `Expires ${v.puc_expiry}`, days: v.puc_days })
    }
    if (v.service_days !== null && v.service_days >= 0 && v.service_days <= 7) {
      alerts.push({ key: `veh-svc-${v.id}`, icon: '🔧', title: `${v.name} — Service`, subtitle: `Due ${v.next_service_date}`, days: v.service_days })
    }
  }

  // Medicines ending within 7 days
  for (const m of upcomingMedicines.value) {
    if (m.end_date) {
      const days = Math.ceil((new Date(m.end_date) - new Date()) / 86400000)
      if (days >= 0 && days <= 7) {
        alerts.push({ key: `med-${m.id}`, icon: '💊', title: `${m.name} — Course ending`, subtitle: `Last dose: ${formatDate(m.end_date)}`, days })
      }
    }
  }

  // Sort: today first, then by soonest
  return alerts.sort((a, b) => a.days - b.days)
})

function typeIcon(type) {
  const icons = { birthday: '🎂', anniversary: '💍', recharge: '📱', custom: '📅' }
  return icons[type] || '🔔'
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
.border-dashed { border-style: dashed !important; }

/* Urgent blinking for reminders due today */
.urgent-reminder {
  background-color: #fff3f3;
  border-color: #dc3545 !important;
  animation: urgent-pulse 1.2s ease-in-out infinite;
}

@keyframes urgent-pulse {
  0%, 100% {
    background-color: #fff3f3;
    box-shadow: 0 0 0 0 rgba(220, 53, 69, 0.4);
  }
  50% {
    background-color: #ffe0e0;
    box-shadow: 0 0 0 6px rgba(220, 53, 69, 0);
  }
}
</style>

<template>
  <BContainer class="py-5">
    <BRow class="mb-4 align-items-center">
      <BCol md="8" class="mb-3 mb-md-0">
        <h1 class="fw-bold mb-0">🚗 Vehicle Tracker</h1>
        <p class="text-muted mb-0">Track insurance, PUC, and service reminders for your vehicles</p>
      </BCol>
      <BCol md="4" class="text-md-end">
        <BButton variant="primary" @click="openModal()" class="fw-bold px-4 w-100 w-md-auto">+ Add Vehicle</BButton>
      </BCol>
    </BRow>

    <div v-if="loading" class="text-center py-5"><BSpinner variant="primary" /></div>

    <div v-else-if="vehicles.length === 0" class="text-center py-5">
      <div class="display-1 mb-2">🚗</div>
      <h4 class="fw-bold">No vehicles added yet</h4>
      <p class="text-muted">Add your car or bike to track insurance, PUC & service dates.</p>
      <BButton variant="primary" @click="openModal()">+ Add Vehicle</BButton>
    </div>

    <BRow v-else>
      <BCol v-for="v in vehicles" :key="v.id" md="6" lg="4" class="mb-4">
        <BCard class="h-100 shadow-sm border-0 vehicle-card">
          <div class="d-flex justify-content-between align-items-center mb-3">
            <div>
              <span class="fs-2 me-2">{{ typeIcon(v.type) }}</span>
              <span class="fw-bold fs-5">{{ v.name }}</span>
            </div>
            <div class="d-flex gap-2">
              <BButton size="sm" variant="outline-primary" @click="openModal(v)">Edit</BButton>
              <BButton size="sm" variant="outline-danger" @click="deleteVehicle(v.id)">🗑</BButton>
            </div>
          </div>

          <p v-if="v.registration_number" class="text-muted small mb-3">
            🔢 {{ v.registration_number }}
          </p>

          <div class="d-flex flex-column gap-2">
            <div class="d-flex justify-content-between align-items-center p-2 rounded"
              :class="expiryClass(v.insurance_days)">
              <span class="small fw-semibold">🛡️ Insurance</span>
              <span class="small fw-bold">{{ expiryLabel(v.insurance_days, v.insurance_expiry) }}</span>
            </div>
            <div class="d-flex justify-content-between align-items-center p-2 rounded"
              :class="expiryClass(v.puc_days)">
              <span class="small fw-semibold">🌿 PUC</span>
              <span class="small fw-bold">{{ expiryLabel(v.puc_days, v.puc_expiry) }}</span>
            </div>
            <div class="d-flex justify-content-between align-items-center p-2 rounded"
              :class="expiryClass(v.service_days, 30)">
              <span class="small fw-semibold">🔧 Service</span>
              <span class="small fw-bold">{{ expiryLabel(v.service_days, v.next_service_date) }}</span>
            </div>
          </div>

          <p v-if="v.notes" class="text-muted small mt-3 mb-0 fst-italic border-top pt-2">{{ v.notes }}</p>
        </BCard>
      </BCol>
    </BRow>

    <!-- Modal -->
    <BModal v-model="showModal" :title="editingId ? 'Edit Vehicle' : 'Add Vehicle'"
      ok-title="Save" @ok.prevent="saveVehicle" size="lg">
      <BAlert v-if="formError" variant="danger" show>{{ formError }}</BAlert>
      <BForm>
        <BRow>
          <BCol md="6">
            <BFormGroup label="Vehicle Name" class="mb-3 fw-semibold">
              <BFormInput v-model="form.name" placeholder="e.g. My Honda Activa" required />
            </BFormGroup>
          </BCol>
          <BCol md="3">
            <BFormGroup label="Type" class="mb-3 fw-semibold">
              <BFormSelect v-model="form.type" :options="typeOptions" />
            </BFormGroup>
          </BCol>
          <BCol md="3">
            <BFormGroup label="Reg. Number" class="mb-3 fw-semibold">
              <BFormInput v-model="form.registration_number" placeholder="MH12AB1234" style="text-transform:uppercase" />
            </BFormGroup>
          </BCol>
        </BRow>
        <BRow>
          <BCol md="6">
            <BFormGroup label="Insurance Expiry" class="mb-3 fw-semibold">
              <BFormInput v-model="form.insurance_expiry" type="date" />
            </BFormGroup>
          </BCol>
          <BCol md="6">
            <BFormGroup label="PUC Expiry" class="mb-3 fw-semibold">
              <BFormInput v-model="form.puc_expiry" type="date" />
            </BFormGroup>
          </BCol>
        </BRow>
        <BRow>
          <BCol md="6">
            <BFormGroup label="Last Service Date" class="mb-3 fw-semibold">
              <BFormInput v-model="form.last_service_date" type="date" />
            </BFormGroup>
          </BCol>
          <BCol md="6">
            <BFormGroup label="Next Service Date" class="mb-3 fw-semibold">
              <BFormInput v-model="form.next_service_date" type="date" />
            </BFormGroup>
          </BCol>
        </BRow>
        <BFormGroup label="Notes" class="mb-3 fw-semibold">
          <BFormTextarea v-model="form.notes" rows="2" />
        </BFormGroup>
      </BForm>
    </BModal>
  </BContainer>
</template>

<script setup>
import { useAuthStore } from '~/stores/auth'

definePageMeta({ middleware: 'auth' })

const config = useRuntimeConfig()
const auth = useAuthStore()
const { show: showToast } = useToast()

const vehicles = ref([])
const loading = ref(true)
const showModal = ref(false)
const editingId = ref(null)
const formError = ref('')

const form = reactive({
  name: '', type: 'bike', registration_number: '',
  insurance_expiry: '', puc_expiry: '',
  last_service_date: '', next_service_date: '', notes: ''
})

const typeOptions = [
  { value: 'car',    text: '🚗 Car' },
  { value: 'bike',   text: '🏍️ Bike' },
  { value: 'scooter', text: '🛵 Scooter' },
  { value: 'truck',  text: '🚛 Truck' },
  { value: 'auto',   text: '🛺 Auto' },
  { value: 'other',  text: '🚌 Other' },
]

const typeIcons = { car: '🚗', bike: '🏍️', scooter: '🛵', truck: '🚛', auto: '🛺', other: '🚌' }
function typeIcon(t) { return typeIcons[t] || '🚗' }

function expiryClass(days, threshold = 30) {
  if (days === null || days === undefined) return 'bg-light'
  if (days < 0)  return 'bg-danger bg-opacity-10 border border-danger'
  if (days <= threshold) return 'bg-warning bg-opacity-10 border border-warning'
  return 'bg-success bg-opacity-10 border border-success'
}

function expiryLabel(days, dateStr) {
  if (!dateStr) return '—'
  if (days === null || days === undefined) return dateStr
  if (days < 0)  return `⚠️ Expired ${Math.abs(days)}d ago`
  if (days === 0) return '⚠️ Expires Today!'
  if (days <= 30) return `⏳ ${days}d left`
  return `✅ ${dateStr}`
}

function authHeaders() { return { Authorization: `Bearer ${auth.token}` } }

async function fetchVehicles() {
  loading.value = true
  try {
    vehicles.value = await $fetch(`${config.public.apiBase}/vehicles`, { headers: authHeaders() })
  } catch (e) { console.error(e) } finally { loading.value = false }
}

function openModal(item = null) {
  formError.value = ''
  if (item) {
    editingId.value = item.id
    Object.assign(form, {
      name: item.name, type: item.type,
      registration_number: item.registration_number || '',
      insurance_expiry: item.insurance_expiry || '', puc_expiry: item.puc_expiry || '',
      last_service_date: item.last_service_date || '', next_service_date: item.next_service_date || '',
      notes: item.notes || ''
    })
  } else {
    editingId.value = null
    Object.assign(form, { name: '', type: 'bike', registration_number: '', insurance_expiry: '', puc_expiry: '', last_service_date: '', next_service_date: '', notes: '' })
  }
  showModal.value = true
}

async function saveVehicle() {
  if (!form.name) { formError.value = 'Vehicle name is required.'; return }
  const payload = { ...form }
  // Convert empty strings to null for date fields
  for (const key of ['insurance_expiry', 'puc_expiry', 'last_service_date', 'next_service_date']) {
    if (!payload[key]) payload[key] = null
  }
  const method = editingId.value ? 'PUT' : 'POST'
  const url = editingId.value
    ? `${config.public.apiBase}/vehicles/${editingId.value}`
    : `${config.public.apiBase}/vehicles`
  try {
    await $fetch(url, { method, body: payload, headers: authHeaders() })
    showModal.value = false
    showToast({ title: 'Success', body: 'Vehicle saved successfully!', variant: 'success' })
    await fetchVehicles()
  } catch (e) {
    formError.value = e.data?.message || Object.values(e.data?.errors || {})[0]?.[0] || 'Failed to save.'
  }
}

async function deleteVehicle(id) {
  if (!confirm('Delete this vehicle?')) return
  try {
    await $fetch(`${config.public.apiBase}/vehicles/${id}`, { method: 'DELETE', headers: authHeaders() })
    showToast({ title: 'Removed', body: 'Vehicle removed from tracker.', variant: 'success' })
    await fetchVehicles()
  } catch (e) {
    showToast({ title: 'Error', body: 'Failed to delete vehicle.', variant: 'danger' })
  }
}

onMounted(fetchVehicles)
</script>

<style scoped>
.vehicle-card { transition: transform 0.2s; }
.vehicle-card:hover { transform: translateY(-3px); }
</style>

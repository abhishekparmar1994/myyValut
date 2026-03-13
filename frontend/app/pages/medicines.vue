<template>
  <BContainer class="py-5">
    <!-- Header -->
    <BRow class="mb-4 align-items-center">
      <BCol md="8" class="mb-3 mb-md-0">
        <h1 class="fw-bold mb-0">💊 Medicines</h1>
        <p class="text-muted mb-0">Track your daily medicines and never miss a dose</p>
      </BCol>
      <BCol md="4" class="text-md-end">
        <BButton variant="primary" @click="openModal()" class="fw-bold px-4 w-100 w-md-auto">+ Add Medicine</BButton>
      </BCol>
    </BRow>

    <!-- Today's Schedule Card -->
    <BCard class="border-0 shadow-sm mb-4">
      <template #header>
        <div class="d-flex justify-content-between align-items-center py-1">
          <h3 class="h6 fw-bold mb-0">📅 Today's Schedule</h3>
          <span class="small text-muted">{{ todayDate }}</span>
        </div>
      </template>

      <div v-if="loadingToday" class="text-center py-3"><BSpinner small variant="primary" /></div>

      <div v-else-if="todayMedicines.length === 0" class="text-center py-3 text-muted small">
        No medicines scheduled for today.
      </div>

      <div v-else class="d-flex flex-wrap gap-3 py-1">
        <div v-for="med in todayMedicines" :key="med.id"
          class="border rounded px-3 py-2 bg-light d-flex align-items-center gap-2" style="min-width:220px">
          <span class="fs-5">💊</span>
          <div>
            <p class="fw-semibold mb-0 small">{{ med.name }}</p>
            <p class="text-muted mb-0" style="font-size:0.72rem">{{ med.dosage }} · {{ med.times.join(', ') }}</p>
          </div>
        </div>
      </div>
    </BCard>

    <!-- All Medicines -->
    <BCard class="border-0 shadow-sm">
      <template #header>
        <div class="py-1 fw-bold">All Medicines</div>
      </template>

      <div v-if="loading" class="text-center py-4"><BSpinner variant="primary" /></div>

      <div v-else-if="medicines.length === 0" class="text-center py-5">
        <div class="display-1 mb-2">💊</div>
        <h4 class="fw-bold">No medicines added yet</h4>
        <p class="text-muted">Add your first medicine to start tracking doses.</p>
        <BButton variant="primary" @click="openModal()">+ Add Medicine</BButton>
      </div>

      <BTable v-else :items="medicines" :fields="tableFields" responsive hover class="mb-0">
        <template #cell(name)="{ item }">
          <p class="fw-bold mb-0">{{ item.name }}</p>
          <small class="text-muted">{{ item.dosage }}</small>
        </template>
        <template #cell(times)="{ item }">
          <BBadge v-for="t in item.times" :key="t" variant="secondary" class="me-1">{{ t }}</BBadge>
        </template>
        <template #cell(duration)="{ item }">
          <span class="small text-muted">
            {{ formatDate(item.start_date) }}
            {{ item.end_date ? '→ ' + formatDate(item.end_date) : '(Ongoing)' }}
          </span>
        </template>
        <template #cell(status)="{ item }">
          <BBadge :variant="item.is_ongoing ? 'success' : 'secondary'">
            {{ item.is_ongoing ? 'Active' : 'Ended' }}
          </BBadge>
        </template>
        <template #cell(actions)="{ item }">
          <div class="d-flex gap-2">
            <BButton size="sm" variant="outline-primary" @click="openModal(item)">Edit</BButton>
            <BButton size="sm" variant="outline-danger" @click="deleteMedicine(item.id)">Delete</BButton>
          </div>
        </template>
      </BTable>
    </BCard>

    <!-- Add/Edit Modal -->
    <BModal v-model="showModal" :title="editingId ? 'Edit Medicine' : 'Add Medicine'"
      ok-title="Save" cancel-title="Cancel" @ok.prevent="saveMedicine" size="lg">
      <BAlert v-if="formError" variant="danger" show dismissible>{{ formError }}</BAlert>
      <BForm>
        <BRow>
          <BCol md="6">
            <BFormGroup label="Medicine Name" class="mb-3 fw-semibold">
              <BFormInput v-model="form.name" placeholder="e.g. Paracetamol" required />
            </BFormGroup>
          </BCol>
          <BCol md="6">
            <BFormGroup label="Dosage" class="mb-3 fw-semibold">
              <BFormInput v-model="form.dosage" placeholder="e.g. 500mg, 1 tablet" />
            </BFormGroup>
          </BCol>
        </BRow>

        <BFormGroup label="Times to Take (add one or more)" class="mb-3 fw-semibold">
          <div class="d-flex flex-wrap gap-2 mb-2">
            <BBadge v-for="(t, i) in form.times" :key="i" variant="primary" class="px-3 py-2 d-flex align-items-center gap-1">
              {{ t }}
              <span style="cursor:pointer" @click="removeTime(i)">✕</span>
            </BBadge>
          </div>
          <div class="d-flex gap-2">
            <BFormInput v-model="newTime" type="time" style="max-width: 160px;" />
            <BButton variant="outline-primary" size="sm" @click="addTime">+ Add Time</BButton>
          </div>
          <div class="d-flex gap-2 mt-2 flex-wrap">
            <BButton v-for="preset in timePresets" :key="preset" size="sm" variant="light"
              @click="addTime(preset)">{{ preset }}</BButton>
          </div>
        </BFormGroup>

        <BRow>
          <BCol md="6">
            <BFormGroup label="Start Date" class="mb-3 fw-semibold">
              <BFormInput v-model="form.start_date" type="date" required />
            </BFormGroup>
          </BCol>
          <BCol md="6">
            <BFormGroup label="End Date (leave blank for ongoing)" class="mb-3 fw-semibold">
              <BFormInput v-model="form.end_date" type="date" />
            </BFormGroup>
          </BCol>
        </BRow>

        <BFormGroup label="Notes (optional)" class="mb-3 fw-semibold">
          <BFormTextarea v-model="form.notes" rows="2" placeholder="Before/after food, any special instructions..." />
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

const medicines = ref([])
const todayMedicines = ref([])
const loading = ref(true)
const loadingToday = ref(true)
const showModal = ref(false)
const editingId = ref(null)
const formError = ref('')
const newTime = ref('08:00')

const timePresets = ['06:00', '08:00', '12:00', '14:00', '18:00', '21:00']

const form = reactive({
  name: '', dosage: '', times: [], start_date: today(), end_date: '', notes: ''
})

const tableFields = [
  { key: 'name', label: 'Medicine' },
  { key: 'times', label: 'Times' },
  { key: 'duration', label: 'Duration' },
  { key: 'status', label: 'Status' },
  { key: 'actions', label: 'Actions' },
]

function today() {
  return new Date().toISOString().slice(0, 10)
}

const todayDate = computed(() =>
  new Date().toLocaleDateString('en-IN', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' })
)

function formatDate(d) {
  return new Date(d).toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' })
}

function authHeaders() {
  return { Authorization: `Bearer ${auth.token}` }
}

function addTime(t) {
  const time = t || newTime.value
  if (time && !form.times.includes(time)) {
    form.times.push(time)
    form.times.sort()
  }
}

function removeTime(i) {
  form.times.splice(i, 1)
}

function openModal(item = null) {
  formError.value = ''
  if (item) {
    editingId.value = item.id
    form.name = item.name
    form.dosage = item.dosage || ''
    form.times = [...item.times]
    form.start_date = item.start_date
    form.end_date = item.end_date || ''
    form.notes = item.notes || ''
  } else {
    editingId.value = null
    form.name = ''; form.dosage = ''; form.times = []; form.start_date = today(); form.end_date = ''; form.notes = ''
  }
  showModal.value = true
}

async function fetchMedicines() {
  loading.value = true
  try {
    medicines.value = await $fetch(`${config.public.apiBase}/medicines`, { headers: authHeaders() })
  } catch (e) { console.error(e) } finally { loading.value = false }
}

async function fetchToday() {
  loadingToday.value = true
  try {
    todayMedicines.value = await $fetch(`${config.public.apiBase}/medicines/today`, { headers: authHeaders() })
  } catch (e) { console.error(e) } finally { loadingToday.value = false }
}

async function saveMedicine() {
  if (!form.name) { formError.value = 'Medicine name is required.'; return }
  if (form.times.length === 0) { formError.value = 'Please add at least one time.'; return }

  const payload = { ...form, end_date: form.end_date || null }
  const method = editingId.value ? 'PUT' : 'POST'
  const url = editingId.value
    ? `${config.public.apiBase}/medicines/${editingId.value}`
    : `${config.public.apiBase}/medicines`

  try {
    await $fetch(url, { method, body: payload, headers: authHeaders() })
    showModal.value = false
    showToast({ title: 'Success', body: 'Medicine saved successfully!', variant: 'success' })
    await fetchMedicines()
    await fetchToday()
  } catch (e) {
    formError.value = e.data?.message || Object.values(e.data?.errors || {})[0]?.[0] || 'Failed to save.'
  }
}

async function deleteMedicine(id) {
  if (!confirm('Remove this medicine?')) return
  try {
    await $fetch(`${config.public.apiBase}/medicines/${id}`, { method: 'DELETE', headers: authHeaders() })
    showToast({ title: 'Removed', body: 'Medicine removed from tracker.', variant: 'success' })
    await fetchMedicines()
    await fetchToday()
  } catch (e) {
    showToast({ title: 'Error', body: 'Failed to delete medicine.', variant: 'danger' })
  }
}

onMounted(() => {
  fetchMedicines()
  fetchToday()
})
</script>

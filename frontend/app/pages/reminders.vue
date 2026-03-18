<template>
  <BContainer class="py-5">
    <!-- Header -->
    <BRow class="mb-4 align-items-center">
      <BCol md="8" class="mb-3 mb-md-0 d-flex align-items-center">
        <BellIcon :size="32" class="text-primary me-3" />
        <div>
          <h1 class="fw-bold mb-0">Reminders</h1>
          <p class="text-muted mb-0">Never forget important dates and tasks</p>
        </div>
      </BCol>
      <BCol md="4" class="text-md-end">
        <BButton variant="primary" @click="openModal()" class="fw-bold px-4 w-100 w-md-auto d-flex align-items-center justify-content-center gap-2">
          <PlusIcon :size="18" /> Add Reminder
        </BButton>
      </BCol>
    </BRow>

    <!-- Empty State -->
    <BCard v-if="!loading && reminders.length === 0" class="text-center py-5 border-0 shadow-sm">
      <div class="mb-3 text-muted opacity-50">
        <BellIcon :size="64" class="mx-auto" />
      </div>
      <h4 class="fw-bold">No reminders set</h4>
      <p class="text-muted">Add important dates like birthdays or recharge due dates.</p>
      <BButton variant="primary" @click="openModal()" class="d-inline-flex align-items-center gap-2">
        <PlusIcon :size="18" /> Set New Reminder
      </BButton>
    </BCard>

    <!-- Reminders Table -->
    <BCard v-else class="border-0 shadow-sm overflow-hidden">
      <div v-if="loading" class="text-center py-4"><BSpinner variant="primary" /></div>
      <BTable v-else :items="reminders" :fields="tableFields" responsive hover class="mb-0">
        <template #cell(type)="{ item }">
          <BBadge :variant="getReminder(item.type).badge" class="px-2 py-1 d-inline-flex align-items-center gap-2">
            <component :is="getReminder(item.type).icon" :size="14" />
            {{ getReminder(item.type).text }}
          </BBadge>
        </template>
        
        <template #cell(next_date)="{ item }">
          <div class="fw-semibold">{{ formatDate(item.next_date) }}</div>
          <small v-if="item.days_left !== null" :class="item.days_left <= 7 ? 'text-danger fw-bold' : 'text-muted'">
            {{ item.days_left === 0 ? 'Today!' : `${item.days_left} days left` }}
          </small>
        </template>

        <template #cell(actions)="{ item }">
          <div class="d-flex gap-2">
            <BButton size="sm" variant="outline-primary" @click="openModal(item)" class="p-1 px-2">
              <PencilIcon :size="14" />
            </BButton>
            <BButton size="sm" variant="outline-danger" @click="deleteReminder(item.id)" class="p-1 px-2">
               <Trash2Icon :size="14" />
            </BButton>
          </div>
        </template>
      </BTable>
    </BCard>

    <!-- Add/Edit Modal (Standard BootstrapVueNext) -->
    <BModal v-model="showModal" :title="editingId ? 'Edit Reminder' : 'Add Reminder'" 
      ok-title="Save" @ok.prevent="saveReminder">
      <BForm>
        <BFormGroup label="Label / Message" class="mb-3 fw-semibold">
          <BFormInput v-model="form.title" placeholder="e.g. Mom's Birthday" required />
        </BFormGroup>
        
        <BRow>
          <BCol md="6">
            <BFormGroup label="Type" class="mb-3 fw-semibold">
              <BFormSelect v-model="form.type" :options="typeOptions" required />
            </BFormGroup>
          </BCol>
          <BCol md="6">
            <BFormGroup label="Date" class="mb-3 fw-semibold">
              <BFormInput v-model="form.date" type="date" required />
            </BFormGroup>
          </BCol>
        </BRow>

        <BRow>
          <BCol md="6">
            <BFormGroup label="Time" class="mb-3 fw-semibold">
              <BFormInput v-model="form.time" type="time" />
            </BFormGroup>
          </BCol>
          <BCol md="6">
            <BFormGroup label="Frequency" class="mb-3 fw-semibold">
              <BFormSelect v-model="form.frequency" :options="freqOptions" />
            </BFormGroup>
          </BCol>
        </BRow>
      </BForm>
    </BModal>
  </BContainer>
</template>

<script setup>
import { 
  BellIcon, PlusIcon, CakeIcon, GemIcon, 
  SmartphoneIcon, CalendarIcon, Trash2Icon, PencilIcon 
} from 'lucide-vue-next'
import { useAuthStore } from '~/stores/auth'

definePageMeta({ middleware: 'auth' })

const config = useRuntimeConfig()
const auth = useAuthStore()
const { show: showToast } = useToast()

const reminders = ref([])
const loading = ref(true)
const showModal = ref(false)
const editingId = ref(null)

const form = reactive({
  title: '', type: 'event', date: '', time: '09:00', frequency: 'once'
})

const typeOptions = [
  { value: 'birthday',    text: 'Birthday', icon: CakeIcon, badge: 'primary' },
  { value: 'anniversary', text: 'Anniversary', icon: GemIcon, badge: 'danger' },
  { value: 'recharge',    text: 'Recharge', icon: SmartphoneIcon, badge: 'success' },
  { value: 'event',       text: 'Event', icon: CalendarIcon, badge: 'info' },
]

function getReminder(val) { return typeOptions.find(o => o.value === val) || typeOptions[3] }

const freqOptions = [
  { value: 'once', text: 'Once' },
  { value: 'yearly', text: 'Yearly' },
  { value: 'monthly', text: 'Monthly' },
]

const tableFields = [
  { key: 'title', label: 'Reminder', sortable: true },
  { key: 'type', label: 'Type' },
  { key: 'next_date', label: 'Next Due', sortable: true },
  { key: 'actions', label: 'Actions' },
]

function formatDate(d) {
  return new Date(d).toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' })
}

function authHeaders() {
  return { Authorization: `Bearer ${auth.token}` }
}

async function fetchReminders() {
  loading.value = true
  try {
    reminders.value = await $fetch(`${config.public.apiBase}/reminders`, { headers: authHeaders() })
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
}

function openModal(item = null) {
  if (item) {
    editingId.value = item.id
    form.title = item.title
    form.type = item.type
    form.date = item.date
    form.time = item.time || '09:00'
    form.frequency = item.frequency
  } else {
    editingId.value = null
    form.title = ''; form.type = 'event'; form.date = ''; form.time = '09:00'; form.frequency = 'once'
  }
  showModal.value = true
}

async function saveReminder() {
  try {
    if (editingId.value) {
      await $fetch(`${config.public.apiBase}/reminders/${editingId.value}`, {
        method: 'PUT', body: { ...form }, headers: authHeaders()
      })
    } else {
      await $fetch(`${config.public.apiBase}/reminders`, {
        method: 'POST', body: { ...form }, headers: authHeaders()
      })
    }
    showToast({ title: 'Success', body: 'Reminder saved successfully!', variant: 'success' })
    await fetchReminders()
  } catch (e) {
    showToast({ title: 'Error', body: 'Failed to save reminder.', variant: 'danger' })
    console.error('Save failed', e)
  }
}

async function deleteReminder(id) {
  if (!confirm('Delete this reminder?')) return
  try {
    await $fetch(`${config.public.apiBase}/reminders/${id}`, {
      method: 'DELETE', headers: authHeaders()
    })
    showToast({ title: 'Deleted', body: 'Reminder removed.', variant: 'success' })
    await fetchReminders()
  } catch (e) {
    showToast({ title: 'Error', body: 'Failed to delete reminder.', variant: 'danger' })
    console.error('Delete failed', e)
  }
}

onMounted(fetchReminders)
</script>

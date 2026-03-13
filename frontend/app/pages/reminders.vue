<template>
  <BContainer class="py-5">
    <!-- Header -->
    <BRow class="mb-4 align-items-center">
      <BCol md="8" class="mb-3 mb-md-0">
        <h1 class="fw-bold mb-0">My Reminders</h1>
        <p class="text-muted mb-0">Manage your personal reminders and alerts</p>
      </BCol>
      <BCol md="4" class="text-md-end">
        <BButton variant="primary" @click="openModal()" class="fw-bold px-4 w-100 w-md-auto">
          + Add Reminder
        </BButton>
      </BCol>
    </BRow>

    <!-- Loading -->
    <div v-if="loading" class="text-center py-5">
      <BSpinner variant="primary" /> <span class="ms-2 text-muted">Loading reminders...</span>
    </div>

    <!-- Empty State -->
    <BCard v-else-if="reminders.length === 0" class="text-center py-5 border-0 shadow-sm">
      <div class="display-1 mb-3">🔔</div>
      <h3 class="fw-bold">No Reminders Yet</h3>
      <p class="text-muted">Add a birthday, anniversary, or recharge reminder to get started.</p>
      <BButton variant="primary" @click="openModal()">Add Your First Reminder</BButton>
    </BCard>

    <!-- Reminders Table -->
    <BCard v-else class="shadow-sm border-0">
      <BTable
        :items="reminders"
        :fields="tableFields"
        hover
        responsive
        class="mb-0"
      >
        <template #cell(type)="{ item }">
          <BBadge :variant="typeBadge(item.type).variant" class="px-3 py-2">
            {{ typeBadge(item.type).icon }} {{ item.type.charAt(0).toUpperCase() + item.type.slice(1) }}
          </BBadge>
        </template>

        <template #cell(reminder_date)="{ item }">
          {{ formatDate(item.reminder_date) }}
          <span class="text-muted small ms-1">({{ item.repeat_yearly ? 'Yearly' : 'Once' }})</span>
        </template>

        <template #cell(days_remaining)="{ item }">
          <BBadge
            :variant="item.days_remaining <= 3 ? 'danger' : item.days_remaining <= 7 ? 'warning' : 'success'"
            class="px-2 py-1"
          >
            {{ item.days_remaining === 0 ? 'Today!' : `${item.days_remaining} days` }}
          </BBadge>
        </template>

        <template #cell(actions)="{ item }">
          <div class="d-flex gap-2">
            <BButton size="sm" variant="outline-primary" @click="openModal(item)">Edit</BButton>
            <BButton size="sm" variant="outline-danger" @click="deleteReminder(item.id)">Delete</BButton>
          </div>
        </template>
      </BTable>
    </BCard>

    <!-- Add/Edit Modal -->
    <BModal v-model="showModal" :title="editingId ? 'Edit Reminder' : 'Add Reminder'" @ok="saveReminder" ok-title="Save" cancel-title="Cancel">
      <BForm>
        <BFormGroup label="Title" class="mb-3 fw-semibold">
          <BFormInput v-model="form.title" placeholder="e.g. Mom's Birthday" required />
        </BFormGroup>

        <BFormGroup label="Type" class="mb-3 fw-semibold">
          <BFormSelect v-model="form.type" :options="typeOptions" required />
        </BFormGroup>

        <!-- Mobile Number: only shown for recharge type -->
        <BFormGroup v-if="form.type === 'recharge'" label="Mobile Number" class="mb-3 fw-semibold">
          <BFormInput v-model="form.mobile_number" type="tel" placeholder="e.g. 9876543210" />
          <div class="form-text">Add separate reminders for each number.</div>
        </BFormGroup>

        <BFormGroup label="Date" class="mb-3 fw-semibold">
          <BFormInput v-model="form.reminder_date" type="date" required />
        </BFormGroup>

        <BFormGroup label="Repeat" class="mb-3 fw-semibold">
          <BFormSelect v-model="form.repeat_type" :options="repeatOptions" />
        </BFormGroup>

        <BFormGroup label="Notes (optional)" class="mb-3 fw-semibold">
          <BFormTextarea v-model="form.notes" rows="2" placeholder="Any additional notes..." />
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

const reminders = ref([])
const loading = ref(true)
const showModal = ref(false)
const editingId = ref(null)

const form = reactive({
  title: '',
  type: 'birthday',
  reminder_date: '',
  repeat_type: 'yearly',
  mobile_number: '',
  notes: ''
})

const tableFields = [
  { key: 'title', label: 'Title' },
  { key: 'type', label: 'Type' },
  { key: 'mobile_number', label: 'Mobile No.' },
  { key: 'reminder_date', label: 'Date' },
  { key: 'days_remaining', label: 'Days Left' },
  { key: 'notes', label: 'Notes' },
  { key: 'actions', label: 'Actions' }
]

const typeOptions = [
  { value: 'birthday', text: '🎂 Birthday' },
  { value: 'anniversary', text: '💍 Anniversary' },
  { value: 'recharge', text: '📱 Mobile Recharge' },
  { value: 'custom', text: '📅 Custom' }
]

const repeatOptions = computed(() => {
  const opts = [
    { value: 'none', text: 'No repeat (once)' },
    { value: 'yearly', text: 'Every year' },
  ]
  if (form.type === 'recharge') {
    opts.splice(1, 0, { value: 'monthly', text: 'Every month' })
  }
  return opts
})

function typeBadge(type) {
  const map = {
    birthday: { variant: 'danger', icon: '🎂' },
    anniversary: { variant: 'warning', icon: '💍' },
    recharge: { variant: 'success', icon: '📱' },
    custom: { variant: 'info', icon: '📅' }
  }
  return map[type] || { variant: 'secondary', icon: '📌' }
}

function formatDate(d) {
  return new Date(d).toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' })
}

function authHeaders() {
  return { Authorization: `Bearer ${auth.token}` }
}

async function fetchReminders() {
  loading.value = true
  try {
    const data = await $fetch(`${config.public.apiBase}/reminders`, { headers: authHeaders() })
    reminders.value = data
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
    form.reminder_date = item.reminder_date
    form.repeat_type = item.repeat_type || 'yearly'
    form.mobile_number = item.mobile_number || ''
    form.notes = item.notes || ''
  } else {
    editingId.value = null
    form.title = ''
    form.type = 'birthday'
    form.reminder_date = ''
    form.repeat_type = 'yearly'
    form.mobile_number = ''
    form.notes = ''
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

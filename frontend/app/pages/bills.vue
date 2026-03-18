<template>
  <BContainer class="py-5">
    <!-- Header -->
    <BRow class="mb-4 align-items-center">
      <BCol md="8" class="mb-3 mb-md-0 d-flex align-items-center">
        <LightbulbIcon :size="32" class="text-primary me-3" />
        <div>
          <h1 class="fw-bold mb-0">Bill Payment Tracker</h1>
          <p class="text-muted mb-0">Track recurring bills, due dates, and payment status</p>
        </div>
      </BCol>
      <BCol md="4" class="text-md-end">
        <BButton variant="primary" @click="openModal()" class="fw-bold px-4 w-100 w-md-auto d-flex align-items-center justify-content-center gap-2">
          <PlusIcon :size="18" /> Add Bill
        </BButton>
      </BCol>
    </BRow>

    <!-- Summary Row -->
    <BRow class="mb-4">
      <BCol md="4" class="mb-3">
        <BCard class="border-0 shadow-sm text-center h-100">
          <p class="text-secondary small fw-bold text-uppercase mb-1">Total Bills</p>
          <h2 class="fw-black text-primary mb-0">{{ bills.length }}</h2>
        </BCard>
      </BCol>
      <BCol md="4" class="mb-3">
        <BCard class="border-0 shadow-sm text-center h-100">
          <p class="text-secondary small fw-bold text-uppercase mb-1">Due This Month</p>
          <h2 class="fw-black text-warning mb-0">{{ unpaidBills.length }}</h2>
        </BCard>
      </BCol>
      <BCol md="4" class="mb-3">
        <BCard class="border-0 shadow-sm text-center h-100">
          <p class="text-secondary small fw-bold text-uppercase mb-1">Paid This Month</p>
          <h2 class="fw-black text-success mb-0">{{ paidBills.length }}</h2>
        </BCard>
      </BCol>
    </BRow>

    <!-- Loading -->
    <div v-if="loading" class="text-center py-5"><BSpinner variant="primary" /></div>

    <!-- Empty -->
    <BCard v-else-if="bills.length === 0" class="border-0 shadow-sm text-center py-5">
      <div class="mb-3 text-muted opacity-50">
        <LightbulbIcon :size="64" class="mx-auto" />
      </div>
      <h4 class="fw-bold">No bills added yet</h4>
      <p class="text-muted">Add your first bill to start tracking due dates.</p>
      <BButton variant="primary" @click="openModal()" class="d-inline-flex align-items-center gap-2">
        <PlusIcon :size="18" /> Add Bill
      </BButton>
    </BCard>

    <!-- Bills Table -->
    <BCard v-else class="border-0 shadow-sm">
      <BTable :items="bills" :fields="tableFields" responsive hover class="mb-0">
        <template #cell(name)="{ item }">
          <div class="d-flex align-items-center gap-3">
            <div class="p-2 rounded bg-light">
              <component :is="getCategory(item.category).icon" :size="20" :class="getCategory(item.category).color" />
            </div>
            <div>
              <p class="fw-bold mb-0 text-main">{{ item.name }}</p>
              <small class="text-muted">{{ getCategory(item.category).text }}</small>
            </div>
          </div>
        </template>
        <template #cell(amount)="{ item }">
          <span class="fw-semibold">{{ item.amount ? '₹' + item.amount : '—' }}</span>
        </template>
        <template #cell(due)="{ item }">
          <div>
            <span class="fw-semibold">{{ ordinal(item.due_day) }} of month</span><br>
            <small :class="item.days_until_due <= 3 ? 'text-danger fw-bold' : 'text-muted'" class="d-flex align-items-center gap-1">
              <template v-if="item.days_until_due === 0">
                <AlertTriangleIcon :size="14" /> Due Today
              </template>
              <template v-else-if="item.days_until_due < 0">
                 <AlertTriangleIcon :size="14" /> Overdue
              </template>
              <template v-else>
                 <ClockIcon :size="14" /> in {{ item.days_until_due }} days
              </template>
            </small>
          </div>
        </template>
        <template #cell(status)="{ item }">
          <BBadge :variant="item.is_paid_this_month ? 'success' : 'warning'" class="d-inline-flex align-items-center gap-1 px-2 py-1">
            <CheckCircleIcon v-if="item.is_paid_this_month" :size="12" />
            <ClockIcon v-else :size="12" />
            {{ item.is_paid_this_month ? 'Paid' : 'Pending' }}
          </BBadge>
        </template>
        <template #cell(actions)="{ item }">
          <div class="d-flex gap-2">
            <BButton v-if="!item.is_paid_this_month" size="sm" variant="success" @click="markPaid(item.id)" class="d-flex align-items-center gap-1">
              <CheckCircleIcon :size="14" /> Mark Paid
            </BButton>
            <BButton size="sm" variant="outline-primary" @click="openModal(item)" class="d-flex align-items-center gap-1">
              <PencilIcon :size="14" /> Edit
            </BButton>
            <BButton size="sm" variant="outline-danger" @click="deleteBill(item.id)" class="d-flex align-items-center">
              <Trash2Icon :size="14" />
            </BButton>
          </div>
        </template>
      </BTable>
    </BCard>

    <!-- Add/Edit Modal -->
    <BModal v-model="showModal" :title="editingId ? 'Edit Bill' : 'Add Bill'"
      ok-title="Save" @ok.prevent="saveBill" size="lg">
      <BAlert v-if="formError" variant="danger" show>{{ formError }}</BAlert>
      <BForm>
        <BRow>
          <BCol md="6">
            <BFormGroup label="Bill Name" class="mb-3 fw-semibold">
              <BFormInput v-model="form.name" placeholder="e.g. MSEDCL Electricity" required />
            </BFormGroup>
          </BCol>
          <BCol md="6">
            <BFormGroup label="Category" class="mb-3 fw-semibold">
              <BFormSelect v-model="form.category" :options="categoryOptions" required />
            </BFormGroup>
          </BCol>
        </BRow>
        <BRow>
          <BCol md="4">
            <BFormGroup label="Expected Amount (₹)" class="mb-3 fw-semibold">
              <BFormInput v-model="form.amount" type="number" min="0" placeholder="e.g. 500" />
            </BFormGroup>
          </BCol>
          <BCol md="4">
            <BFormGroup label="Due Day (of month)" class="mb-3 fw-semibold">
              <BFormInput v-model.number="form.due_day" type="number" min="1" max="31" required />
            </BFormGroup>
          </BCol>
          <BCol md="4">
            <BFormGroup label="Recurring?" class="mb-3 fw-semibold">
              <BFormCheckbox v-model="form.auto_renews" switch>Monthly recurring</BFormCheckbox>
            </BFormGroup>
          </BCol>
        </BRow>
        <BFormGroup label="Notes (optional)" class="mb-3 fw-semibold">
          <BFormTextarea v-model="form.notes" rows="2" />
        </BFormGroup>
      </BForm>
    </BModal>
  </BContainer>
</template>

<script setup>
import { 
  LightbulbIcon, ZapIcon, DropletsIcon, FlameIcon, GlobeIcon, 
  SmartphoneIcon, CreditCardIcon, ShieldCheckIcon, LandmarkIcon, 
  ClipboardListIcon, AlertTriangleIcon, CheckCircleIcon, ClockIcon, Trash2Icon,
  PlusIcon, PencilIcon
} from 'lucide-vue-next'
import { useAuthStore } from '~/stores/auth'

definePageMeta({ middleware: 'auth' })

const config = useRuntimeConfig()
const auth = useAuthStore()
const { show: showToast } = useToast()

const bills = ref([])
const loading = ref(true)
const showModal = ref(false)
const editingId = ref(null)
const formError = ref('')

const form = reactive({ name: '', category: 'electricity', amount: '', due_day: 15, auto_renews: true, notes: '' })

const tableFields = [
  { key: 'name', label: 'Bill' },
  { key: 'amount', label: 'Amount' },
  { key: 'due', label: 'Due Date' },
  { key: 'status', label: 'Status' },
  { key: 'actions', label: 'Actions' },
]

const categoryOptions = [
  { value: 'electricity', text: 'Electricity', icon: ZapIcon, color: 'text-warning' },
  { value: 'water', text: 'Water', icon: DropletsIcon, color: 'text-info' },
  { value: 'gas', text: 'Gas / LPG', icon: FlameIcon, color: 'text-danger' },
  { value: 'internet', text: 'Internet / Broadband', icon: GlobeIcon, color: 'text-primary' },
  { value: 'phone', text: 'Phone / Mobile', icon: SmartphoneIcon, color: 'text-success' },
  { value: 'credit_card', text: 'Credit Card', icon: CreditCardIcon, color: 'text-dark' },
  { value: 'insurance', text: 'Insurance Premium', icon: ShieldCheckIcon, color: 'text-primary' },
  { value: 'emi', text: 'EMI / Loan', icon: LandmarkIcon, color: 'text-secondary' },
  { value: 'other', text: 'Other', icon: ClipboardListIcon, color: 'text-muted' },
]

function getCategory(val) { return categoryOptions.find(o => o.value === val) || categoryOptions[8] }

function ordinal(n) {
  const s = ['th', 'st', 'nd', 'rd']
  const v = n % 100
  return n + (s[(v - 20) % 10] || s[v] || s[0])
}

const unpaidBills = computed(() => bills.value.filter(b => !b.is_paid_this_month))
const paidBills   = computed(() => bills.value.filter(b => b.is_paid_this_month))

function authHeaders() { return { Authorization: `Bearer ${auth.token}` } }

async function fetchBills() {
  loading.value = true
  try {
    bills.value = await $fetch(`${config.public.apiBase}/bills`, { headers: authHeaders() })
  } catch (e) { console.error(e) } finally { loading.value = false }
}

function openModal(item = null) {
  formError.value = ''
  if (item) {
    editingId.value = item.id
    form.name = item.name; form.category = item.category; form.amount = item.amount
    form.due_day = item.due_day; form.auto_renews = item.auto_renews; form.notes = item.notes || ''
  } else {
    editingId.value = null
    form.name = ''; form.category = 'electricity'; form.amount = ''; form.due_day = 15; form.auto_renews = true; form.notes = ''
  }
  showModal.value = true
}

async function saveBill() {
  if (!form.name) { formError.value = 'Bill name is required.'; return }
  const payload = { ...form, amount: form.amount || null }
  const method = editingId.value ? 'PUT' : 'POST'
  const url = editingId.value
    ? `${config.public.apiBase}/bills/${editingId.value}`
    : `${config.public.apiBase}/bills`
  try {
    await $fetch(url, { method, body: payload, headers: authHeaders() })
    showModal.value = false
    showToast({ title: 'Success', body: 'Bill saved successfully!', variant: 'success' })
    await fetchBills()
  } catch (e) {
    formError.value = e.data?.message || Object.values(e.data?.errors || {})[0]?.[0] || 'Failed to save.'
  }
}

async function markPaid(id) {
  try {
    await $fetch(`${config.public.apiBase}/bills/${id}/mark-paid`, { method: 'POST', headers: authHeaders() })
    showToast({ title: 'Paid', body: 'Bill marked as paid!', variant: 'success' })
    await fetchBills()
  } catch (e) {
    showToast({ title: 'Error', body: 'Failed to mark bill as paid.', variant: 'danger' })
  }
}

async function deleteBill(id) {
  if (!confirm('Remove this bill?')) return
  try {
    await $fetch(`${config.public.apiBase}/bills/${id}`, { method: 'DELETE', headers: authHeaders() })
    showToast({ title: 'Removed', body: 'Bill removed successfully.', variant: 'success' })
    await fetchBills()
  } catch (e) {
    showToast({ title: 'Error', body: 'Failed to delete bill.', variant: 'danger' })
  }
}

onMounted(fetchBills)
</script>

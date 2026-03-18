<template>
  <BContainer class="py-5">
    <!-- Header -->
    <BRow class="mb-4 align-items-center">
      <BCol md="8" class="mb-3 mb-md-0 d-flex align-items-center">
        <BarChart3Icon :size="32" class="text-primary me-3" />
        <div>
          <h1 class="fw-bold mb-0 text-main">Budget Tracker</h1>
          <p class="text-muted mb-0">Monitor your income, expenses, and savings</p>
        </div>
      </BCol>
      <BCol md="4" class="text-md-end d-flex gap-2 justify-content-md-end">
        <BButton variant="success" @click="openModal('income')" class="fw-bold d-flex align-items-center gap-2">
          <TrendingUpIcon :size="18" /> Income
        </BButton>
        <BButton variant="danger" @click="openModal('expense')" class="fw-bold d-flex align-items-center gap-2">
          <TrendingDownIcon :size="18" /> Expense
        </BButton>
      </BCol>
    </BRow>

    <div v-if="loading" class="text-center py-5">
      <BSpinner variant="primary" />
      <p class="text-muted mt-2">Loading budget data...</p>
    </div>

    <div v-else>
      <!-- Summary Cards -->
      <BRow class="mb-4">
        <BCol md="4" class="mb-3 mb-md-0">
          <BCard class="border-0 shadow-sm text-center h-100">
            <div class="p-2 rounded-circle bg-success bg-opacity-10 d-inline-block mx-auto mb-2">
              <CircleDollarSignIcon :size="24" class="text-success" />
            </div>
            <h6 class="text-muted mb-1 small fw-bold text-uppercase">Total Income</h6>
            <h3 class="fw-bold text-success">₹{{ (totals.income || 0).toLocaleString('en-IN') }}</h3>
          </BCard>
        </BCol>
        <BCol md="4" class="mb-3 mb-md-0">
          <BCard class="border-0 shadow-sm text-center h-100">
            <div class="p-2 rounded-circle bg-danger bg-opacity-10 d-inline-block mx-auto mb-2">
              <BanknoteIcon :size="24" class="text-danger" />
            </div>
            <h6 class="text-muted mb-1 small fw-bold text-uppercase">Total Expenses</h6>
            <h3 class="fw-bold text-danger">₹{{ (totals.expense || 0).toLocaleString('en-IN') }}</h3>
          </BCard>
        </BCol>
        <BCol md="4">
          <BCard class="border-0 shadow-sm text-center h-100">
            <div class="p-2 rounded-circle bg-primary bg-opacity-10 d-inline-block mx-auto mb-2">
               <TrendingUpIcon v-if="(totals.income - totals.expense) >= 0" :size="24" class="text-primary" />
               <TrendingDownIcon v-else :size="24" class="text-danger" />
            </div>
            <h6 class="text-muted mb-1 small fw-bold text-uppercase">Balance</h6>
            <h3 class="fw-bold" :class="(totals.income - totals.expense) >= 0 ? 'text-primary' : 'text-danger'">
              ₹{{ ((totals.income || 0) - (totals.expense || 0)).toLocaleString('en-IN') }}
            </h3>
          </BCard>
        </BCol>
      </BRow>

      <BRow>
        <BCol lg="8" class="mb-4">
          <BCard class="border-0 shadow-sm h-100 overflow-hidden">
            <template #header>
              <div class="py-1 fw-bold d-flex align-items-center gap-2">
                <CreditCardIcon :size="18" class="text-primary" /> Recent Transactions
              </div>
            </template>
            <BTable :items="transactions" :fields="tableFields" responsive hover class="mb-0">
              <template #cell(type)="{ item }">
                <BBadge :variant="item.type === 'income' ? 'success' : 'danger'" class="d-inline-flex align-items-center gap-1">
                  <TrendingUpIcon v-if="item.type === 'income'" :size="12" />
                  <TrendingDownIcon v-else :size="12" />
                  {{ item.type === 'income' ? 'Income' : 'Expense' }}
                </BBadge>
              </template>
              <template #cell(amount)="{ item }">
                <span :class="item.type === 'income' ? 'text-success' : 'text-danger'" class="fw-bold">
                  {{ item.type === 'income' ? '+' : '-' }}₹{{ Number(item.amount).toLocaleString('en-IN') }}
                </span>
              </template>
              <template #cell(date)="{ item }">
                <span class="text-muted small">{{ formatDate(item.date) }}</span>
              </template>
              <template #cell(actions)="{ item }">
                <BButton size="sm" variant="outline-danger" @click="deleteTransaction(item.id)" class="p-1 px-2">
                  <Trash2Icon :size="14" />
                </BButton>
              </template>
            </BTable>
            <div v-if="transactions.length === 0" class="text-center py-5 text-muted">No transactions recorded yet.</div>
          </BCard>
        </BCol>

        <BCol lg="4" class="mb-4">
          <BCard class="border-0 shadow-sm h-100">
            <template #header>
              <div class="py-1 fw-bold d-flex align-items-center gap-2">
                <BarChart3Icon :size="18" class="text-primary" /> Expense Breakdown
              </div>
            </template>
            <div v-if="!breakdown || Object.keys(breakdown).length === 0" class="text-center py-5 text-muted small">
              No expense data available for breakdown.
            </div>
            <div v-else class="p-2">
              <div v-for="(amt, cat) in breakdown" :key="cat" class="mb-3">
                <div class="d-flex justify-content-between mb-1 small">
                  <span class="text-capitalize fw-semibold text-muted">{{ cat }}</span>
                  <span class="fw-bold">₹{{ amt.toLocaleString('en-IN') }}</span>
                </div>
                <BProgress :value="amt" :max="totals.expense" variant="primary" height="6px" animated />
              </div>
            </div>
          </BCard>
        </BCol>
      </BRow>
    </div>

    <!-- Modal -->
    <BModal v-model="showModal" @ok.prevent="saveTransaction" :ok-title="'Save ' + (modalType === 'income' ? 'Income' : 'Expense')">
      <template #title>
        <div class="d-flex align-items-center gap-2">
          <TrendingUpIcon v-if="modalType === 'income'" class="text-success" />
          <TrendingDownIcon v-else class="text-danger" />
          Add {{ modalType === 'income' ? 'Income' : 'Expense' }}
        </div>
      </template>
      <BForm @submit.prevent="saveTransaction">
        <BAlert v-if="formError" variant="danger" show dismissible>{{ formError }}</BAlert>
        
        <BFormGroup label="Amount (₹)" class="mb-3 fw-semibold">
          <BFormInput v-model.number="form.amount" type="number" required placeholder="0.00" />
        </BFormGroup>
        
        <BFormGroup label="Category" class="mb-3 fw-semibold">
          <BFormSelect v-model="form.category" :options="modalType === 'income' ? incomeCats : expenseCats" required />
        </BFormGroup>
        
        <BFormGroup label="Description" class="mb-3 fw-semibold">
          <BFormInput v-model="form.description" placeholder="e.g. Monthly Salary, Grocery bill" required />
        </BFormGroup>
        
        <BFormGroup label="Date" class="mb-3 fw-semibold">
          <BFormInput v-model="form.date" type="date" required />
        </BFormGroup>
      </BForm>
    </BModal>
  </BContainer>
</template>

<script setup>
import { 
  BarChart3Icon, CircleDollarSignIcon, BanknoteIcon, CreditCardIcon,
  TrendingUpIcon, TrendingDownIcon, Trash2Icon, PlusIcon, PencilIcon
} from 'lucide-vue-next'
import { useAuthStore } from '~/stores/auth'
import { useToast } from 'bootstrap-vue-next'

definePageMeta({ middleware: 'auth' })

const config = useRuntimeConfig()
const auth = useAuthStore()
const { show: showToast } = useToast()

const transactions = ref([])
const totals = ref({ income: 0, expense: 0 })
const breakdown = ref({})
const loading = ref(true)
const showModal = ref(false)
const modalType = ref('expense')
const formError = ref('')

const form = reactive({ 
  amount: '', 
  category: '', 
  description: '', 
  date: new Date().toISOString().slice(0, 10) 
})

const incomeCats = [
  { value: 'Salary', text: 'Salary' },
  { value: 'Freelance', text: 'Freelance' },
  { value: 'Business', text: 'Business' },
  { value: 'Investment', text: 'Investment' },
  { value: 'Gift', text: 'Gift' },
  { value: 'Other', text: 'Other' }
]

const expenseCats = [
  { value: 'Food', text: 'Food & Dining' },
  { value: 'Rent', text: 'Rent / Home' },
  { value: 'Utilities', text: 'Bills & Utilities' },
  { value: 'Shopping', text: 'Shopping' },
  { value: 'Transport', text: 'Transport' },
  { value: 'Medical', text: 'Medical' },
  { value: 'Entertainment', text: 'Entertainment' },
  { value: 'Other', text: 'Other' }
]

const tableFields = [
  { key: 'date', label: 'Date' },
  { key: 'description', label: 'Description' },
  { key: 'category', label: 'Category' },
  { key: 'type', label: 'Type' },
  { key: 'amount', label: 'Amount' },
  { key: 'actions', label: 'Actions' },
]

function authHeaders() { return { Authorization: `Bearer ${auth.token}` } }

function formatDate(d) {
  return new Date(d).toLocaleDateString('en-IN', { day: 'numeric', month: 'short' })
}

async function fetchBudget() {
  loading.value = true
  try {
    const data = await $fetch(`${config.public.apiBase}/budget/summary`, { headers: authHeaders() })
    transactions.value = data.recent_transactions || []
    totals.value = data.totals || { income: 0, expense: 0 }
    breakdown.value = data.category_breakdown || {}
  } catch (e) {
    console.error(e)
    showToast('Failed to fetch budget data.', { variant: 'danger' })
  } finally {
    loading.value = false
  }
}

function openModal(type) {
  modalType.value = type
  form.amount = ''
  form.description = ''
  form.category = type === 'income' ? 'Salary' : 'Other'
  form.date = new Date().toISOString().slice(0, 10)
  formError.value = ''
  showModal.value = true
}

async function saveTransaction() {
  if (!form.amount || form.amount <= 0) { formError.value = 'Please enter a valid amount.'; return }
  if (!form.category) { formError.value = 'Please select a category.'; return }
  
  try {
    await $fetch(`${config.public.apiBase}/transactions`, {
      method: 'POST',
      body: { ...form, type: modalType.value },
      headers: authHeaders(),
    })
    showModal.value = false
    showToast(`${modalType.value.charAt(0).toUpperCase() + modalType.value.slice(1)} added successfully!`, { variant: 'success' })
    fetchBudget()
  } catch (e) {
    formError.value = e.data?.message || 'Failed to save transaction. Please try again.'
  }
}

async function deleteTransaction(id) {
  if (!confirm('Are you sure you want to delete this transaction?')) return
  
  try {
    await $fetch(`${config.public.apiBase}/transactions/${id}`, {
      method: 'DELETE',
      headers: authHeaders(),
    })
    showToast('Transaction deleted successfully.', { variant: 'success' })
    fetchBudget()
  } catch (e) {
    showToast('Failed to delete transaction.', { variant: 'danger' })
  }
}

onMounted(fetchBudget)
</script>

<style scoped>
.text-main { color: #2c3338; }
.fw-black { font-weight: 900; }
</style>

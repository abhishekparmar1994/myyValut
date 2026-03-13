<template>
  <BContainer class="py-5">
    <BRow class="mb-4 align-items-center">
      <BCol md="6" class="mb-3 mb-md-0">
        <h1 class="fw-bold mb-0">📊 Monthly Budget</h1>
        <p class="text-muted mb-0">Track your income and expenses every month</p>
      </BCol>
      <BCol md="6" class="text-md-end d-flex flex-wrap gap-2 justify-content-md-end align-items-center">
        <BFormInput v-model="currentMonth" type="month" style="max-width:160px;" class="flex-grow-1 flex-md-grow-0" @change="fetchAll" />
        <div class="d-flex gap-2 w-100 w-md-auto">
          <BButton variant="success" @click="openModal('income')" class="fw-semibold flex-grow-1">+ Income</BButton>
          <BButton variant="danger" @click="openModal('expense')" class="fw-semibold flex-grow-1">− Expense</BButton>
        </div>
      </BCol>
    </BRow>

    <!-- Summary Cards -->
    <BRow class="mb-4">
      <BCol md="4" class="mb-3">
        <BCard class="border-0 shadow-sm text-center h-100">
          <p class="text-secondary small fw-bold text-uppercase mb-1">Total Income</p>
          <h2 class="fw-black text-success mb-0">₹{{ summary.income.toLocaleString('en-IN') }}</h2>
        </BCard>
      </BCol>
      <BCol md="4" class="mb-3">
        <BCard class="border-0 shadow-sm text-center h-100">
          <p class="text-secondary small fw-bold text-uppercase mb-1">Total Expenses</p>
          <h2 class="fw-black text-danger mb-0">₹{{ summary.expense.toLocaleString('en-IN') }}</h2>
        </BCard>
      </BCol>
      <BCol md="4" class="mb-3">
        <BCard class="border-0 shadow-sm text-center h-100">
          <p class="text-secondary small fw-bold text-uppercase mb-1">Balance</p>
          <h2 class="fw-black mb-0" :class="summary.balance >= 0 ? 'text-primary' : 'text-danger'">
            ₹{{ summary.balance.toLocaleString('en-IN') }}
          </h2>
        </BCard>
      </BCol>
    </BRow>

    <!-- Category Breakdown + Transactions -->
    <BRow>
      <BCol lg="4" class="mb-4">
        <BCard class="border-0 shadow-sm h-100">
          <template #header><div class="py-1 fw-bold">📊 Expense Breakdown</div></template>
          <div v-if="Object.keys(summary.breakdown).length === 0" class="text-muted small text-center py-3">
            No expenses yet this month.
          </div>
          <div v-else>
            <div v-for="(amount, cat) in summary.breakdown" :key="cat" class="d-flex justify-content-between align-items-center mb-2">
              <span class="small fw-semibold">{{ cat }}</span>
              <span class="small text-danger fw-bold">₹{{ amount.toLocaleString('en-IN') }}</span>
            </div>
          </div>
        </BCard>
      </BCol>

      <BCol lg="8" class="mb-4">
        <BCard class="border-0 shadow-sm h-100">
          <template #header><div class="py-1 fw-bold">💳 Transactions</div></template>

          <div v-if="loading" class="text-center py-3"><BSpinner small /></div>

          <div v-else-if="transactions.length === 0" class="text-center py-4 text-muted small">
            No transactions for this month yet.
          </div>

          <BTable v-else :items="transactions" :fields="tableFields" responsive hover class="mb-0">
            <template #cell(type)="{ item }">
              <BBadge :variant="item.type === 'income' ? 'success' : 'danger'">
                {{ item.type === 'income' ? '💰 Income' : '💸 Expense' }}
              </BBadge>
            </template>
            <template #cell(amount)="{ item }">
              <span :class="item.type === 'income' ? 'text-success' : 'text-danger'" class="fw-bold">
                {{ item.type === 'income' ? '+' : '−' }}₹{{ Number(item.amount).toLocaleString('en-IN') }}
              </span>
            </template>
            <template #cell(actions)="{ item }">
              <BButton size="sm" variant="outline-danger" @click="deleteTx(item.id)">🗑</BButton>
            </template>
          </BTable>
        </BCard>
      </BCol>
    </BRow>

    <!-- Add Modal -->
    <BModal v-model="showModal" :title="formType === 'income' ? '💰 Add Income' : '💸 Add Expense'"
      :ok-variant="formType === 'income' ? 'success' : 'danger'"
      ok-title="Add" @ok.prevent="saveTransaction">
      <BAlert v-if="formError" variant="danger" show>{{ formError }}</BAlert>
      <BForm>
        <BFormGroup label="Category" class="mb-3 fw-semibold">
          <BFormSelect v-model="form.category" :options="categoryOptions" required />
        </BFormGroup>
        <BRow>
          <BCol md="6">
            <BFormGroup label="Amount (₹)" class="mb-3 fw-semibold">
              <BFormInput v-model.number="form.amount" type="number" min="0.01" step="0.01" required />
            </BFormGroup>
          </BCol>
          <BCol md="6">
            <BFormGroup label="Date" class="mb-3 fw-semibold">
              <BFormInput v-model="form.date" type="date" required />
            </BFormGroup>
          </BCol>
        </BRow>
        <BFormGroup label="Description (optional)" class="mb-3 fw-semibold">
          <BFormInput v-model="form.description" placeholder="e.g. Monthly salary, Grocery shopping" />
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

const transactions = ref([])
const summary = reactive({ income: 0, expense: 0, balance: 0, breakdown: {} })
const loading = ref(true)
const showModal = ref(false)
const formType = ref('expense')
const formError = ref('')
const currentMonth = ref(new Date().toISOString().slice(0, 7))

const form = reactive({ category: '', amount: '', date: new Date().toISOString().slice(0, 10), description: '' })

const incomeCategories = ['Salary', 'Freelance', 'Business', 'Rent Income', 'Investment', 'Gift', 'Other Income']
const expenseCategories = ['Food', 'Grocery', 'Transport', 'Medical', 'Shopping', 'Entertainment', 'Education', 'Utility Bill', 'Rent', 'EMI', 'Insurance', 'Other']

const categoryOptions = computed(() =>
  (formType.value === 'income' ? incomeCategories : expenseCategories).map(c => ({ value: c, text: c }))
)

const tableFields = [
  { key: 'date', label: 'Date' },
  { key: 'type', label: 'Type' },
  { key: 'category', label: 'Category' },
  { key: 'description', label: 'Description' },
  { key: 'amount', label: 'Amount' },
  { key: 'actions', label: '' },
]

function authHeaders() { return { Authorization: `Bearer ${auth.token}` } }

async function fetchAll() {
  loading.value = true
  try {
    const [txData, sumData] = await Promise.all([
      $fetch(`${config.public.apiBase}/transactions?month=${currentMonth.value}`, { headers: authHeaders() }),
      $fetch(`${config.public.apiBase}/transactions/summary?month=${currentMonth.value}`, { headers: authHeaders() }),
    ])
    transactions.value = txData
    Object.assign(summary, sumData)
  } catch (e) { console.error(e) } finally { loading.value = false }
}

function openModal(type) {
  formType.value = type
  form.category = type === 'income' ? 'Salary' : 'Food'
  form.amount = ''; form.description = ''
  form.date = new Date().toISOString().slice(0, 10)
  formError.value = ''
  showModal.value = true
}

async function saveTransaction() {
  if (!form.amount || form.amount <= 0) { formError.value = 'Enter a valid amount.'; return }
  if (!form.category) { formError.value = 'Category is required.'; return }
  try {
    await $fetch(`${config.public.apiBase}/transactions`, {
      method: 'POST',
      body: { ...form, type: formType.value },
      headers: authHeaders(),
    })
    showModal.value = false
    await fetchAll()
  } catch (e) {
    formError.value = e.data?.message || Object.values(e.data?.errors || {})[0]?.[0] || 'Failed to save.'
  }
}

async function deleteTx(id) {
  if (!confirm('Delete this transaction?')) return
  await $fetch(`${config.public.apiBase}/transactions/${id}`, { method: 'DELETE', headers: authHeaders() })
  await fetchAll()
}

onMounted(fetchAll)
</script>

<template>
  <BContainer class="py-5">
    <!-- Header -->
    <BRow class="mb-4 align-items-center">
      <BCol md="8" class="mb-3 mb-md-0">
        <h1 class="fw-bold mb-0">📄 My Documents</h1>
        <p class="text-muted mb-0">Securely store and manage your important documents</p>
      </BCol>
      <BCol md="4" class="text-md-end">
        <BButton variant="primary" @click="showUploadModal = true" class="fw-bold px-4 w-100 w-md-auto">
          + Upload Document
        </BButton>
      </BCol>
    </BRow>

    <!-- Category Filter Tabs -->
    <BNav tabs class="mb-4 flex-nowrap overflow-auto text-nowrap pb-1">
      <BNavItem
        v-for="cat in categories"
        :key="cat.value"
        :active="activeCategory === cat.value"
        @click="activeCategory = cat.value"
        class="fw-semibold"
      >
        {{ cat.icon }} {{ cat.label }}
        <BBadge v-if="countByCategory(cat.value)" pill variant="primary" class="ms-1">
          {{ cat.value === 'all' ? documents.length : countByCategory(cat.value) }}
        </BBadge>
      </BNavItem>
    </BNav>

    <!-- Loading -->
    <div v-if="loading" class="text-center py-5">
      <BSpinner variant="primary" /> <span class="ms-2 text-muted">Loading documents...</span>
    </div>

    <!-- Empty State -->
    <BCard v-else-if="filteredDocuments.length === 0" class="text-center py-5 border-0 shadow-sm">
      <div class="display-1 mb-3">📂</div>
      <h3 class="fw-bold">No Documents Yet</h3>
      <p class="text-muted">Upload your Aadhaar, PAN, or any other document to keep it secure.</p>
      <BButton variant="primary" @click="showUploadModal = true">Upload Your First Document</BButton>
    </BCard>

    <!-- Document Grid -->
    <BRow v-else>
      <BCol
        v-for="doc in filteredDocuments"
        :key="doc.id"
        md="4" sm="6" class="mb-4"
      >
        <BCard class="h-100 shadow-sm border-0 doc-card">
          <!-- File type icon area -->
          <div class="text-center py-3 rounded mb-3" :class="categoryColor(doc.category)">
            <span style="font-size: 2.5rem;">{{ fileIcon(doc.mime_type) }}</span>
          </div>

          <h5 class="fw-bold mb-1 text-truncate" :title="doc.name">{{ doc.name }}</h5>
          <p class="text-muted small mb-1">
            <BBadge :variant="categoryBadge(doc.category)" class="me-1">{{ doc.document_type }}</BBadge>
          </p>
          <p class="text-muted small mb-3">
            📁 {{ doc.file_name }}<br>
            📦 {{ doc.file_size }} &nbsp;·&nbsp; 📅 {{ doc.created_at }}
          </p>
          <p v-if="doc.notes" class="text-muted small fst-italic border-top pt-2 mb-3">{{ doc.notes }}</p>

          <div class="d-flex gap-2 mt-auto">
            <BButton
              size="sm"
              variant="outline-primary"
              class="flex-grow-1 fw-semibold"
              @click="downloadDoc(doc)"
            >
              ⬇ Download
            </BButton>
            <BButton
              size="sm"
              variant="outline-danger"
              @click="deleteDoc(doc.id)"
            >
              🗑
            </BButton>
          </div>
        </BCard>
      </BCol>
    </BRow>

    <!-- Upload Modal -->
    <BModal
      v-model="showUploadModal"
      title="Upload Document"
      ok-title="Upload"
      cancel-title="Cancel"
      @ok.prevent="uploadDocument"
      size="lg"
    >
      <BForm @submit.prevent="uploadDocument">
        <BAlert v-if="uploadError" variant="danger" show dismissible>{{ uploadError }}</BAlert>

        <BRow>
          <BCol md="6">
            <BFormGroup label="Label / Name" class="mb-3 fw-semibold">
              <BFormInput v-model="form.name" placeholder="e.g. My Aadhaar Card" required />
            </BFormGroup>
          </BCol>
          <BCol md="6">
            <BFormGroup label="Category" class="mb-3 fw-semibold">
              <BFormSelect v-model="form.category" :options="categoryOptions" required />
            </BFormGroup>
          </BCol>
        </BRow>

        <BFormGroup label="Document Type" class="mb-3 fw-semibold">
          <BFormSelect v-model="form.document_type" :options="documentTypeOptions" required />
        </BFormGroup>

        <BFormGroup label="File" class="mb-3 fw-semibold">
          <!-- Drag & Drop Zone -->
          <div
            class="drop-zone rounded p-4 text-center border-2"
            :class="{ 'drop-active': isDragging }"
            @dragover.prevent="isDragging = true"
            @dragleave="isDragging = false"
            @drop.prevent="onFileDrop"
            @click="$refs.fileInput.click()"
          >
            <input ref="fileInput" type="file" class="d-none" accept=".jpg,.jpeg,.png,.pdf,.doc,.docx,.xls,.xlsx" @change="onFileChange" />
            <div v-if="!form.file">
              <div class="fs-1 mb-2">📎</div>
              <p class="fw-semibold mb-1">Drag & drop or click to browse</p>
              <p class="text-muted small mb-0">Supports: JPG, PNG, PDF, DOC, DOCX, XLS, XLSX (max 10MB)</p>
            </div>
            <div v-else class="text-success fw-semibold">
              ✅ {{ form.file.name }} ({{ (form.file.size / 1024).toFixed(1) }} KB)
            </div>
          </div>
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

const documents = ref([])
const loading = ref(true)
const showUploadModal = ref(false)
const uploadError = ref('')
const isDragging = ref(false)
const activeCategory = ref('all')
const fileInput = ref(null)

const form = reactive({
  name: '', category: 'identity', document_type: '', notes: '', file: null
})

const categories = [
  { value: 'all',      label: 'All',      icon: '📁' },
  { value: 'identity', label: 'Identity', icon: '🪪' },
  { value: 'property', label: 'Property', icon: '🏠' },
  { value: 'general',  label: 'General',  icon: '📋' },
  { value: 'bills',    label: 'Bills',    icon: '🧾' },
]

const categoryOptions = [
  { value: 'identity', text: '🪪 Identity Documents' },
  { value: 'property', text: '🏠 Property Documents' },
  { value: 'general',  text: '📋 General Documents' },
  { value: 'bills',    text: '🧾 Bills & Invoices' },
]

const documentTypes = {
  identity: ['Aadhaar Card', 'PAN Card', 'Passport', 'Voter ID', 'Driving License', 'Ration Card', 'Birth Certificate', 'Other'],
  property: ['Property Deed', 'Sale Deed', 'Lease Agreement', 'Rent Agreement', 'NOC', 'Electricity Bill', 'Water Bill', 'Other'],
  general:  ['Educational Certificate', 'Medical Record', 'Insurance Policy', 'Bank Statement', 'IT Return', 'Other'],
  bills:    ['Shopping Invoice', 'Electronics Bill', 'Medical Bill', 'Restaurant Bill', 'Vehicle Bill', 'Other'],
}

const documentTypeOptions = computed(() =>
  (documentTypes[form.category] || []).map(t => ({ value: t, text: t }))
)

watch(() => form.category, () => { form.document_type = '' })

const filteredDocuments = computed(() =>
  activeCategory.value === 'all'
    ? documents.value
    : documents.value.filter(d => d.category === activeCategory.value)
)

function countByCategory(cat) {
  if (cat === 'all') return documents.value.length
  return documents.value.filter(d => d.category === cat).length
}

function fileIcon(mime) {
  if (!mime) return '📄'
  if (mime.startsWith('image/')) return '🖼️'
  if (mime === 'application/pdf') return '📕'
  if (mime.includes('spreadsheet') || mime.includes('excel')) return '📊'
  if (mime.includes('word') || mime.includes('document')) return '📝'
  return '📄'
}

function categoryColor(cat) {
  const map = { identity: 'bg-primary bg-opacity-10', property: 'bg-success bg-opacity-10', general: 'bg-secondary bg-opacity-10', bills: 'bg-warning bg-opacity-10' }
  return map[cat] || 'bg-light'
}

function categoryBadge(cat) {
  const map = { identity: 'primary', property: 'success', general: 'secondary', bills: 'warning' }
  return map[cat] || 'secondary'
}

function authHeaders() {
  return { Authorization: `Bearer ${auth.token}` }
}

async function fetchDocuments() {
  loading.value = true
  try {
    documents.value = await $fetch(`${config.public.apiBase}/documents`, { headers: authHeaders() })
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
}

function onFileChange(e) {
  form.file = e.target.files[0] || null
}

function onFileDrop(e) {
  isDragging.value = false
  form.file = e.dataTransfer.files[0] || null
}

async function uploadDocument() {
  if (!form.file) { uploadError.value = 'Please select a file to upload.'; return }
  if (!form.document_type) { uploadError.value = 'Please select a document type.'; return }

  uploadError.value = ''
  const fd = new FormData()
  fd.append('name', form.name)
  fd.append('category', form.category)
  fd.append('document_type', form.document_type)
  fd.append('notes', form.notes || '')
  fd.append('file', form.file)

  try {
    // Use native fetch (not $fetch) so the browser sets the correct
    // multipart/form-data Content-Type boundary automatically
    const res = await fetch(`${config.public.apiBase}/documents`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${auth.token}` }, // No Content-Type — let browser handle it
      body: fd,
    })

    if (!res.ok) {
      let msg = 'Upload failed. Please try again.'
      try {
        const err = await res.json()
        msg = err.message || (Object.values(err)[0]?.[0]) || msg
      } catch (_) {
        // Response might be HTML (Laravel exception page) — show generic error
        msg = `Server error (${res.status}). Make sure you have run: php artisan migrate`
      }
      uploadError.value = msg
      return
    }

    showUploadModal.value = false
    form.name = ''; form.category = 'identity'; form.document_type = ''; form.notes = ''; form.file = null
    if (fileInput.value) fileInput.value.value = ''
    showToast({ title: 'Success', body: 'Document uploaded successfully!', variant: 'success' })
    await fetchDocuments()
  } catch (e) {
    uploadError.value = 'Network error. Make sure the backend is running.'
  }
}

async function downloadDoc(doc) {
  const url = `${config.public.apiBase}/documents/${doc.id}/download`
  const res = await fetch(url, { headers: authHeaders() })
  const blob = await res.blob()
  const link = document.createElement('a')
  link.href = URL.createObjectURL(blob)
  link.download = doc.file_name
  link.click()
  URL.revokeObjectURL(link.href)
}

async function deleteDoc(id) {
  if (!confirm('Delete this document? This cannot be undone.')) return
  try {
    await $fetch(`${config.public.apiBase}/documents/${id}`, { method: 'DELETE', headers: authHeaders() })
    showToast({ title: 'Deleted', body: 'Document removed successfully.', variant: 'success' })
    await fetchDocuments()
  } catch (e) {
    showToast({ title: 'Error', body: 'Failed to delete document.', variant: 'danger' })
    console.error(e)
  }
}

onMounted(fetchDocuments)
</script>

<style scoped>
.doc-card {
  transition: transform 0.2s, box-shadow 0.2s;
}
.doc-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 24px rgba(0,0,0,0.1) !important;
}
.drop-zone {
  border: 2px dashed #ced4da;
  cursor: pointer;
  transition: border-color 0.2s, background 0.2s;
  background: #f8f9fa;
}
.drop-zone:hover, .drop-active {
  border-color: #0d6efd;
  background: #e8f0fe;
}
</style>

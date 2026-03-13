<template>
  <BContainer class="py-5">
    <BRow class="mb-4 align-items-center">
      <BCol md="7" class="mb-3 mb-md-0">
        <h1 class="fw-bold mb-0">📋 Notes & To-Dos</h1>
        <p class="text-muted mb-0">Quick notes, pinned items, and to-do lists</p>
      </BCol>
      <BCol md="5" class="text-md-end d-flex gap-2 justify-content-md-end">
        <BButton variant="outline-primary" @click="openModal('note')" class="fw-semibold flex-grow-1 flex-md-grow-0">📝 Note</BButton>
        <BButton variant="primary" @click="openModal('todo')" class="fw-semibold flex-grow-1 flex-md-grow-0">✅ To-Do</BButton>
      </BCol>
    </BRow>

    <!-- Filter Tabs -->
    <BNav pills class="mb-4 gap-2">
      <BNavItem :active="filter === 'all'"  @click="filter = 'all'">All</BNavItem>
      <BNavItem :active="filter === 'note'" @click="filter = 'note'">📝 Notes</BNavItem>
      <BNavItem :active="filter === 'todo'" @click="filter = 'todo'">✅ To-Dos</BNavItem>
    </BNav>

    <div v-if="loading" class="text-center py-5"><BSpinner variant="primary" /></div>

    <div v-else-if="filtered.length === 0" class="text-center py-5">
      <div class="display-1 mb-2">📋</div>
      <h4 class="fw-bold">Nothing here yet</h4>
      <p class="text-muted">Add your first note or to-do.</p>
    </div>

    <!-- Notes Grid -->
    <BRow v-else>
      <BCol v-for="note in filtered" :key="note.id" md="4" sm="6" class="mb-4">
        <BCard class="h-100 border-0 shadow-sm note-card"
          :style="note.color ? `background:${note.color}` : ''">
          <div class="d-flex justify-content-between align-items-start mb-2">
            <div class="d-flex align-items-center gap-2">
              <BBadge :variant="note.type === 'todo' ? 'success' : 'primary'" class="small">
                {{ note.type === 'todo' ? '✅ To-Do' : '📝 Note' }}
              </BBadge>
              <span v-if="note.is_pinned" title="Pinned">📌</span>
            </div>
            <div class="d-flex gap-1">
              <BButton size="sm" variant="link" class="p-0 text-muted" @click="togglePin(note)">
                {{ note.is_pinned ? '📌' : '🔲' }}
              </BButton>
              <BButton size="sm" variant="link" class="p-0 text-muted" @click="openEdit(note)">✏️</BButton>
              <BButton size="sm" variant="link" class="p-0 text-danger" @click="deleteNote(note.id)">🗑</BButton>
            </div>
          </div>

          <!-- Todo checkbox -->
          <div v-if="note.type === 'todo'" class="d-flex align-items-center gap-2 mb-2">
            <input type="checkbox" :checked="note.is_done" @change="toggleDone(note)"
              class="form-check-input mt-0" style="cursor:pointer;width:1.2em;height:1.2em;" />
            <h5 class="mb-0 fw-bold" :class="{ 'text-decoration-line-through text-muted': note.is_done }">
              {{ note.title }}
            </h5>
          </div>
          <h5 v-else class="fw-bold mb-2">{{ note.title }}</h5>

          <p v-if="note.content" class="text-muted small mb-2 note-content">{{ note.content }}</p>
          <small class="text-muted">{{ note.created_at }}</small>
        </BCard>
      </BCol>
    </BRow>

    <!-- Add/Edit Modal -->
    <BModal v-model="showModal" :title="editingId ? 'Edit' : (formType === 'todo' ? '✅ New To-Do' : '📝 New Note')"
      ok-title="Save" @ok.prevent="saveNote">
      <BAlert v-if="formError" variant="danger" show>{{ formError }}</BAlert>
      <BForm>
        <BFormGroup label="Title" class="mb-3 fw-semibold">
          <BFormInput v-model="form.title" :placeholder="formType === 'todo' ? 'e.g. Buy groceries' : 'e.g. Meeting notes'" required />
        </BFormGroup>
        <BFormGroup label="Content (optional)" class="mb-3 fw-semibold">
          <BFormTextarea v-model="form.content" rows="4" placeholder="Details..." />
        </BFormGroup>
        <BFormGroup label="Card Color (optional)" class="mb-3 fw-semibold">
          <div class="d-flex gap-2 flex-wrap">
            <span v-for="c in colorOptions" :key="c"
              @click="form.color = c"
              class="color-dot rounded-circle border"
              :style="`background:${c};width:28px;height:28px;cursor:pointer;${form.color === c ? 'outline:3px solid #0d6efd' : ''}`">
            </span>
            <span @click="form.color = null" class="color-dot rounded-circle border bg-white"
              style="width:28px;height:28px;cursor:pointer;font-size:12px;display:flex;align-items:center;justify-content:center;">✕</span>
          </div>
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

const notes = ref([])
const loading = ref(true)
const showModal = ref(false)
const editingId = ref(null)
const formType = ref('note')
const formError = ref('')
const filter = ref('all')

const form = reactive({ title: '', content: '', color: null })

const colorOptions = ['#fef3c7', '#dbeafe', '#dcfce7', '#fce7f3', '#f3e8ff', '#fed7aa']

const filtered = computed(() => {
  const sorted = [...notes.value].sort((a, b) => b.is_pinned - a.is_pinned)
  return filter.value === 'all' ? sorted : sorted.filter(n => n.type === filter.value)
})

function authHeaders() { return { Authorization: `Bearer ${auth.token}` } }

function openModal(type) {
  formError.value = ''
  editingId.value = null
  formType.value = type
  form.title = ''; form.content = ''; form.color = null
  showModal.value = true
}

function openEdit(note) {
  editingId.value = note.id
  formType.value = note.type
  form.title = note.title; form.content = note.content || ''; form.color = note.color
  showModal.value = true
}

async function fetchNotes() {
  loading.value = true
  try {
    notes.value = await $fetch(`${config.public.apiBase}/notes`, { headers: authHeaders() })
  } catch (e) { console.error(e) } finally { loading.value = false }
}

async function saveNote() {
  if (!form.title) { formError.value = 'Title is required.'; return }
  const payload = { title: form.title, content: form.content, color: form.color, type: formType.value }
  const method = editingId.value ? 'PUT' : 'POST'
  const url = editingId.value
    ? `${config.public.apiBase}/notes/${editingId.value}`
    : `${config.public.apiBase}/notes`
  try {
    await $fetch(url, { method, body: payload, headers: authHeaders() })
    showModal.value = false
    showToast({ title: 'Success', body: 'Note/To-Do saved!', variant: 'success' })
    await fetchNotes()
  } catch (e) { formError.value = 'Failed to save.' }
}

async function toggleDone(note) {
  await $fetch(`${config.public.apiBase}/notes/${note.id}`, {
    method: 'PUT', body: { is_done: !note.is_done }, headers: authHeaders()
  })
  showToast({ title: note.is_done ? 'Reopened' : 'Done!', body: note.is_done ? 'Task marked as pending.' : 'Task completed.', variant: 'success' })
  await fetchNotes()
}

async function togglePin(note) {
  await $fetch(`${config.public.apiBase}/notes/${note.id}`, {
    method: 'PUT', body: { is_pinned: !note.is_pinned }, headers: authHeaders()
  })
  showToast({ title: note.is_pinned ? 'Unpinned' : 'Pinned', body: note.is_pinned ? 'Item unpinned from top.' : 'Item pinned to top.', variant: 'info' })
  await fetchNotes()
}

async function deleteNote(id) {
  if (!confirm('Delete this note?')) return
  try {
    await $fetch(`${config.public.apiBase}/notes/${id}`, { method: 'DELETE', headers: authHeaders() })
    showToast({ title: 'Deleted', body: 'Note removed successfully.', variant: 'success' })
    await fetchNotes()
  } catch (e) {
    showToast({ title: 'Error', body: 'Failed to delete note.', variant: 'danger' })
  }
}

onMounted(fetchNotes)
</script>

<style scoped>
.note-card { transition: transform 0.2s, box-shadow 0.2s; }
.note-card:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(0,0,0,0.1) !important; }
.note-content { white-space: pre-line; max-height: 120px; overflow: hidden; }
.color-dot:hover { opacity: 0.8; }
</style>

<template>
  <BContainer class="py-5">
    <!-- Header -->
    <BRow class="mb-4 align-items-center">
      <BCol md="8" class="mb-3 mb-md-0 d-flex align-items-center">
        <UserIcon :size="32" class="text-primary me-3" />
        <div>
          <h1 class="fw-bold mb-0 text-main">My Profile</h1>
          <p class="text-muted mb-0">Manage your personal information and account settings</p>
        </div>
      </BCol>
      <BCol md="4" class="text-md-end">
        <BButton variant="outline-danger" @click="handleLogout" class="fw-bold d-flex align-items-center justify-content-center gap-2 w-100 w-md-auto ms-auto">
          <LogOutIcon :size="18" /> Logout
        </BButton>
      </BCol>
    </BRow>

    <div v-if="loading" class="text-center py-5">
      <BSpinner variant="primary" />
      <p class="text-muted mt-2">Loading profile...</p>
    </div>

    <BRow v-else>
      <!-- Left: Profile Overview -->
      <BCol lg="4" class="mb-4">
        <BCard class="border-0 shadow-sm text-center h-100 position-relative">
          <div class="position-relative d-inline-block mb-4 mt-3">
            <div class="rounded-circle overflow-hidden border border-4 border-primary border-opacity-10 shadow-sm mx-auto" style="width:140px;height:140px;">
              <img
                v-if="profile.profile_image_url"
                :src="storageUrl(profile.profile_image_url) + '?t=' + imageKey"
                alt="Profile"
                class="w-100 h-100"
                style="object-fit:cover;"
              />
              <div v-else class="w-100 h-100 bg-primary d-flex align-items-center justify-content-center text-white" style="font-size:3.5rem;font-weight:900;">
                {{ profile.name?.charAt(0)?.toUpperCase() }}
              </div>
            </div>
            <label for="avatar-upload" class="position-absolute bottom-0 end-0 bg-primary text-white rounded-circle d-flex align-items-center justify-content-center shadow-sm" style="width:40px;height:40px;cursor:pointer;border:3px solid white;">
              <CameraIcon :size="20" />
            </label>
            <input id="avatar-upload" type="file" accept="image/*" class="d-none" @change="uploadImage" />
          </div>

          <h4 class="fw-bold mb-1 text-main">{{ profile.name }}</h4>
          <p class="text-muted small mb-4">{{ profile.email }}</p>
          
          <div v-if="uploadingImage" class="mb-3 text-primary small animate-pulse">
            <BSpinner small variant="primary" class="me-2" /> Uploading photo...
          </div>

          <hr class="my-4 opacity-10" />
          
          <div class="text-start px-2">
            <div class="d-flex align-items-center gap-3 mb-3">
              <div class="detail-icon bg-primary bg-opacity-10 text-primary rounded-3 p-2">
                <UserIcon :size="18" />
              </div>
              <div>
                <small class="text-muted d-block lh-1 mb-1 small fw-bold text-uppercase" style="font-size: 0.65rem; letter-spacing: 0.5px;">Full Name</small>
                <span class="fw-semibold">{{ profile.name }}</span>
              </div>
            </div>
            <div class="d-flex align-items-center gap-3 mb-3">
              <div class="detail-icon bg-success bg-opacity-10 text-success rounded-3 p-2">
                <SmartphoneIcon :size="18" />
              </div>
              <div>
                <small class="text-muted d-block lh-1 mb-1 small fw-bold text-uppercase" style="font-size: 0.65rem; letter-spacing: 0.5px;">Phone Number</small>
                <span class="fw-semibold">{{ profile.phone || '—' }}</span>
              </div>
            </div>
            <div class="d-flex align-items-center gap-3 mb-3">
              <div class="detail-icon bg-info bg-opacity-10 text-info rounded-3 p-2">
                <CakeIcon :size="18" />
              </div>
              <div>
                <small class="text-muted d-block lh-1 mb-1 small fw-bold text-uppercase" style="font-size: 0.65rem; letter-spacing: 0.5px;">Birth Date</small>
                <span class="fw-semibold">{{ profile.date_of_birth || '—' }}</span>
              </div>
            </div>
            <div class="d-flex align-items-center gap-3 mb-0">
              <div class="detail-icon bg-danger bg-opacity-10 text-danger rounded-3 p-2">
                <MapPinIcon :size="18" />
              </div>
              <div>
                <small class="text-muted d-block lh-1 mb-1 small fw-bold text-uppercase" style="font-size: 0.65rem; letter-spacing: 0.5px;">City</small>
                <span class="fw-semibold">{{ profile.city || '—' }}</span>
              </div>
            </div>
          </div>
        </BCard>
      </BCol>

      <!-- Right: Settings & Forms -->
      <BCol lg="8">
        <!-- Edit Details -->
        <BCard class="border-0 shadow-sm mb-4 overflow-hidden">
          <template #header>
            <div class="py-1 fw-bold d-flex align-items-center gap-2">
              <PencilIcon :size="18" class="text-primary" /> Edit Personal Details
            </div>
          </template>
          <BForm @submit.prevent="saveProfile">
            <BRow>
              <BCol md="6" class="mb-3">
                <BFormGroup label="Full Name" class="fw-semibold small">
                  <BFormInput v-model="form.name" required placeholder="Your full name" />
                </BFormGroup>
              </BCol>
              <BCol md="6" class="mb-3">
                <BFormGroup label="Email Address (Locked)" class="fw-semibold small">
                  <BFormInput :value="profile.email" disabled class="bg-light" />
                </BFormGroup>
              </BCol>
              <BCol md="6" class="mb-3">
                <BFormGroup label="Phone Number" class="fw-semibold small">
                  <BFormInput v-model="form.phone" type="tel" placeholder="e.g. 9876543210" />
                </BFormGroup>
              </BCol>
              <BCol md="6" class="mb-3">
                <BFormGroup label="Birth Date" class="fw-semibold small">
                  <BFormInput v-model="form.date_of_birth" type="date" />
                </BFormGroup>
              </BCol>
              <BCol md="8" class="mb-4">
                <BFormGroup label="Address" class="fw-semibold small">
                  <BFormInput v-model="form.address" placeholder="Street / Society / Area" />
                </BFormGroup>
              </BCol>
              <BCol md="4" class="mb-4">
                <BFormGroup label="City" class="fw-semibold small">
                  <BFormInput v-model="form.city" placeholder="e.g. Mumbai" />
                </BFormGroup>
              </BCol>
            </BRow>
            <div class="text-end">
              <BButton type="submit" variant="primary" :disabled="savingProfile" class="fw-bold px-4 d-inline-flex align-items-center gap-2">
                <CheckCircleIcon v-if="!savingProfile" :size="18" />
                <BSpinner v-else small />
                {{ savingProfile ? 'Saving...' : 'Save Changes' }}
              </BButton>
            </div>
          </BForm>
        </BCard>

        <!-- Security -->
        <BCard class="border-0 shadow-sm mb-4 overflow-hidden">
          <template #header>
            <div class="py-1 fw-bold d-flex align-items-center gap-2">
              <LockIcon :size="18" class="text-primary" /> Change Password
            </div>
          </template>
          <BForm @submit.prevent="changePassword">
            <BFormGroup label="Current Password" class="mb-3 fw-semibold small">
              <BFormInput v-model="pw.current_password" type="password" required placeholder="••••••••" />
            </BFormGroup>
            <BRow>
              <BCol md="6" class="mb-3">
                <BFormGroup label="New Password" class="fw-semibold small">
                  <BFormInput v-model="pw.password" type="password" required placeholder="At least 8 characters" minlength="8" />
                </BFormGroup>
              </BCol>
              <BCol md="6" class="mb-3">
                <BFormGroup label="Confirm New Password" class="fw-semibold small">
                  <BFormInput v-model="pw.password_confirmation" type="password" required placeholder="••••••••" />
                </BFormGroup>
              </BCol>
            </BRow>
            <div class="text-end">
              <BButton type="submit" variant="dark" :disabled="savingPw" class="fw-bold px-4 d-inline-flex align-items-center gap-2">
                <LockIcon v-if="!savingPw" :size="18" />
                <BSpinner v-else small />
                {{ savingPw ? 'Updating...' : 'Change Password' }}
              </BButton>
            </div>
          </BForm>
        </BCard>

        <!-- Themes -->
        <BCard class="border-0 shadow-sm mb-4">
          <template #header>
            <div class="py-1 fw-bold d-flex align-items-center gap-2">
              <PaletteIcon :size="18" class="text-primary" /> App Theme
            </div>
          </template>
          <div class="row g-3">
            <div v-for="t in themeOptions" :key="t.id" class="col-6 col-md-3">
              <div 
                class="theme-card p-3 rounded-4 border text-center cursor-pointer transition-all h-100 d-flex flex-column align-items-center justify-content-center"
                :class="{ 'border-primary bg-primary bg-opacity-10 shadow-sm': form.theme === t.id }"
                @click="updateThemePreview(t.id)"
              >
                <div class="theme-bubble mb-2 border shadow-sm rounded-circle" :style="`background: ${t.color}; width: 32px; height: 32px;` "></div>
                <div class="small fw-bold">{{ t.name }}</div>
              </div>
            </div>
          </div>
        </BCard>
      </BCol>
    </BRow>
  </BContainer>
</template>

<script setup>
import { 
  UserIcon, CameraIcon, SmartphoneIcon, CakeIcon, 
  MapPinIcon, PencilIcon, LockIcon, PaletteIcon, 
  LogOutIcon, CheckCircleIcon 
} from 'lucide-vue-next'
import { useAuthStore } from '~/stores/auth'

definePageMeta({ middleware: 'auth' })

const config  = useRuntimeConfig()
const auth    = useAuthStore()
const { show: showToast } = useToast()

// State
const profile = ref({})
const loading = ref(true)
const imageKey = ref(Date.now())

const form = reactive({ 
  name: '', phone: '', date_of_birth: '', 
  address: '', city: '', theme: 'light' 
})

const pw = reactive({ 
  current_password: '', password: '', 
  password_confirmation: '' 
})

const savingProfile = ref(false)
const savingPw = ref(false)
const uploadingImage = ref(false)

const themeOptions = [
  { id: 'light', name: 'Light', color: '#0d6efd' },
  { id: 'dark', name: 'Dark', color: '#1e293b' },
  { id: 'vibrant', name: 'Vibrant', color: '#e11d48' },
  { id: 'glass', name: 'Glass', color: 'rgba(255,255,255,0.5)' },
  { id: 'ocean', name: 'Ocean', color: '#0284c7' },
  { id: 'forest', name: 'Forest', color: '#15803d' },
  { id: 'midnight', name: 'Midnight', color: '#6366f1' },
  { id: 'chatvibe', name: 'ChatVibe', color: '#3b71ed' },
]

const headers = computed(() => ({ Authorization: `Bearer ${auth.token}` }))
const backendBase = config.public.apiBase.replace(/\/api$/, '')

function storageUrl(path) {
  if (!path) return null
  if (path.startsWith('http')) return path
  return backendBase + path
}

async function fetchProfile() {
  loading.value = true
  try {
    const data = await $fetch(`${config.public.apiBase}/profile`, { headers: headers.value })
    profile.value = data
    auth.profileImageUrl = storageUrl(data.profile_image_url)
    form.name = data.name || ''
    form.phone = data.phone || ''
    form.date_of_birth = data.date_of_birth || ''
    form.address = data.address || ''
    form.city = data.city || ''
    form.theme = data.theme || 'light'
    applyThemeGlobally(form.theme)
  } catch (e) {
    console.error(e)
    showToast('Failed to load profile.', { variant: 'danger' })
  } finally {
    loading.value = false
  }
}

async function saveProfile() {
  savingProfile.value = true
  try {
    const res = await $fetch(`${config.public.apiBase}/profile`, {
      method: 'PUT', body: form, headers: headers.value
    })
    profile.value = res.user
    auth.setUser(res.user)
    showToast('Profile updated successfully!', { variant: 'success' })
  } catch (e) {
    showToast(e.data?.message || 'Update failed.', { variant: 'danger' })
  } finally {
    savingProfile.value = false
  }
}

async function changePassword() {
  if (pw.password !== pw.password_confirmation) {
    showToast('Passwords do not match.', { variant: 'warning' })
    return
  }
  savingPw.value = true
  try {
    const res = await $fetch(`${config.public.apiBase}/profile/password`, {
      method: 'PUT', body: pw, headers: headers.value
    })
    showToast(res.message || 'Password changed!', { variant: 'success' })
    pw.current_password = ''; pw.password = ''; pw.password_confirmation = ''
  } catch (e) {
    showToast(e.data?.message || 'Password change failed.', { variant: 'danger' })
  } finally {
    savingPw.value = false
  }
}

async function uploadImage(event) {
  const file = event.target.files?.[0]
  if (!file) return
  if (file.size > 2 * 1024 * 1024) {
    showToast('Image must be under 2MB.', { variant: 'warning' })
    return
  }

  uploadingImage.value = true
  const formData = new FormData()
  formData.append('image', file)

  try {
    const res = await $fetch(`${config.public.apiBase}/profile/image`, {
      method: 'POST', body: formData, headers: headers.value
    })
    profile.value.profile_image_url = res.profile_image_url
    imageKey.value = Date.now()
    auth.profileImageUrl = storageUrl(res.profile_image_url)
    showToast('Profile photo updated!', { variant: 'success' })
  } catch (e) {
    showToast('Upload failed.', { variant: 'danger' })
  } finally {
    uploadingImage.value = false
    event.target.value = ''
  }
}

function updateThemePreview(themeId) {
  form.theme = themeId
  applyThemeGlobally(themeId)
}

function applyThemeGlobally(themeId) {
  if (!process.client) return
  const body = document.body
  themeOptions.forEach(t => body.classList.remove(`theme-${t.id}`))
  if (themeId && themeId !== 'light') body.classList.add(`theme-${themeId}`)
}

function handleLogout() {
  if (confirm('Are you sure you want to logout?')) {
    auth.logout()
    navigateTo('/login')
  }
}

onMounted(fetchProfile)
</script>

<style scoped>
.text-main { color: #2c3338; }
.detail-icon {
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
}
.theme-card {
  transition: all 0.2s ease;
  border: 2px solid transparent;
}
.theme-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 4px 12px rgba(0,0,0,0.08);
}
.transition-all { transition: all 0.3s ease; }
.cursor-pointer { cursor: pointer; }
</style>

<template>
  <BContainer class="py-5">
    <BRow class="mb-4">
      <BCol>
        <h1 class="fw-bold mb-0">👤 My Profile</h1>
        <p class="text-muted mb-0">Manage your personal information and account settings</p>
      </BCol>
    </BRow>

    <div v-if="loading" class="text-center py-5"><BSpinner variant="primary" /></div>

    <BRow v-else>
      <!-- Left: Profile Image -->
      <BCol lg="4" class="mb-4">
        <BCard class="border-0 shadow-sm text-center h-100">
          <!-- Avatar -->
          <div class="position-relative d-inline-block mb-4">
            <div
              class="rounded-circle overflow-hidden border border-3 border-primary mx-auto"
              style="width:140px;height:140px;"
            >
              <img
                v-if="profile.profile_image_url"
                :src="storageUrl(profile.profile_image_url) + '?t=' + imageKey"
                alt="Profile"
                class="w-100 h-100"
                style="object-fit:cover;"
              />
              <div
                v-else
                class="w-100 h-100 bg-primary d-flex align-items-center justify-content-center text-white"
                style="font-size:3.5rem;font-weight:900;"
              >
                {{ profile.name?.charAt(0)?.toUpperCase() }}
              </div>
            </div>
            <!-- Camera overlay -->
            <label
              for="avatar-upload"
              class="position-absolute bottom-0 end-0 bg-primary text-white rounded-circle d-flex align-items-center justify-content-center"
              style="width:36px;height:36px;cursor:pointer;border:2px solid white;"
              title="Change photo"
            >
              📷
            </label>
            <input
              id="avatar-upload"
              type="file"
              accept="image/jpeg,image/png,image/webp"
              class="d-none"
              @change="uploadImage"
            />
          </div>

          <h3 class="fw-bold mb-0">{{ profile.name }}</h3>
          <p class="text-muted small mb-3">{{ profile.email }}</p>

          <div v-if="uploadingImage" class="mt-2 text-primary small">
            <BSpinner small variant="primary" class="me-2" /> Uploading...
          </div>

          <hr class="my-3" />
          <div class="text-start small text-muted">
            <div class="d-flex gap-2 mb-2"><span>📱</span><span>{{ profile.phone || '—' }}</span></div>
            <div class="d-flex gap-2 mb-2"><span>🎂</span><span>{{ profile.date_of_birth || '—' }}</span></div>
            <div class="d-flex gap-2 mb-2"><span>📍</span><span>{{ profile.city || '—' }}</span></div>
          </div>
        </BCard>
      </BCol>

      <!-- Right: Forms -->
      <BCol lg="8">
        <!-- Profile Details Form -->
        <BCard class="border-0 shadow-sm mb-4">
          <template #header><div class="py-1 fw-bold">✏️ Edit Profile Details</div></template>

          <BForm @submit.prevent="saveProfile">
            <BRow>
              <BCol md="6">
                <BFormGroup label="Full Name" class="mb-3 fw-semibold">
                  <BFormInput v-model="form.name" required placeholder="Your full name" />
                </BFormGroup>
              </BCol>
              <BCol md="6">
                <BFormGroup label="Email Address" class="mb-3 fw-semibold">
                  <BFormInput :value="profile.email" disabled type="email" />
                  <small class="text-muted">Email cannot be changed</small>
                </BFormGroup>
              </BCol>
            </BRow>
            <BRow>
              <BCol md="6">
                <BFormGroup label="Phone Number" class="mb-3 fw-semibold">
                  <BFormInput v-model="form.phone" type="tel" placeholder="e.g. 9876543210" maxlength="15" />
                </BFormGroup>
              </BCol>
              <BCol md="6">
                <BFormGroup label="Date of Birth" class="mb-3 fw-semibold">
                  <BFormInput v-model="form.date_of_birth" type="date" />
                </BFormGroup>
              </BCol>
            </BRow>
            <BRow>
              <BCol md="8">
                <BFormGroup label="Address" class="mb-3 fw-semibold">
                  <BFormInput v-model="form.address" placeholder="Street / Society / Area" />
                </BFormGroup>
              </BCol>
              <BCol md="4">
                <BFormGroup label="City" class="mb-3 fw-semibold">
                  <BFormInput v-model="form.city" placeholder="e.g. Mumbai" />
                </BFormGroup>
              </BCol>
            </BRow>
            <BButton type="submit" variant="primary" :disabled="savingProfile" class="fw-bold px-4">
              <BSpinner v-if="savingProfile" small class="me-2" /> Save Changes
            </BButton>
          </BForm>
        </BCard>

        <!-- Change Password Form -->
        <BCard class="border-0 shadow-sm">
          <template #header><div class="py-1 fw-bold">🔐 Change Password</div></template>

          <BForm @submit.prevent="changePassword">
            <BFormGroup label="Current Password" class="mb-3 fw-semibold">
              <BFormInput v-model="pw.current_password" type="password" placeholder="••••••••" required />
            </BFormGroup>
            <BRow>
              <BCol md="6">
                <BFormGroup label="New Password" class="mb-3 fw-semibold">
                  <BFormInput v-model="pw.password" type="password" placeholder="Min. 8 characters" required minlength="8" />
                </BFormGroup>
              </BCol>
              <BCol md="6">
                <BFormGroup label="Confirm New Password" class="mb-3 fw-semibold">
                  <BFormInput v-model="pw.password_confirmation" type="password" placeholder="••••••••" required />
                </BFormGroup>
              </BCol>
            </BRow>
            <BButton type="submit" variant="warning" :disabled="savingPw" class="fw-bold px-4">
              <BSpinner v-if="savingPw" small class="me-2" /> Change Password
            </BButton>
          </BForm>
        </BCard>
      </BCol>
    </BRow>
  </BContainer>
</template>

<script setup>
import { useAuthStore } from '~/stores/auth'

definePageMeta({ middleware: 'auth' })

const config  = useRuntimeConfig()
const auth    = useAuthStore()
const { show: showToast } = useToast()
const headers = computed(() => ({ Authorization: `Bearer ${auth.token}` }))

// Backend host — strip /api suffix from apiBase to get the storage URL root
// e.g. http://localhost:8000/api → http://localhost:8000
const backendBase = config.public.apiBase.replace(/\/api$/, '')

function storageUrl(path) {
  if (!path) return null
  if (path.startsWith('http')) return path
  return backendBase + path
}

// State
const profile = ref({})
const loading  = ref(true)

// Profile form
const form          = reactive({ name: '', phone: '', date_of_birth: '', address: '', city: '' })
const savingProfile = ref(false)
const profileSuccess = ref(''), profileError = ref('')

// Password form
const pw         = reactive({ current_password: '', password: '', password_confirmation: '' })
const savingPw   = ref(false)
const pwSuccess  = ref(''), pwError = ref('')

// Image upload
const uploadingImage = ref(false)
const imageSuccess   = ref(''), imageError = ref('')

// Timestamp to bust <img> src cache after upload
const imageKey = ref(Date.now())

async function fetchProfile() {
  loading.value = true
  try {
    const data = await $fetch(`${config.public.apiBase}/profile`, { headers: headers.value })
    profile.value = data
    // Also sync auth store so navbar shows correct image
    auth.profileImageUrl = storageUrl(data.profile_image_url)
    form.name          = data.name || ''
    form.phone         = data.phone || ''
    form.date_of_birth = data.date_of_birth || ''
    form.address       = data.address || ''
    form.city          = data.city || ''
  } catch (e) { console.error(e) } finally { loading.value = false }
}

async function saveProfile() {
  profileSuccess.value = ''; profileError.value = ''
  savingProfile.value = true
  try {
    const res = await $fetch(`${config.public.apiBase}/profile`, {
      method: 'PUT', body: { ...form }, headers: headers.value
    })
    profile.value = res.user
    // Update name in auth store
    if (auth.user) auth.user.name = res.user.name
    showToast({ title: 'Success', body: 'Profile updated successfully!', variant: 'success' })
  } catch (e) {
    showToast({ title: 'Error', body: e.data?.message || 'Update failed.', variant: 'danger' })
  } finally { savingProfile.value = false }
}

async function changePassword() {
  pwSuccess.value = ''; pwError.value = ''
  if (pw.password !== pw.password_confirmation) {
    pwError.value = 'Passwords do not match.'
    return
  }
  savingPw.value = true
  try {
    const res = await $fetch(`${config.public.apiBase}/profile/password`, {
      method: 'PUT', body: { ...pw }, headers: headers.value
    })
    showToast({ title: 'Success', body: res.message, variant: 'success' })
    pw.current_password = ''; pw.password = ''; pw.password_confirmation = ''
  } catch (e) {
    showToast({ title: 'Error', body: e.data?.message || 'Password change failed.', variant: 'danger' })
  } finally { savingPw.value = false }
}

async function uploadImage(event) {
  const file = event.target.files?.[0]
  if (!file) return
  if (file.size > 2 * 1024 * 1024) { imageError.value = 'Image must be under 2MB.'; return }

  imageError.value = ''; imageSuccess.value = ''
  uploadingImage.value = true

  const formData = new FormData()
  formData.append('image', file)

  try {
    const res = await fetch(`${config.public.apiBase}/profile/image`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${auth.token}` },
      body: formData,
    })
    if (!res.ok) throw await res.json()
    const data = await res.json()
    const fullUrl = storageUrl(data.profile_image_url)
    // Use the returned public URL directly
    profile.value.profile_image_url = data.profile_image_url
    profile.value.has_image = true
    imageKey.value = Date.now()           // bust any cached <img> src
    auth.profileImageUrl = fullUrl        // update navbar instantly
    showToast({ title: 'Success', body: 'Profile photo updated!', variant: 'success' })
  } catch (e) {
    showToast({ title: 'Error', body: e.message || 'Upload failed.', variant: 'danger' })
  } finally {
    uploadingImage.value = false
    event.target.value = ''  // reset file input
  }
}

onMounted(fetchProfile)
</script>

<style scoped>
label[for="avatar-upload"]:hover {
  opacity: 0.85;
  transform: scale(1.1);
  transition: transform 0.2s;
}
</style>

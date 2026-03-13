<template>
  <BContainer class="py-5">
    <BRow class="justify-content-center">
      <BCol md="6">
        <BCard class="p-4 shadow">
          <div class="text-center mb-4">
            <h2 class="fw-bold">Create Account</h2>
            <p class="text-muted">Create your free MyVault account</p>
          </div>

          <BAlert v-if="Object.keys(errors).length > 0" variant="danger" show>
            <ul class="mb-0 small">
              <li v-for="(error, field) in errors" :key="field">{{ error[0] }}</li>
            </ul>
          </BAlert>

          <BForm @submit.prevent="handleRegister">
            <BFormGroup label="Full Name" label-for="name" class="mb-3 fw-semibold">
              <BFormInput
                id="name"
                v-model="form.name"
                type="text"
                placeholder="John Doe"
                required
              />
            </BFormGroup>

            <BFormGroup label="Email Address" label-for="email" class="mb-3 fw-semibold">
              <BFormInput
                id="email"
                v-model="form.email"
                type="email"
                placeholder="name@example.com"
                required
              />
            </BFormGroup>

            <BRow>
              <BCol md="6">
                <BFormGroup label="Password" label-for="password" class="mb-3 fw-semibold">
                  <BFormInput
                    id="password"
                    v-model="form.password"
                    type="password"
                    placeholder="••••••••"
                    required
                  />
                </BFormGroup>
              </BCol>
              <BCol md="6">
                <BFormGroup label="Confirm Password" label-for="confirm" class="mb-4 fw-semibold">
                  <BFormInput
                    id="confirm"
                    v-model="form.password_confirmation"
                    type="password"
                    placeholder="••••••••"
                    required
                  />
                </BFormGroup>
              </BCol>
            </BRow>

            <BButton type="submit" variant="primary" class="w-100 py-2 mb-3 fw-bold" :disabled="loading">
              <BSpinner small v-if="loading" class="me-2" />
              {{ loading ? 'Creating Account...' : 'Register Now' }}
            </BButton>
          </BForm>

          <div class="text-center mt-4">
            <p class="text-muted small">
              Already have an account? 
              <NuxtLink to="/login" class="fw-bold text-decoration-none">Sign in</NuxtLink>
            </p>
          </div>
        </BCard>
      </BCol>
    </BRow>
  </BContainer>
</template>

<script setup>
import { useAuthStore } from '~/stores/auth'
const config = useRuntimeConfig()
const auth = useAuthStore()

// Redirect to home if already logged in
if (auth.isLoggedIn) {
  await navigateTo('/home')
}

const form = reactive({
  name: '',
  email: '',
  password: '',
  password_confirmation: ''
})

const loading = ref(false)
const errors = ref({})

async function handleRegister() {
  loading.value = true
  errors.value = {}
  
  try {
    const data = await $fetch(`${config.public.apiBase}/register`, {
      method: 'POST',
      body: form
    })
    
    auth.setToken(data.access_token)
    // Navigate immediately - home page will fetch user data
    await navigateTo('/home')
  } catch (err) {
    if (err.data && typeof err.data === 'object') {
      errors.value = err.data
    } else {
      errors.value = { message: ['Registration failed. Please try again.'] }
    }
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <BContainer class="py-5">
    <BRow class="justify-content-center">
      <BCol md="5">
        <BCard class="p-4 shadow">
          <div class="text-center mb-4">
            <h2 class="fw-bold">Sign In</h2>
            <p class="text-muted">Access your MyVault dashboard</p>
          </div>

          <BAlert v-if="error" variant="danger" show dismissible>
            {{ error }}
          </BAlert>

          <BForm @submit.prevent="handleLogin">
            <BFormGroup label="Email Address" label-for="email" class="mb-3 fw-semibold">
              <BFormInput
                id="email"
                v-model="form.email"
                type="email"
                placeholder="name@example.com"
                required
              />
            </BFormGroup>

            <BFormGroup label="Password" label-for="password" class="mb-4 fw-semibold">
              <BFormInput
                id="password"
                v-model="form.password"
                type="password"
                placeholder="••••••••"
                required
              />
            </BFormGroup>

            <BButton type="submit" variant="primary" class="w-100 py-2 mb-3 fw-bold" :disabled="loading">
              <BSpinner small v-if="loading" class="me-2" />
              {{ loading ? 'Signing In...' : 'Sign In' }}
            </BButton>
          </BForm>

          <div class="text-center mt-4">
            <p class="text-muted small">
              Don't have an account? 
              <NuxtLink to="/register" class="fw-bold text-decoration-none">Register here</NuxtLink>
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

const form = reactive({
  email: '',
  password: ''
})

const loading = ref(false)
const error = ref('')

async function handleLogin() {
  loading.value = true
  error.value = ''
  
  try {
    const data = await $fetch(`${config.public.apiBase}/login`, {
      method: 'POST',
      body: form
    })
    
    auth.setToken(data.access_token)
    // Navigate immediately - home page will fetch user data
    await navigateTo('/home')
  } catch (err) {
    error.value = err.data?.message || 'Login failed. Please check your credentials.'
  } finally {
    loading.value = false
  }
}
</script>

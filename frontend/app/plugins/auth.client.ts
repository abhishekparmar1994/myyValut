// This plugin runs before route middleware and restores the auth token
// from localStorage into the Pinia store, so the auth guard works correctly on page refresh.
export default defineNuxtPlugin(() => {
  const auth = useAuthStore()

  // Only run on client side
  if (import.meta.client) {
    const token = localStorage.getItem('auth_token')
    if (token) {
      auth.token = token
      // Fetch user in the background; don't await so it doesn't block rendering
      auth.fetchUser()
    }
  }
})

export default defineNuxtRouteMiddleware((to) => {
  const auth = useAuthStore()

  // On client, also check localStorage in case the store hasn't been hydrated yet
  const hasToken = auth.isLoggedIn || (import.meta.client && !!localStorage.getItem('auth_token'))

  const publicRoutes = ['/', '/login', '/register']
  if (!hasToken && !publicRoutes.includes(to.path)) {
    return navigateTo('/login')
  }

  // If already logged in, redirect away from login/register pages
  if (hasToken && (to.path === '/login' || to.path === '/register')) {
    return navigateTo('/home')
  }
})

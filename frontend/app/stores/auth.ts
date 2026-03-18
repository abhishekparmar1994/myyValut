import { defineStore } from 'pinia'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null as any,
    token: null as string | null,
    profileImageUrl: null as string | null,
    theme: 'light' as string,
  }),
  getters: {
    isLoggedIn: (state) => !!state.token,
  },
  actions: {
    setToken(token: string) {
      this.token = token
      if (process.client) {
        localStorage.setItem('auth_token', token)
      }
    },
    setUser(user: any) {
      this.user = user
      this.profileImageUrl = user?.profile_image_url ?? null
      this.theme = user?.theme ?? 'light'
      if (process.client) {
        localStorage.setItem('auth_theme', this.theme)
      }
      this.applyTheme()
    },
    async logout() {
      const config = useRuntimeConfig()
      try {
        await $fetch(`${config.public.apiBase}/logout`, {
          method: 'POST',
          headers: { Authorization: `Bearer ${this.token}` },
        })
      } catch (error) {
        console.error('Logout failed', error)
      } finally {
        this.token = null
        this.user = null
        this.profileImageUrl = null
        if (process.client) {
          localStorage.removeItem('auth_token')
          localStorage.removeItem('auth_theme')
        }
        navigateTo('/login')
      }
    },
    async fetchUser() {
      if (!this.token) return
      const config = useRuntimeConfig()
      try {
        // Fetch from /profile to get profile_image_url along with user data
        const profile = await $fetch<any>(`${config.public.apiBase}/profile`, {
          headers: { Authorization: `Bearer ${this.token}` },
        })
        this.user = profile
        this.profileImageUrl = profile.profile_image_url ?? null
        this.theme = profile.theme ?? 'light'
        if (process.client) {
          localStorage.setItem('auth_theme', this.theme)
        }
        this.applyTheme()
      } catch (error) {
        this.token = null
        this.user = null
        this.profileImageUrl = null
        if (process.client) {
          localStorage.removeItem('auth_token')
        }
      }
    },
    initialize() {
      if (process.client) {
        const token = localStorage.getItem('auth_token')
        const savedTheme = localStorage.getItem('auth_theme')
        if (savedTheme) {
          this.theme = savedTheme
          this.applyTheme()
        }
        if (token) {
          this.token = token
          this.fetchUser()
        }
      }
    },
    applyTheme() {
      if (!process.client) return
      const themeId = this.theme || 'light'
      const body = document.body
      const themes = ['dark', 'vibrant', 'glass', 'ocean', 'forest', 'midnight']
      themes.forEach(t => body.classList.remove(`theme-${t}`))
      if (themeId !== 'light') {
        body.classList.add(`theme-${themeId}`)
      }
    }
  },
})

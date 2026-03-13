// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2025-07-15',
  devtools: { enabled: true },
  ssr: false,  // SPA mode — auth uses localStorage which is client-only
  modules: ['@pinia/nuxt', '@bootstrap-vue-next/nuxt'],
  runtimeConfig: {
    public: {
      apiBase: process.env.NUXT_PUBLIC_API_BASE || 'http://localhost:8000/api',
      socketUrl: process.env.NUXT_PUBLIC_SOCKET_URL || 'http://localhost:3001'
    }
  },
  app: {
    head: {
      title: 'MyVault – Personal Document & Reminder Manager',
      meta: [
        { name: 'description', content: 'Store documents, manage reminders, and track your personal activity — all in one secure place.' }
      ],
      link: [
        { rel: 'preconnect', href: 'https://fonts.googleapis.com' },
        { rel: 'preconnect', href: 'https://fonts.gstatic.com', crossorigin: '' },
        { rel: 'stylesheet', href: 'https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap' }
      ]
    }
  },
  css: [
    'bootstrap/dist/css/bootstrap.min.css',
    '~/assets/css/main.css'
  ]
})

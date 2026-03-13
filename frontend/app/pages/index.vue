<template>
  <BContainer class="py-5">
    <!-- Hero Section -->
    <BRow class="align-items-center mb-5 py-5">
      <BCol lg="6" class="mb-4 mb-lg-0">
        <h1 class="display-3 fw-black text-dark mb-4 leading-tight">
          Your Portal to <span class="text-primary">Public Services</span>
        </h1>
        <p class="lead text-secondary mb-5">
          Access all government utilities, track service requests, and manage your citizen profile through our secure and unified platform.
        </p>
        <div class="d-flex flex-column flex-sm-row gap-3">
          <BButton as="NuxtLink" to="/register" variant="primary" size="lg" class="px-5 shadow-sm">Get Started</BButton>
          <BButton as="NuxtLink" to="/login" variant="outline-primary" size="lg" class="px-5">Member Login</BButton>
        </div>
      </BCol>
      <BCol lg="6" class="text-center">
        <div class="p-5 rounded-4 bg-primary bg-opacity-10">
          <h2 class="h4 fw-bold text-primary mb-3 text-uppercase tracking-wider">Secure & Trusted</h2>
          <p class="text-muted">Join over 1,000,000 citizens using GovUtility for their daily administrative needs.</p>
        </div>
      </BCol>
    </BRow>

    <!-- Features Section -->
    <BRow class="pt-5">
      <BCol md="4" class="mb-4" v-for="feature in features" :key="feature.title">
        <BCard class="h-100 shadow-sm hover-shadow transition">
          <div class="mb-4 text-primary h1">{{ feature.icon }}</div>
          <h3 class="h4 fw-bold mb-3">{{ feature.title }}</h3>
          <p class="text-muted small">{{ feature.desc }}</p>
        </BCard>
      </BCol>
    </BRow>
  </BContainer>
</template>

<script setup>
const features = [
  {
    title: 'Secure Access',
    desc: 'Our platform uses high-level encryption to ensure your personal data is protected and accessible only to you.',
    icon: '🛡️'
  },
  {
    title: 'Instant Updates',
    desc: 'Receive real-time notifications on the status of your requests and official government announcements.',
    icon: '⚡'
  },
  {
    title: 'Digital Services',
    desc: 'From tax payments to license renewals, everything you need is available in a few clicks.',
    icon: '💻'
  }
]
</script>

<style scoped>
.hover-shadow {
  transition: all 0.3s ease;
}
.hover-shadow:hover {
  transform: translateY(-5px);
  box-shadow: 0 1rem 3rem rgba(0,0,0,.175) !important;
}
</style>

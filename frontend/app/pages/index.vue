<template>
  <div class="landing-page position-relative overflow-hidden">
    <!-- Hero Section -->
    <BContainer class="py-5 text-center min-vh-75 d-flex flex-column justify-content-center pt-5">
      <BRow class="justify-content-center">
        <BCol lg="8" class="pt-5 mt-5">
          <BBadge variant="primary" class="mb-3 px-3 py-2 rounded-pill fw-bold animate-fadeInDown">
             <LayoutDashboardIcon :size="14" class="me-1" /> All-in-one Management
          </BBadge>
          <h1 class="display-3 fw-black text-main mb-4 animate-scaleUp">
            The Ultimate <span class="text-primary text-gradient">Utility</span> Hub
          </h1>
          <p class="lead text-muted mb-5 animate-fadeInUp">
            Organize your life with our comprehensive suite of tools for managing<br class="d-none d-md-block">
            medical, financial, and personal documentation.
          </p>
          <div class="d-flex flex-wrap justify-content-center gap-3 mb-5">
            <BButton to="/register" variant="primary" size="lg" class="fw-bold px-5 py-3 shadow-lg d-flex align-items-center gap-2">
              Get Started <ArrowRightIcon :size="20" />
            </BButton>
            <BButton variant="outline-dark" size="lg" class="fw-bold px-5 py-3 d-flex align-items-center gap-2">
               Learn More <LayoutDashboardIcon :size="20" />
            </BButton>
          </div>
        </BCol>
      </BRow>

      <!-- Features Grid -->
      <BRow class="mt-5 pt-5 gx-4 gy-4">
        <BCol md="4" v-for="f in features" :key="f.title">
          <BCard class="border-0 shadow-sm h-100 hover-lift rounded-4 p-3 text-center">
            <div :class="`feature-icon-wrapper rounded-circle p-3 mx-auto mb-4 bg-${f.color} bg-opacity-10`" style="width: 72px; height: 72px; display: flex; align-items: center; justify-content: center;">
              <component :is="f.icon" :size="32" :class="`text-${f.color}`" />
            </div>
            <h4 class="fw-bold text-main mb-3">{{ f.title }}</h4>
            <p class="text-muted small mb-0">{{ f.desc }}</p>
          </BCard>
        </BCol>
      </BRow>
    </BContainer>
  </div>
</template>

<script setup>
import { 
  ShieldCheckIcon, ZapIcon, MonitorIcon, 
  ArrowRightIcon, LayoutDashboardIcon 
} from 'lucide-vue-next'

const features = [
  { 
    title: "Secure Vault", 
    desc: "Your data is encrypted and saved securely. We never share your sensitive information.", 
    icon: ShieldCheckIcon, 
    color: 'primary' 
  },
  { 
    title: "Instant Sync", 
    desc: "Access your dashboard across all devices instantly with cloud synchronization.", 
    icon: ZapIcon, 
    color: 'warning' 
  },
  { 
    title: "Modern Interface", 
    desc: "A clean, intuitive, and high-performance UI designed for maximum productivity.", 
    icon: MonitorIcon, 
    color: 'info' 
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
.text-main { color: #2c3338; }
.text-gradient {
  background: linear-gradient(135deg, #0d6efd 30%, #6610f2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}
.hover-lift {
  transition: all 0.3s ease;
}
.hover-lift:hover {
  transform: translateY(-8px);
  box-shadow: 0 15px 30px rgba(0,0,0,0.1) !important;
}
.animate-scaleUp { animation: scaleUp 0.8s ease backwards; }
@keyframes scaleUp { from { opacity: 0; transform: scale(0.95); } }
</style>

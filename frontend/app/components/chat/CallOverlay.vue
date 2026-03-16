<template>
  <div v-if="isOpen" class="call-overlay-fixed d-flex flex-column align-items-center justify-content-center p-4">
    <div class="call-container shadow-2xl rounded-5 overflow-hidden position-relative bg-dark d-flex flex-column">
      
      <!-- Video Streams -->
      <div class="flex-grow-1 position-relative d-flex align-items-center justify-content-center bg-black overflow-hidden">
        <!-- Remote Video -->
        <video 
          ref="remoteVideo" 
          autoplay 
          playsinline 
          class="remote-video w-100 h-100 object-fit-cover"
          :class="{ 'hidden': !remoteStream }"
        ></video>
        
        <!-- Audio-only Placeholder -->
        <div v-if="activeCallType === 'audio' || !remoteStream" class="text-center text-white opacity-50">
          <BAvatar size="6rem" variant="primary" :text="userName?.charAt(0) || 'U'" class="mb-3" />
          <h4 class="fw-bold">{{ activeCallType === 'audio' ? 'Voice Call' : 'Connecting...' }}</h4>
          <p class="small mb-0">{{ statusText }}</p>
        </div>

        <!-- Local Video (Picture-in-Picture) -->
        <div v-if="activeCallType === 'video' && localStream" class="local-video-pip shadow-lg rounded-4 overflow-hidden border border-white border-opacity-25">
          <video 
            ref="localVideo" 
            autoplay 
            playsinline 
            muted 
            class="w-100 h-100 object-fit-cover"
          ></video>
        </div>
      </div>

      <!-- Call Controls -->
      <div class="p-4 bg-glass border-top border-white border-opacity-10 d-flex align-items-center justify-content-center gap-4">
        <BButton 
          variant="light" 
          @click="toggleMute" 
          class="rounded-circle d-flex align-items-center justify-content-center shadow-none" 
          style="width: 56px; height: 56px;"
          :class="{ 'btn-active': isMuted }"
        >
          <span class="fs-4">{{ isMuted ? '🔇' : '🎤' }}</span>
        </BButton>

        <BButton 
          v-if="activeCallType === 'video'"
          variant="light" 
          @click="toggleCamera" 
          class="rounded-circle d-flex align-items-center justify-content-center shadow-none" 
          style="width: 56px; height: 56px;"
          :class="{ 'btn-active': !isVideoEnabled }"
        >
          <span class="fs-4">{{ isVideoEnabled ? '📹' : '🚫' }}</span>
        </BButton>

        <BButton 
          variant="danger" 
          @click="onHangup" 
          class="rounded-circle d-flex align-items-center justify-content-center shadow-none border-0" 
          style="width: 64px; height: 64px; background: #ef4444;"
        >
          <span class="fs-3 text-white">📞</span>
        </BButton>
      </div>

      <!-- Status Info -->
      <div class="position-absolute top-0 start-0 w-100 p-4 d-flex justify-content-between align-items-center pointer-events-none">
        <div class="d-flex align-items-center gap-3">
          <BBadge variant="danger" class="px-2 py-1 rounded-pill blink">REC</BBadge>
          <div class="text-white shadow-text">
            <h6 class="mb-0 fw-bold">{{ userName }}</h6>
            <small class="opacity-75">{{ callDuration }}</small>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, watch, onMounted, onUnmounted } from 'vue'

const props = defineProps({
  isOpen: Boolean,
  userName: String,
  localStream: Object,
  remoteStream: Object,
  activeCallType: String,
  statusText: String,
  callDuration: {
    type: String,
    default: '00:00'
  }
})

const emit = defineEmits(['hangup', 'mute', 'camera'])

const localVideo = ref(null)
const remoteVideo = ref(null)
const isMuted = ref(false)
const isVideoEnabled = ref(true)

const toggleMute = () => {
    isMuted.value = !isMuted.value
    emit('mute', isMuted.value)
}

const toggleCamera = () => {
    isVideoEnabled.value = !isVideoEnabled.value
    emit('camera', isVideoEnabled.value)
}

const onHangup = () => {
    emit('hangup')
}

watch(() => props.localStream, (stream) => {
  if (stream && localVideo.value) {
    localVideo.value.srcObject = stream
  }
})

watch(() => props.remoteStream, (stream) => {
  if (stream && remoteVideo.value) {
    remoteVideo.value.srcObject = stream
  }
})

onMounted(() => {
  if (props.localStream && localVideo.value) {
    localVideo.value.srcObject = props.localStream
  }
  if (props.remoteStream && remoteVideo.value) {
    remoteVideo.value.srcObject = props.remoteStream
  }
})
</script>

<style scoped>
.call-overlay-fixed {
    position: fixed;
    top: 0;
    left: 0;
    width: 100vw;
    height: 100vh;
    background: rgba(0, 0, 0, 0.85);
    backdrop-filter: blur(12px);
    z-index: 10000;
}

.call-container {
    width: 100%;
    max-width: 900px;
    height: 85vh;
    background: #111;
}

.remote-video {
    background: #000;
}

.local-video-pip {
    position: absolute;
    bottom: 2rem;
    right: 2rem;
    width: 220px;
    height: 140px;
    background: #222;
    z-index: 10;
}

.bg-glass {
    background: rgba(255, 255, 255, 0.05);
    backdrop-filter: blur(10px);
}

.btn-active {
    background: rgba(239, 68, 68, 0.2) !important;
    border-color: #ef4444 !important;
}

.shadow-text {
    text-shadow: 0 2px 4px rgba(0, 0, 0, 0.5);
}

.blink {
    animation: blink-animation 1.5s steps(5, start) infinite;
}

@keyframes blink-animation {
    to { visibility: hidden; }
}

.pointer-events-none {
    pointer-events: none;
}

.hidden {
    opacity: 0;
}
</style>

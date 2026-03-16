<template>
  <div v-if="isOpen" class="call-overlay-fixed d-flex flex-column align-items-center justify-content-center p-4">
    <div class="call-container shadow-2xl rounded-5 overflow-hidden position-relative bg-dark d-flex flex-column">
      
      <!-- Participants Grid -->
      <div class="flex-grow-1 position-relative p-3 bg-black overflow-hidden d-flex align-items-center justify-content-center">
        <div class="participants-grid w-100 h-100" :class="gridClass">
            
          <!-- Local Video (Featured or in Grid) -->
          <div class="participant-card local-participant" :class="{ 'pip': remoteStreams.size > 0 }">
            <video 
              ref="localVideo" 
              autoplay 
              playsinline 
              muted 
              class="participant-video shadow-lg"
              :class="{ 'video-disabled': !isVideoEnabled }"
            ></video>
            <div class="participant-name">You</div>
            <div v-if="!isVideoEnabled" class="video-disabled-avatar">
                <BAvatar variant="primary" text="Y" size="4rem" />
            </div>
          </div>
 
          <!-- Remote Participants -->
          <div v-for="[userId, stream] in remoteStreams" :key="userId" class="participant-card">
            <RemoteVideo :stream="stream" class="participant-video" />
            <div class="participant-name">User {{ userId.substring(0, 4) }}</div>
          </div>
 
          <!-- Audio-only Placeholder if no streams -->
          <div v-if="remoteStreams.size === 0 && !localStream" class="text-center text-white opacity-50 position-absolute">
            <BAvatar size="6rem" variant="primary" :text="userName?.charAt(0) || 'U'" class="mb-3" />
            <h4 class="fw-bold">{{ activeCallType === 'audio' ? 'Voice Call' : 'Connecting...' }}</h4>
            <p class="small mb-0">{{ statusText }}</p>
          </div>
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
            <h6 class="mb-0 fw-bold">{{ currentRoomId ? 'Group Call' : userName }}</h6>
            <small class="opacity-75">{{ callDuration }}</small>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, watch, onMounted, computed, defineComponent, h } from 'vue'

// Helper component for remote video to manage srcObject correctly in v-for
const RemoteVideo = defineComponent({
  props: ['stream'],
  setup(props) {
    const videoRef = ref(null)
    watch(() => props.stream, (s) => {
      if (videoRef.value && s) videoRef.value.srcObject = s
    }, { immediate: true })
    return () => h('video', { 
      ref: videoRef, 
      autoplay: true, 
      playsinline: true, 
      class: 'w-100 h-100 object-fit-cover rounded-4 shadow'
    })
  }
})

const props = defineProps({
  isOpen: Boolean,
  userName: String,
  localStream: Object,
  remoteStreams: {
    type: Map,
    default: () => new Map()
  },
  activeCallType: String,
  statusText: String,
  currentRoomId: String,
  callDuration: {
    type: String,
    default: '00:00'
  }
})

const emit = defineEmits(['hangup', 'mute', 'camera'])

const localVideo = ref(null)
const isMuted = ref(false)
const isVideoEnabled = ref(true)

const gridClass = computed(() => {
    const count = (props.remoteStreams?.size || 0) + 1
    if (count <= 1) return 'grid-1'
    if (count === 2) return 'grid-2'
    if (count <= 4) return 'grid-4'
    return 'grid-many'
})

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

onMounted(() => {
  if (props.localStream && localVideo.value) {
    localVideo.value.srcObject = props.localStream
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
    background: rgba(0, 0, 0, 0.9);
    backdrop-filter: blur(20px);
    z-index: 10000;
}

.call-container {
    width: 100%;
    max-width: 1100px;
    height: 90vh;
    background: #000;
}

.participants-grid {
    display: grid;
    gap: 1rem;
    align-content: center;
}

.grid-1 { grid-template-columns: 1fr; }
.grid-2 { grid-template-columns: 1fr 1fr; }
.grid-4 { grid-template-columns: 1fr 1fr; grid-template-rows: 1fr 1fr; }
.grid-many { grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); }

.participant-card {
    position: relative;
    border-radius: 1.5rem;
    overflow: hidden;
    background: #111;
    transition: all 0.3s ease;
}

.participant-video {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.participant-name {
    position: absolute;
    bottom: 1rem;
    left: 1rem;
    background: rgba(0, 0, 0, 0.5);
    color: white;
    padding: 0.2rem 0.8rem;
    border-radius: 2rem;
    font-size: 0.8rem;
    backdrop-filter: blur(5px);
}

.local-participant.pip {
    position: absolute;
    bottom: 2rem;
    right: 2rem;
    width: 200px;
    height: 150px;
    z-index: 100;
    box-shadow: 0 10px 30px rgba(0,0,0,0.5);
    border: 1px solid rgba(255,255,255,0.1);
}

.video-disabled-avatar {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
}

.video-disabled {
    filter: blur(20px) brightness(0.5);
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
</style>

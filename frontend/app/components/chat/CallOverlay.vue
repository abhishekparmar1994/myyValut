<template>
  <div v-if="isOpen" class="call-overlay-fixed d-flex flex-column align-items-center justify-content-center p-4">
    <div class="call-container shadow-2xl rounded-5 overflow-hidden position-relative bg-dark d-flex flex-column">
      
      <!-- Participants Grid -->
      <div class="flex-grow-1 position-relative p-3 bg-black overflow-hidden d-flex align-items-center justify-content-center">
        <div class="participants-grid w-100 h-100" :class="gridClass">
            
          <!-- Local Video (Featured or in Grid) -->
          <div class="participant-card local-participant shadow-2xl border border-white border-opacity-10" :class="{ 'pip': remoteStreams.size > 0, 'active-speaker': isVideoEnabled }">
            <video 
              ref="localVideo" 
              autoplay 
              playsinline 
              muted 
              class="participant-video shadow-lg"
              :class="{ 'video-disabled': !isVideoEnabled }"
            ></video>
            <div class="participant-name glass-pill">You</div>
            <div v-if="!isVideoEnabled" class="video-disabled-avatar">
                <BAvatar variant="primary" :text="auth.user?.name?.charAt(0) || 'Y'" size="5rem" class="shadow-lg border-3 border-white border-opacity-20" />
            </div>
          </div>
 
          <!-- Remote Participants -->
          <div v-for="[userId, stream] in remoteStreams" :key="userId" class="participant-card shadow-xl border border-white border-opacity-10">
            <RemoteVideo :stream="stream" class="participant-video" />
            <div class="participant-name glass-pill">User {{ userId.substring(0, 4) }}</div>
          </div>
 
          <!-- Audio-only Placeholder if no streams -->
          <div v-if="remoteStreams.size === 0 && !localStream" class="text-center text-white position-absolute animate-fade-in">
            <BAvatar size="8rem" variant="info" :text="userName?.charAt(0) || 'U'" class="mb-4 shadow-2xl border-4 border-white border-opacity-20 pulse-avatar" />
            <h3 class="fw-bold mb-1">{{ activeCallType === 'audio' ? 'Voice Call' : 'Connecting...' }}</h3>
            <p class="opacity-75 tracking-wide">{{ statusText }}</p>
          </div>
        </div>
      </div>
 
      <!-- Call Controls -->
      <div class="p-4 py-5 bg-glass border-top border-white border-opacity-10 d-flex align-items-center justify-content-center gap-4">
        <BButton 
          variant="light" 
          @click="toggleMute" 
          class="rounded-circle d-flex align-items-center justify-content-center shadow-lg border-0 transition-all hover-scale" 
          style="width: 56px; height: 56px;"
          :class="{ 'btn-active bg-danger-subtle text-danger': isMuted, 'bg-white text-dark': !isMuted }"
        >
          <MicOffIcon v-if="isMuted" :size="24" />
          <MicIcon v-else :size="24" />
        </BButton>
 
        <BButton 
          v-if="activeCallType === 'video'"
          variant="light" 
          @click="toggleCamera" 
          class="rounded-circle d-flex align-items-center justify-content-center shadow-lg border-0 transition-all hover-scale" 
          style="width: 56px; height: 56px;"
          :class="{ 'btn-active bg-danger-subtle text-danger': !isVideoEnabled, 'bg-white text-dark': isVideoEnabled }"
        >
          <VideoOffIcon v-if="!isVideoEnabled" :size="24" />
          <VideoIcon v-else :size="24" />
        </BButton>
 
        <BButton 
          variant="danger" 
          @click="onHangup" 
          class="rounded-circle d-flex align-items-center justify-content-center shadow-lg border-0 transition-all hover-bounce hangup-btn" 
          style="width: 64px; height: 64px;"
        >
          <PhoneOffIcon :size="28" class="text-white" />
        </BButton>
      </div>
 
      <!-- Status Info -->
      <div class="position-absolute top-0 start-0 w-100 p-4 d-flex justify-content-between align-items-center pointer-events-none">
        <div class="d-flex align-items-center gap-3">
          <div class="rec-indicator d-flex align-items-center gap-2 px-3 py-1 rounded-pill bg-black bg-opacity-50 backdrop-blur">
            <div class="rec-dot"></div>
            <span class="text-white fw-bold extra-small tracking-wider">LIVE</span>
          </div>
          <div class="text-white shadow-text">
            <h5 class="mb-0 fw-bold">{{ currentRoomId ? 'Group Call' : userName }}</h5>
            <div class="d-flex align-items-center gap-2">
              <div class="timer-dot"></div>
              <small class="opacity-75 font-monospace">{{ callDuration }}</small>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, watch, onMounted, computed, defineComponent, h } from 'vue'
import { 
  Mic as MicIcon, 
  MicOff as MicOffIcon, 
  Video as VideoIcon, 
  VideoOff as VideoOffIcon, 
  PhoneOff as PhoneOffIcon 
} from 'lucide-vue-next'
import { useAuthStore } from '~/stores/auth'

const auth = useAuthStore()

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

.glass-pill {
    background: rgba(0, 0, 0, 0.4);
    backdrop-filter: blur(8px);
    border: 1px solid rgba(255, 255, 255, 0.1);
    color: white;
    padding: 0.3rem 0.8rem;
    border-radius: 2rem;
    font-size: 0.75rem;
    font-weight: 500;
}

.rec-indicator {
    border: 1px solid rgba(255, 255, 255, 0.1);
}

.rec-dot {
    width: 8px;
    height: 8px;
    background: #ef4444;
    border-radius: 50%;
    box-shadow: 0 0 10px #ef4444;
    animation: pulse-red 1.5s infinite;
}

@keyframes pulse-red {
    0% { transform: scale(1); opacity: 1; }
    50% { transform: scale(1.3); opacity: 0.7; }
    100% { transform: scale(1); opacity: 1; }
}

.timer-dot {
    width: 6px;
    height: 6px;
    background: #10b981;
    border-radius: 50%;
}

.active-speaker {
    box-shadow: 0 0 0 4px rgba(59, 113, 237, 0.5);
    animation: speaker-pulse 2s infinite;
}

@keyframes speaker-pulse {
    0% { box-shadow: 0 0 0 0px rgba(59, 113, 237, 0.5); }
    70% { box-shadow: 0 0 0 10px rgba(59, 113, 237, 0); }
    100% { box-shadow: 0 0 0 0px rgba(59, 113, 237, 0); }
}

.pulse-avatar {
    animation: avatar-pulse 3s infinite;
}

@keyframes avatar-pulse {
    0% { transform: scale(1); }
    50% { transform: scale(1.05); }
    100% { transform: scale(1); }
}

.extra-small {
    font-size: 0.65rem;
}

.tracking-wider {
    letter-spacing: 0.1em;
}

.backdrop-blur {
    backdrop-filter: blur(10px);
}

.shadow-text {
    text-shadow: 0 2px 4px rgba(0, 0, 0, 0.5);
}

.hover-scale:hover {
    transform: scale(1.1);
}

.hover-bounce:hover {
    transform: translateY(-5px) scale(1.05);
}

.hangup-btn {
    background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%) !important;
}

.transition-all {
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
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

import { ref, onUnmounted } from 'vue'
import { useChatStore } from '../stores/chat'

export function useWebRTC() {
    const chat = useChatStore()

    const peerConnection = ref<RTCPeerConnection | null>(null)
    const localStream = ref<MediaStream | null>(null)
    const remoteStream = ref<MediaStream | null>(null)
    const isCalling = ref(false)
    const isConnected = ref(false)
    const activeCallType = ref<'audio' | 'video'>('video')
    const remoteUserId = ref<string | null>(null)
    const startTime = ref<number | null>(null)
    const callDuration = ref<string>('00:00')
    let durationInterval: any = null

    const configuration: RTCConfiguration = {
        iceServers: [
            { urls: 'stun:stun.l.google.com:19302' },
            { urls: 'stun:stun1.l.google.com:19302' }
        ]
    }

    const initPeerConnection = (targetUserId: string) => {
        console.log('[WebRTC] Initializing Peer Connection for', targetUserId)
        remoteUserId.value = targetUserId
        peerConnection.value = new RTCPeerConnection(configuration)

        // Handle ICE candidates
        peerConnection.value.onicecandidate = (event) => {
            if (event.candidate) {
                (chat.socket as any)?.emit('call:ice-candidate', {
                    receiverId: targetUserId,
                    candidate: event.candidate
                })
            }
        }

        // Handle remote stream
        peerConnection.value.ontrack = (event) => {
            console.log('[WebRTC] Received remote track')
            if (event.streams && event.streams[0]) {
                remoteStream.value = event.streams[0]
            }
            isConnected.value = true
            
            // Start duration timer if not already started
            if (!startTime.value) {
                startTime.value = Date.now()
                durationInterval = setInterval(() => {
                    const diff = Math.floor((Date.now() - startTime.value!) / 1000)
                    const mins = Math.floor(diff / 60).toString().padStart(2, '0')
                    const secs = (diff % 60).toString().padStart(2, '0')
                    callDuration.value = `${mins}:${secs}`
                }, 1000)
            }
        }

        // Add local tracks to peer connection
        if (localStream.value) {
            localStream.value.getTracks().forEach(track => {
                peerConnection.value?.addTrack(track, localStream.value!)
            })
        }
    }

    const startCall = async (targetUserId: string, type: 'audio' | 'video' = 'video') => {
        try {
            console.log(`[WebRTC] Starting ${type} call to ${targetUserId}`)
            activeCallType.value = type
            isCalling.value = true
            
            // 1. Get local media
            if (!navigator?.mediaDevices?.getUserMedia) {
                throw new Error('Media access is restricted (non-HTTPS/localhost).')
            }

            try {
                localStream.value = await navigator.mediaDevices.getUserMedia({
                    audio: true,
                    video: type === 'video'
                })
            } catch (mediaErr: any) {
                if (mediaErr.name === 'NotFoundError') {
                    throw new Error(`Device not found: Ensure your ${type === 'video' ? 'camera/mic' : 'microphone'} is connected.`)
                }
                throw mediaErr
            }

            // 2. Init Peer Connection
            initPeerConnection(targetUserId)

            if (!peerConnection.value) throw new Error('Failed to initialize PeerConnection')

            // 3. Create Offer
            const offer = await peerConnection.value.createOffer()
            
            // 4. Set local description (defensive access)
            const pc = peerConnection.value as any
            if (typeof pc.setLocalDescription === 'function') {
                await pc.setLocalDescription(offer)
            } else {
                throw new Error('setLocalDescription is not a function on RTCPeerConnection instance')
            }

            // 5. Send offer via signaling
            (chat.socket as any)?.emit('call:offer', { 
                receiverId: targetUserId, 
                offer, 
                type 
            })
        } catch (err: any) {
            console.error('[WebRTC] Failed to start call', err)
            alert(err.message || 'Failed to start call')
            endCall()
        }
    }

    const handleOffer = async (senderId: string, offer: RTCSessionDescriptionInit, type: 'audio' | 'video') => {
        try {
            console.log(`[WebRTC] Handling ${type} offer from ${senderId}`)
            activeCallType.value = type
            isCalling.value = true
            
            // 1. Get local media
            if (!navigator?.mediaDevices?.getUserMedia) {
                throw new Error('Media access is restricted (non-HTTPS/localhost).')
            }

            try {
                localStream.value = await navigator.mediaDevices.getUserMedia({
                    audio: true,
                    video: type === 'video'
                })
            } catch (mediaErr: any) {
                if (mediaErr.name === 'NotFoundError') {
                    throw new Error(`Device not found: Ensure your ${type === 'video' ? 'camera/mic' : 'microphone'} is connected.`)
                }
                throw mediaErr
            }

            // 2. Init Peer Connection
            initPeerConnection(senderId)

            if (!peerConnection.value) throw new Error('Failed to initialize PeerConnection')

            // 3. Set remote description
            await peerConnection.value.setRemoteDescription(new RTCSessionDescription(offer))

            // 4. Create Answer
            const realAnswer = await peerConnection.value.createAnswer()
            
            // 5. Set local description
            const pc = peerConnection.value as any
            if (typeof pc.setLocalDescription === 'function') {
                await pc.setLocalDescription(realAnswer)
            } else {
                throw new Error('setLocalDescription is not a function on RTCPeerConnection instance')
            }

            // 6. Send answer
            (chat.socket as any)?.emit('call:answer', { 
                receiverId: senderId, 
                answer: realAnswer 
            })
        } catch (err: any) {
            console.error('[WebRTC] Failed to handle offer', err)
            alert(err.message || 'Failed to handle incoming call')
            endCall()
        }
    }

    const handleAnswer = async (answer: RTCSessionDescriptionInit) => {
        try {
            await peerConnection.value?.setRemoteDescription(new RTCSessionDescription(answer))
        } catch (err) {
            console.error('[WebRTC] Failed to handle answer', err)
        }
    }

    const handleIceCandidate = async (candidate: RTCIceCandidateInit) => {
        try {
            await peerConnection.value?.addIceCandidate(new RTCIceCandidate(candidate))
        } catch (err) {
            console.error('[WebRTC] Failed to handle ICE candidate', err)
        }
    }

    const endCall = () => {
        console.log('[WebRTC] Ending call')

        // Notify remote user if applicable
        if (remoteUserId.value) {
            (chat.socket as any)?.emit('call:end', { receiverId: remoteUserId.value })
        }

        // Cleanup local state
        localStream.value?.getTracks().forEach(track => track.stop())
        localStream.value = null
        remoteStream.value = null

        peerConnection.value?.close()
        peerConnection.value = null

        isCalling.value = false
        isConnected.value = false
        remoteUserId.value = null

        // Stop timer
        if (durationInterval) clearInterval(durationInterval)
        durationInterval = null
        startTime.value = null
        callDuration.value = '00:00'
    }

    const resetTimer = () => {
        startTime.value = null
        callDuration.value = '00:00'
    }

    const toggleMute = () => {
        if (localStream.value) {
            const audioTrack = localStream.value.getAudioTracks()[0]
            if (audioTrack) audioTrack.enabled = !audioTrack.enabled
        }
    }

    const toggleVideo = () => {
        if (localStream.value && activeCallType.value === 'video') {
            const videoTrack = localStream.value.getVideoTracks()[0]
            if (videoTrack) videoTrack.enabled = !videoTrack.enabled
        }
    }

    onUnmounted(() => {
        endCall()
    })

    return {
        localStream,
        remoteStream,
        isCalling,
        isConnected,
        activeCallType,
        remoteUserId,
        callDuration,
        startTime,
        startCall,
        handleOffer,
        handleAnswer,
        handleIceCandidate,
        endCall,
        resetTimer,
        toggleMute,
        toggleVideo
    }
}

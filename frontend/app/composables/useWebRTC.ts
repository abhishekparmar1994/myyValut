import { ref, onUnmounted } from 'vue'
import { useChatStore } from '../stores/chat'

export function useWebRTC() {
    const chat = useChatStore()

    const localStream = ref<MediaStream | null>(null)
    const remoteStreams = ref<Map<string, MediaStream>>(new Map()) // userId -> MediaStream
    const peers = ref<Map<string, RTCPeerConnection>>(new Map()) // userId -> connection
    
    const isCalling = ref(false)
    const isConnected = ref(false)
    const activeCallType = ref<'audio' | 'video'>('video')
    const remoteUserId = ref<string | null>(null)
    const currentRoomId = ref<string | null>(null)
    
    const startTime = ref<number | null>(null)
    const callDuration = ref<string>('00:00')
    let durationInterval: any = null

    const configuration: RTCConfiguration = {
        iceServers: [
            { urls: 'stun:stun.l.google.com:19302' },
            { urls: 'stun:stun1.l.google.com:19302' }
        ]
    }

    const startTimer = () => {
        if (startTime.value) return;
        startTime.value = Date.now();
        durationInterval = setInterval(() => {
            const diff = Math.floor((Date.now() - startTime.value!) / 1000);
            const mins = Math.floor(diff / 60).toString().padStart(2, '0');
            const secs = (diff % 60).toString().padStart(2, '0');
            callDuration.value = `${mins}:${secs}`;
        }, 1000);
    };

    const resetTimer = () => {
        if (durationInterval) clearInterval(durationInterval);
        durationInterval = null;
        startTime.value = null;
        callDuration.value = '00:00';
    };

    const endCall = () => {
        console.log('[WebRTC] Ending call');

        if (remoteUserId.value) {
            (chat.socket as any)?.emit('call:end', { receiverId: remoteUserId.value });
        }

        peers.value.forEach(pc => pc.close());
        peers.value.clear();
        remoteStreams.value.clear();

        localStream.value?.getTracks().forEach(track => track.stop());
        localStream.value = null;

        isCalling.value = false;
        isConnected.value = false;
        remoteUserId.value = null;
        currentRoomId.value = null;
        resetTimer();
    };

    const leaveGroupCall = () => {
        if (currentRoomId.value) {
            const socket = chat.socket as any;
            socket.emit('call:leave-room', { roomId: currentRoomId.value });
            socket.off('call:room-participants');
            socket.off('call:user-joined');
            socket.off('call:user-left');
            socket.off('call:signal');
        }
        endCall();
    };

    const removePeer = (targetUserId: string) => {
        const pc = peers.value.get(targetUserId);
        if (pc) {
            pc.close();
            peers.value.delete(targetUserId);
        }
        remoteStreams.value.delete(targetUserId);
        
        if (peers.value.size === 0) {
            isConnected.value = false;
            if (!currentRoomId.value) endCall();
        }
    };

    const createPeerConnection = (targetUserId: string, isInitiator: boolean) => {
        console.log(`[WebRTC] Creating PeerConnection for ${targetUserId}, initiator: ${isInitiator}`);
        const pc = new RTCPeerConnection(configuration);
        peers.value.set(targetUserId, pc);

        pc.onicecandidate = (event) => {
            if (event.candidate) {
                (chat.socket as any)?.emit('call:signal', { 
                    to: targetUserId, 
                    signal: { type: 'ice-candidate', candidate: event.candidate } 
                });
            }
        };

        pc.ontrack = (event) => {
            console.log(`[WebRTC] Received remote track from ${targetUserId}`);
            if (event.streams && event.streams[0]) {
                remoteStreams.value.set(targetUserId, event.streams[0]);
                isConnected.value = true;
                startTimer();
            }
        };

        pc.onconnectionstatechange = () => {
            console.log(`[WebRTC] PC state with ${targetUserId}: ${pc.connectionState}`);
            if (pc.connectionState === 'disconnected' || pc.connectionState === 'failed' || pc.connectionState === 'closed') {
                removePeer(targetUserId);
            }
        };

        if (localStream.value) {
            localStream.value.getTracks().forEach(track => {
                pc.addTrack(track, localStream.value!);
            });
        }

        return pc;
    };

    const getLocalStream = async (type: 'audio' | 'video') => {
        try {
            return await navigator.mediaDevices.getUserMedia({
                audio: true,
                video: type === 'video'
            });
        } catch (mediaErr: any) {
            if (mediaErr.name === 'NotFoundError' || mediaErr.name === 'DevicesNotFoundError') {
                throw new Error(`Device not found: Ensure your ${type === 'video' ? 'camera and microphone are' : 'microphone is'} connected and accessible.`);
            }
            if (mediaErr.name === 'NotAllowedError' || mediaErr.name === 'PermissionDeniedError') {
                throw new Error('Permission denied: Please allow access to your camera/microphone in browser settings.');
            }
            throw mediaErr;
        }
    };

    const startCall = async (targetUserId: string, type: 'audio' | 'video' = 'video') => {
        try {
            console.log(`[WebRTC] Starting ${type} call to ${targetUserId}`);
            activeCallType.value = type;
            isCalling.value = true;
            remoteUserId.value = targetUserId;
            
            localStream.value = await getLocalStream(type);

            const pc = createPeerConnection(targetUserId, true);
            const offer = await pc.createOffer();
            await pc.setLocalDescription(offer);
            
            (chat.socket as any)?.emit('call:initiate', { receiverId: targetUserId, type });
            (chat.socket as any)?.emit('call:offer', { receiverId: targetUserId, offer, type });
        } catch (err: any) {
            console.error('[WebRTC] Failed to start call', err);
            alert(err.message || 'Failed to start call');
            endCall();
        }
    };

    const joinGroupCall = async (roomId: string, type: 'audio' | 'video' = 'video') => {
        try {
            console.log(`[WebRTC] Joining group call room: ${roomId}`);
            currentRoomId.value = roomId;
            activeCallType.value = type;
            isCalling.value = true;
            
            localStream.value = await getLocalStream(type);

            const socket = chat.socket as any;
            socket.emit('call:join-room', { roomId });
            
            socket.on('call:room-participants', async ({ participants }: { participants: string[] }) => {
                for (const pId of participants) {
                    if (pId === (chat.socket as any).user?.id) continue;
                    if (peers.value.has(pId)) continue;
                    const pc = createPeerConnection(pId, true);
                    const offer = await pc.createOffer();
                    await pc.setLocalDescription(offer);
                    socket.emit('call:signal', { to: pId, signal: { type: 'offer', offer } });
                }
            });

            socket.on('call:user-joined', ({ userId }: { userId: string }) => {
                console.log('[WebRTC] User joined room:', userId);
            });

            socket.on('call:user-left', ({ userId }: { userId: string }) => {
                console.log('[WebRTC] User left room:', userId);
                removePeer(userId);
            });

            socket.on('call:signal', async ({ from, signal }: { from: string, signal: any }) => {
                let pc = peers.value.get(from);
                
                if (signal.type === 'offer') {
                    if (!pc) pc = createPeerConnection(from, false);
                    await pc.setRemoteDescription(new RTCSessionDescription(signal.offer));
                    const answer = await pc.createAnswer();
                    await pc.setLocalDescription(answer);
                    socket.emit('call:signal', { to: from, signal: { type: 'answer', answer } });
                } else if (signal.type === 'answer') {
                    if (pc) await pc.setRemoteDescription(new RTCSessionDescription(signal.answer));
                } else if (signal.type === 'ice-candidate') {
                    if (pc) await pc.addIceCandidate(new RTCIceCandidate(signal.candidate));
                }
            });

        } catch (err: any) {
            console.error('[WebRTC] Failed to join group call', err);
            alert(err.message || 'Failed to join group call');
            leaveGroupCall();
        }
    };

    const handleOffer = async (senderId: string, offer: RTCSessionDescriptionInit, type: 'audio' | 'video') => {
        try {
            console.log(`[WebRTC] Handling ${type} offer from ${senderId}`);
            activeCallType.value = type;
            isCalling.value = true;
            remoteUserId.value = senderId;
            
            if (!localStream.value) {
                localStream.value = await getLocalStream(type);
            }

            const pc = createPeerConnection(senderId, false);
            await pc.setRemoteDescription(new RTCSessionDescription(offer));
            const answer = await pc.createAnswer();
            await pc.setLocalDescription(answer);
            
            (chat.socket as any)?.emit('call:answer', { 
                receiverId: senderId, 
                answer 
            });
        } catch (err: any) {
            console.error('[WebRTC] Failed to handle offer', err);
            alert(err.message || 'Failed to handle incoming call');
            endCall();
        }
    };

    const handleAnswer = async (senderId: string, answer: RTCSessionDescriptionInit) => {
        try {
            const pc = peers.value.get(senderId);
            if (pc) await pc.setRemoteDescription(new RTCSessionDescription(answer));
        } catch (err) {
            console.error('[WebRTC] Failed to handle answer', err);
        }
    };

    const handleIceCandidate = async (senderId: string, candidate: RTCIceCandidateInit) => {
        try {
            const pc = peers.value.get(senderId);
            if (pc) await pc.addIceCandidate(new RTCIceCandidate(candidate));
        } catch (err) {
            console.error('[WebRTC] Failed to handle ICE candidate', err);
        }
    };

    const toggleMute = () => {
        if (localStream.value) {
            localStream.value.getAudioTracks().forEach(track => {
                track.enabled = !track.enabled;
            });
        }
    };

    const toggleVideo = () => {
        if (localStream.value && activeCallType.value === 'video') {
            localStream.value.getVideoTracks().forEach(track => {
                track.enabled = !track.enabled;
            });
        }
    };

    onUnmounted(() => {
        leaveGroupCall();
    });

    return {
        localStream,
        remoteStreams,
        isCalling,
        isConnected,
        activeCallType,
        remoteUserId,
        currentRoomId,
        callDuration,
        startTime,
        startCall,
        joinGroupCall,
        leaveGroupCall,
        handleOffer,
        handleAnswer,
        handleIceCandidate,
        endCall,
        resetTimer,
        toggleMute,
        toggleVideo
    };
}

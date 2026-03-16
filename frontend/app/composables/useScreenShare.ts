import { ref, onUnmounted } from 'vue'
import { useChatStore } from '../stores/chat'

export function useScreenShare() {
    const chat = useChatStore();
    
    const localScreenStream = ref<MediaStream | null>(null);
    const remoteScreenStream = ref<MediaStream | null>(null);
    const pc = ref<RTCPeerConnection | null>(null);
    
    const isSharing = ref(false);
    const isViewing = ref(false);
    const sharingWith = ref<string | null>(null);
    const screenPasscode = ref<string | null>(null);
    
    const configuration: RTCConfiguration = {
        iceServers: [
            { urls: 'stun:stun.l.google.com:19302' },
            { urls: 'stun:stun1.l.google.com:19302' }
        ]
    };

    const endScreenShare = () => {
        console.log('[ScreenShare] Ending session');
        
        if (sharingWith.value) {
            (chat.socket as any)?.emit('screenshare:end', { to: sharingWith.value });
        }
        
        pc.value?.close();
        pc.value = null;
        
        localScreenStream.value?.getTracks().forEach(track => track.stop());
        localScreenStream.value = null;
        remoteScreenStream.value = null;
        
        isSharing.value = false;
        isViewing.value = false;
        sharingWith.value = null;
        screenPasscode.value = null;
    };

    const createPeerConnection = (targetUserId: string) => {
        const newPc = new RTCPeerConnection(configuration);
        pc.value = newPc;

        newPc.onicecandidate = (event) => {
            if (event.candidate) {
                (chat.socket as any)?.emit('screenshare:signal', { 
                    to: targetUserId, 
                    signal: { type: 'ice-candidate', candidate: event.candidate } 
                });
            }
        };

        newPc.ontrack = (event) => {
            if (event.streams && event.streams[0]) {
                remoteScreenStream.value = event.streams[0];
                isViewing.value = true;
            }
        };

        newPc.onconnectionstatechange = () => {
            if (newPc.connectionState === 'disconnected' || newPc.connectionState === 'failed' || newPc.connectionState === 'closed') {
                endScreenShare();
            }
        };

        if (localScreenStream.value) {
            localScreenStream.value.getTracks().forEach(track => {
                newPc.addTrack(track, localScreenStream.value!);
            });
        }

        return newPc;
    };

    const startSharing = async (targetUserId: string) => {
        try {
            console.log(`[ScreenShare] Starting sharing with ${targetUserId}`);
            sharingWith.value = targetUserId;
            
            localScreenStream.value = await navigator.mediaDevices.getDisplayMedia({
                video: true,
                audio: false
            });

            // Generate a random 6-digit passcode
            const passcode = Math.floor(100000 + Math.random() * 900000).toString();
            screenPasscode.value = passcode;
            
            // Listen for stop from browser native UI
            const videoTracks = localScreenStream.value.getVideoTracks();
            if (videoTracks && videoTracks[0]) {
                videoTracks[0].onended = () => endScreenShare();
            }

            (chat.socket as any)?.emit('screenshare:invite', { receiverId: targetUserId, passcode });
            isSharing.value = true;
            
            return passcode;
        } catch (err) {
            console.error('[ScreenShare] Failed to start sharing', err);
            endScreenShare();
            throw err;
        }
    };

    const joinSharing = async (initiatorId: string, passcode: string, username: string) => {
        try {
            console.log(`[ScreenShare] Attempting to join sharing session with ${initiatorId}`);
            sharingWith.value = initiatorId;
            
            (chat.socket as any)?.emit('screenshare:join-request', { 
                senderId: initiatorId, 
                passcode, 
                username 
            });
        } catch (err) {
            console.error('[ScreenShare] Failed to join sharing', err);
            endScreenShare();
            throw err;
        }
    };

    const handleJoinAttempt = async (receiverId: string, providedPasscode: string) => {
        try {
            if (providedPasscode !== screenPasscode.value) {
                console.warn('[ScreenShare] Invalid passcode attempt from', receiverId);
                return false;
            }

            console.log('[ScreenShare] Passcode valid, initiating WebRTC offer');
            const newPc = createPeerConnection(receiverId);
            const offer = await newPc.createOffer();
            await newPc.setLocalDescription(offer);
            
            (chat.socket as any)?.emit('screenshare:join-accept', { receiverId });
            (chat.socket as any)?.emit('screenshare:signal', { 
                to: receiverId, 
                signal: { type: 'offer', offer } 
            });
            
            return true;
        } catch (err) {
            console.error('[ScreenShare] Failed to handle join attempt', err);
            return false;
        }
    };

    const handleAccepted = async (initiatorId: string) => {
        console.log('[ScreenShare] Sharing accepted by initiator');
    };

    const handleSignal = async (from: string, signal: any) => {
        try {
            if (signal.type === 'offer') {
                const newPc = createPeerConnection(from);
                await newPc.setRemoteDescription(new RTCSessionDescription(signal.offer));
                const answer = await newPc.createAnswer();
                await newPc.setLocalDescription(answer);
                
                (chat.socket as any)?.emit('screenshare:signal', { 
                    to: from, 
                    signal: { type: 'answer', answer } 
                });
            } else if (signal.type === 'answer') {
                if (pc.value) await pc.value.setRemoteDescription(new RTCSessionDescription(signal.answer));
            } else if (signal.type === 'ice-candidate') {
                if (pc.value) await pc.value.addIceCandidate(new RTCIceCandidate(signal.candidate));
            }
        } catch (err) {
            console.error('[ScreenShare] Failed to handle signal', err);
        }
    };

    onUnmounted(() => {
        endScreenShare();
    });

    return {
        localScreenStream,
        remoteScreenStream,
        isSharing,
        isViewing,
        sharingWith,
        screenPasscode,
        startSharing,
        joinSharing,
        handleJoinAttempt,
        handleAccepted,
        handleSignal,
        endScreenShare
    };
}

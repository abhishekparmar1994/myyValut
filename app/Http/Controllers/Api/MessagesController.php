<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Message;
use App\Models\MessageReaction;
use App\Models\PinnedMessage;
use App\Events\SystemNotification;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;
use Exception;

class MessagesController extends Controller
{
    public function index(Request $request, $receiverId)
    {
        $userId = $request->user()->id;

        $messages = Message::where(function ($query) use ($userId, $receiverId) {
            $query->where('sender_id', $userId)
                ->where('receiver_id', $receiverId);
        })->orWhere(function ($query) use ($userId, $receiverId) {
            $query->where('sender_id', $receiverId)
                ->where('receiver_id', $userId);
        })
            ->whereDoesntHave('deletions', function ($q) use ($userId) {
                $q->where('user_id', $userId);
            })
            ->with(['reactions', 'replyTo'])
            ->orderBy('created_at', 'asc')
            ->get();

        $pinned = \App\Models\PinnedMessage::where(function ($q) use ($userId, $receiverId) {
            $q->where('user1_id', $userId)->where('user2_id', $receiverId);
        })->orWhere(function ($q) use ($userId, $receiverId) {
            $q->where('user1_id', $receiverId)->where('user2_id', $userId);
        })->with('message.reactions')->first();

        return response()->json([
            'messages' => $messages,
            'pinned' => $pinned ? $pinned->message : null
        ]);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'receiver_id' => 'required|exists:users,id',
            'content' => 'required|string',
            'type' => 'nullable|string',
            'file_name' => 'nullable|string',
            'reply_to_id' => 'nullable|exists:messages,id',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $senderId = $request->user()->id;
        $receiverId = $request->receiver_id;

        // Check for active blocks
        $isBlocked = \App\Models\UserBlock::where(function ($query) use ($senderId, $receiverId) {
            $query->where('blocker_id', $senderId)
                ->where('blocked_id', $receiverId);
        })->orWhere(function ($query) use ($senderId, $receiverId) {
            $query->where('blocker_id', $receiverId)
                ->where('blocked_id', $senderId);
        })->exists();

        if ($isBlocked) {
            return response()->json(['error' => 'Communication unavailable due to an active block.'], 403);
        }

        $message = Message::create([
            'sender_id' => $request->user()->id,
            'receiver_id' => $request->receiver_id,
            'content' => $request->content,
            'type' => $request->type ?? 'text',
            'file_name' => $request->file_name,
            'reply_to_id' => $request->reply_to_id,
        ]);

        $message->load('replyTo');

        return response()->json($message, 201);
    }

    public function markAsRead(Request $request, $senderId)
    {
        Message::where('sender_id', $senderId)
            ->where('receiver_id', $request->user()->id)
            ->where('is_read', false)
            ->update(['is_read' => true]);

        return response()->json(['status' => 'success']);
    }

    public function unreadCounts(Request $request)
    {
        $userId = $request->user()->id;
        
        $counts = Message::where('receiver_id', $userId)
            ->where('is_read', false)
            ->where('is_deleted_everyone', false)
            ->whereDoesntHave('deletions', function ($q) use ($userId) {
                $q->where('user_id', $userId);
            })
            ->groupBy('sender_id')
            ->selectRaw('sender_id, count(*) as count')
            ->get()
            ->pluck('count', 'sender_id');

        return response()->json($counts);
    }

    public function upload(Request $request)
    {
        $request->validate([
            'file' => 'required|file|mimes:jpg,jpeg,png,webp,pdf,doc,docx,xls,xlsx,zip,csv,txt|max:10240', // 10MB max
        ]);

        if ($request->hasFile('file')) {
            $file = $request->file('file');
            $originalName = $file->getClientOriginalName();
            $mime = $file->getMimeType();
            $path = $file->store('chat/media', 'public');
            $url = asset('storage/' . $path);

            // Determine type: 'image' or generic 'file'
            $type = str_contains($mime, 'image') ? 'image' : 'file';

            return response()->json([
                'url' => $url,
                'path' => $path,
                'name' => $originalName,
                'type' => $type,
                'mime' => $mime
            ]);
        }

        return response()->json(['error' => 'No file uploaded'], 400);
    }

    /**
     * Serve a file with CORS headers for in-browser previewing.
     */
    public function getFile(Request $request, $path)
    {
        if (!Storage::disk('public')->exists($path)) {
            abort(404);
        }

        $file = Storage::disk('public')->get($path);
        $mime = Storage::disk('public')->mimeType($path);

        return response($file, 200)
            ->header('Content-Type', $mime)
            ->header('Access-Control-Allow-Origin', '*')
            ->header('Access-Control-Allow-Methods', 'GET')
            ->header('Access-Control-Allow-Headers', 'Content-Type, X-Requested-With, Authorization');
    }

    public function deleteMessage(Request $request, $messageId)
    {
        $request->validate(['type' => 'required|in:me,everyone']);
        $userId = $request->user()->id;
        $message = Message::findOrFail($messageId);

        if ($request->type === 'me') {
            \App\Models\MessageDeletion::updateOrCreate([
                'user_id' => $userId,
                'message_id' => $messageId
            ]);
            return response()->json(['status' => 'deleted_for_me']);
        }

        // Delete for everyone
        if ((int)$message->sender_id !== (int)$userId) {
            return response()->json(['error' => 'You can only delete your own messages for everyone.'], 403);
        }

        $message->update(['is_deleted_everyone' => true]);

        // Notify both participants
        $senderId = (int)$message->sender_id;
        $receiverId = (int)$message->receiver_id;

        event(new SystemNotification([
            'type' => 'message_deleted_everyone',
            'messageId' => $messageId,
            'partnerId' => $receiverId
        ], $senderId));

        event(new SystemNotification([
            'type' => 'message_deleted_everyone',
            'messageId' => $messageId,
            'partnerId' => $senderId
        ], $receiverId));

        return response()->json(['status' => 'deleted_for_everyone']);
    }

    public function toggleReaction(Request $request, $messageId)
    {
        $request->validate(['emoji' => 'required|string']);
        $userId = $request->user()->id;
        $emoji = $request->emoji;

        $reaction = MessageReaction::where('message_id', $messageId)
            ->where('user_id', $userId)
            ->where('emoji', $emoji)
            ->first();

        if ($reaction) {
            $reaction->delete();
            $status = 'removed';
        } else {
            MessageReaction::create([
                'message_id' => $messageId,
                'user_id' => $userId,
                'emoji' => $emoji
            ]);
            $status = 'added';
        }

        $message = Message::with('reactions')->find($messageId);
        if (!$message) return response()->json(['error' => 'Not found'], 404);

        // Notify Sender: Partner is Receiver
        event(new SystemNotification([
            'type' => 'reaction_updated',
            'messageId' => $messageId,
            'reactions' => $message->reactions,
            'status' => $status,
            'partnerId' => $message->receiver_id
        ], $message->sender_id));

        // Notify Receiver: Partner is Sender
        event(new SystemNotification([
            'type' => 'reaction_updated',
            'messageId' => $messageId,
            'reactions' => $message->reactions,
            'status' => $status,
            'partnerId' => $message->sender_id
        ], $message->receiver_id));

        return response()->json(['status' => $status, 'reactions' => $message->reactions]);
    }

    public function togglePin(Request $request, $messageId)
    {
        $userId = $request->user()->id;
        $message = Message::findOrFail($messageId);

        $senderId = (int)$message->sender_id;
        $receiverId = (int)$message->receiver_id;

        $u1 = min($senderId, $receiverId);
        $u2 = max($senderId, $receiverId);

        $existing = PinnedMessage::where('user1_id', $u1)
            ->where('user2_id', $u2)
            ->first();

        if ($existing && $existing->message_id == $messageId) {
            $existing->delete();
            $status = 'unpinned';
            $pinnedMessage = null;
        } else {
            if ($existing) {
                $existing->update(['message_id' => $messageId]);
            } else {
                PinnedMessage::create([
                    'user1_id' => $u1,
                    'user2_id' => $u2,
                    'message_id' => $messageId
                ]);
            }
            $status = 'pinned';
            $pinnedMessage = $message->load('reactions');
        }

        // Notify Sender: Partner is Receiver
        event(new SystemNotification([
            'type' => 'pin_updated',
            'pinned' => $pinnedMessage,
            'status' => $status,
            'partnerId' => $receiverId
        ], $senderId));

        // Notify Receiver: Partner is Sender
        event(new SystemNotification([
            'type' => 'pin_updated',
            'pinned' => $pinnedMessage,
            'status' => $status,
            'partnerId' => $senderId
        ], $receiverId));

        return response()->json(['status' => $status, 'pinned' => $pinnedMessage]);
    }
}

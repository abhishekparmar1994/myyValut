<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Message;
use App\Models\MessageReaction;
use App\Models\PinnedMessage;
use App\Models\Room;
use App\Models\RoomMember;
use App\Events\SystemNotification;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;
use Exception;

class MessagesController extends Controller
{
    public function index(Request $request, $id)
    {
        $userId = $request->user()->id;
        $isRoom = $request->query('is_room') === 'true';

        $query = Message::query();

        if ($isRoom) {
            $query->where('room_id', $id);
        }
        else {
            $query->where(function ($q) use ($userId, $id) {
                $q->where(function ($sq) use ($userId, $id) {
                        $sq->where('sender_id', $userId)->where('receiver_id', $id);
                    }
                    )->orWhere(function ($sq) use ($userId, $id) {
                        $sq->where('sender_id', $id)->where('receiver_id', $userId);
                    }
                    );
                })->whereNull('room_id');
        }

        $limit = $request->query('limit', 50);

        $messages = $query->whereDoesntHave('deletions', function ($q) use ($userId) {
            $q->where('user_id', $userId);
        })
            ->with(['reactions', 'replyTo', 'sender'])
            ->orderBy('created_at', 'desc') // Get latest first
            ->paginate($limit);

        // Reverse for chat display
        $messages_items = collect($messages->items())->reverse()->values();

        $pinned = null;
        if (!$isRoom) {
            $pinned = \App\Models\PinnedMessage::where(function ($q) use ($userId, $id) {
                $q->where('user1_id', $userId)->where('user2_id', $id);
            })->orWhere(function ($q) use ($userId, $id) {
                $q->where('user1_id', $id)->where('user2_id', $userId);
            })->with('message.reactions')->first();
        }

        return response()->json([
            'messages' => $messages_items,
            'pagination' => [
                'current_page' => $messages->currentPage(),
                'last_page' => $messages->lastPage(),
                'total' => $messages->total(),
            ],
            'pinned' => $pinned ? $pinned->message : null
        ]);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'receiver_id' => 'required_without:room_id|nullable|exists:users,id',
            'room_id' => 'required_without:receiver_id|nullable|exists:rooms,id',
            'content' => 'required|string',
            'type' => 'nullable|string',
            'file_name' => 'nullable|string',
            'reply_to_id' => 'nullable|exists:messages,id',
            'is_forwarded' => 'nullable|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $senderId = $request->user()->id;
        $receiverId = $request->receiver_id;
        $roomId = $request->room_id;

        if ($receiverId) {
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
        }

        // Log incoming metadata for debugging
        if ($request->has('link_metadata')) {
            \Log::info('[CHAT] Incoming link metadata:', ['data' => $request->link_metadata]);
        }

        $message = Message::create([
            'sender_id' => $senderId,
            'receiver_id' => $receiverId,
            'room_id' => $roomId,
            'content' => $request->content,
            'type' => $request->type ?? 'text',
            'file_name' => $request->file_name,
            'reply_to_id' => $request->reply_to_id,
            'is_forwarded' => $request->is_forwarded ?? false,
            'link_metadata' => $request->link_metadata,
        ]);

        $message->load(['replyTo', 'sender']);

        // Notification logic
        $payload = [
            'type' => 'message_received',
            'message' => $message,
        ];

        if ($roomId) {
            $room = \App\Models\Room::with('members')->find($roomId);
            foreach ($room->members as $member) {
                if ($member->id !== $senderId) {
                    event(new SystemNotification($payload, $member->id));
                }
            }
        }
        else {
            event(new SystemNotification($payload, $receiverId));
        }

        return response()->json($message, 201);
    }

    public function getLinkMetadata(Request $request)
    {
        $url = $request->query('url');
        if (!$url || !filter_var($url, FILTER_VALIDATE_URL)) {
            return response()->json(['url' => $url, 'success' => false, 'error' => 'Invalid URL'], 422);
        }

        try {
            $html = $this->fetchHtmlWithCurl($url);
            if (!$html) {
                return response()->json(['url' => $url, 'success' => false, 'error' => 'Could not fetch content']);
            }

            libxml_use_internal_errors(true);
            $doc = new \DOMDocument();
            // Suppress errors and handle encoding
            @$doc->loadHTML(mb_convert_encoding($html, 'HTML-ENTITIES', 'UTF-8'));
            libxml_clear_errors();

            $xpath = new \DOMXPath($doc);

            $metadata = [
                'url' => $url,
                'title' => '',
                'description' => '',
                'image' => '',
                'success' => true
            ];

            // Title detection - use string() to get text value directly
            $titleQueries = [
                'string(//meta[@property="og:title"]/@content)',
                'string(//meta[@name="og:title"]/@content)',
                'string(//meta[@name="twitter:title"]/@content)',
                'string(//meta[@name="title"]/@content)',
                'string(//title)'
            ];
            foreach ($titleQueries as $query) {
                $val = trim($xpath->evaluate($query));
                if ($val) {
                    $metadata['title'] = html_entity_decode($val);
                    break;
                }
            }

            // Description detection
            $descQueries = [
                'string(//meta[@property="og:description"]/@content)',
                'string(//meta[@name="og:description"]/@content)',
                'string(//meta[@name="twitter:description"]/@content)',
                'string(//meta[@name="description"]/@content)'
            ];
            foreach ($descQueries as $query) {
                $val = trim($xpath->evaluate($query));
                if ($val) {
                    $metadata['description'] = html_entity_decode($val);
                    break;
                }
            }

            // Image detection
            $imageQueries = [
                'string(//meta[@property="og:image"]/@content)',
                'string(//meta[@property="og:image:url"]/@content)',
                'string(//meta[@name="twitter:image"]/@content)',
                'string(//meta[@name="image"]/@content)',
                'string(//img[1]/@src)' // Extra fallback
            ];
            foreach ($imageQueries as $query) {
                $val = trim($xpath->evaluate($query));
                if ($val) {
                    $metadata['image'] = $val;
                    break;
                }
            }

            // Absolute URL for image
            if ($metadata['image']) {
                if (!filter_var($metadata['image'], FILTER_VALIDATE_URL)) {
                    $parsedUrl = parse_url($url);
                    $baseUrl = ($parsedUrl['scheme'] ?? 'http') . '://' . ($parsedUrl['host'] ?? '');

                    if (strpos($metadata['image'], '//') === 0) {
                        $metadata['image'] = ($parsedUrl['scheme'] ?? 'http') . ':' . $metadata['image'];
                    }
                    elseif (strpos($metadata['image'], '/') === 0) {
                        $metadata['image'] = $baseUrl . $metadata['image'];
                    }
                    else {
                        $path = isset($parsedUrl['path']) ? dirname($parsedUrl['path']) : '';
                        $metadata['image'] = $baseUrl . ($path === '/' ? '' : $path) . '/' . $metadata['image'];
                    }
                }
            }

            // Final sanity check
            if (empty($metadata['title']) && empty($metadata['image']) && empty($metadata['description'])) {
                $metadata['success'] = false;
            }

            return response()->json($metadata);
        }
        catch (\Exception $e) {
            return response()->json(['url' => $url, 'success' => false, 'error' => $e->getMessage()]);
        }
    }

    private function fetchHtmlWithCurl($url)
    {
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
        curl_setopt($ch, CURLOPT_MAXREDIRS, 5);
        curl_setopt($ch, CURLOPT_TIMEOUT, 10);
        curl_setopt($ch, CURLOPT_USERAGENT, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36');
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false); // For local dev environments
        curl_setopt($ch, CURLOPT_ENCODING, ''); // Handle compressed responses

        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        return ($httpCode === 200) ? $response : false;
    }

    public function markAsRead(Request $request, $id)
    {
        $isRoom = $request->query('is_room') === 'true';
        $userId = $request->user()->id;

        if ($isRoom) {
            RoomMember::where('room_id', $id)
                ->where('user_id', $userId)
                ->update(['last_read_at' => now()]);
        }
        else {
            Message::where('sender_id', $id)
                ->where('receiver_id', $userId)
                ->where('is_read', false)
                ->update(['is_read' => true]);
        }

        return response()->json(['status' => 'success']);
    }

    public function unreadCounts(Request $request)
    {
        $userId = $request->user()->id;

        // DM counts
        $counts = Message::where('receiver_id', $userId)
            ->whereNull('room_id')
            ->where('is_read', false)
            ->where('is_deleted_everyone', false)
            ->whereDoesntHave('deletions', function ($q) use ($userId) {
            $q->where('user_id', $userId);
        })
            ->groupBy('sender_id')
            ->selectRaw('sender_id, count(*) as count')
            ->get()
            ->pluck('count', 'sender_id')
            ->mapWithKeys(function ($count, $senderId) {
            return ["user_$senderId" => $count];
        })
            ->toArray();

        // Room counts
        $roomMembers = RoomMember::where('user_id', $userId)->get();
        foreach ($roomMembers as $member) {
            $roomUnread = Message::where('room_id', $member->room_id)
                ->where('sender_id', '!=', $userId)
                ->where(function ($q) use ($member) {
                if ($member->last_read_at) {
                    $q->where('created_at', '>', $member->last_read_at);
                }
            })
                ->whereDoesntHave('deletions', function ($q) use ($userId) {
                $q->where('user_id', $userId);
            })
                ->count();

            if ($roomUnread > 0) {
                $counts["room_{$member->room_id}"] = $roomUnread;
            }
        }

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
            $encryptedPath = encrypt($path);
            $url = route('api.messages.file', ['path' => $encryptedPath]);

            // Determine type: 'image' or generic 'file'
            $type = str_contains($mime, 'image') ? 'image' : 'file';

            return response()->json([
                'url' => $url,
                'path' => $encryptedPath,
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
    public function getFile(Request $request, $encryptedPath)
    {
        try {
            $path = decrypt($encryptedPath);
        }
        catch (\Exception $e) {
            return response()->json(['error' => 'Invalid file token'], 400);
        }

        if (!Storage::disk('public')->exists($path)) {
            abort(404);
        }

        // Security Check: Is this user allowed to see this file?
        // Check if there is any message containing this path that this user is part of
        $userId = $request->user()->id;
        $hasAccess = Message::where('content', 'LIKE', '%' . $path . '%')
            ->where(function ($q) use ($userId) {
            $q->where('sender_id', $userId)
                ->orWhere('receiver_id', $userId)
                ->orWhereHas('room.members', function ($sq) use ($userId) {
                $sq->where('user_id', $userId);
            }
            );
        })->exists();

        if (!$hasAccess) {
            return response()->json(['error' => 'Unauthorized access to media'], 403);
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

        // Notify participants
        $senderId = (int)$message->sender_id;
        $roomId = $message->room_id;

        if ($roomId) {
            $payload = [
                'type' => 'message_deleted_everyone',
                'messageId' => $messageId,
                'roomId' => $roomId,
                'senderId' => $senderId
            ];

            $room = \App\Models\Room::with('members')->find($roomId);
            foreach ($room->members as $member) {
                event(new SystemNotification($payload, $member->id));
            }
        }
        else {
            $receiverId = (int)$message->receiver_id;

            // Notify sender
            event(new SystemNotification([
                'type' => 'message_deleted_everyone',
                'messageId' => $messageId,
                'partnerId' => $receiverId
            ], $senderId));

            // Notify receiver
            event(new SystemNotification([
                'type' => 'message_deleted_everyone',
                'messageId' => $messageId,
                'partnerId' => $senderId
            ], $receiverId));
        }

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
        }
        else {
            MessageReaction::create([
                'message_id' => $messageId,
                'user_id' => $userId,
                'emoji' => $emoji
            ]);
            $status = 'added';
        }

        $message = Message::with('reactions')->find($messageId);
        if (!$message)
            return response()->json(['error' => 'Not found'], 404);

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
        }
        else {
            if ($existing) {
                $existing->update(['message_id' => $messageId]);
            }
            else {
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

    public function editMessage(Request $request, $messageId)
    {
        $request->validate(['content' => 'required|string']);
        $userId = $request->user()->id;
        $message = Message::findOrFail($messageId);

        if ((int)$message->sender_id !== (int)$userId) {
            return response()->json(['error' => 'You can only edit your own messages.'], 403);
        }

        if ($message->is_deleted_everyone) {
            return response()->json(['error' => 'Cannot edit a deleted message.'], 403);
        }

        // 1 hour limit
        if ($message->created_at->diffInHours(now()) >= 1) {
            return response()->json(['error' => 'Messages can only be edited within 1 hour of sending.'], 403);
        }

        $message->update([
            'content' => $request->content,
            'is_edited' => true
        ]);

        // Notify both participants
        $senderId = (int)$message->sender_id;
        $receiverId = (int)$message->receiver_id;

        $payload = [
            'type' => 'message_edited',
            'messageId' => $messageId,
            'content' => $message->content,
            'is_edited' => true,
            'partnerId' => $receiverId
        ];

        event(new SystemNotification($payload, $senderId));

        $payload['partnerId'] = $senderId;
        event(new SystemNotification($payload, $receiverId));

        return response()->json(['status' => 'success', 'message' => $message]);
    }
}

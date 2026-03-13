<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Message;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;

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
        ->orderBy('created_at', 'asc')
        ->get();

        return response()->json($messages);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'receiver_id' => 'required|exists:users,id',
            'content' => 'required|string',
            'type' => 'nullable|string',
            'file_name' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $senderId = $request->user()->id;
        $receiverId = $request->receiver_id;

        // Check for active blocks
        $isBlocked = \App\Models\UserBlock::where(function($query) use ($senderId, $receiverId) {
                $query->where('blocker_id', $senderId)
                      ->where('blocked_id', $receiverId);
            })->orWhere(function($query) use ($senderId, $receiverId) {
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
        ]);

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
}

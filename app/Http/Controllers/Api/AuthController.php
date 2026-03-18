<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Traits\LogsActivity;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class AuthController extends Controller
{
    use LogsActivity;

    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8|confirmed',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
        ]);

        $this->logActivity($user->id, 'registered', 'Account created successfully', '🎉');

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'access_token' => $token,
            'token_type' => 'Bearer',
        ]);
    }

    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'message' => 'Invalid login details'
            ], 401);
        }

        $this->logActivity($user->id, 'logged_in', 'Signed in to your account', '🔐');

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'access_token' => $token,
            'token_type' => 'Bearer',
        ]);
    }

    public function logout(Request $request)
    {
        $this->logActivity($request->user()->id, 'logged_out', 'Signed out of your account', '👋');

        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Successfully logged out'
        ]);
    }

    public function users(Request $request)
    {
        $currentUserId = $request->user()->id;
        
        return response()->json(
            User::where('id', '!=', $currentUserId)
                ->select('id', 'name', 'email', 'profile_image')
                ->addSelect(['last_message' => \App\Models\Message::select('content')
                    ->where(function ($q) use ($currentUserId) {
                        $q->where('sender_id', $currentUserId)
                          ->whereColumn('receiver_id', 'users.id');
                    })
                    ->orWhere(function ($q) use ($currentUserId) {
                        $q->where('receiver_id', $currentUserId)
                          ->whereColumn('sender_id', 'users.id');
                    })
                    ->where('is_deleted_everyone', false)
                    ->whereDoesntHave('deletions', function ($q) use ($currentUserId) {
                        $q->where('user_id', $currentUserId);
                    })
                    ->latest()
                    ->limit(1)
                ])
                ->addSelect(['last_message_id' => \App\Models\Message::select('id')
                    ->where(function ($q) use ($currentUserId) {
                        $q->where('sender_id', $currentUserId)
                          ->whereColumn('receiver_id', 'users.id');
                    })
                    ->orWhere(function ($q) use ($currentUserId) {
                        $q->where('receiver_id', $currentUserId)
                          ->whereColumn('sender_id', 'users.id');
                    })
                    ->where('is_deleted_everyone', false)
                    ->whereDoesntHave('deletions', function ($q) use ($currentUserId) {
                        $q->where('user_id', $currentUserId);
                    })
                    ->latest()
                    ->limit(1)
                ])
                ->addSelect(['last_message_type' => \App\Models\Message::select('type')
                    ->where(function ($q) use ($currentUserId) {
                        $q->where('sender_id', $currentUserId)
                          ->whereColumn('receiver_id', 'users.id');
                    })
                    ->orWhere(function ($q) use ($currentUserId) {
                        $q->where('receiver_id', $currentUserId)
                          ->whereColumn('sender_id', 'users.id');
                    })
                    ->where('is_deleted_everyone', false)
                    ->whereDoesntHave('deletions', function ($q) use ($currentUserId) {
                        $q->where('user_id', $currentUserId);
                    })
                    ->latest()
                    ->limit(1)
                ])
                ->addSelect(['last_message_time' => \App\Models\Message::select('created_at')
                    ->where(function ($q) use ($currentUserId) {
                        $q->where('sender_id', $currentUserId)
                          ->whereColumn('receiver_id', 'users.id');
                    })
                    ->orWhere(function ($q) use ($currentUserId) {
                        $q->where('receiver_id', $currentUserId)
                          ->whereColumn('sender_id', 'users.id');
                    })
                    ->where('is_deleted_everyone', false)
                    ->whereDoesntHave('deletions', function ($q) use ($currentUserId) {
                        $q->where('user_id', $currentUserId);
                    })
                    ->latest()
                    ->limit(1)
                ])
                ->addSelect(['is_archived' => \App\Models\ChatSetting::select('is_archived')
                    ->where('user_id', $currentUserId)
                    ->whereColumn('target_id', 'users.id')
                    ->limit(1)
                ])
                ->addSelect(['is_favourite' => \App\Models\ChatSetting::select('is_favourite')
                    ->where('user_id', $currentUserId)
                    ->whereColumn('target_id', 'users.id')
                    ->limit(1)
                ])
                ->addSelect(['is_unread_manual' => \App\Models\ChatSetting::select('is_unread_manual')
                    ->where('user_id', $currentUserId)
                    ->whereColumn('target_id', 'users.id')
                    ->limit(1)
                ])
                ->get()
                ->map(function($user) {
                    $user->is_archived = (bool)$user->is_archived;
                    $user->is_favourite = (bool)$user->is_favourite;
                    $user->is_unread_manual = (bool)$user->is_unread_manual;
                    return $user;
                })
        );
    }
}

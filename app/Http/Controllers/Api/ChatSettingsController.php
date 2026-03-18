<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ChatSetting;
use App\Models\RoomMember;
use Illuminate\Http\Request;

class ChatSettingsController extends Controller
{
    public function toggleArchive(Request $request)
    {
        $request->validate([
            'is_room' => 'required|boolean',
            'target_id' => 'required|integer',
        ]);

        $userId = $request->user()->id;
        $targetId = $request->target_id;

        if ($request->is_room) {
            $member = RoomMember::where('room_id', $targetId)->where('user_id', $userId)->firstOrFail();
            $member->update(['is_archived' => !$member->is_archived]);
            return response()->json(['is_archived' => $member->is_archived]);
        } else {
            $setting = ChatSetting::firstOrCreate(
                ['user_id' => $userId, 'target_id' => $targetId]
            );
            $setting->update(['is_archived' => !$setting->is_archived]);
            return response()->json(['is_archived' => $setting->is_archived]);
        }
    }

    public function toggleFavourite(Request $request)
    {
        $request->validate([
            'is_room' => 'required|boolean',
            'target_id' => 'required|integer',
        ]);

        $userId = $request->user()->id;
        $targetId = $request->target_id;

        if ($request->is_room) {
            $member = RoomMember::where('room_id', $targetId)->where('user_id', $userId)->firstOrFail();
            $member->update(['is_favourite' => !$member->is_favourite]);
            return response()->json(['is_favourite' => $member->is_favourite]);
        } else {
            $setting = ChatSetting::firstOrCreate(
                ['user_id' => $userId, 'target_id' => $targetId]
            );
            $setting->update(['is_favourite' => !$setting->is_favourite]);
            return response()->json(['is_favourite' => $setting->is_favourite]);
        }
    }

    public function toggleUnread(Request $request)
    {
        $request->validate([
            'is_room' => 'required|boolean',
            'target_id' => 'required|integer',
            'status' => 'required|boolean'
        ]);

        $userId = $request->user()->id;
        $targetId = $request->target_id;

        if ($request->is_room) {
            $member = RoomMember::where('room_id', $targetId)->where('user_id', $userId)->firstOrFail();
            $member->update(['is_unread_manual' => $request->status]);
            return response()->json(['is_unread_manual' => $member->is_unread_manual]);
        } else {
            $setting = ChatSetting::firstOrCreate(
                ['user_id' => $userId, 'target_id' => $targetId]
            );
            $setting->update(['is_unread_manual' => $request->status]);
            return response()->json(['is_unread_manual' => $setting->is_unread_manual]);
        }
    }
}

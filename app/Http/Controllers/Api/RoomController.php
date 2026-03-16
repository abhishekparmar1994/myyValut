<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Room;
use App\Models\RoomMember;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class RoomController extends Controller
{
    public function index(Request $request)
    {
        $rooms = $request->user()->rooms()->with(['members'])->get();
        return response()->json($rooms);
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'member_ids' => 'required|array',
            'member_ids.*' => 'exists:users,id',
            'description' => 'nullable|string',
        ]);

        return DB::transaction(function () use ($request) {
            $room = Room::create([
                'name' => $request->name,
                'type' => 2, // Group
                'description' => $request->description,
                'created_by' => $request->user()->id,
            ]);

            // Add creator as admin
            $room->members()->attach($request->user()->id, ['role' => 'admin']);

            // Add other members
            $memberIds = array_diff($request->member_ids, [$request->user()->id]);
            foreach ($memberIds as $id) {
                $room->members()->attach($id, ['role' => 'member']);
            }

            return response()->json($room->load('members'), 201);
        });
    }

    public function show(Room $room)
    {
        $room->load(['members', 'creator']);
        return response()->json($room);
    }

    public function update(Request $request, Room $room)
    {
        // Check if user is admin
        $member = RoomMember::where('room_id', $room->id)
            ->where('user_id', $request->user()->id)
            ->first();

        if (!$member || $member->role !== 'admin') {
            return response()->json(['error' => 'Unauthorized. Only admins can update the group.'], 403);
        }

        $request->validate([
            'name' => 'sometimes|string|max:255',
            'description' => 'nullable|string',
        ]);

        $room->update($request->only(['name', 'description']));

        return response()->json($room);
    }

    public function addMembers(Request $request, Room $room)
    {
        $memberAt = RoomMember::where('room_id', $room->id)
            ->where('user_id', $request->user()->id)
            ->first();

        if (!$memberAt || $memberAt->role !== 'admin') {
            return response()->json(['error' => 'Only admins can add members.'], 403);
        }

        $request->validate([
            'user_ids' => 'required|array',
            'user_ids.*' => 'exists:users,id',
        ]);

        foreach ($request->user_ids as $userId) {
            if (!$room->members()->where('users.id', $userId)->exists()) {
                $room->members()->attach($userId, ['role' => 'member']);
            }
        }

        return response()->json($room->load('members'));
    }

    public function leave(Request $request, Room $room)
    {
        $userId = $request->user()->id;
        $member = RoomMember::where('room_id', $room->id)
            ->where('user_id', $userId)
            ->first();

        if (!$member) {
            return response()->json(['error' => 'You are not a member of this room.'], 404);
        }

        return DB::transaction(function () use ($room, $member, $userId) {
            $role = $member->role;
            $member->delete();

            // If leaving user was an admin, check if we need to promote someone
            if ($role === 'admin') {
                $anyOtherAdmin = RoomMember::where('room_id', $room->id)
                    ->where('role', 'admin')
                    ->exists();

                if (!$anyOtherAdmin) {
                    // Promote longest standing member
                    $nextAdmin = RoomMember::where('room_id', $room->id)
                        ->orderBy('created_at', 'asc')
                        ->first();

                    if ($nextAdmin) {
                        $nextAdmin->update(['role' => 'admin']);
                    }
                }
            }

            // If no members left, optionally delete room? For now keep it.
            if ($room->members()->count() === 0) {
                // $room->delete();
            }

            return response()->json(['message' => 'Successfully left the room.']);
        });
    }
}

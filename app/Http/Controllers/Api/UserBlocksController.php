<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\UserBlock;
use Illuminate\Http\Request;

class UserBlocksController extends Controller
{
    public function index(Request $request)
    {
        $blockedUsers = UserBlock::where('blocker_id', $request->user()->id)
            ->with('blocked')
            ->get()
            ->pluck('blocked');

        return response()->json($blockedUsers);
    }

    public function toggle(Request $request)
    {
        $request->validate([
            'blocked_id' => 'required|exists:users,id'
        ]);

        $blockerId = $request->user()->id;
        $blockedId = $request->blocked_id;

        if ($blockerId == $blockedId) {
            return response()->json(['error' => 'You cannot block yourself'], 400);
        }

        $block = UserBlock::where('blocker_id', $blockerId)
            ->where('blocked_id', $blockedId)
            ->first();

        if ($block) {
            $block->delete();
            event(new \App\Events\UserBlockToggled($blockerId, $blockedId, 'unblocked'));
            return response()->json(['status' => 'unblocked']);
        }

        UserBlock::create([
            'blocker_id' => $blockerId,
            'blocked_id' => $blockedId
        ]);

        event(new \App\Events\UserBlockToggled($blockerId, $blockedId, 'blocked'));

        return response()->json(['status' => 'blocked']);
    }

    public function check(Request $request, $userId)
    {
        $myId = $request->user()->id;
        
        $blockedByMe = UserBlock::where('blocker_id', $myId)
            ->where('blocked_id', $userId)
            ->exists();
            
        $hasBlockedMe = UserBlock::where('blocker_id', $userId)
            ->where('blocked_id', $myId)
            ->exists();

        return response()->json([
            'blocked_by_me' => $blockedByMe,
            'has_blocked_me' => $hasBlockedMe,
            'is_blocked' => $blockedByMe || $hasBlockedMe
        ]);
    }
}

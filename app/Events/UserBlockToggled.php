<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class UserBlockToggled implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $blockerId;
    public $blockedId;
    public $status; // 'blocked' or 'unblocked'

    public function __construct($blockerId, $blockedId, $status)
    {
        $this->blockerId = $blockerId;
        $this->blockedId = $blockedId;
        $this->status = $status;
    }

    public function broadcastOn(): array
    {
        // Broadcast on a public channel unique to the user
        return [
            new Channel('user.' . $this->blockedId),
        ];
    }

    public function broadcastAs(): string
    {
        return 'block.updated';
    }

    public function broadcastWith(): array
    {
        return [
            'blockerId' => $this->blockerId,
            'status' => $this->status,
        ];
    }
}

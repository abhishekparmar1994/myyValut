<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PinnedMessage extends Model
{
    protected $fillable = ['user1_id', 'user2_id', 'message_id'];

    public function message(): BelongsTo
    {
        return $this->belongsTo(Message::class);
    }
}

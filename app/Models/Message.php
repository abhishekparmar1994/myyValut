<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Message extends Model
{
    protected $fillable = [
        'room_id',
        'sender_id',
        'receiver_id',
        'content',
        'type',
        'file_name',
        'is_read',
        'reply_to_id',
        'is_deleted_everyone',
        'is_edited',
        'is_forwarded',
        'link_metadata'
    ];

    protected $casts = [
        'is_read' => 'boolean',
        'is_deleted_everyone' => 'boolean',
        'is_edited' => 'boolean',
        'is_forwarded' => 'boolean',
        'link_metadata' => 'array'
    ];

    public function deletions()
    {
        return $this->hasMany(MessageDeletion::class);
    }

    public function reactions()
    {
        return $this->hasMany(MessageReaction::class);
    }

    public function replyTo(): BelongsTo
    {
        return $this->belongsTo(Message::class , 'reply_to_id');
    }

    public function replies()
    {
        return $this->hasMany(Message::class , 'reply_to_id');
    }

    public function sender(): BelongsTo
    {
        return $this->belongsTo(User::class , 'sender_id');
    }

    public function receiver(): BelongsTo
    {
        return $this->belongsTo(User::class , 'receiver_id');
    }

    public function room(): BelongsTo
    {
        return $this->belongsTo(Room::class);
    }
}

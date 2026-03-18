<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ChatSetting extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'target_id',
        'is_archived',
        'is_favourite',
        'is_unread_manual'
    ];

    protected $casts = [
        'is_archived' => 'boolean',
        'is_favourite' => 'boolean',
        'is_unread_manual' => 'boolean'
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function targetUser()
    {
        return $this->belongsTo(User::class, 'target_id');
    }
}

<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class RoomMember extends Model
{
    protected $table = 'room_members';
    
    protected $fillable = [
        'room_id',
        'user_id',
        'role',
        'last_read_at'
    ];

    protected $casts = [
        'last_read_at' => 'datetime',
    ];

    public function room()
    {
        return $this->belongsTo(Room::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}

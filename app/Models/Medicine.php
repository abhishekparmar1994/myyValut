<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class Medicine extends Model
{
    protected $fillable = [
        'user_id', 'name', 'dosage', 'times',
        'start_date', 'end_date', 'is_active', 'notes',
    ];

    protected $casts = [
        'times'      => 'array',
        'start_date' => 'date',
        'end_date'   => 'date',
        'is_active'  => 'boolean',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Is this medicine still active today?
     */
    public function getIsOngoingAttribute(): bool
    {
        if (!$this->is_active) return false;
        $today = Carbon::today();
        if ($this->start_date->gt($today)) return false;
        if ($this->end_date && $this->end_date->lt($today)) return false;
        return true;
    }

    /**
     * Scope: medicines that should be taken today.
     */
    public function scopeActiveToday($query)
    {
        $today = Carbon::today();
        return $query->where('is_active', true)
                     ->where('start_date', '<=', $today)
                     ->where(function ($q) use ($today) {
                         $q->whereNull('end_date')->orWhere('end_date', '>=', $today);
                     });
    }
}

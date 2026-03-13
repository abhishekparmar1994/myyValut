<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class Reminder extends Model
{
    protected $fillable = [
        'user_id',
        'title',
        'type',
        'reminder_date',
        'repeat_type',
        'mobile_number',
        'notes',
    ];

    protected $casts = [
        'reminder_date' => 'date',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the next occurrence of this reminder from today.
     * Supports: none, monthly, yearly repeat types.
     */
    public function getNextOccurrenceAttribute(): Carbon
    {
        $today = Carbon::today();
        $date = $this->reminder_date->copy();

        if ($this->repeat_type === 'yearly') {
            $date->year($today->year);
            if ($date->lt($today)) {
                $date->addYear();
            }
        } elseif ($this->repeat_type === 'monthly') {
            // Same day-of-month each month
            $date = Carbon::today()->day($this->reminder_date->day);
            if ($date->lt($today)) {
                $date->addMonth();
            }
        }
        // 'none' → return the original date as-is

        return $date;
    }

    /**
     * Get days remaining until the next occurrence.
     */
    public function getDaysRemainingAttribute(): int
    {
        return (int) Carbon::today()->diffInDays($this->next_occurrence, false);
    }

    /**
     * Scope: upcoming reminders within the next N days.
     */
    public function scopeUpcoming($query, int $days = 7)
    {
        $today = Carbon::today();
        $end = $today->copy()->addDays($days);

        return $query->get()->filter(function ($reminder) use ($today, $end) {
            $next = $reminder->next_occurrence;
            return $next->gte($today) && $next->lte($end);
        });
    }
}

<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class Bill extends Model
{
    protected $fillable = [
        'user_id', 'name', 'category', 'amount',
        'due_day', 'auto_renews', 'last_paid_at', 'notes',
    ];

    protected $casts = [
        'auto_renews'  => 'boolean',
        'last_paid_at' => 'date',
        'amount'       => 'decimal:2',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * The next due date based on due_day (day of month).
     */
    public function getNextDueDateAttribute(): Carbon
    {
        $today = Carbon::today();
        $due   = Carbon::today()->day($this->due_day);
        if ($due->lt($today)) {
            $due->addMonth();
        }
        return $due;
    }

    /**
     * Days until next due date.
     */
    public function getDaysUntilDueAttribute(): int
    {
        return (int) Carbon::today()->diffInDays($this->next_due_date, false);
    }

    /**
     * Is this bill paid for the current month?
     */
    public function getIsPaidThisMonthAttribute(): bool
    {
        if (!$this->last_paid_at) return false;
        return $this->last_paid_at->month === Carbon::today()->month
            && $this->last_paid_at->year === Carbon::today()->year;
    }
}

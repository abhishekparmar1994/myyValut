<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class Vehicle extends Model
{
    protected $fillable = [
        'user_id', 'name', 'type', 'registration_number',
        'insurance_expiry', 'puc_expiry',
        'last_service_date', 'next_service_date', 'notes',
    ];

    protected $casts = [
        'insurance_expiry'    => 'date',
        'puc_expiry'          => 'date',
        'last_service_date'   => 'date',
        'next_service_date'   => 'date',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Returns days until expiry for a date field. Negative = already expired.
     */
    public function daysUntil(?Carbon $date): ?int
    {
        if (!$date) return null;
        return (int) Carbon::today()->diffInDays($date, false);
    }

    public function getInsuranceDaysAttribute(): ?int
    {
        return $this->daysUntil($this->insurance_expiry);
    }

    public function getPucDaysAttribute(): ?int
    {
        return $this->daysUntil($this->puc_expiry);
    }

    public function getServiceDaysAttribute(): ?int
    {
        return $this->daysUntil($this->next_service_date);
    }
}

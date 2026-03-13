<?php

namespace App\Traits;

use App\Models\UserActivity;

trait LogsActivity
{
    /**
     * Log an activity for a user.
     *
     * @param int    $userId
     * @param string $action       machine-readable key e.g. 'reminder_created'
     * @param string $description  human-readable string e.g. 'Created reminder: Mom Birthday'
     * @param string $icon         emoji icon
     */
    protected function logActivity(int $userId, string $action, string $description, string $icon = '📋'): void
    {
        UserActivity::create([
            'user_id'     => $userId,
            'action'      => $action,
            'description' => $description,
            'icon'        => $icon,
        ]);
    }
}

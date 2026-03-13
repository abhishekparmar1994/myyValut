<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Reminder;
use App\Traits\LogsActivity;
use Illuminate\Http\Request;

class ReminderController extends Controller
{
    use LogsActivity;

    private function formatReminder(Reminder $reminder): array
    {
        return array_merge($reminder->toArray(), [
            'next_occurrence' => $reminder->next_occurrence->toDateString(),
            'days_remaining'  => $reminder->days_remaining,
        ]);
    }

    public function index(Request $request)
    {
        $reminders = $request->user()->reminders()->orderBy('reminder_date')->get()
            ->map(fn($r) => $this->formatReminder($r));

        return response()->json($reminders);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'title'         => 'required|string|max:255',
            'type'          => 'required|in:birthday,anniversary,recharge,custom',
            'reminder_date' => 'required|date',
            'repeat_type'   => 'in:none,monthly,yearly',
            'mobile_number' => 'nullable|string|max:20',
            'notes'         => 'nullable|string|max:1000',
        ]);

        $reminder = $request->user()->reminders()->create($validated);

        $typeIcons = ['birthday' => '🎂', 'anniversary' => '💍', 'recharge' => '📱', 'custom' => '📅'];
        $icon = $typeIcons[$reminder->type] ?? '🔔';
        $this->logActivity($request->user()->id, 'reminder_created', "Added reminder: {$reminder->title}", $icon);

        return response()->json($this->formatReminder($reminder), 201);
    }

    public function update(Request $request, Reminder $reminder)
    {
        if ($reminder->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'title'         => 'sometimes|string|max:255',
            'type'          => 'sometimes|in:birthday,anniversary,recharge,custom',
            'reminder_date' => 'sometimes|date',
            'repeat_type'   => 'in:none,monthly,yearly',
            'mobile_number' => 'nullable|string|max:20',
            'notes'         => 'nullable|string|max:1000',
        ]);

        $reminder->update($validated);

        $this->logActivity($request->user()->id, 'reminder_updated', "Updated reminder: {$reminder->title}", '✏️');

        return response()->json($this->formatReminder($reminder));
    }

    public function destroy(Request $request, Reminder $reminder)
    {
        if ($reminder->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $title = $reminder->title;
        $reminder->delete();

        $this->logActivity($request->user()->id, 'reminder_deleted', "Deleted reminder: {$title}", '🗑️');

        return response()->json(['message' => 'Reminder deleted']);
    }

    public function upcoming(Request $request)
    {
        $reminders = $request->user()->reminders()->upcoming(7)
            ->sortBy('days_remaining')
            ->map(fn($r) => [
                'id'             => $r->id,
                'title'          => $r->title,
                'type'           => $r->type,
                'notes'          => $r->notes,
                'reminder_date'  => $r->reminder_date->toDateString(),
                'next_occurrence' => $r->next_occurrence->toDateString(),
                'days_remaining' => $r->days_remaining,
                'repeat_type'    => $r->repeat_type,
            ])->values();

        return response()->json($reminders);
    }
}

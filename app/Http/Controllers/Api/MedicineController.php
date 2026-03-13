<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Medicine;
use App\Traits\LogsActivity;
use Illuminate\Http\Request;
use Carbon\Carbon;

class MedicineController extends Controller
{
    use LogsActivity;

    private function format(Medicine $m): array
    {
        return [
            'id'         => $m->id,
            'name'       => $m->name,
            'dosage'     => $m->dosage,
            'times'      => $m->times,
            'start_date' => $m->start_date->toDateString(),
            'end_date'   => $m->end_date?->toDateString(),
            'is_active'  => $m->is_active,
            'is_ongoing' => $m->is_ongoing,
            'notes'      => $m->notes,
        ];
    }

    public function index(Request $request)
    {
        return response()->json(
            $request->user()->medicines()->latest()->get()->map(fn($m) => $this->format($m))
        );
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name'       => 'required|string|max:255',
            'dosage'     => 'nullable|string|max:100',
            'times'      => 'required|array|min:1',
            'times.*'    => 'required|date_format:H:i',
            'start_date' => 'required|date',
            'end_date'   => 'nullable|date|after_or_equal:start_date',
            'is_active'  => 'boolean',
            'notes'      => 'nullable|string|max:500',
        ]);

        $medicine = $request->user()->medicines()->create($validated);
        $this->logActivity($request->user()->id, 'medicine_added', "Added medicine: {$medicine->name}", '💊');

        return response()->json($this->format($medicine), 201);
    }

    public function update(Request $request, Medicine $medicine)
    {
        if ($medicine->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'name'       => 'sometimes|string|max:255',
            'dosage'     => 'nullable|string|max:100',
            'times'      => 'sometimes|array|min:1',
            'times.*'    => 'required|date_format:H:i',
            'start_date' => 'sometimes|date',
            'end_date'   => 'nullable|date',
            'is_active'  => 'boolean',
            'notes'      => 'nullable|string|max:500',
        ]);

        $medicine->update($validated);
        $this->logActivity($request->user()->id, 'medicine_updated', "Updated medicine: {$medicine->name}", '✏️');

        return response()->json($this->format($medicine));
    }

    public function destroy(Request $request, Medicine $medicine)
    {
        if ($medicine->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $name = $medicine->name;
        $medicine->delete();
        $this->logActivity($request->user()->id, 'medicine_deleted', "Removed medicine: {$name}", '🗑️');

        return response()->json(['message' => 'Medicine removed']);
    }

    public function today(Request $request)
    {
        $medicines = $request->user()->medicines()->activeToday()->get()
            ->map(fn($m) => $this->format($m));

        return response()->json($medicines);
    }
}

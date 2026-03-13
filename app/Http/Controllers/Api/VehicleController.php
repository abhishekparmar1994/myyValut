<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Vehicle;
use App\Traits\LogsActivity;
use Illuminate\Http\Request;

class VehicleController extends Controller
{
    use LogsActivity;

    private function format(Vehicle $v): array
    {
        return [
            'id'                   => $v->id,
            'name'                 => $v->name,
            'type'                 => $v->type,
            'registration_number'  => $v->registration_number,
            'insurance_expiry'     => $v->insurance_expiry?->toDateString(),
            'insurance_days'       => $v->insurance_days,
            'puc_expiry'           => $v->puc_expiry?->toDateString(),
            'puc_days'             => $v->puc_days,
            'last_service_date'    => $v->last_service_date?->toDateString(),
            'next_service_date'    => $v->next_service_date?->toDateString(),
            'service_days'         => $v->service_days,
            'notes'                => $v->notes,
        ];
    }

    public function index(Request $request)
    {
        return response()->json(
            $request->user()->vehicles()->latest()->get()->map(fn($v) => $this->format($v))
        );
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name'                => 'required|string|max:255',
            'type'                => 'required|in:car,bike,scooter,truck,auto,other',
            'registration_number' => 'nullable|string|max:20',
            'insurance_expiry'    => 'nullable|date',
            'puc_expiry'          => 'nullable|date',
            'last_service_date'   => 'nullable|date',
            'next_service_date'   => 'nullable|date',
            'notes'               => 'nullable|string|max:500',
        ]);

        $vehicle = $request->user()->vehicles()->create($validated);
        $this->logActivity($request->user()->id, 'vehicle_added', "Added vehicle: {$vehicle->name}", '🚗');

        return response()->json($this->format($vehicle), 201);
    }

    public function update(Request $request, Vehicle $vehicle)
    {
        if ($vehicle->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'name'                => 'sometimes|string|max:255',
            'type'                => 'sometimes|in:car,bike,scooter,truck,auto,other',
            'registration_number' => 'nullable|string|max:20',
            'insurance_expiry'    => 'nullable|date',
            'puc_expiry'          => 'nullable|date',
            'last_service_date'   => 'nullable|date',
            'next_service_date'   => 'nullable|date',
            'notes'               => 'nullable|string|max:500',
        ]);

        $vehicle->update($validated);
        $this->logActivity($request->user()->id, 'vehicle_updated', "Updated vehicle: {$vehicle->name}", '✏️');

        return response()->json($this->format($vehicle));
    }

    public function destroy(Request $request, Vehicle $vehicle)
    {
        if ($vehicle->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $name = $vehicle->name;
        $vehicle->delete();
        $this->logActivity($request->user()->id, 'vehicle_deleted', "Deleted vehicle: {$name}", '🗑️');

        return response()->json(['message' => 'Vehicle deleted']);
    }
}

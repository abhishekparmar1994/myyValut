<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Bill;
use App\Traits\LogsActivity;
use Illuminate\Http\Request;
use Carbon\Carbon;

class BillController extends Controller
{
    use LogsActivity;

    private function format(Bill $b): array
    {
        return [
            'id'               => $b->id,
            'name'             => $b->name,
            'category'         => $b->category,
            'amount'           => $b->amount,
            'due_day'          => $b->due_day,
            'auto_renews'      => $b->auto_renews,
            'last_paid_at'     => $b->last_paid_at?->toDateString(),
            'notes'            => $b->notes,
            'next_due_date'    => $b->next_due_date->toDateString(),
            'days_until_due'   => $b->days_until_due,
            'is_paid_this_month' => $b->is_paid_this_month,
        ];
    }

    public function index(Request $request)
    {
        return response()->json(
            $request->user()->bills()->latest()->get()->map(fn($b) => $this->format($b))
        );
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name'        => 'required|string|max:255',
            'category'    => 'required|in:electricity,water,gas,internet,phone,credit_card,insurance,emi,other',
            'amount'      => 'nullable|numeric|min:0',
            'due_day'     => 'required|integer|min:1|max:31',
            'auto_renews' => 'boolean',
            'notes'       => 'nullable|string|max:500',
        ]);

        $bill = $request->user()->bills()->create($validated);
        $this->logActivity($request->user()->id, 'bill_added', "Added bill: {$bill->name}", '💡');

        return response()->json($this->format($bill), 201);
    }

    public function update(Request $request, Bill $bill)
    {
        if ($bill->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'name'        => 'sometimes|string|max:255',
            'category'    => 'sometimes|in:electricity,water,gas,internet,phone,credit_card,insurance,emi,other',
            'amount'      => 'nullable|numeric|min:0',
            'due_day'     => 'sometimes|integer|min:1|max:31',
            'auto_renews' => 'boolean',
            'notes'       => 'nullable|string|max:500',
        ]);

        $bill->update($validated);
        $this->logActivity($request->user()->id, 'bill_updated', "Updated bill: {$bill->name}", '✏️');

        return response()->json($this->format($bill));
    }

    public function destroy(Request $request, Bill $bill)
    {
        if ($bill->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $name = $bill->name;
        $bill->delete();
        $this->logActivity($request->user()->id, 'bill_deleted', "Removed bill: {$name}", '🗑️');

        return response()->json(['message' => 'Bill removed']);
    }

    public function markPaid(Request $request, Bill $bill)
    {
        if ($bill->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $bill->update(['last_paid_at' => Carbon::today()]);
        $this->logActivity($request->user()->id, 'bill_paid', "Marked as paid: {$bill->name}", '✅');

        return response()->json($this->format($bill));
    }
}

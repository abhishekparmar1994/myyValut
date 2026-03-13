<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use App\Traits\LogsActivity;
use Illuminate\Http\Request;
use Carbon\Carbon;

class TransactionController extends Controller
{
    use LogsActivity;

    private function format(Transaction $t): array
    {
        return [
            'id'          => $t->id,
            'type'        => $t->type,
            'category'    => $t->category,
            'amount'      => (float) $t->amount,
            'description' => $t->description,
            'date'        => $t->date->toDateString(),
        ];
    }

    public function index(Request $request)
    {
        $month = $request->query('month', Carbon::today()->format('Y-m'));
        [$year, $month] = explode('-', $month);

        $transactions = $request->user()
            ->transactions()
            ->whereYear('date', $year)
            ->whereMonth('date', $month)
            ->orderByDesc('date')
            ->get()
            ->map(fn($t) => $this->format($t));

        return response()->json($transactions);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'type'        => 'required|in:income,expense',
            'category'    => 'required|string|max:100',
            'amount'      => 'required|numeric|min:0.01',
            'description' => 'nullable|string|max:255',
            'date'        => 'required|date',
        ]);

        $tx = $request->user()->transactions()->create($validated);
        $icon = $tx->type === 'income' ? '💰' : '💸';
        $this->logActivity($request->user()->id, 'transaction_added',
            "{$tx->type}: ₹{$tx->amount} ({$tx->category})", $icon);

        return response()->json($this->format($tx), 201);
    }

    public function destroy(Request $request, Transaction $transaction)
    {
        if ($transaction->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $transaction->delete();
        return response()->json(['message' => 'Transaction deleted']);
    }

    public function summary(Request $request)
    {
        $month = $request->query('month', Carbon::today()->format('Y-m'));
        [$year, $m] = explode('-', $month);

        $transactions = $request->user()
            ->transactions()
            ->whereYear('date', $year)
            ->whereMonth('date', $m)
            ->get();

        $income  = $transactions->where('type', 'income')->sum('amount');
        $expense = $transactions->where('type', 'expense')->sum('amount');

        // Category breakdown
        $breakdown = $transactions
            ->where('type', 'expense')
            ->groupBy('category')
            ->map(fn($g) => round($g->sum('amount'), 2))
            ->sortDesc();

        return response()->json([
            'income'    => (float) $income,
            'expense'   => (float) $expense,
            'balance'   => (float) ($income - $expense),
            'breakdown' => $breakdown,
        ]);
    }
}

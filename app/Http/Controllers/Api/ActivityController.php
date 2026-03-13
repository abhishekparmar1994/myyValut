<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class ActivityController extends Controller
{
    public function index(Request $request)
    {
        $activities = $request->user()
            ->activities()
            ->latest()
            ->take(20)
            ->get()
            ->map(fn($a) => [
                'id'          => $a->id,
                'action'      => $a->action,
                'description' => $a->description,
                'icon'        => $a->icon,
                'created_at'  => $a->created_at->diffForHumans(),
                'date'        => $a->created_at->toDateTimeString(),
            ]);

        return response()->json($activities);
    }
}

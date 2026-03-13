<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Note;
use App\Traits\LogsActivity;
use Illuminate\Http\Request;

class NoteController extends Controller
{
    use LogsActivity;

    private function format(Note $n): array
    {
        return [
            'id'        => $n->id,
            'title'     => $n->title,
            'content'   => $n->content,
            'type'      => $n->type,
            'is_done'   => $n->is_done,
            'is_pinned' => $n->is_pinned,
            'color'     => $n->color,
            'created_at' => $n->created_at->format('d M Y'),
        ];
    }

    public function index(Request $request)
    {
        $notes = $request->user()->notes()
            ->orderByDesc('is_pinned')
            ->latest()
            ->get()
            ->map(fn($n) => $this->format($n));

        return response()->json($notes);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'title'     => 'required|string|max:255',
            'content'   => 'nullable|string',
            'type'      => 'in:note,todo',
            'is_pinned' => 'boolean',
            'color'     => 'nullable|string|max:10',
        ]);

        $note = $request->user()->notes()->create($validated);
        $icon = $note->type === 'todo' ? '✅' : '📝';
        $this->logActivity($request->user()->id, 'note_added', "Added {$note->type}: {$note->title}", $icon);

        return response()->json($this->format($note), 201);
    }

    public function update(Request $request, Note $note)
    {
        if ($note->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'title'     => 'sometimes|string|max:255',
            'content'   => 'nullable|string',
            'type'      => 'in:note,todo',
            'is_done'   => 'boolean',
            'is_pinned' => 'boolean',
            'color'     => 'nullable|string|max:10',
        ]);

        $note->update($validated);
        return response()->json($this->format($note));
    }

    public function destroy(Request $request, Note $note)
    {
        if ($note->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $title = $note->title;
        $note->delete();
        $this->logActivity($request->user()->id, 'note_deleted', "Deleted note: {$title}", '🗑️');

        return response()->json(['message' => 'Note deleted']);
    }
}

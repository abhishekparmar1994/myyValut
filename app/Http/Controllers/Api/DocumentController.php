<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Document;
use App\Traits\LogsActivity;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class DocumentController extends Controller
{
    use LogsActivity;

    private function formatDocument(Document $doc): array
    {
        return [
            'id'            => $doc->id,
            'name'          => $doc->name,
            'category'      => $doc->category,
            'document_type' => $doc->document_type,
            'file_name'     => $doc->file_name,
            'mime_type'     => $doc->mime_type,
            'file_size'     => $doc->file_size_human,
            'notes'         => $doc->notes,
            'created_at'    => $doc->created_at->format('d M Y'),
        ];
    }

    public function index(Request $request)
    {
        $documents = $request->user()
            ->documents()
            ->latest()
            ->get()
            ->map(fn($d) => $this->formatDocument($d));

        return response()->json($documents);
    }

    public function store(Request $request)
    {
        $request->validate([
            'name'          => 'required|string|max:255',
            'category'      => 'required|in:identity,property,general,bills',
            'document_type' => 'required|string|max:100',
            'file'          => 'required|file|mimes:jpg,jpeg,png,pdf,doc,docx,xls,xlsx|max:10240',
            'notes'         => 'nullable|string|max:500',
        ]);

        $file     = $request->file('file');
        $userId   = $request->user()->id;
        $folder   = "documents/{$userId}";
        $filename = Str::uuid() . '.' . $file->getClientOriginalExtension();
        $path     = $file->storeAs($folder, $filename, 'local');

        $document = $request->user()->documents()->create([
            'name'          => $request->name,
            'category'      => $request->category,
            'document_type' => $request->document_type,
            'file_name'     => $file->getClientOriginalName(),
            'file_path'     => $path,
            'mime_type'     => $file->getMimeType(),
            'file_size'     => $file->getSize(),
            'notes'         => $request->notes,
        ]);

        $this->logActivity($userId, 'document_uploaded', "Uploaded document: {$document->name}", '📄');

        return response()->json($this->formatDocument($document), 201);
    }

    public function download(Request $request, Document $document)
    {
        if ($document->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        if (!Storage::disk('local')->exists($document->file_path)) {
            return response()->json(['message' => 'File not found'], 404);
        }

        return Storage::disk('local')->download($document->file_path, $document->file_name);
    }

    public function destroy(Request $request, Document $document)
    {
        if ($document->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        Storage::disk('local')->delete($document->file_path);
        $name = $document->name;
        $document->delete();

        $this->logActivity($request->user()->id, 'document_deleted', "Deleted document: {$name}", '🗑️');

        return response()->json(['message' => 'Document deleted']);
    }
}

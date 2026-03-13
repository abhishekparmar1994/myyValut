<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Traits\LogsActivity;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class ProfileController extends Controller
{
    use LogsActivity;

    public function show(Request $request)
    {
        return response()->json($this->format($request->user()));
    }

    public function update(Request $request)
    {
        $user = $request->user();

        $validated = $request->validate([
            'name'          => 'required|string|max:255',
            'phone'         => 'nullable|string|max:15',
            'date_of_birth' => 'nullable|date',
            'address'       => 'nullable|string|max:500',
            'city'          => 'nullable|string|max:100',
        ]);

        $user->update($validated);
        $this->logActivity($user->id, 'profile_updated', 'Updated profile details', '👤');

        return response()->json(['message' => 'Profile updated successfully', 'user' => $this->format($user)]);
    }

    public function updatePassword(Request $request)
    {
        $user = $request->user();

        $request->validate([
            'current_password' => 'required',
            'password'         => 'required|min:8|confirmed',
        ]);

        if (!Hash::check($request->current_password, $user->password)) {
            return response()->json(['message' => 'Current password is incorrect.'], 422);
        }

        $user->update(['password' => $request->password]);
        $this->logActivity($user->id, 'password_changed', 'Changed account password', '🔐');

        return response()->json(['message' => 'Password changed successfully']);
    }

    /**
     * Upload profile image — stored in the PUBLIC disk so it can be served directly via URL.
     * Run `php artisan storage:link` once to enable public storage.
     */
    public function updateImage(Request $request)
    {
        $request->validate([
            'image' => 'required|image|mimes:jpg,jpeg,png,webp|max:2048',
        ]);

        $user = $request->user();

        // Delete old image from public disk
        if ($user->profile_image && Storage::disk('public')->exists($user->profile_image)) {
            Storage::disk('public')->delete($user->profile_image);
        }

        $file     = $request->file('image');
        $filename = 'avatars/' . $user->id . '_' . Str::uuid() . '.' . $file->getClientOriginalExtension();
        $file->storeAs('avatars', basename($filename), 'public');

        $user->update(['profile_image' => $filename]);
        $this->logActivity($user->id, 'profile_image_updated', 'Updated profile photo', '📷');

        return response()->json([
            'message'           => 'Profile image updated',
            'profile_image_url' => asset('storage/' . $filename),
        ]);
    }

    private function format($user): array
    {
        return [
            'id'                => $user->id,
            'name'              => $user->name,
            'email'             => $user->email,
            'phone'             => $user->phone,
            'date_of_birth'     => $user->date_of_birth?->toDateString(),
            'address'           => $user->address,
            'city'              => $user->city,
            'has_image'         => (bool) $user->profile_image,
            'profile_image_url' => $user->profile_image
                ? asset('storage/' . $user->profile_image)
                : null,
        ];
    }
}


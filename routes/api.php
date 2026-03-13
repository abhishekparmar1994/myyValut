<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ReminderController;
use App\Http\Controllers\Api\ActivityController;
use App\Http\Controllers\Api\DocumentController;
use App\Http\Controllers\Api\MedicineController;
use App\Http\Controllers\Api\BillController;
use App\Http\Controllers\Api\NoteController;
use App\Http\Controllers\Api\VehicleController;
use App\Http\Controllers\Api\TransactionController;
use App\Http\Controllers\Api\ProfileController;
use App\Http\Controllers\Api\MessagesController;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', fn(Request $request) => $request->user());
    Route::get('/users', [AuthController::class, 'users']);
    Route::get('/messages/{receiverId}', [MessagesController::class, 'index']);
    Route::post('/messages', [MessagesController::class, 'store']);
    Route::post('/messages/upload', [MessagesController::class, 'upload']);
    Route::post('/messages/read/{senderId}', [MessagesController::class, 'markAsRead']);
    Route::post('/logout', [AuthController::class, 'logout']);

    // Profile
    Route::get('/profile', [ProfileController::class, 'show']);
    Route::put('/profile', [ProfileController::class, 'update']);
    Route::put('/profile/password', [ProfileController::class, 'updatePassword']);
    Route::post('/profile/image', [ProfileController::class, 'updateImage']);
    Route::get('/profile/image', [ProfileController::class, 'image']);

    // Activities
    Route::get('/activities', [ActivityController::class, 'index']);

    // Reminders
    Route::get('/reminders/upcoming', [ReminderController::class, 'upcoming']);
    Route::apiResource('reminders', ReminderController::class);

    // Documents
    Route::get('/documents', [DocumentController::class, 'index']);
    Route::post('/documents', [DocumentController::class, 'store']);
    Route::get('/documents/{document}/download', [DocumentController::class, 'download']);
    Route::delete('/documents/{document}', [DocumentController::class, 'destroy']);

    // Medicines
    Route::get('/medicines/today', [MedicineController::class, 'today']);
    Route::apiResource('medicines', MedicineController::class);

    // Bills
    Route::post('/bills/{bill}/mark-paid', [BillController::class, 'markPaid']);
    Route::apiResource('bills', BillController::class);

    // Notes  
    Route::apiResource('notes', NoteController::class)->except(['show']);

    // Vehicles
    Route::apiResource('vehicles', VehicleController::class)->except(['show']);

    // Budget / Transactions
    Route::get('/transactions/summary', [TransactionController::class, 'summary']);
    Route::get('/transactions', [TransactionController::class, 'index']);
    Route::post('/transactions', [TransactionController::class, 'store']);
    Route::delete('/transactions/{transaction}', [TransactionController::class, 'destroy']);

    // File Preview with CORS
    Route::get('/messages/file/{path}', [MessagesController::class, 'getFile'])->where('path', '.*');
});

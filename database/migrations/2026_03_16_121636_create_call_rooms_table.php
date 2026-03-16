<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('call_rooms', function (Blueprint $table) {
            $table->id();
            $table->string('room_id')->unique(); // Unique identifier for the call session
            $table->foreignId('created_by')->constrained('users')->onDelete('cascade');
            $table->string('type'); // 'audio' or 'video'
            $table->json('participants')->nullable(); // Track who is currently in the room
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('call_rooms');
    }
};

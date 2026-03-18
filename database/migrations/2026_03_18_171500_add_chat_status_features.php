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
        // 1. Add fields to room_members (Group Chats)
        Schema::table('room_members', function (Blueprint $table) {
            $table->boolean('is_archived')->default(false);
            $table->boolean('is_favourite')->default(false);
            $table->boolean('is_unread_manual')->default(false);
        });

        // 2. Create chat_settings for private conversations (1-on-1 Chats)
        Schema::create('chat_settings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->unsignedBigInteger('target_id'); // userId of the other person
            $table->boolean('is_archived')->default(false);
            $table->boolean('is_favourite')->default(false);
            $table->boolean('is_unread_manual')->default(false);
            $table->timestamps();

            // Unique setting per user and conversation partner
            $table->unique(['user_id', 'target_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('chat_settings');
        Schema::table('room_members', function (Blueprint $table) {
            $table->dropColumn(['is_archived', 'is_favourite', 'is_unread_manual']);
        });
    }
};

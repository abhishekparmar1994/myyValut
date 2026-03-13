<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('messages', function (Blueprint $column) {
            $column->id();
            $column->foreignId('sender_id')->constrained('users')->onDelete('cascade');
            $column->foreignId('receiver_id')->constrained('users')->onDelete('cascade');
            $column->text('content');
            $column->string('type')->default('text');
            $column->boolean('is_read')->default(false);
            $column->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('messages');
    }
};

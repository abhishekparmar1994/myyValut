<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('documents', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('name');                          // user-given label
            $table->enum('category', ['identity', 'property', 'general', 'bills'])->default('general');
            $table->string('document_type');                 // e.g. 'Aadhaar Card', 'PAN Card'
            $table->string('file_name');                     // original filename
            $table->string('file_path');                     // stored path
            $table->string('mime_type');
            $table->unsignedBigInteger('file_size');         // bytes
            $table->text('notes')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('documents');
    }
};

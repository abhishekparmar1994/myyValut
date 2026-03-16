<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('messages', function (Blueprint $table) {
            $table->foreignId('room_id')->nullable()->after('id')->constrained('rooms')->onDelete('cascade');
            $table->foreignId('receiver_id')->nullable()->change();
        });
    }

    public function down(): void
    {
        Schema::table('messages', function (Blueprint $table) {
            $table->dropForeign(['room_id']);
            $table->dropColumn('room_id');
            $table->foreignId('receiver_id')->nullable(false)->change();
        });
    }
};

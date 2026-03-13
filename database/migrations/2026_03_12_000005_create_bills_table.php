<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('bills', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('name');                                     // e.g. "MSEDCL Electricity"
            $table->enum('category', [
                'electricity', 'water', 'gas', 'internet', 'phone',
                'credit_card', 'insurance', 'emi', 'other'
            ])->default('other');
            $table->decimal('amount', 10, 2)->nullable();               // expected amount
            $table->tinyInteger('due_day');                             // day of month (1-31)
            $table->boolean('auto_renews')->default(true);              // monthly recurring
            $table->date('last_paid_at')->nullable();
            $table->text('notes')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('bills');
    }
};

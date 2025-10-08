<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('feedback', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable()->constrained()->nullOnDelete();
            $table->text('message');
            $table->string('contact')->nullable();
            $table->string('user_agent')->nullable();
            $table->string('ip')->nullable();
            $table->timestamps();
        });
    }
    public function down(): void {
        Schema::dropIfExists('feedback');
    }
};

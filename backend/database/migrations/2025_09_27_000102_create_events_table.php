<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        if(!Schema::hasTable('events')) {
            Schema::create('events', function (Blueprint $table) {
                $table->id();
                $table->string('title');
                $table->text('description')->nullable();
                $table->string('cover')->nullable();
                $table->string('location')->nullable();
                $table->date('start_date');
                $table->date('end_date');
                $table->string('start_time',10)->nullable();
                $table->string('city',120)->nullable();
                $table->enum('audience',[ 'open','city','limited' ])->default('open');
                $table->unsignedInteger('limit')->nullable();
                $table->unsignedInteger('registrations_count')->default(0);
                $table->json('images')->nullable();
                $table->timestamps();
                $table->index('start_date');
                $table->index('city');
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('events');
    }
};

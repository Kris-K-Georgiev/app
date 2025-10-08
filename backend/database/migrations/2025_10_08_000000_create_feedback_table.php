<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Enhanced feedback table with moderation + tracking metadata.
 * If a master schema migration already creates 'feedback', run: php artisan migrate:fresh.
 */
return new class extends Migration {
    public function up(): void
    {
        // Create table only if it doesn't already exist (safe for incremental deploys)
        if (!Schema::hasTable('feedback')) {
            Schema::create('feedback', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->text('message');
            $table->string('contact',255)->nullable();
            $table->string('user_agent',255)->nullable();
            $table->string('ip',45)->nullable();
            // Moderation / workflow
            $table->enum('status',[ 'new','reviewed','closed' ])->default('new');
            $table->tinyInteger('severity')->nullable()->comment('1=low .. 5=critical');
            $table->foreignId('handled_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamp('handled_at')->nullable();
            // Flexible structured context (client app version, platform, etc.)
            $table->json('context')->nullable();
            $table->timestamps();
            $table->softDeletes();

            // Indexes
            $table->index(['status','created_at']);
            $table->index('handled_by');
            $table->index(['user_id','created_at']);
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('feedback');
    }
};

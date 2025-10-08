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
        // If table exists (from previous simple migration), adjust by dropping to create new clean spec (for fresh dev only)
        if (Schema::hasTable('feedback')) {
            // Comment this drop in production upgrades. Intended for local reset.
            Schema::drop('feedback');
        }

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

    public function down(): void
    {
        Schema::dropIfExists('feedback');
    }
};

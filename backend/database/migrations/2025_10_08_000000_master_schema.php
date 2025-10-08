<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        // USERS
        Schema::create('users', function(Blueprint $table){
            $table->id();
            $table->string('name');
            $table->string('email')->unique();
            $table->string('phone',40)->nullable();
            $table->timestamp('email_verified_at')->nullable();
            $table->string('password');
            $table->string('avatar_path')->nullable();
            $table->string('role',50)->default('student');
            $table->string('city',120)->nullable();
            $table->text('bio')->nullable();
            $table->enum('status',['active','inactive'])->default('active');
            $table->rememberToken();
            $table->timestamps();
            $table->index('role');
        });

        // PASSWORD RESET CODES
        Schema::create('password_reset_codes', function(Blueprint $table){
            $table->id();
            $table->string('email');
            $table->char('code',6);
            $table->timestamp('expires_at');
            $table->timestamps();
            $table->index('email');
        });

        // PENDING REGISTRATIONS
        Schema::create('pending_registrations', function(Blueprint $table){
            $table->id();
            $table->string('first_name');
            $table->string('last_name');
            $table->string('email')->unique();
            $table->string('password_hash');
            $table->string('city',120)->nullable();
            $table->char('code',6);
            $table->unsignedTinyInteger('attempts')->default(0);
            $table->timestamp('expires_at');
            $table->timestamp('last_sent_at')->nullable();
            $table->timestamps();
        });

        // SESSIONS (optional DB driver)
        Schema::create('sessions', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->foreignId('user_id')->nullable()->constrained('users')->cascadeOnDelete();
            $table->string('ip_address', 45)->nullable();
            $table->text('user_agent')->nullable();
            $table->longText('payload');
            $table->integer('last_activity');
            $table->index('user_id');
            $table->index('last_activity');
        });

        // CACHE
        Schema::create('cache', function(Blueprint $table){
            $table->string('key')->primary();
            $table->mediumText('value');
            $table->integer('expiration');
        });
        Schema::create('cache_locks', function(Blueprint $table){
            $table->string('key')->primary();
            $table->string('owner');
            $table->integer('expiration');
        });

        // QUEUE/JOBS
        Schema::create('jobs', function (Blueprint $table) {
            $table->id();
            $table->string('queue');
            $table->longText('payload');
            $table->unsignedTinyInteger('attempts');
            $table->unsignedInteger('reserved_at')->nullable();
            $table->unsignedInteger('available_at');
            $table->unsignedInteger('created_at');
            $table->index('queue');
        });
        Schema::create('job_batches', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->string('name');
            $table->integer('total_jobs');
            $table->integer('pending_jobs');
            $table->integer('failed_jobs');
            $table->longText('failed_job_ids');
            $table->mediumText('options')->nullable();
            $table->integer('cancelled_at')->nullable();
            $table->integer('created_at');
            $table->integer('finished_at')->nullable();
        });
        Schema::create('failed_jobs', function (Blueprint $table) {
            $table->id();
            $table->string('uuid')->unique();
            $table->text('connection');
            $table->text('queue');
            $table->longText('payload');
            $table->longText('exception');
            $table->timestamp('failed_at')->useCurrent();
        });

        // SANCTUM TOKENS
        Schema::create('personal_access_tokens', function (Blueprint $table) {
            $table->id();
            $table->string('tokenable_type');
            $table->unsignedBigInteger('tokenable_id');
            $table->string('name');
            $table->string('token', 64)->unique();
            $table->text('abilities')->nullable();
            $table->timestamp('last_used_at')->nullable();
            $table->timestamp('expires_at')->nullable();
            $table->timestamps();
            $table->index(['tokenable_type','tokenable_id']);
        });

        // NEWS
        Schema::create('news', function(Blueprint $table){
            $table->id();
            $table->string('title');
            $table->text('content');
            $table->string('cover')->nullable();
            $table->string('image')->nullable();
            $table->enum('status',['draft','published'])->default('published');
            $table->foreignId('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();
            $table->index('title');
        });
        Schema::create('news_images', function(Blueprint $table){
            $table->id();
            $table->foreignId('news_id')->constrained('news')->cascadeOnDelete();
            $table->string('path');
            $table->integer('position')->unsigned()->default(0);
            $table->timestamps();
            $table->index(['news_id','position']);
        });
        Schema::create('news_likes', function(Blueprint $table){
            $table->id();
            $table->foreignId('news_id')->constrained('news')->cascadeOnDelete();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->timestamps();
            $table->unique(['news_id','user_id']);
            $table->index('user_id');
        });
        Schema::create('news_comments', function(Blueprint $table){
            $table->id();
            $table->foreignId('news_id')->constrained('news')->cascadeOnDelete();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->text('content');
            $table->timestamps();
            $table->index(['news_id','created_at']);
            $table->index('user_id');
        });

        // EVENT TYPES / EVENTS
        Schema::create('event_types', function(Blueprint $table){
            $table->id();
            $table->string('slug')->unique();
            $table->string('name');
            $table->string('color',20)->nullable();
            $table->timestamps();
        });
        Schema::create('events', function(Blueprint $table){
            $table->id();
            $table->string('title');
            $table->foreignId('event_type_id')->nullable()->constrained('event_types')->nullOnDelete();
            $table->text('description')->nullable();
            $table->string('cover')->nullable();
            $table->string('location')->nullable();
            $table->date('start_date');
            $table->date('end_date');
            $table->string('start_time',10)->nullable();
            $table->string('city',120)->nullable();
            $table->enum('status',['active','inactive'])->default('active');
            $table->enum('audience',['open','city','limited'])->default('open');
            $table->integer('limit')->unsigned()->nullable();
            $table->integer('registrations_count')->unsigned()->default(0);
            $table->json('images')->nullable();
            $table->foreignId('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();
            $table->index('start_date');
            $table->index('city');
            $table->index('event_type_id');
        });
        Schema::create('event_registrations', function(Blueprint $table){
            $table->id();
            $table->foreignId('event_id')->constrained('events')->cascadeOnDelete();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('status',30)->default('confirmed');
            $table->timestamps();
            $table->unique(['event_id','user_id']);
            $table->index('user_id');
        });

        // APP VERSION
        Schema::create('app_versions', function(Blueprint $table){
            $table->id();
            $table->integer('version_code')->unsigned();
            $table->string('version_name',50);
            $table->text('release_notes')->nullable();
            $table->boolean('is_mandatory')->default(false);
            $table->string('download_url')->nullable();
            $table->timestamps();
            $table->index('version_code');
        });

        // COMMUNITY: POSTS
        Schema::create('posts', function(Blueprint $table){
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->text('content');
            $table->string('image')->nullable();
            $table->timestamps();
            $table->softDeletes();
            $table->index('user_id');
            $table->index(['created_at','user_id']);
        });
        Schema::create('post_likes', function(Blueprint $table){
            $table->id();
            $table->foreignId('post_id')->constrained('posts')->cascadeOnDelete();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->timestamps();
            $table->unique(['post_id','user_id']);
            $table->index('user_id');
            $table->index(['post_id','created_at']);
        });
        Schema::create('post_comments', function(Blueprint $table){
            $table->id();
            $table->foreignId('post_id')->constrained('posts')->cascadeOnDelete();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->text('content');
            $table->timestamps();
            $table->index(['post_id','created_at']);
            $table->index('user_id');
        });

        // COMMUNITY: PRAYERS
        Schema::create('prayers', function(Blueprint $table){
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->text('content');
            $table->boolean('is_anonymous')->default(false);
            $table->boolean('answered')->default(false);
            $table->timestamps();
            $table->softDeletes();
            $table->index('user_id');
            $table->index(['created_at','user_id']);
        });
        Schema::create('prayer_likes', function(Blueprint $table){
            $table->id();
            $table->foreignId('prayer_id')->constrained('prayers')->cascadeOnDelete();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->timestamps();
            $table->unique(['prayer_id','user_id']);
            $table->index('user_id');
            $table->index(['prayer_id','created_at']);
        });

        // FEEDBACK (soft deletes for moderation)
        Schema::create('feedback', function(Blueprint $table){
            $table->id();
            $table->foreignId('user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->text('message');
            $table->string('contact')->nullable();
            $table->string('user_agent')->nullable();
            $table->string('ip')->nullable();
            $table->timestamps();
            $table->softDeletes();
            $table->index('user_id');
            $table->index('created_at');
        });
    }

    public function down(): void {
        Schema::dropIfExists('feedback');
        Schema::dropIfExists('prayer_likes');
        Schema::dropIfExists('prayers');
        Schema::dropIfExists('post_comments');
        Schema::dropIfExists('post_likes');
        Schema::dropIfExists('posts');
        Schema::dropIfExists('app_versions');
        Schema::dropIfExists('event_registrations');
        Schema::dropIfExists('events');
        Schema::dropIfExists('event_types');
        Schema::dropIfExists('news_comments');
        Schema::dropIfExists('news_likes');
        Schema::dropIfExists('news_images');
        Schema::dropIfExists('news');
        Schema::dropIfExists('personal_access_tokens');
        Schema::dropIfExists('failed_jobs');
        Schema::dropIfExists('job_batches');
        Schema::dropIfExists('jobs');
        Schema::dropIfExists('cache_locks');
        Schema::dropIfExists('cache');
        Schema::dropIfExists('sessions');
        Schema::dropIfExists('pending_registrations');
        Schema::dropIfExists('password_reset_codes');
        Schema::dropIfExists('users');
    }
};

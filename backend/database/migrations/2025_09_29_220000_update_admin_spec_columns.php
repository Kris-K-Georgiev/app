<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        // Users: phone, status
        if(Schema::hasTable('users')){
            Schema::table('users', function(Blueprint $table){
                if(!Schema::hasColumn('users','phone')){ $table->string('phone',40)->nullable()->after('email'); }
                if(!Schema::hasColumn('users','status')){ $table->enum('status',['active','inactive'])->default('active')->after('bio'); }
            });
        }

        // News: status, created_by
        if(Schema::hasTable('news')){
            Schema::table('news', function(Blueprint $table){
                if(!Schema::hasColumn('news','status')){ $table->enum('status',['draft','published'])->default('published')->after('cover'); }
                if(!Schema::hasColumn('news','created_by')){ $table->foreignId('created_by')->nullable()->after('status')->constrained('users')->nullOnDelete(); }
            });
        }

        // Events: status, created_by
        if(Schema::hasTable('events')){
            Schema::table('events', function(Blueprint $table){
                if(!Schema::hasColumn('events','status')){ $table->enum('status',['active','inactive'])->default('active')->after('city'); }
                if(!Schema::hasColumn('events','created_by')){ $table->foreignId('created_by')->nullable()->after('status')->constrained('users')->nullOnDelete(); }
            });
        }
    }

    public function down(): void
    {
        // Rollback (best effort) - keep data safe (do not drop by default). If needed explicitly drop.
        if(Schema::hasTable('events')){
            Schema::table('events', function(Blueprint $table){
                if(Schema::hasColumn('events','created_by')){ $table->dropForeign(['created_by']); $table->dropColumn('created_by'); }
                if(Schema::hasColumn('events','status')){ $table->dropColumn('status'); }
            });
        }
        if(Schema::hasTable('news')){
            Schema::table('news', function(Blueprint $table){
                if(Schema::hasColumn('news','created_by')){ $table->dropForeign(['created_by']); $table->dropColumn('created_by'); }
                if(Schema::hasColumn('news','status')){ $table->dropColumn('status'); }
            });
        }
        if(Schema::hasTable('users')){
            Schema::table('users', function(Blueprint $table){
                if(Schema::hasColumn('users','phone')) $table->dropColumn('phone');
                if(Schema::hasColumn('users','status')) $table->dropColumn('status');
            });
        }
    }
};

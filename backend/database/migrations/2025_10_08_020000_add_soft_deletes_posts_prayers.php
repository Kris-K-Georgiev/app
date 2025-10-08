<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        if (Schema::hasTable('posts') && !Schema::hasColumn('posts','deleted_at')) {
            Schema::table('posts', function(Blueprint $t){ $t->softDeletes(); });
        }
        if (Schema::hasTable('prayers') && !Schema::hasColumn('prayers','deleted_at')) {
            Schema::table('prayers', function(Blueprint $t){ $t->softDeletes(); });
        }
    }
    public function down(): void {
        if (Schema::hasTable('posts') && Schema::hasColumn('posts','deleted_at')) {
            Schema::table('posts', function(Blueprint $t){ $t->dropSoftDeletes(); });
        }
        if (Schema::hasTable('prayers') && Schema::hasColumn('prayers','deleted_at')) {
            Schema::table('prayers', function(Blueprint $t){ $t->dropSoftDeletes(); });
        }
    }
};
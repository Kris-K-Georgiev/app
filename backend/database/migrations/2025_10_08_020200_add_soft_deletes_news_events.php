<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        if (Schema::hasTable('news') && !Schema::hasColumn('news','deleted_at')) {
            Schema::table('news', function(Blueprint $t){ $t->softDeletes(); });
        }
        if (Schema::hasTable('events') && !Schema::hasColumn('events','deleted_at')) {
            Schema::table('events', function(Blueprint $t){ $t->softDeletes(); });
        }
    }
    public function down(): void {
        if (Schema::hasTable('news') && Schema::hasColumn('news','deleted_at')) {
            Schema::table('news', function(Blueprint $t){ $t->dropSoftDeletes(); });
        }
        if (Schema::hasTable('events') && Schema::hasColumn('events','deleted_at')) {
            Schema::table('events', function(Blueprint $t){ $t->dropSoftDeletes(); });
        }
    }
};
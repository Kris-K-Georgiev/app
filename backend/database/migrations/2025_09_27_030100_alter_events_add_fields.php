<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        // This migration is now a compatibility no-op because the base create migration already defines
        // start_date, end_date, start_time (string), and images (json). We only add missing columns if
        // the project was created from an earlier scaffold.
        if(!Schema::hasTable('events')) return;
        Schema::table('events', function (Blueprint $table) {
            if(!Schema::hasColumn('events','start_date')) { $table->date('start_date')->nullable()->after('id'); }
            if(!Schema::hasColumn('events','end_date')) { $table->date('end_date')->nullable()->after('start_date'); }
            // We purposely skip adding end_time (deprecated) and avoid conflicting start_time type changes.
            if(!Schema::hasColumn('events','images')) { $table->json('images')->nullable()->after('location'); }
        });
    }
    public function down(): void
    {
        // Best-effort rollback: do NOT drop columns that may be in use; leave as-is.
    }
};

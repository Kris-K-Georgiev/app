<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    public function up(): void {
        if(Schema::hasTable('events') && Schema::hasColumn('events','registrations_count')) {
            try { DB::statement('CREATE INDEX events_registrations_count_index ON events(registrations_count)'); } catch(\Throwable $e) {}
        }
    }
    public function down(): void {
        try { DB::statement('DROP INDEX events_registrations_count_index ON events'); } catch(\Throwable $e) {}
    }
};

<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    public function up(): void
    {
        // Ensure role has default 'student' and is not nullable
        if(Schema::hasColumn('users','role')) {
            // Some DBs require raw SQL to alter default / nullability
            $driver = DB::getDriverName();
            if($driver === 'mysql') {
                DB::statement("ALTER TABLE users MODIFY role VARCHAR(50) NOT NULL DEFAULT 'student'");
            } else if($driver === 'sqlite') {
                // SQLite does not support many ALTERs; skip (acceptable for dev)
            }
            // Add index on role if not exists (MySQL 8 has IF NOT EXISTS for indexes only in 8.0.21+)
            try { DB::statement('CREATE INDEX users_role_index ON users(role)'); } catch(\Throwable $e) {}
        }

        // Add index for events start_date if column exists
        if(Schema::hasTable('events') && Schema::hasColumn('events','start_date')) {
            try { DB::statement('CREATE INDEX events_start_date_index ON events(start_date)'); } catch(\Throwable $e) {}
        }

        // event_registrations: add user_id index if not exists
        if(Schema::hasTable('event_registrations') && Schema::hasColumn('event_registrations','user_id')) {
            try { DB::statement('CREATE INDEX er_user_id_index ON event_registrations(user_id)'); } catch(\Throwable $e) {}
        }
    }

    public function down(): void
    {
        // Down migrations for raw index creation (best-effort)
        $driver = DB::getDriverName();
        if($driver === 'mysql') {
            try { DB::statement('DROP INDEX users_role_index ON users'); } catch(\Throwable $e) {}
            try { DB::statement('DROP INDEX events_start_date_index ON events'); } catch(\Throwable $e) {}
            try { DB::statement('DROP INDEX er_user_id_index ON event_registrations'); } catch(\Throwable $e) {}
        }
    }
};

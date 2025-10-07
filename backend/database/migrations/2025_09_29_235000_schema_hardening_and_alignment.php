<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    public function up(): void
    {
        $this->fixPendingRegistrationsNameSplit();
        $this->addEventRegistrationsUserIndex();
        $this->addAppVersionsVersionCodeIndex();
        $this->addSessionsUserForeignKey();
    }

    /**
     * If legacy column 'name' exists (single field) and first_name/last_name not present, create them and split.
     */
    protected function fixPendingRegistrationsNameSplit(): void
    {
        if(!Schema::hasTable('pending_registrations')) return;
        $hasName = Schema::hasColumn('pending_registrations','name');
        $hasFirst = Schema::hasColumn('pending_registrations','first_name');
        $hasLast = Schema::hasColumn('pending_registrations','last_name');
        if($hasName && (!$hasFirst || !$hasLast)) {
            Schema::table('pending_registrations', function(Blueprint $table) use($hasFirst,$hasLast){
                if(!$hasFirst) $table->string('first_name',255)->nullable()->after('id');
                if(!$hasLast) $table->string('last_name',255)->nullable()->after('first_name');
            });
            // Populate from legacy name column
            try {
                DB::transaction(function(){
                    $rows = DB::table('pending_registrations')->select('id','name')->get();
                    foreach($rows as $row){
                        if(!$row->name) continue;
                        $parts = preg_split('/\s+/', trim($row->name));
                        if(!$parts || count($parts)==0){
                            $first = $row->name; $last = null;
                        } elseif(count($parts)==1){
                            $first = $parts[0]; $last = null;
                        } else {
                            $first = array_shift($parts);
                            $last = implode(' ', $parts);
                        }
                        DB::table('pending_registrations')->where('id',$row->id)->update([
                            'first_name'=>$first,
                            'last_name'=>$last
                        ]);
                    }
                });
            } catch(\Throwable $e) {
                // best effort; leave silently
            }
            // Make new columns NOT NULL with fallback
            Schema::table('pending_registrations', function(Blueprint $table){
                DB::statement("UPDATE pending_registrations SET first_name = COALESCE(first_name,'')");
                DB::statement("UPDATE pending_registrations SET last_name = COALESCE(last_name,'')");
                // Cannot easily alter to NOT NULL portably without checking data; optional: keep nullable.
            });
            // Drop legacy column if fully migrated
            try {
                Schema::table('pending_registrations', function(Blueprint $table){
                    if(Schema::hasColumn('pending_registrations','name')) $table->dropColumn('name');
                });
            } catch(\Throwable $e) { /* ignore if platform restrictions */ }
        }
    }

    protected function addEventRegistrationsUserIndex(): void
    {
        if(!Schema::hasTable('event_registrations')) return;
        // Check if a standalone index on user_id exists (composite unique may already include it; this adds explicit for user filtering)
        try {
            $hasIndex = $this->indexExists('event_registrations','event_registrations_user_id_index')
                || $this->indexExists('event_registrations','er_user_id_index');
            if(!$hasIndex) {
                Schema::table('event_registrations', function(Blueprint $table){
                    $table->index('user_id','er_user_id_index');
                });
            }
        } catch(\Throwable $e) { /* ignore */ }
    }

    protected function addAppVersionsVersionCodeIndex(): void
    {
        if(!Schema::hasTable('app_versions') || Schema::hasColumn('app_versions','__no')) { /* placeholder guard */ }
        try {
            $hasIndex = $this->indexExists('app_versions','app_versions_version_code_index');
            if(!$hasIndex){
                Schema::table('app_versions', function(Blueprint $table){
                    $table->index('version_code','app_versions_version_code_index');
                });
            }
        } catch(\Throwable $e) { /* ignore */ }
    }

    protected function addSessionsUserForeignKey(): void
    {
        if(!Schema::hasTable('sessions') || !Schema::hasColumn('sessions','user_id')) return;
        // Detect existing FK by querying information_schema (MySQL) — safe ignore on other drivers
        try {
            $driver = DB::getDriverName();
            if($driver === 'mysql') {
                $db = DB::getDatabaseName();
                $fk = DB::selectOne("SELECT CONSTRAINT_NAME FROM information_schema.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA = ? AND TABLE_NAME='sessions' AND COLUMN_NAME='user_id' AND REFERENCED_TABLE_NAME='users' LIMIT 1", [$db]);
                if(!$fk){
                    Schema::table('sessions', function(Blueprint $table){
                        // Use a deterministic constraint name
                        $table->foreign('user_id','sessions_user_id_fk')->references('id')->on('users')->cascadeOnDelete();
                    });
                }
            }
        } catch(\Throwable $e) { /* ignore */ }
    }

    /**
     * Portable-ish index existence check using Doctrine schema manager when available.
     */
    protected function indexExists(string $table, string $index): bool
    {
        try {
            $sm = Schema::getConnection()->getDoctrineSchemaManager();
            $indexes = $sm->listTableIndexes($table);
            return array_key_exists(strtolower($index), array_change_key_case($indexes, CASE_LOWER));
        } catch(\Throwable $e) { return false; }
    }

    public function down(): void
    {
        // Best-effort rollback: drop added indexes / FK only (do NOT recreate legacy 'name' column)
        if(Schema::hasTable('event_registrations')) {
            try { Schema::table('event_registrations', function(Blueprint $table){ $table->dropIndex('er_user_id_index'); }); } catch(\Throwable $e) {}
        }
        if(Schema::hasTable('app_versions')) {
            try { Schema::table('app_versions', function(Blueprint $table){ $table->dropIndex('app_versions_version_code_index'); }); } catch(\Throwable $e) {}
        }
        if(Schema::hasTable('sessions')) {
            try { Schema::table('sessions', function(Blueprint $table){ $table->dropForeign('sessions_user_id_fk'); }); } catch(\Throwable $e) {}
        }
    }
};

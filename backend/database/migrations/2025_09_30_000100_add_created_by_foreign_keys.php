<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    public function up(): void
    {
        // This migration is defensive: initial created_by columns & FKs may already be present.
        // We only add missing foreign keys if the column exists and no FK referencing users(id) on that column.
        $connection = Schema::getConnection()->getName();
        $database = Schema::getConnection()->getDatabaseName();

        $fkExists = function(string $table, string $column) use ($database) : bool {
            $sql = "SELECT COUNT(*) AS c FROM information_schema.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ? AND COLUMN_NAME = ? AND REFERENCED_TABLE_NAME = 'users'";
            $count = collect(DB::select($sql, [$database, $table, $column]))->first()->c ?? 0;
            return $count > 0;
        };

        if (Schema::hasTable('news') && Schema::hasColumn('news','created_by') && !$fkExists('news','created_by')) {
            Schema::table('news', function (Blueprint $table) {
                try { $table->foreign('created_by')->references('id')->on('users')->nullOnDelete(); } catch (\Throwable $e) {}
            });
        }
        if (Schema::hasTable('events') && Schema::hasColumn('events','created_by') && !$fkExists('events','created_by')) {
            Schema::table('events', function (Blueprint $table) {
                try { $table->foreign('created_by')->references('id')->on('users')->nullOnDelete(); } catch (\Throwable $e) {}
            });
        }
    }
    public function down(): void
    {
        if (Schema::hasTable('news')) {
            Schema::table('news', function (Blueprint $table) {
                try { $table->dropForeign(['created_by']); } catch (\Throwable $e) {}
            });
        }
        if (Schema::hasTable('events')) {
            Schema::table('events', function (Blueprint $table) {
                try { $table->dropForeign(['created_by']); } catch (\Throwable $e) {}
            });
        }
    }
};

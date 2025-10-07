<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('users', function(Blueprint $table){
                // Columns may already exist from earlier incremental migrations; guard each one.
                if (!Schema::hasColumn('users','nickname')) {
                    $table->string('nickname')->nullable()->after('name');
                }
                if (!Schema::hasColumn('users','avatar_path')) {
                    $table->string('avatar_path')->nullable()->after('nickname');
                }
                if (!Schema::hasColumn('users','role')) {
                    $table->string('role')->nullable()->after('password'); // extended roles
                }
                if (!Schema::hasColumn('users','city')) {
                    $table->string('city')->nullable()->after('role');
                }
        });
    }
    public function down(): void
    {
        Schema::table('users', function(Blueprint $table){
            $table->dropColumn(['nickname','avatar_path','role','city']);
        });
    }
};

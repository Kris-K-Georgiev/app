<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    public function up(): void
    {
        // Normalize existing roles: null -> student, varna1 -> varnava1, varna2 -> varnava2
        DB::table('users')->whereNull('role')->update(['role'=>'student']);
        DB::table('users')->where('role','varna1')->update(['role'=>'varnava1']);
        DB::table('users')->where('role','varna2')->update(['role'=>'varnava2']);
    }
    public function down(): void
    {
        // No reliable rollback; leave as-is
    }
};

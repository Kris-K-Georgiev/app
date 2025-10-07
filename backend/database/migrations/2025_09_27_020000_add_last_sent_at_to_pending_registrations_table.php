<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        if(Schema::hasTable('pending_registrations') && !Schema::hasColumn('pending_registrations','last_sent_at')) {
            Schema::table('pending_registrations', function (Blueprint $table) {
                $table->timestamp('last_sent_at')->nullable()->after('expires_at');
            });
        }
    }
    public function down(): void
    {
        Schema::table('pending_registrations', function (Blueprint $table) {
            $table->dropColumn('last_sent_at');
        });
    }
};
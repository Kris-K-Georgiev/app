<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        if(Schema::hasTable('events')) {
            Schema::table('events', function(Blueprint $table){
                if(!Schema::hasColumn('events','cover')) $table->string('cover')->nullable()->after('description');
                if(!Schema::hasColumn('events','city')) $table->string('city')->nullable()->after('location');
                if(!Schema::hasColumn('events','audience')) $table->enum('audience',['open','city','limited'])->default('open')->after('city');
                if(!Schema::hasColumn('events','limit')) $table->unsignedInteger('limit')->nullable()->after('audience');
                if(!Schema::hasColumn('events','registrations_count')) $table->unsignedInteger('registrations_count')->default(0)->after('limit');
            });
        }
    }
    public function down(): void
    {
        Schema::table('events', function(Blueprint $table){
            $table->dropColumn(['cover','city','audience','limit','registrations_count']);
        });
    }
};

<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        // Users table safety: add columns only if missing
        Schema::table('users', function(Blueprint $table){
            if(!Schema::hasColumn('users','avatar_path')) $table->string('avatar_path')->nullable()->after('password');
            if(!Schema::hasColumn('users','role')) $table->string('role',50)->default('student')->after('avatar_path');
            if(!Schema::hasColumn('users','city')) $table->string('city',120)->nullable()->after('role');
            if(!Schema::hasColumn('users','bio')) $table->text('bio')->nullable()->after('city');
        });
        // Events table safety: ensure new structure exists (if an old 'date' column lingers)
        if(Schema::hasTable('events')){
            if(!Schema::hasColumn('events','start_date') && Schema::hasColumn('events','date')){
                // Fallback: rename 'date' to 'start_date' and duplicate to end_date
                Schema::table('events', function(Blueprint $table){
                    $table->date('start_date')->nullable();
                    $table->date('end_date')->nullable();
                });
                // Data copy left out as driver-agnostic complexity; admin can patch manually.
            }
            Schema::table('events', function(Blueprint $table){
                if(!Schema::hasColumn('events','end_date')) $table->date('end_date')->after('start_date');
                if(!Schema::hasColumn('events','start_time')) $table->string('start_time',10)->nullable()->after('end_date');
                if(!Schema::hasColumn('events','city')) $table->string('city',120)->nullable()->after('location');
                if(!Schema::hasColumn('events','audience')) $table->enum('audience',[ 'open','city','limited' ])->default('open')->after('city');
                if(!Schema::hasColumn('events','limit')) $table->unsignedInteger('limit')->nullable()->after('audience');
                if(!Schema::hasColumn('events','registrations_count')) $table->unsignedInteger('registrations_count')->default(0)->after('limit');
                if(!Schema::hasColumn('events','images')) $table->json('images')->nullable()->after('registrations_count');
                if(!Schema::hasColumn('events','cover')) $table->string('cover')->nullable()->after('description');
            });
        }
    }
    public function down(): void {
        // Down removes only columns we added, cautiously.
        Schema::table('users', function(Blueprint $table){
            if(Schema::hasColumn('users','bio')) $table->dropColumn('bio');
            if(Schema::hasColumn('users','city')) $table->dropColumn('city');
            if(Schema::hasColumn('users','role')) $table->dropColumn('role');
            if(Schema::hasColumn('users','avatar_path')) $table->dropColumn('avatar_path');
        });
        Schema::table('events', function(Blueprint $table){
            if(Schema::hasColumn('events','cover')) $table->dropColumn('cover');
            if(Schema::hasColumn('events','images')) $table->dropColumn('images');
            if(Schema::hasColumn('events','registrations_count')) $table->dropColumn('registrations_count');
            if(Schema::hasColumn('events','limit')) $table->dropColumn('limit');
            if(Schema::hasColumn('events','audience')) $table->dropColumn('audience');
            if(Schema::hasColumn('events','city')) $table->dropColumn('city');
            if(Schema::hasColumn('events','start_time')) $table->dropColumn('start_time');
            if(Schema::hasColumn('events','end_date')) $table->dropColumn('end_date');
            if(Schema::hasColumn('events','start_date')) $table->dropColumn('start_date');
        });
    }
};

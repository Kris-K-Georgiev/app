<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        // Add bio to users if not exists
        if(!Schema::hasColumn('users','bio')){
            Schema::table('users', function(Blueprint $table){
                $table->text('bio')->nullable()->after('city');
            });
        }
        // Adjust events table: drop legacy date & end_time, ensure start_date/end_date not null
        if(Schema::hasTable('events')){
            Schema::table('events', function(Blueprint $table){
                if(Schema::hasColumn('events','date')){ $table->dropColumn('date'); }
                if(Schema::hasColumn('events','end_time')){ $table->dropColumn('end_time'); }
            });
            // Make start_date/end_date NOT NULL if currently nullable
            Schema::table('events', function(Blueprint $table){
                if(Schema::hasColumn('events','start_date')){
                    $table->date('start_date')->nullable(false)->change();
                }
                if(Schema::hasColumn('events','end_date')){
                    $table->date('end_date')->nullable(false)->change();
                }
            });
        }
    }

    public function down(): void
    {
        // Reverse changes (best-effort)
        if(Schema::hasTable('users') && Schema::hasColumn('users','bio')){
            Schema::table('users', function(Blueprint $table){ $table->dropColumn('bio'); });
        }
        if(Schema::hasTable('events')){
            Schema::table('events', function(Blueprint $table){
                if(!Schema::hasColumn('events','date')){ $table->dateTime('date')->nullable(); }
                if(!Schema::hasColumn('events','end_time')){ $table->string('end_time',10)->nullable(); }
            });
        }
    }
};

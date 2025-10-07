<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    public function up(): void
    {
        // Create event_types table if not exists
        if(!Schema::hasTable('event_types')) {
            Schema::create('event_types', function(Blueprint $table){
                $table->id();
                $table->string('slug')->unique(); // machine key, e.g. lecture, workshop
                $table->string('name');           // human readable (localized later)
                $table->string('color', 20)->nullable(); // optional hex (fallback to theme if null)
                $table->timestamps();
            });

            // Seed a baseline set (safe to ignore errors if rerun)
            try {
                DB::table('event_types')->insert([
                    ['slug'=>'general','name'=>'General','color'=>null,'created_at'=>now(),'updated_at'=>now()],
                    ['slug'=>'lecture','name'=>'Lecture','color'=>null,'created_at'=>now(),'updated_at'=>now()],
                    ['slug'=>'workshop','name'=>'Workshop','color'=>null,'created_at'=>now(),'updated_at'=>now()],
                    ['slug'=>'competition','name'=>'Competition','color'=>null,'created_at'=>now(),'updated_at'=>now()],
                    ['slug'=>'social','name'=>'Social','color'=>null,'created_at'=>now(),'updated_at'=>now()],
                ]);
            } catch(\Throwable $e) {}
        }

        // Add nullable FK to events
        if(Schema::hasTable('events') && !Schema::hasColumn('events','event_type_id')) {
            Schema::table('events', function(Blueprint $table){
                $table->foreignId('event_type_id')->nullable()->after('title')->constrained('event_types')->nullOnDelete();
                $table->index('event_type_id');
            });

            // Optionally backfill existing events with 'general'
            try {
                $generalId = DB::table('event_types')->where('slug','general')->value('id');
                if($generalId) {
                    DB::table('events')->whereNull('event_type_id')->update(['event_type_id'=>$generalId]);
                }
            } catch(\Throwable $e) {}
        }
    }

    public function down(): void
    {
        if(Schema::hasTable('events') && Schema::hasColumn('events','event_type_id')) {
            Schema::table('events', function(Blueprint $table){
                $table->dropForeign(['event_type_id']);
                $table->dropIndex(['event_type_id']);
                $table->dropColumn('event_type_id');
            });
        }
        Schema::dropIfExists('event_types');
    }
};

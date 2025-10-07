<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    public function up(): void {
        Schema::create('event_images', function(Blueprint $table){
            $table->id();
            $table->foreignId('event_id')->constrained()->cascadeOnDelete();
            $table->string('path');
            $table->unsignedInteger('position')->default(0);
            $table->timestamps();
            $table->index(['event_id','position']);
        });

        // Migrate existing JSON images to new table (best effort)
        if(Schema::hasTable('events') && Schema::hasColumn('events','images')) {
            $events = DB::table('events')->select('id','images')->whereNotNull('images')->get();
            foreach($events as $evt){
                try {
                    $imgs = json_decode($evt->images, true) ?: [];
                    $pos = 0;
                    foreach($imgs as $img){
                        if(is_string($img) && $img !== ''){
                            DB::table('event_images')->insert([
                                'event_id' => $evt->id,
                                'path' => $img,
                                'position' => $pos++,
                                'created_at' => now(),
                                'updated_at' => now(),
                            ]);
                        }
                    }
                } catch(\Throwable $e) { /* ignore migration errors */ }
            }
        }
    }

    public function down(): void {
        Schema::dropIfExists('event_images');
        // Intentionally not re-assembling JSON images column contents.
    }
};

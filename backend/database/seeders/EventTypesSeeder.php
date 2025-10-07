<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class EventTypesSeeder extends Seeder
{
    public function run(): void
    {
        $types = [
            ['slug'=>'general','name'=>'General','color'=>null],
            ['slug'=>'lecture','name'=>'Lecture','color'=>null],
            ['slug'=>'workshop','name'=>'Workshop','color'=>null],
            ['slug'=>'competition','name'=>'Competition','color'=>null],
            ['slug'=>'social','name'=>'Social','color'=>null],
        ];
        foreach($types as $t){
            $exists = DB::table('event_types')->where('slug',$t['slug'])->exists();
            if(!$exists){
                DB::table('event_types')->insert(array_merge($t,[
                    'created_at'=>now(),'updated_at'=>now()
                ]));
            }
        }
    }
}

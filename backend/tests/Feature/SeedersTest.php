<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\EventType;

class SeedersTest extends TestCase
{
    use RefreshDatabase;

    public function test_event_types_seeder_inserts_general()
    {
        $this->artisan('migrate');
        if(class_exists(\Database\Seeders\EventTypesSeeder::class)){
            $this->seed(\Database\Seeders\EventTypesSeeder::class);
        }
        $this->assertTrue(EventType::where('slug','general')->exists(), 'Event type general should exist after seeding.');
    }
}

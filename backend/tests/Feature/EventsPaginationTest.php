<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\Event;
use App\Models\EventType;

class EventsPaginationTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->artisan('migrate');
        // seed event types (simulate DatabaseSeeder partial) if seeder class exists
        if(class_exists(\Database\Seeders\EventTypesSeeder::class)){
            $this->seed(\Database\Seeders\EventTypesSeeder::class);
        }
        // create more than one page of events
        $typeId = EventType::first()?->id;
        Event::factory()->count(25)->create([
            'event_type_id' => $typeId,
        ]);
    }

    public function test_events_paginated_structure()
    {
        $response = $this->getJson('/api/events?page=1&per_page=10');
        $response->assertStatus(200)
            ->assertJsonStructure([
                'data', 'current_page', 'last_page', 'per_page', 'total'
            ]);
        $json = $response->json();
        $this->assertCount(10, $json['data']);
        $this->assertEquals(1, $json['current_page']);
        $this->assertEquals(10, $json['per_page']);
        $this->assertGreaterThan(10, $json['total']);
    }

    public function test_events_plain_array_without_pagination_params()
    {
        $response = $this->getJson('/api/events');
        $response->assertStatus(200);
        $data = $response->json();
        $this->assertIsArray($data);
        $this->assertGreaterThanOrEqual(25, count($data));
    }
}

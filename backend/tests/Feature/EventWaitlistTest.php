<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Event;
use App\Models\EventRegistration;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class EventWaitlistTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        // Basic event schema migration
        $this->artisan('migrate');
    }

    public function test_waitlist_promotion_flow()
    {
        $admin = User::factory()->create(['role'=>'admin']);
        $a = User::factory()->create();
        $b = User::factory()->create();
    $d = date('Y-m-d');
        $event = Event::create([
            'title'=>'Test Event',
            'description'=>null,
            'start_date'=>$d,
            'end_date'=>$d,
            'start_time'=>null,
            'location'=>null,
            'images'=>json_encode([]),
            'audience'=>'limited',
            'limit'=>1,
        ]);

        // User A registers (confirmed)
        $this->actingAs($a)->postJson('/api/events/'.$event->id.'/register')->assertStatus(200)->assertJson(['status'=>'confirmed']);
        $event->refresh();
        $this->assertEquals(1, $event->registrations_count);

        // User B attempts and is waitlisted
        $this->actingAs($b)->postJson('/api/events/'.$event->id.'/register')->assertStatus(200)->assertJson(['status'=>'waitlist']);
        $this->assertDatabaseHas('event_registrations', [
            'event_id'=>$event->id,
            'user_id'=>$b->id,
            'status'=>'waitlist'
        ]);

        // User A unregisters → count decrements
        $this->actingAs($a)->postJson('/api/events/'.$event->id.'/unregister')->assertStatus(200)->assertJson(['status'=>'removed']);
        $event->refresh();
        $this->assertEquals(0, $event->registrations_count);

        // Admin promotes first waitlist (User B)
        $this->actingAs($admin)->postJson('/api/events/'.$event->id.'/promote')->assertStatus(200)->assertJson(['status'=>'promoted']);
        $event->refresh();
        $this->assertEquals(1, $event->registrations_count);
        $this->assertDatabaseHas('event_registrations', [
            'event_id'=>$event->id,
            'user_id'=>$b->id,
            'status'=>'confirmed'
        ]);
    }
}

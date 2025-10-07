<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\PendingRegistration;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class RegistrationFlowTest extends TestCase
{
    use RefreshDatabase;

    public function test_pending_registration_created()
    {
        $resp = $this->postJson('/api/auth/register', [
            'name'=>'Test User','email'=>'t@example.com','password'=>'secret123'
        ]);
        $resp->assertStatus(200)->assertJsonStructure(['message','email']);
        $this->assertDatabaseHas('pending_registrations', ['email'=>'t@example.com']);
    }

    public function test_expired_code_cannot_verify()
    {
        $this->postJson('/api/auth/register', [
            'name'=>'Test User','email'=>'t@example.com','password'=>'secret123'
        ]);
        $pending = PendingRegistration::first();
        // Force expiry
    $pending->expires_at = new \DateTimeImmutable('-1 minutes');
        $pending->save();
        $resp = $this->postJson('/api/auth/register/verify', [
            'email'=>'t@example.com','code'=>$pending->code
        ]);
        $resp->assertStatus(400)->assertJson(['message'=>'Кодът е изтекъл']);
    }

    public function test_cooldown_enforced_on_resend()
    {
        $this->postJson('/api/auth/register', [
            'name'=>'Test User','email'=>'t@example.com','password'=>'secret123'
        ]);
        // Immediate resend should hit cooldown (429)
        $first = $this->postJson('/api/auth/register/resend-code', ['email'=>'t@example.com']);
        $first->assertStatus(429);
        $first->assertJsonStructure(['message']);
    }

    public function test_successful_verification_issues_token()
    {
        $this->postJson('/api/auth/register', [
            'name'=>'Test User','email'=>'t@example.com','password'=>'secret123'
        ]);
        $pending = PendingRegistration::first();
        $resp = $this->postJson('/api/auth/register/verify', [
            'email'=>'t@example.com','code'=>$pending->code
        ]);
        $resp->assertStatus(200)->assertJsonStructure(['token','user']);
        $this->assertDatabaseHas('users', ['email'=>'t@example.com']);
        $this->assertDatabaseMissing('pending_registrations', ['email'=>'t@example.com']);
    }
}

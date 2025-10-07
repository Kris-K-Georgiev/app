<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\AppVersion;

class VersionEndpointTest extends TestCase
{
    use RefreshDatabase;

    /** @test */
    public function it_auto_seeds_when_no_version_exists()
    {
        $this->assertDatabaseCount('app_versions', 0);
        $this->getJson('/api/version/latest')
            ->assertOk()
            ->assertJsonFragment(['version_name' => '1.0.0']);
        $this->assertDatabaseCount('app_versions', 1);
    }

    /** @test */
    public function it_returns_latest_version()
    {
        AppVersion::create([
            'version_code' => 1,
            'version_name' => '1.0.0',
            'release_notes' => 'Initial',
            'is_mandatory' => false,
            'download_url' => null,
        ]);
        $this->getJson('/api/version/latest')
            ->assertOk()
            ->assertJsonFragment(['version_name' => '1.0.0']);
    }
}

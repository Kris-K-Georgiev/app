<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\AppVersion;
// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $this->call([
            AdminUserSeeder::class,
            EventTypesSeeder::class,
            SampleContentSeeder::class,
        ]);

        // Keep legacy sample users optional (commented out)
        // User::factory(2)->create();

        if(!AppVersion::query()->exists()) {
            AppVersion::create([
                'version_code' => 1,
                'version_name' => '1.0.0',
                'release_notes' => 'Initial release',
                'is_mandatory' => false,
                'download_url' => null,
            ]);
        }
    }
}

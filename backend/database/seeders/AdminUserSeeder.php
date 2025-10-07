<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class AdminUserSeeder extends Seeder
{
    public function run(): void
    {
        User::firstOrCreate(
            ['email' => 'admin@bhss.app'],
            [
                'name' => 'Администратор',
                'password' => Hash::make(env('ADMIN_INITIAL_PASSWORD','ChangeMe123!')),
                'role' => 'admin',
                'city' => 'София',
                'email_verified_at' => now(),
                'status' => 'active'
            ]
        );
    }
}

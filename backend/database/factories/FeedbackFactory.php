<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;
use App\Models\Feedback;
use App\Models\User;

class FeedbackFactory extends Factory
{
    protected $model = Feedback::class;
    public function definition(): array
    {
        return [
            'user_id' => User::inRandomOrder()->value('id') ?? User::factory(),
            'message' => $this->faker->paragraph(),
            'contact' => $this->faker->boolean(40)? $this->faker->safeEmail() : null,
            'user_agent' => $this->faker->userAgent(),
            'ip' => $this->faker->ipv4(),
        ];
    }
}

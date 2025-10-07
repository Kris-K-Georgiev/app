<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;
use App\Models\Event;
use Illuminate\Support\Str;

/** @extends Factory<Event> */
class EventFactory extends Factory
{
    protected $model = Event::class;

    public function definition(): array
    {
        $start = $this->faker->dateTimeBetween('-10 days', '+30 days');
        $end = (clone $start)->modify('+'.rand(0,2).' days');
        return [
            'title' => $this->faker->sentence(3),
            'description' => $this->faker->paragraph(),
            'location' => $this->faker->city(),
            'start_date' => $start->format('Y-m-d'),
            'end_date' => $end->format('Y-m-d'),
            'start_time' => $this->faker->time('H:i'),
            'images' => [],
            'cover' => null,
            'city' => $this->faker->city(),
            'audience' => $this->faker->randomElement(['open','city','limited']),
            'limit' => $this->faker->randomElement([null,50,100,150]),
            'registrations_count' => 0,
            'status' => 'active',
        ];
    }
}

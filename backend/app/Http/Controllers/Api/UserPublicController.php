<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Support\Facades\DB;

class UserPublicController extends Controller
{
    public function show(User $user)
    {
        // Aggregate lightweight stats
        $postsCount = $user->posts()->count();
        $prayersCount = $user->prayers()->count();
        // Likes received: sum post likes + prayer likes (could be optimized later with cached counters)
    $postIds = $user->posts()->pluck('id');
    $prayerIds = $user->prayers()->pluck('id');
    $postLikes = $postIds->isEmpty() ? 0 : DB::table('post_likes')->whereIn('post_id', $postIds)->count();
    $prayerLikes = $prayerIds->isEmpty() ? 0 : DB::table('prayer_likes')->whereIn('prayer_id', $prayerIds)->count();
        return [
            'id' => $user->id,
            'name' => $user->name,
            'city' => $user->city,
            'avatar_path' => $user->avatar_path,
            'bio' => $user->bio,
            'role' => $user->role,
            'joined_at' => $user->created_at,
            'stats' => [
                'posts' => $postsCount,
                'prayers' => $prayersCount,
                'likes_received' => $postLikes + $prayerLikes,
            ],
        ];
    }
}

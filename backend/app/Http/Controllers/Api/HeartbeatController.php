<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\News;
use App\Models\Event;
use App\Models\User;

class HeartbeatController extends Controller
{
    public function __invoke()
    {
        $latestNews = News::latest('id')->value('id');
        $latestEvent = Event::latest('id')->value('id');
        $newsUpdated = News::latest('updated_at')->value('updated_at');
        $eventsUpdated = Event::latest('updated_at')->value('updated_at');
        return [
            'latest_news_id' => $latestNews,
            'latest_event_id' => $latestEvent,
            'news_updated_at' => $newsUpdated,
            'events_updated_at' => $eventsUpdated,
            'users_count' => User::count(),
            'ts' => date('c'),
            // Hints for adaptive polling (client can shorten if changed)
            'has_changes' => true, // simple flag for now (could diff hash later)
        ];
    }
}

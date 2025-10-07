<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\News;
use App\Models\Event;
use App\Models\EventRegistration;
use Illuminate\Support\Facades\DB;
use DateTimeImmutable;

class StatsController extends Controller
{
    public function summary()
    {
        $news = News::count();
        $events = Event::count();
        $registrations = EventRegistration::count();

        // Use a single immutable baseline to avoid multiple now() calls and help static analyzers.
    // Baseline date objects using native immutable DateTime to avoid Carbon analyzer issues.
    $today = new DateTimeImmutable('today'); // midnight today
    $from = $today->modify('-6 days'); // midnight 6 days ago

    // Build last 7 day labels (oldest -> newest)
    $days = collect(range(6,0))->map(fn($i) => $today->modify("-{$i} days")->format('Y-m-d'));

        $newsSeries = News::select(DB::raw('DATE(created_at) d'), DB::raw('count(*) c'))
            ->where('created_at','>=', $from->format('Y-m-d 00:00:00'))
            ->groupBy('d')->pluck('c','d');
        $eventSeries = Event::select(DB::raw('DATE(created_at) d'), DB::raw('count(*) c'))
            ->where('created_at','>=', $from->format('Y-m-d 00:00:00'))
            ->groupBy('d')->pluck('c','d');
        $regSeries = EventRegistration::select(DB::raw('DATE(created_at) d'), DB::raw('count(*) c'))
            ->where('created_at','>=', $from->format('Y-m-d 00:00:00'))
            ->groupBy('d')->pluck('c','d');
        return [
            'news' => $news,
            'events' => $events,
            'registrations' => $registrations,
            'charts' => [
                'labels' => $days->values(),
                'news' => $days->map(fn($d)=> (int)($newsSeries[$d] ?? 0))->values(),
                'events' => $days->map(fn($d)=> (int)($eventSeries[$d] ?? 0))->values(),
                'registrations' => $days->map(fn($d)=> (int)($regSeries[$d] ?? 0))->values(),
            ],
        ];
    }
}

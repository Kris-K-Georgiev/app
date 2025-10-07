<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\News;
use App\Models\Event;
use Symfony\Component\HttpFoundation\StreamedResponse;

class StreamController extends Controller
{
    public function __invoke()
    {
        $response = new StreamedResponse(function(){
            @ob_end_flush();
            $lastNews = null; $lastEvent = null; $i=0;
            while($i < 200) { // ~200 cycles safeguard
                $latestNews = News::latest('id')->value('id');
                $latestEvent = Event::latest('id')->value('id');
                $payload = [
                    'news' => $latestNews,
                    'event' => $latestEvent,
                    'ts' => time()
                ];
                if($latestNews !== $lastNews || $latestEvent !== $lastEvent){
                    echo "event: update\n";
                    echo 'data: '.json_encode($payload)."\n\n";
                    $lastNews = $latestNews; $lastEvent = $latestEvent;
                } else {
                    echo "event: ping\n";
                    echo 'data: {"ts":'.time()."}\n\n";
                }
                flush();
                if(connection_aborted()) break;
                sleep(10); $i++;
            }
        });
        $response->headers->set('Content-Type','text/event-stream');
        $response->headers->set('Cache-Control','no-cache');
        $response->headers->set('X-Accel-Buffering','no');
        return $response;
    }
}

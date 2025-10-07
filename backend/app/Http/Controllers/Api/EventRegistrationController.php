<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Event;
use App\Models\EventRegistration;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Foundation\Auth\Access\AuthorizesRequests;

class EventRegistrationController extends Controller
{
    use AuthorizesRequests;
    public function register(Event $event)
    {
        $user = Auth::user();
        if(!$user) return response()->json(['message'=>'Unauthorized'],401);
        $isLimited = $event->audience === 'limited' && $event->limit;
        $existing = EventRegistration::where('event_id',$event->id)->where('user_id',$user->id)->first();
        if($existing) return ['status'=>$existing->status,'registrations_count'=>$event->registrations_count];
        $status = 'confirmed';
        if($isLimited && $event->registrations_count >= $event->limit){
            // Put on waitlist instead of rejecting
            $status = 'waitlist';
        }
        $reg = EventRegistration::create(['event_id'=>$event->id,'user_id'=>$user->id,'status'=>$status]);
        if($status === 'confirmed'){
            $event->increment('registrations_count');
        }
        return ['status'=>$reg->status,'registrations_count'=>$event->registrations_count,'limit'=>$event->limit];
    }

    public function unregister(Event $event)
    {
        $user = Auth::user();
        if(!$user) return response()->json(['message'=>'Unauthorized'],401);
        $deleted = EventRegistration::where('event_id',$event->id)->where('user_id',$user->id)->delete();
        if($deleted){
            $event->decrement('registrations_count');
        }
        return ['status'=>$deleted? 'removed':'none','registrations_count'=>$event->registrations_count,'limit'=>$event->limit];
    }

    public function promote(Event $event)
    {
        $this->authorize('promote', $event);
        if(!$event->limit || $event->registrations_count >= $event->limit){
            return response()->json(['message'=>'No free spots'], 409);
        }
        // Find earliest waitlist registration
        $wait = EventRegistration::where('event_id',$event->id)->where('status','waitlist')->orderBy('created_at')->first();
        if(!$wait) return ['status'=>'none','registrations_count'=>$event->registrations_count];
        $wait->status = 'confirmed';
        $wait->save();
        $event->increment('registrations_count');
        return ['status'=>'promoted','registrations_count'=>$event->registrations_count,'user_id'=>$wait->user_id];
    }

    public function waitlist(Event $event)
    {
        $this->authorize('viewWaitlist', $event);
        $items = EventRegistration::with('user')
            ->where('event_id',$event->id)
            ->where('status','waitlist')
            ->orderBy('created_at')
            ->get()
            ->map(fn($r)=> [
                'id'=>$r->id,
                'user'=>[
                    'id'=>$r->user->id,
                    'name'=>$r->user->name,
                    'city'=>$r->user->city,
                ],
                'created_at'=>$r->created_at,
            ]);
        return ['waitlist'=>$items];
    }
}

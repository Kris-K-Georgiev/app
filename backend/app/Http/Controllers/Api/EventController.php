<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Event;
use App\Models\EventRegistration;
use Illuminate\Support\Facades\Auth;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;
use Illuminate\Validation\Rule;

class EventController extends Controller
{
    public function index(Request $request)
    {
        $query = Event::with('type')->orderBy('start_date');

        if($status = $request->query('status')){
            if($status !== 'all'){
                $query->where('status', $status);
            }
        }
        if($audience = $request->query('audience')){
            if($audience !== 'all'){
                $query->where('audience', $audience);
            }
        }
        if($city = $request->query('city')){
            $query->where('city', $city);
        }
        if($type = $request->query('type')){
            // Match either slug or numeric id of related type
            $query->whereHas('type', function($q) use ($type){
                if(is_numeric($type)){
                    $q->where('id', (int)$type)->orWhere('slug', $type);
                } else {
                    $q->where('slug', $type);
                }
            });
        }

        $hasPageParam = $request->has('page') || $request->has('per_page');
        $perPage = min((int)$request->query('per_page',20), 100);
        $page = (int)$request->query('page',1);

        if(!$hasPageParam){
            // Fallback legacy behavior: return full (filtered) list without pagination metadata
            $events = $query->get();
        } else {
            $paginator = $query->paginate($perPage, ['*'], 'page', $page);
            $events = $paginator->getCollection();
        }
        $userStatuses = [];
        if($uid = Auth::id()){
            $userStatuses = EventRegistration::where('user_id',$uid)
                ->whereIn('event_id', $events->pluck('id'))
                ->pluck('status','event_id')
                ->toArray();
        }
        $data = $events->map(fn(Event $e)=> $this->transform($e, $userStatuses));
        if(!$hasPageParam){
            return $data; // plain array
        }
        return [
            'data' => $data,
            'current_page' => $paginator->currentPage(),
            'last_page' => $paginator->lastPage(),
            'per_page' => $paginator->perPage(),
            'total' => $paginator->total(),
        ];
    }

    public function show(Event $event)
    {
        $userStatuses = [];
        if($uid = Auth::id()){
            $status = EventRegistration::where('user_id',$uid)->where('event_id',$event->id)->value('status');
            if($status){ $userStatuses[$event->id] = $status; }
        }
        return $this->transform($event, $userStatuses);
    }

    public function store(Request $request)
    {
        $user = Auth::user();
        if(!$user){
            return response()->json(['message' => 'Unauthorized'], 401);
        }
        // Simple role gate (align with frontend canCreateEvent): admin, director, teacher
        if(!in_array($user->role, ['admin','director','teacher'])){
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $data = $request->validate([
            'title' => ['required','string','max:255'],
            'description' => ['nullable','string'],
            'location' => ['nullable','string','max:255'],
            'start_date' => ['required','date'],
            'end_date' => ['required','date','after_or_equal:start_date'],
            'start_time' => ['nullable','string','max:10'],
            'city' => ['nullable','string','max:120'],
            'audience' => ['nullable', Rule::in(['open','city','limited'])],
            'limit' => ['nullable','integer','min:1'],
            'event_type_id' => ['nullable','integer','exists:event_types,id'],
            'status' => ['nullable', Rule::in(['active','inactive'])],
            'images' => ['nullable','array'],
            'images.*' => ['string','max:255'],
            'cover' => ['nullable','string','max:255'],
        ]);

        $data['created_by'] = $user->id;
        if(!isset($data['audience'])){ $data['audience'] = 'open'; }
        if(!isset($data['status'])){ $data['status'] = 'active'; }
        $event = Event::create($data);
        $event->load('type');
        return response()->json($this->transform($event), 201);
    }

    protected function transform(Event $e, array $userStatuses = []): array
    {
        return [
            'id' => $e->id,
            'title' => $e->title,
            'description' => $e->description,
            'cover' => $e->cover,
            'start_date' => $e->start_date,
            'end_date' => $e->end_date,
            'start_time' => $e->start_time,
            'location' => $e->location,
            'images' => $e->images ?? [],
            'city' => $e->city,
            'city_name' => $e->city_name,
            'audience' => $e->audience,
            'limit' => $e->limit,
            'registrations_count' => $e->registrations_count,
            'status' => $e->status,
            'event_type' => $e->type ? [
                'id'=>$e->type->id,
                'slug'=>$e->type->slug,
                'name'=>$e->type->name,
                'color'=>$e->type->color,
            ] : null,
            'user_status' => $userStatuses[$e->id] ?? null,
            'days' => ($e->start_date && $e->end_date) ? $e->start_date->diffInDays($e->end_date) + 1 : 1,
            'created_at' => $e->created_at,
            'updated_at' => $e->updated_at,
        ];
    }
}

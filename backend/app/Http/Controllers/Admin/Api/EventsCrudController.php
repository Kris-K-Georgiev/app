<?php
namespace App\Http\Controllers\Admin\Api;

use App\Http\Controllers\Controller;
use App\Models\Event;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class EventsCrudController extends Controller
{
    public function index(Request $r){
    $q = Event::query()->with('type:id,name');
    if($r->boolean('with_deleted')) $q->withTrashed();
        if($type=$r->query('type_id')) $q->where('event_type_id',$type);
        if($status=$r->query('status')) $q->where('status',$status);
        $q->orderByDesc('start_date');
        $p=$q->paginate((int)$r->query('per_page',30));
        $p->getCollection()->transform(fn($e)=>[
            'id'=>$e->id,
            'title'=>$e->title,
            'start_date'=>$e->start_date,
            'end_date'=>$e->end_date,
            'type'=>$e->type?->only(['id','name']),
            'status'=>$e->status,
            'created_at'=>$e->created_at,
        ]);
        return $p;
    }
    public function show(Event $event){ $event->load('type:id,name'); return ['data'=>$event]; }
    public function store(Request $r){
        $data=$r->validate([
            'title'=>'required|string',
            'description'=>'nullable|string',
            'location'=>'nullable|string',
            'start_date'=>'required|date',
            'end_date'=>'nullable|date|after_or_equal:start_date',
            'event_type_id'=>'nullable|exists:event_types,id',
            'status'=>'nullable|string'
        ]);
        $data['created_by']=Auth::id();
        $event=Event::create($data);
        return response()->json(['data'=>$event],201);
    }
    public function update(Request $r, Event $event){
        $data=$r->validate([
            'title'=>'sometimes|required|string',
            'description'=>'sometimes|nullable|string',
            'location'=>'sometimes|nullable|string',
            'start_date'=>'sometimes|date',
            'end_date'=>'sometimes|nullable|date|after_or_equal:start_date',
            'event_type_id'=>'sometimes|nullable|exists:event_types,id',
            'status'=>'sometimes|string'
        ]);
        $event->update($data);
        return ['data'=>$event];
    }
    public function destroy(Event $event){ $event->delete(); return ['ok'=>true]; }
    public function restore($id){ $e=Event::withTrashed()->findOrFail($id); $e->restore(); return ['ok'=>true]; }
}

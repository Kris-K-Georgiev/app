<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Event;
use Illuminate\Http\Request;

class EventAdminController extends Controller
{
    public function index(Request $request) {
    $q = Event::query();
    if($s = $request->query('search')){ $q->where('title','like',"%$s%"); }
	if($from = $request->query('from')){ $q->where('start_date','>=',$from); }
	if($to = $request->query('to')){ $q->where('end_date','<=',$to); }
    if($status = $request->query('status')){ $q->where('status',$status); }
    if($etype = $request->query('type')){ $q->where('event_type_id',$etype); }
    // Sorting
    $sortable=['id','title','start_date','status'];
    $sort=$request->query('sort'); $dir=$request->query('dir')==='asc'?'asc':($request->query('dir')==='desc'?'desc':null);
    if($sort && in_array($sort,$sortable) && $dir){
        $q->orderBy($sort,$dir);
    } else {
        $q->orderByDesc('start_date');
    }
    $items = $q->paginate(15)->withQueryString();
        if($request->wantsJson()) {
            return response()->json([
                'html' => view('admin.events._table', compact('items'))->render(),
                'pagination' => (string) $items->links(),
                'sort' => $sort,
                'dir' => $dir,
            ]);
        }
        if($request->query('fragment') === 'table') {
            return view('admin.events._table', compact('items'));
        }
        return view('admin.events.index', compact('items'));
    }
    public function create() { return view('admin.events.create'); }
    public function store(Request $r) {
        $data = $r->validate([
            'title'=>'required',
            'description'=>'nullable',
            'start_date'=>'required|date',
            'end_date'=>'required|date|after_or_equal:start_date',
            'start_time'=>'nullable|date_format:H:i',
            'location'=>'nullable',
            'status'=>'nullable|in:active,inactive',
            'event_type_id'=>'nullable|exists:event_types,id',
            'images.*'=>'image'
        ]);
        $images = [];
        if($r->hasFile('images')) {
            foreach($r->file('images') as $img){ $p = $img->store('events','public'); $images[] = '/storage/'.$p; }
        }
    if(!empty($images)) $data['images'] = json_encode($images);
    if(!isset($data['status'])) $data['status'] = 'active';
    if(!isset($data['created_by'])) $data['created_by'] = $r->user()?->id;
    Event::create($data);
        return redirect()->route('admin.events.index')->with('ok','Created');
    }
    public function edit(Event $event) { return view('admin.events.edit', compact('event')); }
    public function update(Request $r, Event $event) {
        $data = $r->validate([
            'title'=>'required',
            'description'=>'nullable',
            'start_date'=>'required|date',
            'end_date'=>'required|date|after_or_equal:start_date',
            'start_time'=>'nullable|date_format:H:i',
            'location'=>'nullable',
            'status'=>'nullable|in:active,inactive',
            'event_type_id'=>'nullable|exists:event_types,id',
            'images.*'=>'image'
        ]);
        if($r->hasFile('images')) {
            $existing = $event->images ?? [];
            foreach($r->file('images') as $img){ $p = $img->store('events','public'); $existing[] = '/storage/'.$p; }
            $data['images'] = json_encode($existing);
        }
    if(!isset($data['created_by'])) $data['created_by'] = $r->user()?->id;
    $event->update($data);
        return redirect()->route('admin.events.index')->with('ok','Updated');
    }
    public function destroy(Event $event) { $event->delete(); return back()->with('ok','Deleted'); }

    public function bulkDelete(Request $request){
        $ids = $request->input('ids',[]); if(!is_array($ids) || empty($ids)) return response()->json(['ok'=>false,'error'=>'No IDs'],422);
        Event::whereIn('id',$ids)->delete(); return response()->json(['ok'=>true]);
    }
    public function export(Request $request){
        $q = Event::query();
        if($ids = $request->query('ids')){ $a = array_filter(explode(',',$ids)); if($a) $q->whereIn('id',$a); }
        if($s = $request->query('search')) $q->where('title','like',"%$s%");
    $rows = $q->orderBy('id')->get(['id','title','start_date','end_date','start_time','location']);
    $callback = function() use ($rows){ $out=fopen('php://output','w'); fputcsv($out,['ID','Title','Start Date','End Date','Start Time','Location']); foreach($rows as $r){ fputcsv($out,[$r->id,$r->title,$r->start_date,$r->end_date,$r->start_time,$r->location]); } fclose($out); };
        return response()->streamDownload($callback,'events.csv',['Content-Type'=>'text/csv']);
    }
}

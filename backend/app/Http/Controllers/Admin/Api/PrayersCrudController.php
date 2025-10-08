<?php
namespace App\Http\Controllers\Admin\Api;

use App\Http\Controllers\Controller;
use App\Models\Prayer;
use Illuminate\Http\Request;

class PrayersCrudController extends Controller
{
    public function index(Request $r){
        $q = Prayer::query()->with('user:id,name');
        if($r->boolean('with_deleted')) $q->withTrashed();
        if($r->has('answered')) $q->where('answered',(bool)$r->query('answered'));
        if($s=$r->query('search')) $q->where('content','like',"%$s%");
        $q->orderByDesc('id');
        $p=$q->paginate((int)$r->query('per_page',30));
        $p->getCollection()->transform(fn($pr)=>[
            'id'=>$pr->id,
            'content'=>$pr->content,
            'answered'=>$pr->answered,
            'is_anonymous'=>$pr->is_anonymous,
            'user'=>$pr->user?->only(['id','name']),
            'deleted_at'=>$pr->deleted_at,
            'created_at'=>$pr->created_at,
        ]);
        return $p;
    }
    public function show(Prayer $prayer){ $prayer->load('user:id,name'); return ['data'=>$prayer]; }
    public function store(Request $r){
        $data=$r->validate([
            'user_id'=>'required|exists:users,id',
            'content'=>'required|string',
            'is_anonymous'=>'nullable|boolean',
            'answered'=>'nullable|boolean'
        ]);
        $prayer=Prayer::create($data);
        return response()->json(['data'=>$prayer],201);
    }
    public function update(Request $r, Prayer $prayer){
        $data=$r->validate([
            'content'=>'sometimes|required|string',
            'is_anonymous'=>'sometimes|boolean',
            'answered'=>'sometimes|boolean'
        ]);
        $prayer->update($data);
        return ['data'=>$prayer];
    }
    public function destroy(Prayer $prayer){ $prayer->delete(); return ['ok'=>true]; }
    public function restore($id){ $p=Prayer::withTrashed()->findOrFail($id); $p->restore(); return ['ok'=>true]; }
}

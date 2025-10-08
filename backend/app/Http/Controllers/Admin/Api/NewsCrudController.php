<?php
namespace App\Http\Controllers\Admin\Api;

use App\Http\Controllers\Controller;
use App\Models\News;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class NewsCrudController extends Controller
{
    public function index(Request $r){
    $q = News::query()->with('author:id,name');
    if($r->boolean('with_deleted')) $q->withTrashed();
        if($s=$r->query('search')) $q->where('title','like',"%$s%");
        if($status=$r->query('status')) $q->where('status',$status);
        $q->orderByDesc('id');
        $p=$q->paginate((int)$r->query('per_page',30));
        $p->getCollection()->transform(fn($n)=>[
            'id'=>$n->id,
            'title'=>$n->title,
            'status'=>$n->status,
            'author'=>$n->author?->only(['id','name']),
            'created_at'=>$n->created_at,
        ]);
        return $p;
    }
    public function show(News $news){ $news->load('author:id,name'); return ['data'=>$news]; }
    public function store(Request $r){
        $data = $r->validate([
            'title'=>'required|string',
            'content'=>'required|string',
            'status'=>'nullable|string'
        ]);
        $data['created_by']=Auth::id();
        $news=News::create($data);
        return response()->json(['data'=>$news],201);
    }
    public function update(Request $r, News $news){
        $data = $r->validate([
            'title'=>'sometimes|required|string',
            'content'=>'sometimes|required|string',
            'status'=>'sometimes|string'
        ]);
        $news->update($data);
        return ['data'=>$news];
    }
    public function destroy(News $news){ $news->delete(); return ['ok'=>true]; }
    public function restore($id){ $n=News::withTrashed()->findOrFail($id); $n->restore(); return ['ok'=>true]; }
}

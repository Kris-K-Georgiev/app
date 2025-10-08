<?php
namespace App\Http\Controllers\Admin\Api;

use App\Http\Controllers\Controller;
use App\Models\Post;
use Illuminate\Http\Request;

class PostsCrudController extends Controller
{
    public function index(Request $r){
        $q = Post::query()->with('user:id,name');
        if($r->boolean('with_deleted')) $q->withTrashed();
        if($s=$r->query('search')){ $q->where('content','like',"%$s%"); }
        if($uid=$r->query('user_id')) $q->where('user_id',$uid);
        $q->orderByDesc('id');
        $p = $q->paginate((int)$r->query('per_page',30));
        $p->getCollection()->transform(fn($p)=>[
            'id'=>$p->id,
            'content'=>$p->content,
            'user'=>$p->user?->only(['id','name']),
            'deleted_at'=>$p->deleted_at,
            'created_at'=>$p->created_at,
        ]);
        return $p;
    }
    public function show(Post $post){ $post->load('user:id,name'); return ['data'=>$post]; }
    public function store(Request $r){
        $data = $r->validate([
            'user_id'=>'required|exists:users,id',
            'content'=>'required|string'
        ]);
        $post = Post::create($data);
        return response()->json(['data'=>$post],201);
    }
    public function update(Request $r, Post $post){
        $data = $r->validate([
            'content'=>'sometimes|required|string'
        ]);
        $post->update($data);
        return ['data'=>$post];
    }
    public function destroy(Post $post){ $post->delete(); return ['ok'=>true]; }
    public function restore($id){ $p=Post::withTrashed()->findOrFail($id); $p->restore(); return ['ok'=>true]; }
}

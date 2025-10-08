<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Post;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class PostController extends Controller
{
    private function urlFor(?string $path): ?string
    {
        if(!$path) return null;
        if(Str::startsWith($path, ['http', '/storage', 'storage/'])) return $path;
        return asset('storage/'.$path);
    }

    public function index()
    {
        $perPage = (int) request('per_page', 10);
        $paginator = Post::with('user:id,name,avatar_path')->withCount(['likes','comments'])
            ->latest()->paginate($perPage);
        $user = request()->user();
        $uid = $user?->id;
        $paginator->getCollection()->transform(function(Post $p) use ($uid){
            $liked = false;
            if($uid){ $liked = $p->likes()->where('user_id',$uid)->exists(); }
            $isNew = $p->created_at && $p->created_at->gt(now()->subDays(2));
            return [
                'id' => $p->id,
                'content' => $p->content,
                'image' => $this->urlFor($p->image),
                'likes_count' => $p->likes_count,
                'comments_count' => $p->comments_count,
                'liked' => $liked,
                'can_edit' => $uid && $p->user_id == $uid,
                'author' => $p->user?->only(['id','name','avatar_path']),
                'is_new' => $isNew,
                'created_at' => $p->created_at,
                'updated_at' => $p->updated_at,
            ];
        });
        return $paginator;
    }

    public function store(Request $request)
    {
        $user = $request->user(); if(!$user) return response()->json(['message'=>'Unauthorized'],401);
        $data = $request->validate(['content'=>'required|string|max:5000','image'=>'sometimes|file|image|max:4096']);
        $path = null;
        if($request->hasFile('image')){
            $path = $request->file('image')->store('posts','public');
        }
        $post = Post::create(['user_id'=>$user->id,'content'=>$data['content'],'image'=>$path]);
        $isNew = $post->created_at && $post->created_at->gt(now()->subDays(2));
        return [
            'id'=>$post->id,
            'content'=>$post->content,
            'image'=>$this->urlFor($post->image),
            'likes_count'=>0,
            'comments_count'=>0,
            'liked'=>false,
            'can_edit'=>true,
            'author'=>$post->user?->only(['id','name','avatar_path']),
            'is_new'=>$isNew,
            'created_at'=>$post->created_at,
            'updated_at'=>$post->updated_at,
        ];
    }

    public function update(Post $post, Request $request)
    {
        $user = $request->user(); if(!$user) return response()->json(['message'=>'Unauthorized'],401);
        if($post->user_id !== $user->id) return response()->json(['message'=>'Forbidden'],403);
        $data = $request->validate(['content'=>'sometimes|string|max:5000','image'=>'sometimes|file|image|max:4096']);
        if(isset($data['content'])) $post->content = $data['content'];
        if($request->hasFile('image')){
            $path = $request->file('image')->store('posts','public');
            $post->image = $path;
        }
        $post->save();
        $liked = $post->likes()->where('user_id',$user->id)->exists();
        $post->loadCount(['likes','comments']);
        $isNew = $post->created_at && $post->created_at->gt(now()->subDays(2));
        return [
            'id'=>$post->id,
            'content'=>$post->content,
            'image'=>$this->urlFor($post->image),
            'likes_count'=>$post->likes_count,
            'comments_count'=>$post->comments_count,
            'liked'=>$liked,
            'can_edit'=>true,
            'author'=>$post->user?->only(['id','name','avatar_path']),
            'is_new'=>$isNew,
            'created_at'=>$post->created_at,
            'updated_at'=>$post->updated_at,
        ];
    }

    public function toggleLike(Post $post)
    {
        $user = request()->user(); if(!$user) return response()->json(['message'=>'Unauthorized'],401);
        $existing = $post->likes()->where('user_id',$user->id)->first();
        $liked = false;
        if($existing){ $existing->delete(); $liked=false; } else { $post->likes()->create(['user_id'=>$user->id]); $liked=true; }
        $count = $post->likes()->count();
        return ['liked'=>$liked,'likes_count'=>$count];
    }

    public function addComment(Post $post)
    {
        $user = request()->user(); if(!$user) return response()->json(['message'=>'Unauthorized'],401);
        $content = trim((string) request('content',''));
        if($content==='') return response()->json(['message'=>'Content required'],422);
        $comment = $post->comments()->create(['user_id'=>$user->id,'content'=>$content]);
        $post->loadCount('comments');
        return [
            'comment'=>[
                'id'=>$comment->id,
                'user_id'=>$comment->user_id,
                'user_name'=>optional($comment->user)->name,
                'content'=>$comment->content,
                'created_at'=>$comment->created_at,
            ],
            'comments_count'=>$post->comments_count,
        ];
    }

    public function listComments(Post $post)
    {
        $perPage = (int) request('per_page', 20);
        $paginator = $post->comments()->with('user:id,name,avatar_path')->latest()->paginate($perPage);
        $paginator->getCollection()->transform(function($c){
            return [
                'id' => $c->id,
                'user' => $c->user?->only(['id','name','avatar_path']),
                'content' => $c->content,
                'created_at' => $c->created_at,
            ];
        });
        return $paginator;
    }
}

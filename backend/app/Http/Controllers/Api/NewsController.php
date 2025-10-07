<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\News;
use Illuminate\Support\Str;

class NewsController extends Controller
{
    private function urlFor(?string $path): ?string
    {
        if(!$path) return null;
        // If already absolute or points to public storage, return as-is
    if(Str::startsWith($path, ['http', '/storage', 'storage/'])) return $path;
        // Otherwise, prefix the public storage path
        return asset('storage/'.$path);
    }

    public function index()
    {
        $perPage = (int) request('per_page', 10);
        $paginator = News::with('images')
            ->withCount(['likes','comments'])
            ->latest()->paginate($perPage);
        // Transform collection to include images array (gallery) and keep main image for backward compatibility
        $paginator->getCollection()->transform(function(News $n){
            $cover = $this->urlFor($n->cover);
            $image = $this->urlFor($n->image);
            $images = $n->images->pluck('path')->map(fn($p)=> $this->urlFor($p))->values();
            return [
                'id' => $n->id,
                'title' => $n->title,
                'content' => $n->content,
                'image' => $image, // legacy main image (normalized to absolute URL)
                'cover' => $cover,
                'images' => $images,
                'likes_count' => $n->likes_count,
                'comments_count' => $n->comments_count,
                'status' => $n->status,
                'created_at' => $n->created_at,
                'updated_at' => $n->updated_at,
            ];
        });
        return $paginator;
    }

    public function show(News $news)
    {
        $news->load(['images','comments' => function($q){ $q->latest()->limit(5)->with('user'); }])
            ->loadCount(['likes','comments']);
        $cover = $this->urlFor($news->cover);
        $image = $this->urlFor($news->image);
        $images = $news->images->pluck('path')->map(fn($p)=> $this->urlFor($p))->values();
        return [
            'id' => $news->id,
            'title' => $news->title,
            'content' => $news->content,
            'image' => $image,
            'cover' => $cover,
            'images' => $images,
            'likes_count' => $news->likes_count,
            'comments_count' => $news->comments_count,
            'latest_comments' => $news->comments->map(function($c){ return [
                'id' => $c->id,
                'user_id' => $c->user_id,
                'user_name' => optional($c->user)->name,
                'content' => $c->content,
                'created_at' => $c->created_at,
            ]; })->values(),
            'status' => $news->status,
            'created_at' => $news->created_at,
            'updated_at' => $news->updated_at,
        ];
    }

    /** Toggle like for the authenticated user. Returns the new like state and updated count. */
    public function toggleLike(News $news)
    {
        $user = request()->user();
        if(!$user) return response()->json(['message' => 'Unauthorized'], 401);
        $existing = $news->likes()->where('user_id', $user->id)->first();
        $liked = false;
        if($existing){
            $existing->delete();
            $liked = false;
        } else {
            $news->likes()->create(['user_id' => $user->id]);
            $liked = true;
        }
        $count = $news->likes()->count();
        return response()->json(['liked' => $liked, 'likes_count' => $count]);
    }

    /** Add a comment for the authenticated user. Returns the comment and updated count. */
    public function addComment(News $news)
    {
        $user = request()->user();
        if(!$user) return response()->json(['message' => 'Unauthorized'], 401);
        $content = trim((string) request('content', ''));
        if($content === ''){
            return response()->json(['message' => 'Content required'], 422);
        }
        $comment = $news->comments()->create(['user_id' => $user->id, 'content' => $content]);
        $news->loadCount('comments');
        return response()->json([
            'comment' => [
                'id' => $comment->id,
                'user_id' => $comment->user_id,
                'user_name' => optional($comment->user)->name,
                'content' => $comment->content,
                'created_at' => $comment->created_at,
            ],
            'comments_count' => $news->comments_count,
        ]);
    }
}

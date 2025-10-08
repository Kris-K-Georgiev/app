<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Prayer;
use Illuminate\Http\Request;

class PrayerController extends Controller
{
    public function index()
    {
        $perPage = (int) request('per_page', 10);
        $paginator = Prayer::withCount('likes')->latest()->paginate($perPage);
        $user = request()->user(); $uid = $user?->id;
        $paginator->getCollection()->transform(function(Prayer $p) use ($uid){
            $liked = $uid ? $p->likes()->where('user_id',$uid)->exists() : false;
            return [
                'id'=>$p->id,
                'content'=>$p->content,
                'is_anonymous'=>$p->is_anonymous,
                'answered'=>$p->answered,
                'likes_count'=>$p->likes_count,
                'liked'=>$liked,
                'user_name'=>$p->is_anonymous ? null : optional($p->user)->name,
                'can_edit'=>$uid && $p->user_id==$uid,
                'created_at'=>$p->created_at,
                'updated_at'=>$p->updated_at,
            ];
        });
        return $paginator;
    }

    public function store(Request $request)
    {
        $user = $request->user(); if(!$user) return response()->json(['message'=>'Unauthorized'],401);
        $data = $request->validate([
            'content'=>'required|string|max:5000',
            'is_anonymous'=>'sometimes|boolean'
        ]);
        $p = Prayer::create([
            'user_id'=>$user->id,
            'content'=>$data['content'],
            'is_anonymous'=>$data['is_anonymous'] ?? false,
            'answered'=>false,
        ]);
        return [
            'id'=>$p->id,
            'content'=>$p->content,
            'is_anonymous'=>$p->is_anonymous,
            'answered'=>$p->answered,
            'likes_count'=>0,
            'liked'=>false,
            'user_name'=>$p->is_anonymous? null : optional($p->user)->name,
            'can_edit'=>true,
            'created_at'=>$p->created_at,
            'updated_at'=>$p->updated_at,
        ];
    }

    public function update(Prayer $prayer, Request $request)
    {
        $user = $request->user(); if(!$user) return response()->json(['message'=>'Unauthorized'],401);
        if($prayer->user_id !== $user->id) return response()->json(['message'=>'Forbidden'],403);
        $data = $request->validate([
            'content'=>'sometimes|string|max:5000',
            'is_anonymous'=>'sometimes|boolean',
            'answered'=>'sometimes|boolean'
        ]);
        if(isset($data['content'])) $prayer->content = $data['content'];
        if(array_key_exists('is_anonymous',$data)) $prayer->is_anonymous = $data['is_anonymous'];
        if(array_key_exists('answered',$data)) $prayer->answered = $data['answered'];
        $prayer->save();
        $liked = $prayer->likes()->where('user_id',$user->id)->exists();
        $prayer->loadCount('likes');
        return [
            'id'=>$prayer->id,
            'content'=>$prayer->content,
            'is_anonymous'=>$prayer->is_anonymous,
            'answered'=>$prayer->answered,
            'likes_count'=>$prayer->likes_count,
            'liked'=>$liked,
            'user_name'=>$prayer->is_anonymous? null : optional($prayer->user)->name,
            'can_edit'=>true,
            'created_at'=>$prayer->created_at,
            'updated_at'=>$prayer->updated_at,
        ];
    }

    public function toggleLike(Prayer $prayer)
    {
        $user = request()->user(); if(!$user) return response()->json(['message'=>'Unauthorized'],401);
        $existing = $prayer->likes()->where('user_id',$user->id)->first();
        $liked = false;
        if($existing){ $existing->delete(); $liked=false; } else { $prayer->likes()->create(['user_id'=>$user->id]); $liked=true; }
        $count = $prayer->likes()->count();
        return ['liked'=>$liked,'likes_count'=>$count];
    }
}

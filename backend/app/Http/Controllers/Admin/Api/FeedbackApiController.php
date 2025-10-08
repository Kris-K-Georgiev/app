<?php

namespace App\Http\Controllers\Admin\Api;

use App\Http\Controllers\Controller;
use App\Models\Feedback;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class FeedbackApiController extends Controller
{
    public function index(Request $request)
    {
        $q = Feedback::with(['user:id,name','handler:id,name']);
        if($status = $request->query('status')) $q->status($status);
        if($sevMin = $request->query('sev_min')) $q->severity($sevMin, null);
        if($sevMax = $request->query('sev_max')) $q->severity(null, $sevMax);
        if($from = $request->query('from')) $q->dateBetween($from,null);
        if($to = $request->query('to')) $q->dateBetween(null,$to);
        if($search = $request->query('search')){
            $q->where(function($qq) use ($search){
                $qq->where('message','like',"%$search%")
                    ->orWhere('contact','like',"%$search%")
                    ->orWhere('ip','like',"%$search%")
                    ->orWhere('user_agent','like',"%$search%")
                ;
            });
        }
        $q->orderByDesc('created_at');
        $perPage = (int) $request->query('per_page', 30);
        $p = $q->paginate($perPage)->appends($request->query());
        $p->getCollection()->transform(fn($f)=>[
            'id'=>$f->id,
            'user'=>$f->user?->only(['id','name']),
            'message'=>$f->message,
            'contact'=>$f->contact,
            'status'=>$f->status,
            'severity'=>$f->severity,
            'handled_by'=>$f->handler?->only(['id','name']),
            'handled_at'=>$f->handled_at,
            'ip'=>$f->ip,
            'context'=>$f->context,
            'created_at'=>$f->created_at,
        ]);
        return $p;
    }

    public function updateStatus(Feedback $feedback, Request $request)
    {
        $data = $request->validate([
            'status' => 'required|in:new,reviewed,closed',
            'severity' => 'nullable|integer|min:1|max:5'
        ]);
        $feedback->status = $data['status'];
        if(array_key_exists('severity',$data)) $feedback->severity = $data['severity'];
        $feedback->handled_by = Auth::id();
        $feedback->handled_at = now();
        $feedback->save();
        return [ 'ok'=>true ];
    }
}

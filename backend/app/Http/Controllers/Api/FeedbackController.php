<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;
use App\Mail\FeedbackMail;
use Illuminate\Support\Facades\DB;

class FeedbackController extends Controller
{
    public function store(Request $request)
    {
        $data = $request->validate([
            'message' => 'required|string|min:5|max:2000',
            'contact' => 'nullable|string|max:255'
        ]);
        $user = $request->user();
        $id = DB::table('feedback')->insertGetId([
            'user_id' => $user?->id,
            'message' => $data['message'],
            'contact' => $data['contact'] ?? null,
            'user_agent' => substr((string)$request->userAgent(),0,255),
            'ip' => $request->ip(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);
        $payload = [
            'id' => $id,
            'user_id' => $user?->id,
            'contact' => $data['contact'] ?? null,
            'ip' => $request->ip(),
            'user_agent' => $request->userAgent(),
            'message' => $data['message'],
            'submitted_at' => now()->toIso8601String(),
        ];
        Log::info('[feedback] stored', $payload);
        // Send mail (configure mail.to in .env or hardcode fallback)
        $to = config('mail.feedback_to') ?? config('mail.from.address');
        if($to){
            try { Mail::to($to)->queue(new FeedbackMail($payload)); } catch(\Throwable $e){ Log::warning('[feedback] mail failed: '.$e->getMessage()); }
        }
        return response()->json(['status'=>'ok','id'=>$id]);
    }
}

<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class ReadOnlyIfWorker
{
    protected array $blocked = ['POST','PUT','PATCH','DELETE'];
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();
        if($user && $user->role === 'rabotnik' && in_array($request->getMethod(), $this->blocked)) {
            if($request->wantsJson()){
                return response()->json(['ok'=>false,'error'=>'Read-only role'], 403);
            }
            return redirect()->back()->with('err','Нямате права за промяна');
        }
        return $next($request);
    }
}

<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class AdminOnly
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();
        if(!$user || !in_array($user->role, ['admin','director'])) {
            return redirect()->route('admin.login')->with('err','Unauthorized');
        }
        return $next($request);
    }
}

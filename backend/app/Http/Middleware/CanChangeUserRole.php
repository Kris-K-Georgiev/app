<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CanChangeUserRole
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();
        if(!$user || !in_array($user->role, ['admin','director'])) {
            // If attempting to change role field, strip it
            if($request->has('role')){
                $request->merge(['role'=> $user?->role]);
            }
        }
        return $next($request);
    }
}

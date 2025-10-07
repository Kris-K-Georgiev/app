<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AdminAuthController extends Controller
{
    public function showLogin() { return view('admin.auth.login'); }

    public function login(Request $request) {
        $credentials = $request->validate(['email'=>'required|email','password'=>'required']);
        if(Auth::attempt($credentials, $request->boolean('remember'))) {
            $request->session()->regenerate();
            if(Auth::user()->role !== 'admin') {
                Auth::logout();
                return back()->withErrors(['email'=>'Not an admin']);
            }
            return redirect()->route('admin.dashboard');
        }
        return back()->withErrors(['email'=>'Invalid credentials']);
    }

    public function logout(Request $request)
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();
        return redirect()->route('admin.login');
    }
}

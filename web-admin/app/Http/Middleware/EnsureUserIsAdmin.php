<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

class EnsureUserIsAdmin
{
    public function handle(Request $request, Closure $next): Response
    {
        if (!Auth::check()) {
            return redirect()->route('login');
        }

        if (Auth::user()->role !== 'admin') {
            Auth::logout();
            return redirect()->route('login')
                ->withErrors(['email' => 'Akses tidak sah. Silakan login dengan akun administrator.']);
        }

        return $next($request);
    }
}

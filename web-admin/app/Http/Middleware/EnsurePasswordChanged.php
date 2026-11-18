<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsurePasswordChanged
{
    public function handle(Request $request, Closure $next): Response
    {
        if ($request->user()?->must_change_password) {
            return response()->json([
                'success' => false,
                'code' => 'PASSWORD_CHANGE_REQUIRED',
                'message' => 'Ganti kata sandi sementara sebelum menggunakan fitur aplikasi.',
            ], 423);
        }

        return $next($request);
    }
}

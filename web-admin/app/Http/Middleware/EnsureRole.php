<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureRole
{
    public function handle(Request $request, Closure $next, string ...$roles): Response
    {
        $user = $request->user();
        $allowedRoles = array_values(array_filter(array_map('trim', $roles)));

        if (! $user || $allowedRoles === [] || ! in_array($user->role, $allowedRoles, true)) {
            return response()->json([
                'success' => false,
                'code' => 'ROLE_FORBIDDEN',
                'message' => 'Akun Anda tidak memiliki akses ke fitur ini.',
            ], 403);
        }

        return $next($request);
    }
}

<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureActiveAccount
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if (! $user || ! $user->is_active) {
            // Revoke this bearer token as an additional safeguard. Admin account
            // management already revokes all tokens when an account is disabled.
            $token = $user?->currentAccessToken();
            if ($token && method_exists($token, 'delete')) {
                $token->delete();
            }

            return response()->json([
                'success' => false,
                'code' => 'ACCOUNT_INACTIVE',
                'message' => 'Akun ini tidak aktif. Hubungi Admin TU Madrasah.',
            ], 403);
        }

        return $next($request);
    }
}

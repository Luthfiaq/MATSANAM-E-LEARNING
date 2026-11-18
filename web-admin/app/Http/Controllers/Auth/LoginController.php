<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Schema;
use App\Models\AdminActivityLog;

class LoginController extends Controller
{
    public function showLoginForm()
    {
        if (Auth::check()) {
            return redirect()->route('admin.dashboard');
        }
        
        return view('auth.login');
    }

    public function login(Request $request)
    {
        $credentials = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required'],
        ]);

        if (Auth::attempt($credentials, $request->filled('remember'))) {
            $request->session()->regenerate();

            if (! Auth::user()->is_active) {
                Auth::logout();
                $request->session()->invalidate();
                $request->session()->regenerateToken();
                return back()->withErrors([
                    'email' => 'Akun tidak aktif. Hubungi administrator madrasah.',
                ])->onlyInput('email');
            }

            // Check if user is admin
            if (Auth::user()->role !== 'admin') {
                Auth::logout();
                $request->session()->invalidate();
                $request->session()->regenerateToken();
                return back()->withErrors([
                    'email' => 'Akses ditolak. Hanya administrator yang dapat mengakses sistem ini.',
                ]);
            }

            Auth::user()->forceFill(['last_login_at' => now()])->save();
            $this->recordAuthActivity($request, 'login', 'Admin berhasil masuk ke portal administrasi.');
            return redirect()->intended(route('admin.dashboard'));
        }

        return back()->withErrors([
            'email' => 'Email atau password salah.',
        ])->onlyInput('email');
    }

    public function logout(Request $request)
    {
        $user = $request->user();
        if ($user?->role === 'admin') {
            $this->recordAuthActivity($request, 'logout', 'Admin keluar dari portal administrasi.', $user->id);
        }
        Auth::logout();

        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect()->route('login');
    }

    private function recordAuthActivity(Request $request, string $action, string $description, ?int $actorId = null): void
    {
        try {
            if (! Schema::hasTable('admin_activity_logs')) return;
            AdminActivityLog::create([
                'actor_id' => $actorId ?? $request->user()?->id,
                'module' => 'Autentikasi Admin',
                'action' => $action,
                'description' => $description,
                'metadata' => ['route' => $request->route()?->getName() ?? ($action === 'login' ? 'login' : 'logout'), 'method' => strtoupper($request->method()), 'status_code' => 302],
                'ip_address' => $request->ip(),
                'user_agent' => substr((string) $request->userAgent(), 0, 500),
            ]);
        } catch (\Throwable) {
            // Audit writes must not block sign-in or sign-out.
        }
    }
}

<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use App\Models\User;
use App\Models\Guru;
use App\Models\Siswa;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required|string',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Email atau password salah'
            ], 401);
        }

        if (!$user->is_active) {
            return response()->json([
                'success' => false,
                'message' => 'Akun Anda tidak aktif'
            ], 403);
        }

        // Generate simple token (dalam production, gunakan Laravel Sanctum)
        $token = base64_encode($user->id . '|' . Str::random(40) . '|' . time());

        // Get user profile based on role
        $profile = null;
        if ($user->role === 'guru') {
            $profile = Guru::where('user_id', $user->id)->first();
        } elseif ($user->role === 'siswa') {
            $profile = Siswa::where('user_id', $user->id)->with('kelas')->first();
        }

        return response()->json([
            'success' => true,
            'message' => 'Login berhasil',
            'data' => [
                'token' => $token,
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'role' => $user->role,
                    'profile' => $profile,
                ]
            ]
        ]);
    }

    public function logout(Request $request)
    {
        // Dalam implementasi production dengan Sanctum, hapus token dari database
        return response()->json([
            'success' => true,
            'message' => 'Logout berhasil'
        ]);
    }

    public function me(Request $request)
    {
        // Dummy endpoint untuk get current user
        // Dalam production, extract user dari token
        return response()->json([
            'success' => true,
            'data' => [
                'user' => $request->user()
            ]
        ]);
    }
}

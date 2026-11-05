<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    /**
     * POST /api/login
     * Body: email, password
     */
    public function login(Request $request)
    {
        $data = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
        ], [
            'email.required' => 'Email wajib diisi.',
            'email.email' => 'Format email tidak valid.',
            'password.required' => 'Kata sandi wajib diisi.',
        ]);

        $user = User::where('email', $data['email'])->first();

        if (! $user || ! Hash::check($data['password'], $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Email atau kata sandi salah.',
            ], 401);
        }

        if (! $user->is_active) {
            return response()->json([
                'success' => false,
                'message' => 'Akun Anda dinonaktifkan. Hubungi Admin TU Madrasah.',
            ], 403);
        }

        if ($user->role !== 'siswa') {
            return response()->json([
                'success' => false,
                'message' => 'Aplikasi mobile ini khusus untuk akun siswa.',
            ], 403);
        }

        $siswa = $user->siswa()->with('kelas')->first();
        $token = $user->createToken('matsanam-mobile')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login berhasil.',
            'data' => [
                'token' => $token,
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'role' => $user->role,
                ],
                'siswa' => $siswa ? [
                    'id' => $siswa->id,
                    'nis' => $siswa->nis,
                    'nama_lengkap' => $siswa->nama_lengkap,
                    'kelas' => optional($siswa->kelas)->nama_kelas,
                ] : null,
            ],
        ]);
    }

    /**
     * POST /api/logout (auth:sanctum)
     */
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Berhasil keluar.',
        ]);
    }
}

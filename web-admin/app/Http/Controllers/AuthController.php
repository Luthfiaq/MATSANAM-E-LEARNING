<?php

namespace App\Http\Controllers;

use App\Models\Guru;
use App\Models\Siswa;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
            'device_name' => 'nullable|string',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['Kredensial tidak valid.'],
            ]);
        }

        if (!$user->is_active) {
            return response()->json([
                'success' => false,
                'message' => 'Akun tidak aktif. Hubungi admin.',
            ], 403);
        }

        $token = $user->createToken($request->device_name ?? 'mobile-app')->plainTextToken;

        // Determine role and get profile data
        $role = $user->role;
        $profile = null;
        $profileId = null;

        if ($role === 'guru') {
            $guru = Guru::where('user_id', $user->id)->first();
            if ($guru) {
                $profile = [
                    'id' => $guru->id,
                    'nama_lengkap' => $guru->nama_lengkap,
                    'nip' => $guru->nip,
                    'foto_profil' => $guru->foto_profil,
                ];
                $profileId = $guru->id;
            }
        } elseif ($role === 'siswa') {
            $siswa = Siswa::where('user_id', $user->id)->first();
            if ($siswa) {
                $profile = [
                    'id' => $siswa->id,
                    'nama_lengkap' => $siswa->nama_lengkap,
                    'nis' => $siswa->nis,
                    'nisn' => $siswa->nisn,
                    'kelas' => $siswa->kelas?->nama_kelas,
                    'foto_profil' => $siswa->foto_profil,
                ];
                $profileId = $siswa->id;
            }
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
                    'role' => $role,
                ],
                'profile' => $profile,
                'profile_id' => $profileId,
            ],
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logout berhasil',
        ]);
    }

    public function me(Request $request)
    {
        $user = $request->user();
        $role = $user->role;
        $profile = null;
        $profileId = null;

        if ($role === 'guru') {
            $guru = Guru::where('user_id', $user->id)->first();
            if ($guru) {
                $profile = [
                    'id' => $guru->id,
                    'nama_lengkap' => $guru->nama_lengkap,
                    'nip' => $guru->nip,
                    'foto_profil' => $guru->foto_profil,
                ];
                $profileId = $guru->id;
            }
        } elseif ($role === 'siswa') {
            $siswa = Siswa::where('user_id', $user->id)->first();
            if ($siswa) {
                $profile = [
                    'id' => $siswa->id,
                    'nama_lengkap' => $siswa->nama_lengkap,
                    'nis' => $siswa->nis,
                    'nisn' => $siswa->nisn,
                    'kelas' => $siswa->kelas?->nama_kelas,
                    'foto_profil' => $siswa->foto_profil,
                ];
                $profileId = $siswa->id;
            }
        }

        return response()->json([
            'success' => true,
            'data' => [
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'role' => $role,
                ],
                'profile' => $profile,
                'profile_id' => $profileId,
            ],
        ]);
    }
}
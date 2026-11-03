<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Guru;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;

class GuruController extends Controller
{
    public function index()
    {
        $guru = Guru::with('user')
            ->orderBy('nama_lengkap')
            ->get();

        return view('admin.master-data.guru.index', compact('guru'));
    }

    public function create()
    {
        return view('admin.master-data.guru.create');
    }

    public function store(Request $request)
    {
        $request->validate([
            'nip' => 'required|string|max:50|unique:guru,nip',
            'nama_lengkap' => 'required|string|max:150',
            'jenis_kelamin' => 'required|in:L,P',
            'telepon' => 'nullable|string|max:30',
            'alamat' => 'nullable|string',
            'email' => 'required|email|max:150|unique:users,email',
            'password' => 'required|string|min:6',
            'is_active' => 'required|boolean',
        ]);

        DB::transaction(function () use ($request) {

            $user = User::create([
                'name' => $request->nama_lengkap,
                'email' => $request->email,
                'password' => $request->password,
                'role' => 'guru',
                'is_active' => $request->is_active,
            ]);

            Guru::create([
                'user_id' => $user->id,
                'nip' => $request->nip,
                'nama_lengkap' => $request->nama_lengkap,
                'jenis_kelamin' => $request->jenis_kelamin,
                'telepon' => $request->telepon,
                'alamat' => $request->alamat,
            ]);
        });

        return redirect()
            ->route('admin.master-data.guru.index')
            ->with('success', 'Data guru berhasil ditambahkan.');
    }

    public function edit($id)
    {
        $guru = Guru::with('user')->findOrFail($id);

        return view('admin.master-data.guru.edit', compact('guru'));
    }

    public function update(Request $request, $id)
    {
        $guru = Guru::with('user')->findOrFail($id);

        $request->validate([
            'nip' => [
                'required',
                'string',
                'max:50',
                Rule::unique('guru', 'nip')->ignore($guru->id),
            ],
            'nama_lengkap' => 'required|string|max:150',
            'jenis_kelamin' => 'required|in:L,P',
            'telepon' => 'nullable|string|max:30',
            'alamat' => 'nullable|string',
            'email' => [
                'required',
                'email',
                'max:150',
                Rule::unique('users', 'email')->ignore($guru->user_id),
            ],
            'password' => 'nullable|string|min:6',
            'is_active' => 'required|boolean',
        ]);

        DB::transaction(function () use ($request, $guru) {

            $guru->update([
                'nip' => $request->nip,
                'nama_lengkap' => $request->nama_lengkap,
                'jenis_kelamin' => $request->jenis_kelamin,
                'telepon' => $request->telepon,
                'alamat' => $request->alamat,
            ]);

            $user = $guru->user;

            $user->name = $request->nama_lengkap;
            $user->email = $request->email;
            $user->is_active = $request->is_active;

            if ($request->filled('password')) {
                $user->password = $request->password;
            }

            $user->save();
        });

        return redirect()
            ->route('admin.master-data.guru.index')
            ->with('success', 'Data guru berhasil diperbarui.');
    }

    public function destroy($id)
    {
        $guru = Guru::with('user')->findOrFail($id);

        DB::transaction(function () use ($guru) {

            $user = $guru->user;

            $guru->delete();

            if ($user) {
                $user->delete();
            }
        });

        return redirect()
            ->route('admin.master-data.guru.index')
            ->with('success', 'Data guru berhasil dihapus.');
    }
}
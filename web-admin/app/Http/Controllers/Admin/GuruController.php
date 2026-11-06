<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Guru;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class GuruController extends Controller
{
    public function index()
    {
        $guru = Guru::with('user')->paginate(20);
        return view('admin.guru.index', compact('guru'));
    }

    public function create()
    {
        return view('admin.guru.create');
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'email' => 'required|email|unique:users,email',
            'password' => 'required|min:6',
            'nip' => 'required|unique:guru,nip',
            'nama_lengkap' => 'required',
            'jenis_kelamin' => 'required|in:L,P',
            'telepon' => 'nullable',
            'alamat' => 'nullable',
        ]);

        // Create user
        $user = User::create([
            'email' => $validated['email'],
            'password' => Hash::make($validated['password']),
            'role' => 'guru',
        ]);

        // Create guru
        Guru::create([
            'user_id' => $user->id,
            'nip' => $validated['nip'],
            'nama_lengkap' => $validated['nama_lengkap'],
            'jenis_kelamin' => $validated['jenis_kelamin'],
            'telepon' => $validated['telepon'],
            'alamat' => $validated['alamat'],
        ]);

        return redirect()->route('admin.guru.index')
            ->with('success', 'Data guru berhasil ditambahkan');
    }

    public function edit($id)
    {
        $guru = Guru::with('user')->findOrFail($id);
        return view('admin.guru.edit', compact('guru'));
    }

    public function update(Request $request, $id)
    {
        $guru = Guru::findOrFail($id);
        
        $validated = $request->validate([
            'email' => 'required|email|unique:users,email,' . $guru->user_id,
            'nip' => 'required|unique:guru,nip,' . $id,
            'nama_lengkap' => 'required',
            'jenis_kelamin' => 'required|in:L,P',
            'telepon' => 'nullable',
            'alamat' => 'nullable',
        ]);

        // Update user
        $guru->user->update([
            'email' => $validated['email'],
        ]);

        if ($request->filled('password')) {
            $guru->user->update([
                'password' => Hash::make($request->password),
            ]);
        }

        // Update guru
        $guru->update([
            'nip' => $validated['nip'],
            'nama_lengkap' => $validated['nama_lengkap'],
            'jenis_kelamin' => $validated['jenis_kelamin'],
            'telepon' => $validated['telepon'],
            'alamat' => $validated['alamat'],
        ]);

        return redirect()->route('admin.guru.index')
            ->with('success', 'Data guru berhasil diupdate');
    }

    public function destroy($id)
    {
        $guru = Guru::findOrFail($id);
        $user = $guru->user;
        
        $guru->delete();
        $user->delete();

        return redirect()->route('admin.guru.index')
            ->with('success', 'Data guru berhasil dihapus');
    }
}

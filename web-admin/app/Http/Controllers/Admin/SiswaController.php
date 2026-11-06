<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Siswa;
use App\Models\User;
use App\Models\Kelas;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class SiswaController extends Controller
{
    public function index()
    {
        $siswa = Siswa::with(['user', 'kelas'])->paginate(20);
        return view('admin.siswa.index', compact('siswa'));
    }

    public function create()
    {
        $kelas = Kelas::all();
        return view('admin.siswa.create', compact('kelas'));
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'email' => 'required|email|unique:users,email',
            'password' => 'required|min:6',
            'nis' => 'required|unique:siswa,nis',
            'nama_lengkap' => 'required',
            'jenis_kelamin' => 'required|in:L,P',
            'kelas_id' => 'required|exists:kelas,id',
            'tanggal_lahir' => 'nullable|date',
            'telepon' => 'nullable',
            'alamat' => 'nullable',
        ]);

        $user = User::create([
            'email' => $validated['email'],
            'password' => Hash::make($validated['password']),
            'role' => 'siswa',
        ]);

        Siswa::create([
            'user_id' => $user->id,
            'nis' => $validated['nis'],
            'nama_lengkap' => $validated['nama_lengkap'],
            'jenis_kelamin' => $validated['jenis_kelamin'],
            'kelas_id' => $validated['kelas_id'],
            'tanggal_lahir' => $validated['tanggal_lahir'],
            'telepon' => $validated['telepon'],
            'alamat' => $validated['alamat'],
        ]);

        return redirect()->route('admin.siswa.index')
            ->with('success', 'Data siswa berhasil ditambahkan');
    }

    public function edit($id)
    {
        $siswa = Siswa::with('user')->findOrFail($id);
        $kelas = Kelas::all();
        return view('admin.siswa.edit', compact('siswa', 'kelas'));
    }

    public function update(Request $request, $id)
    {
        $siswa = Siswa::findOrFail($id);
        
        $validated = $request->validate([
            'email' => 'required|email|unique:users,email,' . $siswa->user_id,
            'nis' => 'required|unique:siswa,nis,' . $id,
            'nama_lengkap' => 'required',
            'jenis_kelamin' => 'required|in:L,P',
            'kelas_id' => 'required|exists:kelas,id',
            'tanggal_lahir' => 'nullable|date',
            'telepon' => 'nullable',
            'alamat' => 'nullable',
        ]);

        $siswa->user->update(['email' => $validated['email']]);
        
        if ($request->filled('password')) {
            $siswa->user->update(['password' => Hash::make($request->password)]);
        }

        $siswa->update([
            'nis' => $validated['nis'],
            'nama_lengkap' => $validated['nama_lengkap'],
            'jenis_kelamin' => $validated['jenis_kelamin'],
            'kelas_id' => $validated['kelas_id'],
            'tanggal_lahir' => $validated['tanggal_lahir'],
            'telepon' => $validated['telepon'],
            'alamat' => $validated['alamat'],
        ]);

        return redirect()->route('admin.siswa.index')
            ->with('success', 'Data siswa berhasil diupdate');
    }

    public function destroy($id)
    {
        $siswa = Siswa::findOrFail($id);
        $user = $siswa->user;
        
        $siswa->delete();
        $user->delete();

        return redirect()->route('admin.siswa.index')
            ->with('success', 'Data siswa berhasil dihapus');
    }
}

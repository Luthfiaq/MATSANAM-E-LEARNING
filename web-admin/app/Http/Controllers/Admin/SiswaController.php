<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Siswa;
use App\Models\User;
use App\Models\Kelas;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;

class SiswaController extends Controller
{
    public function index()
    {
        $siswa = Siswa::with(['user', 'kelas'])
            ->orderBy('nama_lengkap')
            ->get();

        return view('admin.master-data.siswa.index', compact('siswa'));
    }

    public function create()
    {
        $kelas = Kelas::orderBy('nama_kelas')->get();

        return view('admin.master-data.siswa.create', compact('kelas'));
    }

    public function store(Request $request)
    {
        $request->validate([
            'nis' => 'required|string|max:50|unique:siswa,nis',
            'nisn' => 'required|string|max:50|unique:siswa,nisn',
            'nama_lengkap' => 'required|string|max:150',
            'jenis_kelamin' => 'required|in:L,P',
            'tanggal_lahir' => 'required|date',
            'tempat_lahir' => 'required|string|max:100',
            'kelas_id' => 'nullable|exists:kelas,id',
            'nama_wali' => 'nullable|string|max:150',
            'telepon_wali' => 'nullable|string|max:30',
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
                'role' => 'siswa',
                'is_active' => $request->is_active,
            ]);

            Siswa::create([
                'user_id' => $user->id,
                'nis' => $request->nis,
                'nisn' => $request->nisn,
                'nama_lengkap' => $request->nama_lengkap,
                'jenis_kelamin' => $request->jenis_kelamin,
                'tanggal_lahir' => $request->tanggal_lahir,
                'tempat_lahir' => $request->tempat_lahir,
                'kelas_id' => $request->kelas_id,
                'nama_wali' => $request->nama_wali,
                'telepon_wali' => $request->telepon_wali,
                'alamat' => $request->alamat,
            ]);
        });

        return redirect()
            ->route('admin.master-data.siswa.index')
            ->with('success', 'Data siswa berhasil ditambahkan.');
    }

    public function edit($id)
    {
        $siswa = Siswa::with('user')->findOrFail($id);
        $kelas = Kelas::orderBy('nama_kelas')->get();

        return view(
            'admin.master-data.siswa.edit',
            compact('siswa', 'kelas')
        );
    }

    public function update(Request $request, $id)
    {
        $siswa = Siswa::with('user')->findOrFail($id);

        $request->validate([
            'nis' => [
                'required',
                'string',
                'max:50',
                Rule::unique('siswa', 'nis')->ignore($siswa->id),
            ],
            'nisn' => [
                'required',
                'string',
                'max:50',
                Rule::unique('siswa', 'nisn')->ignore($siswa->id),
            ],
            'nama_lengkap' => 'required|string|max:150',
            'jenis_kelamin' => 'required|in:L,P',
            'tanggal_lahir' => 'required|date',
            'tempat_lahir' => 'required|string|max:100',
            'kelas_id' => 'nullable|exists:kelas,id',
            'nama_wali' => 'nullable|string|max:150',
            'telepon_wali' => 'nullable|string|max:30',
            'alamat' => 'nullable|string',
            'email' => [
                'required',
                'email',
                'max:150',
                Rule::unique('users', 'email')->ignore($siswa->user_id),
            ],
            'password' => 'nullable|string|min:6',
            'is_active' => 'required|boolean',
        ]);

        DB::transaction(function () use ($request, $siswa) {

            $siswa->update([
                'nis' => $request->nis,
                'nisn' => $request->nisn,
                'nama_lengkap' => $request->nama_lengkap,
                'jenis_kelamin' => $request->jenis_kelamin,
                'tanggal_lahir' => $request->tanggal_lahir,
                'tempat_lahir' => $request->tempat_lahir,
                'kelas_id' => $request->kelas_id,
                'nama_wali' => $request->nama_wali,
                'telepon_wali' => $request->telepon_wali,
                'alamat' => $request->alamat,
            ]);

            $user = $siswa->user;

            $user->name = $request->nama_lengkap;
            $user->email = $request->email;
            $user->is_active = $request->is_active;

            if ($request->filled('password')) {
                $user->password = $request->password;
            }

            $user->save();
        });

        return redirect()
            ->route('admin.master-data.siswa.index')
            ->with('success', 'Data siswa berhasil diperbarui.');
    }

    public function destroy($id)
    {
        $siswa = Siswa::with('user')->findOrFail($id);

        DB::transaction(function () use ($siswa) {

            $user = $siswa->user;

            $siswa->delete();

            if ($user) {
                $user->delete();
            }
        });

        return redirect()
            ->route('admin.master-data.siswa.index')
            ->with('success', 'Data siswa berhasil dihapus.');
    }
}
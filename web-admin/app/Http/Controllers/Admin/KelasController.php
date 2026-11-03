<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Kelas;
use App\Models\Guru;
use Illuminate\Http\Request;

class KelasController extends Controller
{
    public function index()
    {
        $kelas = Kelas::with('waliKelas')->get();

        return view('admin.master-data.kelas.index', compact('kelas'));
    }

    public function create()
    {
        $guru = Guru::orderBy('nama_lengkap')->get();

        return view('admin.master-data.kelas.create', compact('guru'));
    }

    public function store(Request $request)
    {
        $request->validate([
            'nama_kelas' => 'required|string|max:100',
            'tingkat' => 'required|string|max:50',
            'wali_kelas_id' => 'nullable|exists:guru,id',
            'kapasitas' => 'required|integer|min:1',
        ]);

        Kelas::create([
            'nama_kelas' => $request->nama_kelas,
            'tingkat' => $request->tingkat,
            'wali_kelas_id' => $request->wali_kelas_id,
            'kapasitas' => $request->kapasitas,
        ]);

        return redirect()
            ->route('admin.master-data.kelas.index')
            ->with('success', 'Data kelas berhasil ditambahkan.');
    }

    public function edit($id)
    {
        $kelas = Kelas::findOrFail($id);

        $guru = Guru::orderBy('nama_lengkap')->get();

        return view(
            'admin.master-data.kelas.edit',
            compact('kelas', 'guru')
        );
    }

    public function update(Request $request, $id)
    {
        $request->validate([
            'nama_kelas' => 'required|string|max:100',
            'tingkat' => 'required|string|max:50',
            'wali_kelas_id' => 'nullable|exists:guru,id',
            'kapasitas' => 'required|integer|min:1',
        ]);

        $kelas = Kelas::findOrFail($id);

        $kelas->update([
            'nama_kelas' => $request->nama_kelas,
            'tingkat' => $request->tingkat,
            'wali_kelas_id' => $request->wali_kelas_id,
            'kapasitas' => $request->kapasitas,
        ]);

        return redirect()
            ->route('admin.master-data.kelas.index')
            ->with('success', 'Data kelas berhasil diperbarui.');
    }

    public function destroy($id)
    {
        $kelas = Kelas::findOrFail($id);

        $kelas->delete();

        return redirect()
            ->route('admin.master-data.kelas.index')
            ->with('success', 'Data kelas berhasil dihapus.');
    }
}
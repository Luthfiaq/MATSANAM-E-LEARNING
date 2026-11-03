<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\MataPelajaran;
use Illuminate\Http\Request;

class MataPelajaranController extends Controller
{
    /**
     * Menampilkan semua data mata pelajaran
     */
    public function index()
    {
        $mataPelajaran = MataPelajaran::orderBy('kode')->get();

        return view(
            'admin.master-data.mata-pelajaran.index',
            compact('mataPelajaran')
        );
    }

    /**
     * Menampilkan form tambah mata pelajaran
     */
    public function create()
    {
        return view('admin.master-data.mata-pelajaran.create');
    }

    /**
     * Menyimpan mata pelajaran baru
     */
    public function store(Request $request)
    {
        $request->validate([
            'kode' => 'required|string|max:50|unique:mata_pelajaran,kode',
            'nama' => 'required|string|max:150',
            'deskripsi' => 'nullable|string',
            'kkm' => 'required|integer|min:0|max:100',
        ]);

        MataPelajaran::create([
            'kode' => $request->kode,
            'nama' => $request->nama,
            'deskripsi' => $request->deskripsi,
            'kkm' => $request->kkm,
        ]);

        return redirect()
            ->route('admin.master-data.mata-pelajaran.index')
            ->with('success', 'Data mata pelajaran berhasil ditambahkan.');
    }

    /**
     * Menampilkan form edit
     */
    public function edit($id)
    {
        $mataPelajaran = MataPelajaran::findOrFail($id);

        return view(
            'admin.master-data.mata-pelajaran.edit',
            compact('mataPelajaran')
        );
    }

    /**
     * Memperbarui mata pelajaran
     */
    public function update(Request $request, $id)
    {
        $request->validate([
            'kode' => 'required|string|max:50|unique:mata_pelajaran,kode,' . $id,
            'nama' => 'required|string|max:150',
            'deskripsi' => 'nullable|string',
            'kkm' => 'required|integer|min:0|max:100',
        ]);

        $mataPelajaran = MataPelajaran::findOrFail($id);

        $mataPelajaran->update([
            'kode' => $request->kode,
            'nama' => $request->nama,
            'deskripsi' => $request->deskripsi,
            'kkm' => $request->kkm,
        ]);

        return redirect()
            ->route('admin.master-data.mata-pelajaran.index')
            ->with('success', 'Data mata pelajaran berhasil diperbarui.');
    }

    /**
     * Menghapus mata pelajaran
     */
    public function destroy($id)
    {
        $mataPelajaran = MataPelajaran::findOrFail($id);

        $mataPelajaran->delete();

        return redirect()
            ->route('admin.master-data.mata-pelajaran.index')
            ->with('success', 'Data mata pelajaran berhasil dihapus.');
    }
}
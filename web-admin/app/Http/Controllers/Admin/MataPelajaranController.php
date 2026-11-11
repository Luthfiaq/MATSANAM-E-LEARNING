<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\JadwalPelajaran;
use App\Models\MataPelajaran;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Illuminate\View\View;

class MataPelajaranController extends Controller
{
    public function index(): View
    {
        $mataPelajaran = MataPelajaran::query()
            ->withCount(['jadwalPelajaran' => fn ($query) => $query])
            ->orderBy('kode')
            ->paginate(20);
        return view('admin.master-data.mata-pelajaran.index', compact('mataPelajaran'));
    }

    public function create(): View
    {
        return view('admin.master-data.mata-pelajaran.create');
    }

    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'kode' => ['required', 'string', 'max:10', 'unique:mata_pelajaran,kode'],
            'nama' => ['required', 'string', 'max:150'],
            'deskripsi' => ['nullable', 'string', 'max:2000'],
            'kkm' => ['required', 'integer', 'min:0', 'max:100'],
        ]);
        MataPelajaran::create($validated);
        return redirect()->route('admin.master-data.mata-pelajaran.index')->with('success', 'Mata pelajaran berhasil ditambahkan.');
    }

    public function edit(int $id): View
    {
        $mataPelajaran = MataPelajaran::findOrFail($id);
        return view('admin.master-data.mata-pelajaran.edit', compact('mataPelajaran'));
    }

    public function update(Request $request, int $id): RedirectResponse
    {
        $mataPelajaran = MataPelajaran::findOrFail($id);
        $validated = $request->validate([
            'kode' => ['required', 'string', 'max:10', Rule::unique('mata_pelajaran', 'kode')->ignore($mataPelajaran->id)],
            'nama' => ['required', 'string', 'max:150'],
            'deskripsi' => ['nullable', 'string', 'max:2000'],
            'kkm' => ['required', 'integer', 'min:0', 'max:100'],
        ]);
        $mataPelajaran->update($validated);
        return redirect()->route('admin.master-data.mata-pelajaran.index')->with('success', 'Mata pelajaran berhasil diperbarui.');
    }

    public function destroy(int $id): RedirectResponse
    {
        $mataPelajaran = MataPelajaran::findOrFail($id);
        if (JadwalPelajaran::where('mapel_id', $mataPelajaran->id)->exists()) {
            return redirect()->route('admin.master-data.mata-pelajaran.index')
                ->with('error', 'Mata pelajaran tidak dapat dihapus karena masih digunakan pada jadwal mengajar.');
        }
        $mataPelajaran->delete();
        return redirect()->route('admin.master-data.mata-pelajaran.index')->with('success', 'Mata pelajaran berhasil dihapus.');
    }
}

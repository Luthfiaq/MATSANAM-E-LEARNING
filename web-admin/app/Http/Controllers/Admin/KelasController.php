<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Guru;
use App\Models\Kelas;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Illuminate\View\View;

class KelasController extends Controller
{
    public function index(): View
    {
        $kelas = Kelas::with('waliKelas')
            ->withCount(['siswa', 'jadwalPelajaran'])
            ->orderBy('tingkat')
            ->orderBy('nama_kelas')
            ->paginate(20);

        return view('admin.master-data.kelas.index', compact('kelas'));
    }

    public function create(): View
    {
        $guru = Guru::whereHas('user')->orderBy('nama_lengkap')->get();
        return view('admin.master-data.kelas.create', compact('guru'));
    }

    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'nama_kelas' => ['required', 'string', 'max:50', 'unique:kelas,nama_kelas'],
            'tingkat' => ['required', 'integer', Rule::in([7, 8, 9])],
            'wali_kelas_id' => ['nullable', 'exists:guru,id'],
            'kapasitas' => ['required', 'integer', 'min:1', 'max:60'],
        ]);

        Kelas::create($validated);
        return redirect()->route('admin.master-data.kelas.index')->with('success', 'Data kelas berhasil ditambahkan.');
    }

    public function edit(int $id): View
    {
        $kelas = Kelas::findOrFail($id);
        $guru = Guru::whereHas('user')->orWhereKey($kelas->wali_kelas_id)->orderBy('nama_lengkap')->get();
        return view('admin.master-data.kelas.edit', compact('kelas', 'guru'));
    }

    public function update(Request $request, int $id): RedirectResponse
    {
        $kelas = Kelas::findOrFail($id);
        $validated = $request->validate([
            'nama_kelas' => ['required', 'string', 'max:50', Rule::unique('kelas', 'nama_kelas')->ignore($kelas->id)],
            'tingkat' => ['required', 'integer', Rule::in([7, 8, 9])],
            'wali_kelas_id' => ['nullable', 'exists:guru,id'],
            'kapasitas' => ['required', 'integer', 'min:1', 'max:60'],
        ]);

        $kelas->update($validated);
        return redirect()->route('admin.master-data.kelas.index')->with('success', 'Data kelas berhasil diperbarui.');
    }

    public function destroy(int $id): RedirectResponse
    {
        $kelas = Kelas::findOrFail($id);
        if ($kelas->siswa()->exists() || $kelas->jadwalPelajaran()->exists()) {
            return redirect()->route('admin.master-data.kelas.index')
                ->with('error', 'Kelas tidak dapat dihapus karena masih memiliki siswa atau jadwal pelajaran. Pindahkan data terkait terlebih dahulu.');
        }

        $kelas->delete();
        return redirect()->route('admin.master-data.kelas.index')->with('success', 'Data kelas berhasil dihapus.');
    }
}

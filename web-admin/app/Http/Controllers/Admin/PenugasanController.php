<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Guru;
use App\Models\Kelas;
use App\Models\MataPelajaran;
use App\Models\PeriodeAkademik;
use App\Models\JadwalPelajaran;
use Illuminate\Http\Request;

class PenugasanController extends Controller
{
    public function index()
    {
        $jadwal = JadwalPelajaran::with(['guru', 'kelas', 'mataPelajaran', 'periode'])
            ->paginate(15);

        return view('admin.penugasan.index', compact('jadwal'));
    }

    public function create()
    {
        $guru = Guru::with('user')->get();
        $kelas = Kelas::all();
        $mataPelajaran = MataPelajaran::all();
        $periode = PeriodeAkademik::where('is_active', true)->get();

        return view('admin.penugasan.create', compact(
            'guru',
            'kelas',
            'mataPelajaran',
            'periode'
        ));
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'periode_id' => 'required|exists:periode_akademik,id',
            'kelas_id' => 'required|exists:kelas,id',
            'mapel_id' => 'required|exists:mata_pelajaran,id',
            'guru_id' => 'required|exists:guru,id',
            'hari' => 'required|in:Senin,Selasa,Rabu,Kamis,Jumat,Sabtu',
            'jam_mulai' => 'required|date_format:H:i',
            'jam_selesai' => 'required|date_format:H:i|after:jam_mulai',
            'ruangan' => 'nullable|string|max:20',
        ]);

        JadwalPelajaran::create($validated);

        return redirect()->route('admin.penugasan.index')
            ->with('success', 'Penugasan berhasil ditambahkan');
    }

    public function edit($id)
    {
        $jadwal = JadwalPelajaran::findOrFail($id);
        $guru = Guru::with('user')->get();
        $kelas = Kelas::all();
        $mataPelajaran = MataPelajaran::all();
        $periode = PeriodeAkademik::where('is_active', true)->get();

        return view('admin.penugasan.edit', compact(
            'jadwal',
            'guru',
            'kelas',
            'mataPelajaran',
            'periode'
        ));
    }

    public function update(Request $request, $id)
    {
        $validated = $request->validate([
            'periode_id' => 'required|exists:periode_akademik,id',
            'kelas_id' => 'required|exists:kelas,id',
            'mapel_id' => 'required|exists:mata_pelajaran,id',
            'guru_id' => 'required|exists:guru,id',
            'hari' => 'required|in:Senin,Selasa,Rabu,Kamis,Jumat,Sabtu',
            'jam_mulai' => 'required|date_format:H:i',
            'jam_selesai' => 'required|date_format:H:i|after:jam_mulai',
            'ruangan' => 'nullable|string|max:20',
        ]);

        $jadwal = JadwalPelajaran::findOrFail($id);
        $jadwal->update($validated);

        return redirect()->route('admin.penugasan.index')
            ->with('success', 'Penugasan berhasil diperbarui');
    }

    public function destroy($id)
    {
        $jadwal = JadwalPelajaran::findOrFail($id);
        $jadwal->delete();

        return redirect()->route('admin.penugasan.index')
            ->with('success', 'Penugasan berhasil dihapus');
    }
}

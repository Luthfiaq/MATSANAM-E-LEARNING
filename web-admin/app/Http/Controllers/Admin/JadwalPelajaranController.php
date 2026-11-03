<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\JadwalPelajaran;
use App\Models\PeriodeAkademik;
use App\Models\Kelas;
use App\Models\MataPelajaran;
use App\Models\Guru;
use Illuminate\Http\Request;

class JadwalPelajaranController extends Controller
{
    public function index()
    {
        $jadwal = JadwalPelajaran::with([
            'periode',
            'kelas',
            'mataPelajaran',
            'guru'
        ])
        ->orderByRaw("
            CASE hari
                WHEN 'Senin' THEN 1
                WHEN 'Selasa' THEN 2
                WHEN 'Rabu' THEN 3
                WHEN 'Kamis' THEN 4
                WHEN 'Jumat' THEN 5
                WHEN 'Sabtu' THEN 6
                ELSE 7
            END
        ")
        ->orderBy('jam_mulai')
        ->get();

        return view(
            'admin.master-data.jadwal-pelajaran.index',
            compact('jadwal')
        );
    }

    public function create()
    {
        $periode = PeriodeAkademik::orderByDesc('tanggal_mulai')->get();
        $kelas = Kelas::orderBy('nama_kelas')->get();
        $mataPelajaran = MataPelajaran::orderBy('nama')->get();
        $guru = Guru::orderBy('nama_lengkap')->get();

        return view(
            'admin.master-data.jadwal-pelajaran.create',
            compact(
                'periode',
                'kelas',
                'mataPelajaran',
                'guru'
            )
        );
    }

    public function store(Request $request)
    {
        $request->validate([
            'periode_id' => 'required|exists:periode_akademik,id',
            'kelas_id' => 'required|exists:kelas,id',
            'mapel_id' => 'required|exists:mata_pelajaran,id',
            'guru_id' => 'required|exists:guru,id',
            'hari' => 'required|in:Senin,Selasa,Rabu,Kamis,Jumat,Sabtu',
            'jam_mulai' => 'required|date_format:H:i',
            'jam_selesai' => 'required|date_format:H:i|after:jam_mulai',
            'ruangan' => 'nullable|string|max:100',
        ]);

        JadwalPelajaran::create([
            'periode_id' => $request->periode_id,
            'kelas_id' => $request->kelas_id,
            'mapel_id' => $request->mapel_id,
            'guru_id' => $request->guru_id,
            'hari' => $request->hari,
            'jam_mulai' => $request->jam_mulai,
            'jam_selesai' => $request->jam_selesai,
            'ruangan' => $request->ruangan,
        ]);

        return redirect()
            ->route('admin.master-data.jadwal-pelajaran.index')
            ->with('success', 'Jadwal pelajaran berhasil ditambahkan.');
    }

    public function edit($id)
    {
        $jadwal = JadwalPelajaran::findOrFail($id);

        $periode = PeriodeAkademik::orderByDesc('tanggal_mulai')->get();
        $kelas = Kelas::orderBy('nama_kelas')->get();
        $mataPelajaran = MataPelajaran::orderBy('nama')->get();
        $guru = Guru::orderBy('nama_lengkap')->get();

        return view(
            'admin.master-data.jadwal-pelajaran.edit',
            compact(
                'jadwal',
                'periode',
                'kelas',
                'mataPelajaran',
                'guru'
            )
        );
    }

    public function update(Request $request, $id)
    {
        $request->validate([
            'periode_id' => 'required|exists:periode_akademik,id',
            'kelas_id' => 'required|exists:kelas,id',
            'mapel_id' => 'required|exists:mata_pelajaran,id',
            'guru_id' => 'required|exists:guru,id',
            'hari' => 'required|in:Senin,Selasa,Rabu,Kamis,Jumat,Sabtu',
            'jam_mulai' => 'required|date_format:H:i',
            'jam_selesai' => 'required|date_format:H:i|after:jam_mulai',
            'ruangan' => 'nullable|string|max:100',
        ]);

        $jadwal = JadwalPelajaran::findOrFail($id);

        $jadwal->update([
            'periode_id' => $request->periode_id,
            'kelas_id' => $request->kelas_id,
            'mapel_id' => $request->mapel_id,
            'guru_id' => $request->guru_id,
            'hari' => $request->hari,
            'jam_mulai' => $request->jam_mulai,
            'jam_selesai' => $request->jam_selesai,
            'ruangan' => $request->ruangan,
        ]);

        return redirect()
            ->route('admin.master-data.jadwal-pelajaran.index')
            ->with('success', 'Jadwal pelajaran berhasil diperbarui.');
    }

    public function destroy($id)
    {
        $jadwal = JadwalPelajaran::findOrFail($id);

        $jadwal->delete();

        return redirect()
            ->route('admin.master-data.jadwal-pelajaran.index')
            ->with('success', 'Jadwal pelajaran berhasil dihapus.');
    }
}
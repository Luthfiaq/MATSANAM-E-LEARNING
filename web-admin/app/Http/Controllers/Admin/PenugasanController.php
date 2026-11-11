<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Guru;
use App\Models\JadwalPelajaran;
use App\Models\Kelas;
use App\Models\MataPelajaran;
use App\Models\PeriodeAkademik;
use App\Models\AbsensiHarian;
use App\Models\Penugasan;
use App\Support\ScheduleConflictValidator;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class PenugasanController extends Controller
{
    public function index(): View
    {
        $jadwal = JadwalPelajaran::with(['guru', 'kelas', 'mataPelajaran', 'periode'])
            ->orderBy('hari')->orderBy('jam_mulai')->paginate(15);
        return view('admin.penugasan.index', compact('jadwal'));
    }

    public function create(): View
    {
        $guru = Guru::whereHas('user')->with('user')->orderBy('nama_lengkap')->get();
        $kelas = Kelas::orderBy('tingkat')->orderBy('nama_kelas')->get();
        $mataPelajaran = MataPelajaran::orderBy('nama')->get();
        $periode = PeriodeAkademik::where('is_active', true)->orderByDesc('tanggal_mulai')->get();
        return view('admin.penugasan.create', compact('guru', 'kelas', 'mataPelajaran', 'periode'));
    }

    public function store(Request $request): RedirectResponse
    {
        $validated = $this->validateSchedule($request);
        ScheduleConflictValidator::ensureAvailable($validated);
        JadwalPelajaran::create($validated);
        return redirect()->route('admin.penugasan.index')->with('success', 'Penugasan mengajar berhasil ditambahkan.');
    }

    public function edit(int $id): View
    {
        $jadwal = JadwalPelajaran::findOrFail($id);
        $guru = Guru::whereHas('user')->orWhereKey($jadwal->guru_id)->with('user')->orderBy('nama_lengkap')->get();
        $kelas = Kelas::orderBy('tingkat')->orderBy('nama_kelas')->get();
        $mataPelajaran = MataPelajaran::orderBy('nama')->get();
        $periode = PeriodeAkademik::orderByDesc('tanggal_mulai')->get();

        return view('admin.penugasan.edit', compact('jadwal', 'guru', 'kelas', 'mataPelajaran', 'periode'));
    }

    public function update(Request $request, int $id): RedirectResponse
    {
        $jadwal = JadwalPelajaran::findOrFail($id);
        $validated = $this->validateSchedule($request);
        ScheduleConflictValidator::ensureAvailable($validated, $jadwal->id);
        $jadwal->update($validated);
        return redirect()->route('admin.penugasan.index')->with('success', 'Penugasan mengajar berhasil diperbarui.');
    }

    public function destroy(int $id): RedirectResponse
    {
        $jadwal = JadwalPelajaran::findOrFail($id);
        if (AbsensiHarian::where('jadwal_id', $jadwal->id)->exists() || Penugasan::where('jadwal_id', $jadwal->id)->exists()) {
            return redirect()->route('admin.penugasan.index')
                ->with('error', 'Penugasan tidak dapat dihapus karena sudah memiliki data absensi atau tugas.');
        }
        $jadwal->delete();
        return redirect()->route('admin.penugasan.index')->with('success', 'Penugasan berhasil dihapus.');
    }

    private function validateSchedule(Request $request): array
    {
        return $request->validate([
            'periode_id' => ['required', 'exists:periode_akademik,id'],
            'kelas_id' => ['required', 'exists:kelas,id'],
            'mapel_id' => ['required', 'exists:mata_pelajaran,id'],
            'guru_id' => ['required', 'exists:guru,id'],
            'hari' => ['required', 'in:Senin,Selasa,Rabu,Kamis,Jumat,Sabtu'],
            'jam_mulai' => ['required', 'date_format:H:i'],
            'jam_selesai' => ['required', 'date_format:H:i', 'after:jam_mulai'],
            'ruangan' => ['nullable', 'string', 'max:20'],
        ]);
    }
}

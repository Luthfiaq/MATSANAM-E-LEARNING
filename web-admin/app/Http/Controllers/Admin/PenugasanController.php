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
    public function index(Request $request): View
    {
        $filters = $request->validate([
            'q' => ['nullable', 'string', 'max:100'],
            'kelas' => ['nullable', 'integer', 'exists:kelas,id'],
        ]);

        $query = JadwalPelajaran::query()
            ->with(['guru', 'kelas', 'mataPelajaran', 'periode']);

        if (! empty($filters['q'])) {
            $keyword = trim($filters['q']);
            $query->where(function ($searchQuery) use ($keyword) {
                $searchQuery
                    ->whereHas('guru', function ($guruQuery) use ($keyword) {
                        $guruQuery->where('nama_lengkap', 'like', "%{$keyword}%")
                            ->orWhere('nip', 'like', "%{$keyword}%");
                    })
                    ->orWhereHas('kelas', function ($kelasQuery) use ($keyword) {
                        $kelasQuery->where('nama_kelas', 'like', "%{$keyword}%");
                    })
                    ->orWhereHas('mataPelajaran', function ($mapelQuery) use ($keyword) {
                        $mapelQuery->where('nama', 'like', "%{$keyword}%")
                            ->orWhere('kode', 'like', "%{$keyword}%");
                    })
                    ->orWhere('hari', 'like', "%{$keyword}%")
                    ->orWhere('ruangan', 'like', "%{$keyword}%");
            });
        }

        if (! empty($filters['kelas'])) {
            $query->where('kelas_id', $filters['kelas']);
        }

        $jadwal = $query
            ->orderBy('hari')
            ->orderBy('jam_mulai')
            ->paginate(15)
            ->withQueryString();

        $kelasList = Kelas::orderBy('tingkat')->orderBy('nama_kelas')->get();

        return view('admin.penugasan.index', compact('jadwal', 'kelasList', 'filters'));
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

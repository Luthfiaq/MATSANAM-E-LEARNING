<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Guru;
use App\Models\JadwalPelajaran;
use App\Models\Kelas;
use App\Models\MataPelajaran;
use App\Models\PeriodeAkademik;
use App\Support\ScheduleConflictValidator;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Illuminate\View\View;

class JadwalPelajaranController extends Controller
{
    /**
     * Jadwal resmi KBM MTsN 6 Nganjuk 2026/2027.
     */
    private const JADWAL_RESMI = [
        '07:15' => '07:55',
        '07:55' => '08:35',
        '08:35' => '09:15',
        '09:15' => '09:55',
        '10:30' => '11:10',
        '11:10' => '11:50',
        '11:50' => '12:30',
        '12:30' => '13:10',
    ];

    public function index(): View
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
            ->paginate(20);

        return view(
            'admin.master-data.jadwal-pelajaran.index',
            compact('jadwal')
        );
    }

    public function create(): View
    {
        $periode = PeriodeAkademik::orderByDesc('tanggal_mulai')->get();

        $kelas = Kelas::orderBy('tingkat')
            ->orderBy('nama_kelas')
            ->get();

        $mataPelajaran = MataPelajaran::orderBy('nama')->get();

        $guru = Guru::whereHas('user')
            ->orderBy('nama_lengkap')
            ->get();

        return view(
            'admin.master-data.jadwal-pelajaran.create',
            compact('periode', 'kelas', 'mataPelajaran', 'guru')
        );
    }

    public function store(Request $request): RedirectResponse
    {
        $validated = $this->validateSchedule($request);

        ScheduleConflictValidator::ensureAvailable($validated);

        JadwalPelajaran::create($validated);

        return redirect()
            ->route('admin.master-data.jadwal-pelajaran.index')
            ->with('success', 'Jadwal pelajaran berhasil ditambahkan.');
    }

    public function edit(int $id): View
    {
        $jadwal = JadwalPelajaran::findOrFail($id);

        $periode = PeriodeAkademik::orderByDesc('tanggal_mulai')->get();

        $kelas = Kelas::orderBy('tingkat')
            ->orderBy('nama_kelas')
            ->get();

        $mataPelajaran = MataPelajaran::orderBy('nama')->get();

        $guru = Guru::whereHas('user')
            ->orWhereKey($jadwal->guru_id)
            ->orderBy('nama_lengkap')
            ->get();

        return view(
            'admin.master-data.jadwal-pelajaran.edit',
            compact('jadwal', 'periode', 'kelas', 'mataPelajaran', 'guru')
        );
    }

    public function update(Request $request, int $id): RedirectResponse
    {
        $jadwal = JadwalPelajaran::findOrFail($id);

        $validated = $this->validateSchedule($request);

        ScheduleConflictValidator::ensureAvailable(
            $validated,
            $jadwal->id
        );

        $jadwal->update($validated);

        return redirect()
            ->route('admin.master-data.jadwal-pelajaran.index')
            ->with('success', 'Jadwal pelajaran berhasil diperbarui.');
    }

    public function destroy(int $id): RedirectResponse
    {
        $jadwal = JadwalPelajaran::findOrFail($id);

        $hasAttendance = \App\Models\AbsensiHarian::where(
            'jadwal_id',
            $jadwal->id
        )->exists();

        $hasAssignments = \App\Models\Penugasan::where(
            'jadwal_id',
            $jadwal->id
        )->exists();

        if ($hasAttendance || $hasAssignments) {
            return redirect()
                ->route('admin.master-data.jadwal-pelajaran.index')
                ->with(
                    'error',
                    'Jadwal tidak dapat dihapus karena sudah memiliki data absensi atau tugas. Pertahankan jadwal agar riwayat akademik tidak hilang.'
                );
        }

        $jadwal->delete();

        return redirect()
            ->route('admin.master-data.jadwal-pelajaran.index')
            ->with('success', 'Jadwal pelajaran berhasil dihapus.');
    }

    /**
     * Validasi data jadwal berdasarkan waktu resmi sekolah.
     */
    private function validateSchedule(Request $request): array
    {
        return $request->validate([
            'periode_id' => [
                'required',
                'exists:periode_akademik,id'
            ],

            'kelas_id' => [
                'required',
                'exists:kelas,id'
            ],

            'mapel_id' => [
                'required',
                'exists:mata_pelajaran,id'
            ],

            'guru_id' => [
                'required',
                'exists:guru,id'
            ],

            'hari' => [
                'required',
                'in:Senin,Selasa,Rabu,Kamis,Jumat,Sabtu'
            ],

            'jam_mulai' => [
                'required',
                'date_format:H:i',
                Rule::in(array_keys(self::JADWAL_RESMI)),
            ],

            'jam_selesai' => [
                'required',
                'date_format:H:i',
                function ($attribute, $value, $fail) use ($request) {
                    $jamMulai = $request->input('jam_mulai');

                    if (
                        !isset(self::JADWAL_RESMI[$jamMulai]) ||
                        self::JADWAL_RESMI[$jamMulai] !== $value
                    ) {
                        $fail(
                            'Jam mulai dan jam selesai harus sesuai dengan jadwal resmi sekolah.'
                        );
                    }
                },
            ],

            'ruangan' => [
                'nullable',
                'string',
                'max:20'
            ],
        ]);
    }
}
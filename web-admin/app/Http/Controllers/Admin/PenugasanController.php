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
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;

class PenugasanController extends Controller
{
    /**
     * Slot jam pelajaran yang dipakai pada form penugasan guru.
     * Jam istirahat tidak dihitung sebagai jam pelajaran tersendiri.
     */
    private const JAM_PELAJARAN = [
        1 => ['mulai' => '07:15', 'selesai' => '07:55'],
        2 => ['mulai' => '07:55', 'selesai' => '08:35'],
        3 => ['mulai' => '08:35', 'selesai' => '09:15'],
        4 => ['mulai' => '09:15', 'selesai' => '09:55'],
        5 => ['mulai' => '10:30', 'selesai' => '11:10'],
        6 => ['mulai' => '11:10', 'selesai' => '11:50'],
        7 => ['mulai' => '11:50', 'selesai' => '12:30'],
        8 => ['mulai' => '12:30', 'selesai' => '13:10'],
    ];

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
        $jamPelajaran = self::JAM_PELAJARAN;

        return view('admin.penugasan.create', compact('guru', 'kelas', 'mataPelajaran', 'periode', 'jamPelajaran'));
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
        $jamPelajaran = self::JAM_PELAJARAN;
        $jamMulaiKe = $this->findSlotByTime($jadwal->jam_mulai, 'mulai');
        $jamSelesaiKe = $this->findSlotByTime($jadwal->jam_selesai, 'selesai');
        $legacyJamMulai = $jamMulaiKe === null ? substr((string) $jadwal->jam_mulai, 0, 5) : null;
        $legacyJamSelesai = $jamSelesaiKe === null ? substr((string) $jadwal->jam_selesai, 0, 5) : null;

        return view('admin.penugasan.edit', compact(
            'jadwal',
            'guru',
            'kelas',
            'mataPelajaran',
            'periode',
            'jamPelajaran',
            'jamMulaiKe',
            'jamSelesaiKe',
            'legacyJamMulai',
            'legacyJamSelesai'
        ));
    }

    public function update(Request $request, int $id): RedirectResponse
    {
        $jadwal = JadwalPelajaran::findOrFail($id);
        $validated = $this->validateSchedule($request, $jadwal);
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

    private function validateSchedule(Request $request, ?JadwalPelajaran $currentSchedule = null): array
    {
        $allowedSlots = array_map('strval', array_keys(self::JAM_PELAJARAN));
        $startOptions = $allowedSlots;
        $endOptions = $allowedSlots;

        // Data lama yang waktunya tidak pas dengan slot baku tetap bisa diedit
        // tanpa otomatis mengubah jamnya. Sentinel "legacy" hanya berlaku untuk
        // nilai yang sudah ada di record saat ini, bukan nilai bebas dari browser.
        if ($currentSchedule !== null) {
            if ($this->findSlotByTime($currentSchedule->jam_mulai, 'mulai') === null) {
                $startOptions[] = 'legacy';
            }
            if ($this->findSlotByTime($currentSchedule->jam_selesai, 'selesai') === null) {
                $endOptions[] = 'legacy';
            }
        }

        $validated = $request->validate([
            'periode_id' => ['required', 'exists:periode_akademik,id'],
            'kelas_id' => ['required', 'exists:kelas,id'],
            'mapel_id' => ['required', 'exists:mata_pelajaran,id'],
            'guru_id' => ['required', 'exists:guru,id'],
            'hari' => ['required', 'in:Senin,Selasa,Rabu,Kamis,Jumat,Sabtu'],
            'jam_mulai_ke' => ['required', Rule::in($startOptions)],
            'jam_selesai_ke' => ['required', Rule::in($endOptions)],
            'ruangan' => ['nullable', 'string', 'max:20'],
        ]);

        $jamMulai = $validated['jam_mulai_ke'] === 'legacy'
            ? substr((string) $currentSchedule->jam_mulai, 0, 5)
            : self::JAM_PELAJARAN[(int) $validated['jam_mulai_ke']]['mulai'];

        $jamSelesai = $validated['jam_selesai_ke'] === 'legacy'
            ? substr((string) $currentSchedule->jam_selesai, 0, 5)
            : self::JAM_PELAJARAN[(int) $validated['jam_selesai_ke']]['selesai'];

        if ($jamSelesai <= $jamMulai) {
            throw ValidationException::withMessages([
                'jam_selesai_ke' => 'Jam selesai harus berada setelah jam mulai.',
            ]);
        }

        unset($validated['jam_mulai_ke'], $validated['jam_selesai_ke']);
        $validated['jam_mulai'] = $jamMulai;
        $validated['jam_selesai'] = $jamSelesai;

        return $validated;
    }

    private function findSlotByTime(?string $time, string $edge): ?int
    {
        $normalizedTime = substr((string) $time, 0, 5);

        foreach (self::JAM_PELAJARAN as $jamKe => $slot) {
            if ($slot[$edge] === $normalizedTime) {
                return $jamKe;
            }
        }

        return null;
    }
}

<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\JadwalPelajaran;
use App\Models\Materi;
use App\Models\PeriodeAkademik;
use App\Models\Penugasan;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class SiswaDashboardController extends Controller
{
    private const HARI = [
        1 => 'Senin', 2 => 'Selasa', 3 => 'Rabu',
        4 => 'Kamis', 5 => 'Jumat', 6 => 'Sabtu',
    ];

    /**
     * GET /api/siswa/dashboard (auth:sanctum)
     */
    public function index(Request $request)
    {
        $user = $request->user();
        $siswa = $user->siswa()->with('kelas')->first();

        if (! $siswa) {
            return response()->json([
                'success' => false,
                'message' => 'Data siswa untuk akun ini tidak ditemukan.',
            ], 404);
        }

        $now = Carbon::now('Asia/Jakarta');
        $hari = self::HARI[$now->dayOfWeekIso] ?? null; // Minggu => null
        $periode = PeriodeAkademik::where('is_active', true)->first();

        $jadwalQuery = JadwalPelajaran::where('kelas_id', $siswa->kelas_id);
        if ($periode) {
            $jadwalQuery->where('periode_id', $periode->id);
        }
        $jadwalIds = $jadwalQuery->pluck('id');

        // ---- Statistik ----
        $sudahDikumpulkan = DB::table('pengumpulan_tugas')
            ->where('siswa_id', $siswa->id)
            ->pluck('penugasan_id');

        $tugasAktifQuery = Penugasan::with(['jadwal.mataPelajaran', 'guru'])
            ->whereIn('jadwal_id', $jadwalIds)
            ->where('deadline', '>', $now->toDateTimeString())
            ->whereNotIn('id', $sudahDikumpulkan);

        $tugasAktifTotal = (clone $tugasAktifQuery)->count();

        $absenBulan = DB::table('absensi_harian')
            ->where('siswa_id', $siswa->id)
            ->whereYear('tanggal', $now->year)
            ->whereMonth('tanggal', $now->month);
        $totalAbsen = (clone $absenBulan)->count();
        $hadirAbsen = (clone $absenBulan)->where('status', 'hadir')->count();

        $rerata = DB::table('nilai')
            ->join('pengumpulan_tugas', 'pengumpulan_tugas.id', '=', 'nilai.pengumpulan_id')
            ->where('pengumpulan_tugas.siswa_id', $siswa->id)
            ->when($periode, fn ($query) => $query->join('penugasan', 'penugasan.id', '=', 'pengumpulan_tugas.penugasan_id')
                ->join('jadwal_pelajaran', 'jadwal_pelajaran.id', '=', 'penugasan.jadwal_id')
                ->where('jadwal_pelajaran.periode_id', $periode->id))
            ->avg('nilai.nilai');

        // ---- Jadwal hari ini ----
        $jadwalHariIni = collect();
        if ($hari) {
            $absenHariIni = DB::table('absensi_harian')
                ->where('siswa_id', $siswa->id)
                ->whereDate('tanggal', $now->toDateString())
                ->pluck('status', 'jadwal_id');

            $jadwalHariIni = JadwalPelajaran::with(['mataPelajaran', 'guru'])
                ->whereIn('id', $jadwalIds)
                ->where('kelas_id', $siswa->kelas_id)
                ->where('hari', $hari)
                ->orderBy('jam_mulai')
                ->get()
                ->map(fn ($j) => [
                    'id' => $j->id,
                    'mapel' => optional($j->mataPelajaran)->nama,
                    'guru' => optional($j->guru)->nama_lengkap,
                    'ruangan' => $j->ruangan,
                    'jam_mulai' => substr($j->jam_mulai, 0, 5),
                    'jam_selesai' => substr($j->jam_selesai, 0, 5),
                    'status_absen' => $absenHariIni[$j->id] ?? null,
                ])->values();
        }

        // ---- Deadline tugas ----
        $jumlahSiswaKelas = DB::table('siswa')->where('kelas_id', $siswa->kelas_id)->count();

        $deadlineItems = (clone $tugasAktifQuery)
            ->orderBy('deadline')
            ->limit(3)
            ->get()
            ->map(function ($p) use ($jumlahSiswaKelas, $now) {
                $deadline = Carbon::parse($p->deadline, 'Asia/Jakarta');

                return [
                    'id' => $p->id,
                    'judul' => $p->judul,
                    'jenis' => $p->jenis,
                    'mapel' => optional(optional($p->jadwal)->mataPelajaran)->nama,
                    'deadline' => $deadline->toIso8601String(),
                    'sisa_menit' => (int) max(0, floor($now->diffInMinutes($deadline, false))),
                    'sudah_kumpul' => DB::table('pengumpulan_tugas')->where('penugasan_id', $p->id)->count(),
                    'total_siswa' => $jumlahSiswaKelas,
                    'ada_lampiran' => ! empty($p->file_materi),
                ];
            })->values();

        // ---- Materi baru ----
        $materiBaru = Materi::with(['jadwal.mataPelajaran', 'guru'])
            ->whereIn('jadwal_id', $jadwalIds)
            ->latest()
            ->limit(3)
            ->get()
            ->map(fn ($materi) => [
                'id' => $materi->id,
                'judul' => $materi->judul,
                'mapel' => optional(optional($materi->jadwal)->mataPelajaran)->nama,
                'guru' => optional($materi->guru)->nama_lengkap,
                'ekstensi' => $materi->tipe === 'pdf'
                    ? 'PDF'
                    : strtoupper($materi->tipe),
            ])->values();

        return response()->json([
            'success' => true,
            'data' => [
                'siswa' => [
                    'nama' => $siswa->nama_lengkap,
                    'nis' => $siswa->nis,
                    'kelas' => optional($siswa->kelas)->nama_kelas,
                ],
                'periode' => $periode
                    ? ucfirst($periode->semester) . ' ' . $periode->tahun_ajaran
                    : null,
                'hari_ini' => $hari,
                'tanggal' => $now->toDateString(),
                'stats' => [
                    'tugas_aktif' => $tugasAktifTotal,
                    'kehadiran_persen' => $totalAbsen > 0 ? (int) round($hadirAbsen / $totalAbsen * 100) : null,
                    'rerata_nilai' => $rerata !== null ? round((float) $rerata, 1) : null,
                ],
                'jadwal_hari_ini' => $jadwalHariIni,
                'deadline_tugas' => [
                    'total' => $tugasAktifTotal,
                    'items' => $deadlineItems,
                ],
                'materi_baru' => $materiBaru,
            ],
        ]);
    }
}

<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Guru;
use App\Models\JadwalPelajaran;
use App\Models\Kelas;
use App\Models\MataPelajaran;
use App\Models\Siswa;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class GlobalSearchController extends Controller
{
    private const RESULT_LIMIT = 5;

    public function __invoke(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'q' => ['required', 'string', 'min:2', 'max:80'],
        ]);

        $term = trim($validated['q']);
        if (strlen($term) < 2) {
            return response()->json([
                'query' => $term,
                'groups' => [],
                'total' => 0,
            ]);
        }

        $like = '%' . $term . '%';
        $groups = [];

        // Siswa: identitas akademik dan nama akun, tanpa mengembalikan data sensitif.
        $students = Siswa::query()
            ->with('kelas:id,nama_kelas')
            ->whereHas('user')
            ->where(function ($query) use ($like) {
                $query->where('nama_lengkap', 'like', $like)
                    ->orWhere('nis', 'like', $like)
                    ->orWhere('nisn', 'like', $like)
                    ->orWhereHas('user', fn ($userQuery) => $userQuery->where('email', 'like', $like));
            })
            ->orderBy('nama_lengkap')
            ->limit(self::RESULT_LIMIT)
            ->get(['id', 'nama_lengkap', 'nis', 'nisn', 'kelas_id']);

        if ($students->isNotEmpty()) {
            $groups[] = [
                'label' => 'Siswa',
                'items' => $students->map(fn (Siswa $student) => [
                    'title' => $student->nama_lengkap,
                    'subtitle' => trim('NIS ' . ($student->nis ?: '-') . ' · NISN ' . ($student->nisn ?: '-') . ' · ' . ($student->kelas?->nama_kelas ?? 'Belum memiliki kelas')),
                    'url' => route('admin.master-data.siswa.edit', $student->id),
                    'icon' => '♟',
                ])->values(),
            ];
        }

        // Guru: nama, NIP, telepon, dan email akun.
        $teachers = Guru::query()
            ->with('user:id,email')
            ->whereHas('user')
            ->where(function ($query) use ($like) {
                $query->where('nama_lengkap', 'like', $like)
                    ->orWhere('nip', 'like', $like)
                    ->orWhere('telepon', 'like', $like)
                    ->orWhereHas('user', fn ($userQuery) => $userQuery->where('email', 'like', $like));
            })
            ->orderBy('nama_lengkap')
            ->limit(self::RESULT_LIMIT)
            ->get(['id', 'nama_lengkap', 'nip', 'user_id']);

        if ($teachers->isNotEmpty()) {
            $groups[] = [
                'label' => 'Guru',
                'items' => $teachers->map(fn (Guru $teacher) => [
                    'title' => $teacher->nama_lengkap,
                    'subtitle' => 'NIP ' . ($teacher->nip ?: '-') . ($teacher->user?->email ? ' · ' . $teacher->user->email : ''),
                    'url' => route('admin.master-data.guru.edit', $teacher->id),
                    'icon' => '♙',
                ])->values(),
            ];
        }

        // Kelas: nama, tingkat, dan nama wali kelas.
        $classes = Kelas::query()
            ->with('waliKelas:id,nama_lengkap')
            ->where(function ($query) use ($like) {
                $query->where('nama_kelas', 'like', $like)
                    ->orWhere('tingkat', 'like', $like)
                    ->orWhereHas('waliKelas', fn ($teacherQuery) => $teacherQuery->where('nama_lengkap', 'like', $like));
            })
            ->orderBy('tingkat')
            ->orderBy('nama_kelas')
            ->limit(self::RESULT_LIMIT)
            ->get(['id', 'nama_kelas', 'tingkat', 'wali_kelas_id']);

        if ($classes->isNotEmpty()) {
            $groups[] = [
                'label' => 'Kelas',
                'items' => $classes->map(fn (Kelas $class) => [
                    'title' => $class->nama_kelas,
                    'subtitle' => 'Kelas ' . $class->tingkat . ' · Wali kelas ' . ($class->waliKelas?->nama_lengkap ?? 'Belum ditentukan'),
                    'url' => route('admin.master-data.kelas.edit', $class->id),
                    'icon' => '▦',
                ])->values(),
            ];
        }

        // Mata pelajaran: kode, nama, atau deskripsi.
        $subjects = MataPelajaran::query()
            ->where(function ($query) use ($like) {
                $query->where('kode', 'like', $like)
                    ->orWhere('nama', 'like', $like)
                    ->orWhere('deskripsi', 'like', $like);
            })
            ->orderBy('nama')
            ->limit(self::RESULT_LIMIT)
            ->get(['id', 'kode', 'nama']);

        if ($subjects->isNotEmpty()) {
            $groups[] = [
                'label' => 'Mata Pelajaran',
                'items' => $subjects->map(fn (MataPelajaran $subject) => [
                    'title' => $subject->nama,
                    'subtitle' => 'Kode ' . ($subject->kode ?: '-'),
                    'url' => route('admin.master-data.mata-pelajaran.edit', $subject->id),
                    'icon' => '▤',
                ])->values(),
            ];
        }

        // Penugasan/jadwal: cari berdasarkan guru, kelas, mapel, hari, ruang, atau periode.
        $schedules = JadwalPelajaran::query()
            ->with(['guru:id,nama_lengkap', 'kelas:id,nama_kelas', 'mataPelajaran:id,nama,kode', 'periode:id,nama,tahun_ajaran'])
            ->where(function ($query) use ($like) {
                $query->where('hari', 'like', $like)
                    ->orWhere('ruangan', 'like', $like)
                    ->orWhereHas('guru', fn ($teacherQuery) => $teacherQuery->where('nama_lengkap', 'like', $like))
                    ->orWhereHas('kelas', fn ($classQuery) => $classQuery->where('nama_kelas', 'like', $like))
                    ->orWhereHas('mataPelajaran', function ($subjectQuery) use ($like) {
                        $subjectQuery->where('nama', 'like', $like)->orWhere('kode', 'like', $like);
                    })
                    ->orWhereHas('periode', function ($periodQuery) use ($like) {
                        $periodQuery->where('nama', 'like', $like)->orWhere('tahun_ajaran', 'like', $like);
                    });
            })
            ->orderBy('hari')
            ->orderBy('jam_mulai')
            ->limit(self::RESULT_LIMIT)
            ->get(['id', 'guru_id', 'kelas_id', 'mapel_id', 'periode_id', 'hari', 'jam_mulai', 'jam_selesai', 'ruangan']);

        if ($schedules->isNotEmpty()) {
            $groups[] = [
                'label' => 'Penugasan Guru',
                'items' => $schedules->map(fn (JadwalPelajaran $schedule) => [
                    'title' => ($schedule->mataPelajaran?->nama ?? 'Mata pelajaran') . ' · ' . ($schedule->kelas?->nama_kelas ?? 'Kelas'),
                    'subtitle' => ($schedule->guru?->nama_lengkap ?? 'Guru belum ditentukan') . ' · ' . $schedule->hari . ' ' . substr((string) $schedule->jam_mulai, 0, 5) . '–' . substr((string) $schedule->jam_selesai, 0, 5),
                    'url' => route('admin.penugasan.edit', $schedule->id),
                    'icon' => '▣',
                ])->values(),
            ];
        }

        // Menu navigasi. Hasil ini merupakan shortcut, bukan pengganti search pada tabel masing-masing.
        $menuGroups = $this->navigationItems();
        $matchingMenus = collect($menuGroups)
            ->filter(function (array $item) use ($term) {
                $haystack = strtolower($item['title'] . ' ' . $item['keywords']);
                return str_contains($haystack, strtolower($term));
            })
            ->take(7)
            ->map(fn (array $item) => [
                'title' => $item['title'],
                'subtitle' => $item['description'],
                'url' => $item['url'],
                'icon' => '↗',
            ])
            ->values();

        if ($matchingMenus->isNotEmpty()) {
            $groups[] = [
                'label' => 'Navigasi',
                'items' => $matchingMenus,
            ];
        }

        $total = collect($groups)->sum(fn (array $group) => count($group['items']));

        return response()->json([
            'query' => $term,
            'groups' => $groups,
            'total' => $total,
        ]);
    }

    /** @return array<int, array{title:string,description:string,keywords:string,url:string}> */
    private function navigationItems(): array
    {
        return [
            ['title' => 'Dashboard Utama', 'description' => 'Ringkasan aktivitas administrasi', 'keywords' => 'dashboard beranda home ringkasan', 'url' => route('admin.dashboard')],
            ['title' => 'Semua Akun', 'description' => 'Manajemen seluruh akun pengguna', 'keywords' => 'akun pengguna user account', 'url' => route('admin.accounts.index')],
            ['title' => 'Data Guru', 'description' => 'Master data dan akun guru', 'keywords' => 'guru pengajar nip master data', 'url' => route('admin.master-data.guru.index')],
            ['title' => 'Data Siswa', 'description' => 'Master data dan akun siswa', 'keywords' => 'siswa murid peserta didik nis nisn master data', 'url' => route('admin.master-data.siswa.index')],
            ['title' => 'Data Kelas', 'description' => 'Daftar kelas dan wali kelas', 'keywords' => 'kelas rombel rombongan belajar master data', 'url' => route('admin.master-data.kelas.index')],
            ['title' => 'Mata Pelajaran', 'description' => 'Daftar kode dan mata pelajaran', 'keywords' => 'mapel mata pelajaran pelajaran master data', 'url' => route('admin.master-data.mata-pelajaran.index')],
            ['title' => 'Periode Akademik', 'description' => 'Tahun ajaran dan semester aktif', 'keywords' => 'periode akademik tahun ajaran semester ganjil genap', 'url' => route('admin.master-data.periode-akademik.index')],
            ['title' => 'Jadwal Pelajaran', 'description' => 'Jadwal mengajar dan rombongan belajar', 'keywords' => 'jadwal pelajaran penugasan guru kelas', 'url' => route('admin.master-data.jadwal-pelajaran.index')],
            ['title' => 'List Penugasan Guru', 'description' => 'Daftar penugasan mengajar', 'keywords' => 'penugasan guru tugas mengajar jadwal', 'url' => route('admin.penugasan.index')],
            ['title' => 'Atur Penugasan Baru', 'description' => 'Buat penugasan mengajar', 'keywords' => 'tambah penugasan baru jadwal guru', 'url' => route('admin.penugasan.create')],
            ['title' => 'Materi', 'description' => 'Kelola materi pembelajaran', 'keywords' => 'materi pembelajaran bahan ajar', 'url' => route('admin.materi.index')],
            ['title' => 'Tugas', 'description' => 'Kelola tugas dan pengumpulan siswa', 'keywords' => 'tugas pekerjaan rumah pengumpulan', 'url' => route('admin.tugas.index')],
            ['title' => 'Nilai', 'description' => 'Penilaian dan hasil pekerjaan siswa', 'keywords' => 'nilai penilaian koreksi hasil tugas', 'url' => route('admin.nilai.index')],
            ['title' => 'Verifikasi Surat Absensi', 'description' => 'Periksa pengajuan izin dan sakit', 'keywords' => 'verifikasi surat izin sakit absensi pengajuan', 'url' => route('admin.absensi.verifikasi')],
            ['title' => 'Histori Verifikasi Surat', 'description' => 'Riwayat keputusan verifikasi surat', 'keywords' => 'histori verifikasi surat izin sakit arsip', 'url' => route('admin.absensi.histori')],
            ['title' => 'Rekap Absensi Siswa', 'description' => 'Laporan kehadiran siswa', 'keywords' => 'rekap absensi presensi kehadiran siswa', 'url' => route('admin.absensi.rekap')],
            ['title' => 'Notifikasi Admin', 'description' => 'Pusat notifikasi administrasi', 'keywords' => 'notifikasi pemberitahuan pesan', 'url' => route('admin.notifications.index')],
            ['title' => 'Pengaturan', 'description' => 'Profil admin dan pengaturan akun', 'keywords' => 'pengaturan settings profil password', 'url' => route('admin.pengaturan')],
            ['title' => 'Audit Log', 'description' => 'Riwayat aktivitas administrator', 'keywords' => 'audit log aktivitas admin riwayat', 'url' => route('admin.activity-logs.index')],
            ['title' => 'Data Transfer', 'description' => 'Import dan export data guru/siswa', 'keywords' => 'import export data transfer excel csv', 'url' => route('admin.data-transfer.index')],
        ];
    }
}

<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Guru;
use App\Models\JadwalPelajaran;
use App\Models\Kelas;
use App\Models\MataPelajaran;
use App\Models\AbsensiSesi;
use App\Models\Siswa;
use App\Models\AbsensiHarian;
use App\Models\Penugasan;
use App\Models\PengumpulanTugas;
use App\Models\SuratAbsensi;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Carbon\Carbon;

class GuruController extends Controller
{
    public function mapelKelas()
    {
        $guru = Guru::where('user_id', auth()->id())->first();
        if (!$guru) {
            return response()->json(['success' => false, 'message' => 'Profil guru tidak ditemukan.'], 404);
        }

        $jadwal = JadwalPelajaran::with(['mataPelajaran', 'kelas'])
            ->where('guru_id', $guru->id)
            ->get()
            ->map(function ($item) {
                $sesiAktif = AbsensiSesi::where('jadwal_id', $item->id)
                    ->where('status', 'aktif')
                    ->first();

                $tugasMenunggu = Penugasan::where('jadwal_id', $item->id)
                    ->with('pengumpulan.nilai')
                    ->get()
                    ->sum(function ($tugas) {
                        return $tugas->pengumpulan->filter(
                            fn ($submission) => $submission->nilai === null
                        )->count();
                    });

                return [
                    'id' => $item->id,
                    'jadwal_id' => $item->id,
                    'mata_pelajaran' => $item->mataPelajaran?->nama,
                    'kode_mapel' => $item->mataPelajaran?->kode,
                    'kelas' => $item->kelas?->nama_kelas,
                    'hari' => $item->hari,
                    'jam_mulai' => $item->jam_mulai,
                    'jam_selesai' => $item->jam_selesai,
                    'tugas_menunggu' => $tugasMenunggu,
                    'status_absensi' => $sesiAktif ? 'aktif' : 'belum',
                    'sesi_id' => $sesiAktif?->id,
                    'jumlah_siswa' => Siswa::where('kelas_id', $item->kelas_id)->count(),
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $jadwal,
        ]);
    }


    public function generateQr(Request $request)
    {
        $request->validate([
            'jadwal_id' => 'required|exists:jadwal_pelajaran,id',
        ]);

        $guru = Guru::where('user_id', auth()->id())->firstOrFail();
        $jadwal = JadwalPelajaran::where('guru_id', $guru->id)
            ->with(['guru.user', 'kelas', 'mataPelajaran'])
            ->findOrFail($request->jadwal_id);

        $expiredAt = Carbon::parse($jadwal->jam_mulai)->add(30, 'minutes');

        $qrData = json_encode([
            'jadwal_id' => $jadwal->id,
            'expired_at' => $expiredAt->toISOString(),
            'kelas' => $jadwal->kelas->nama_kelas,
            'mapel' => $jadwal->mataPelajaran->nama,
            'guru' => $jadwal->guru->nama_lengkap,
        ]);

        return response()->json([
            'success' => true,
            'data' => [
                // QR is rendered on-device by Flutter's qr_flutter package.
                'qr_code' => null,
                'qr_data' => $qrData,
                'expired_at' => $expiredAt->format('H:i'),
            ],
        ]);
    }

    public function startSession(Request $request)
    {
        $validated = $request->validate([
            'jadwal_id' => 'required|exists:jadwal_pelajaran,id',
            'lokasi_latitude' => 'required|numeric',
            'lokasi_longitude' => 'required|numeric',
            'radius_meter' => 'required|integer|min:1|max:1000',
            'toleransi_keterlambatan' => 'sometimes|boolean',
        ]);

        $guru = Guru::where('user_id', auth()->id())->firstOrFail();
        $jadwal = JadwalPelajaran::where('guru_id', $guru->id)
            ->with(['guru', 'kelas', 'mataPelajaran'])
            ->findOrFail($validated['jadwal_id']);

        $existingSession = AbsensiSesi::where('jadwal_id', $jadwal->id)
            ->where('status', 'aktif')
            ->first();
        if ($existingSession) {
            return response()->json([
                'success' => false,
                'message' => 'Sesi absensi sudah aktif',
                'data' => ['sesi_id' => $existingSession->id, 'status' => 'aktif'],
            ], 409);
        }

        $expiredAt = now()->addMinutes(30);
        if (!empty($validated['toleransi_keterlambatan'])) {
            $expiredAt->addMinutes(15);
        }

        // Create the session first so the QR payload can contain its real database ID.
        $sesi = AbsensiSesi::create([
            'jadwal_id' => $jadwal->id,
            'guru_id' => $guru->id,
            'kelas_id' => $jadwal->kelas_id,
            'lokasi_latitude' => $validated['lokasi_latitude'],
            'lokasi_longitude' => $validated['lokasi_longitude'],
            'radius_meter' => $validated['radius_meter'],
            'toleransi_keterlambatan' => !empty($validated['toleransi_keterlambatan']),
            'status' => 'aktif',
            'qr_code' => '',
            'qr_data' => '',
            'expired_at' => $expiredAt,
        ]);

        $qrData = json_encode([
            'jadwal_id' => $jadwal->id,
            'sesi_id' => $sesi->id,
            'session_id' => (string) $sesi->id,
            'qr_token' => Str::random(48),
            'expired_at' => $expiredAt->toISOString(),
            'kelas' => $jadwal->kelas?->nama_kelas,
            'mapel' => $jadwal->mataPelajaran?->nama,
            'guru' => $guru->nama_lengkap,
        ], JSON_UNESCAPED_UNICODE);

        // Flutter renders the QR from this payload; no server-side image extension is required.
        $sesi->update(['qr_data' => $qrData]);

        return response()->json([
            'success' => true,
            'message' => 'Sesi absensi dimulai',
            'data' => [
                'sesi_id' => $sesi->id,
                'session_id' => (string) $sesi->id,
                'qr_code' => null,
                'qr_data' => $qrData,
                'expired_at' => $expiredAt->toISOString(),
                'status' => 'aktif',
            ],
        ]);
    }

    public function stopSession(Request $request)
    {
        $validated = $request->validate(['sesi_id' => 'required|integer']);
        $guru = Guru::where('user_id', auth()->id())->firstOrFail();
        $sesi = AbsensiSesi::where('guru_id', $guru->id)->findOrFail($validated['sesi_id']);

        if ($sesi->status !== 'aktif') {
            return response()->json(['success' => false, 'message' => 'Sesi tidak aktif'], 400);
        }

        $sesi->update(['status' => 'selesai', 'selesai_at' => now()]);
        return response()->json(['success' => true, 'message' => 'Sesi absensi dihentikan', 'data' => $sesi]);
    }

    public function closeSession($id)
    {
        $guru = Guru::where('user_id', auth()->id())->firstOrFail();
        $sesi = AbsensiSesi::where('guru_id', $guru->id)->findOrFail($id);
        if ($sesi->status !== 'aktif') {
            return response()->json(['success' => false, 'message' => 'Sesi tidak aktif'], 400);
        }
        $sesi->update(['status' => 'selesai', 'selesai_at' => now()]);
        return response()->json(['success' => true, 'message' => 'Sesi absensi dihentikan', 'data' => $sesi]);
    }

    public function sessionDetails($id)
    {
        $guru = Guru::where('user_id', auth()->id())->firstOrFail();
        $sesi = AbsensiSesi::where('guru_id', $guru->id)
            ->with(['jadwal.kelas', 'jadwal.mataPelajaran'])
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $sesi->id,
                'sesi_id' => $sesi->id,
                'jadwal_id' => $sesi->jadwal_id,
                'status' => $sesi->status,
                'qr_data' => $sesi->qr_data,
                'expired_at' => $sesi->expired_at,
                'lokasi_latitude' => $sesi->lokasi_latitude,
                'lokasi_longitude' => $sesi->lokasi_longitude,
                'radius_meter' => $sesi->radius_meter,
                'total_students' => Siswa::where('kelas_id', $sesi->kelas_id)->count(),
                'mata_pelajaran' => $sesi->jadwal?->mataPelajaran?->nama,
                'kelas' => $sesi->jadwal?->kelas?->nama_kelas,
            ],
        ]);
    }

    public function regenerateSessionQr($id)
    {
        $guru = Guru::where('user_id', auth()->id())->firstOrFail();
        $sesi = AbsensiSesi::where('guru_id', $guru->id)
            ->with(['jadwal.kelas', 'jadwal.mataPelajaran'])
            ->findOrFail($id);

        if ($sesi->status !== 'aktif') {
            return response()->json([
                'success' => false,
                'message' => 'QR hanya dapat dibuat ulang untuk sesi yang masih aktif.',
            ], 409);
        }

        if ($sesi->expired_at && Carbon::parse($sesi->expired_at)->isPast()) {
            return response()->json([
                'success' => false,
                'message' => 'Masa berlaku sesi telah berakhir. Buka sesi absensi baru.',
            ], 409);
        }

        // Token baru membuat isi QR benar-benar berubah. Nilainya disimpan di server,
        // sehingga aplikasi tidak menampilkan QR lokal yang tidak dikenal backend.
        $qrData = json_encode([
            'jadwal_id' => $sesi->jadwal_id,
            'sesi_id' => $sesi->id,
            'session_id' => (string) $sesi->id,
            'qr_token' => Str::random(48),
            'expired_at' => $sesi->expired_at?->toISOString(),
            'kelas' => $sesi->jadwal?->kelas?->nama_kelas,
            'mapel' => $sesi->jadwal?->mataPelajaran?->nama,
            'guru' => $guru->nama_lengkap,
        ], JSON_UNESCAPED_UNICODE);

        $sesi->update(['qr_data' => $qrData]);

        return response()->json([
            'success' => true,
            'message' => 'QR Code berhasil dibuat ulang.',
            'data' => [
                'sesi_id' => $sesi->id,
                'qr_data' => $qrData,
                'expired_at' => $sesi->expired_at?->toISOString(),
            ],
        ]);
    }

    public function sessionAttendance($id)
    {
        $guru = Guru::where('user_id', auth()->id())->firstOrFail();
        $sesi = AbsensiSesi::where('guru_id', $guru->id)->with('jadwal')->findOrFail($id);
        $tanggal = $sesi->created_at->toDateString();
        $absensi = AbsensiHarian::with('siswa')
            ->where('jadwal_id', $sesi->jadwal_id)
            ->whereDate('tanggal', $tanggal)
            ->where('status', 'hadir')
            ->latest('waktu_absen')
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'present_count' => $absensi->count(),
                'recent_scans' => $absensi->take(5)->map(fn ($item) => [
                    'nama' => $item->siswa?->nama_lengkap,
                    'waktu' => $item->waktu_absen,
                    'status' => $item->status,
                ])->values(),
                'total_students' => Siswa::where('kelas_id', $sesi->kelas_id)->count(),
            ],
        ]);
    }

    public function sesiReport()
    {
        $guru = Guru::where('user_id', auth()->id())->first();
        if (!$guru) {
            return response()->json(['success' => false, 'message' => 'Profil guru tidak ditemukan.'], 404);
        }

        $query = AbsensiSesi::with(['jadwal.kelas', 'jadwal.mataPelajaran', 'guru'])
            ->where('guru_id', $guru->id)
            ->orderBy('created_at', 'desc');

        $totalSessions = (clone $query)->reorder()->count();
        $activeSessions = (clone $query)->reorder()->where('status', 'aktif')->count();
        $completedSessions = (clone $query)->reorder()->where('status', 'selesai')->count();
        $sesis = $query->paginate(20);

        $report = $sesis->getCollection()->map(function ($sesi) {
            $totalSiswa = $sesi->jadwal->kelas->siswa->count();
            $hadir = $sesi->absensiHarian()
                ->where('status', 'hadir')
                ->whereDate('tanggal', $sesi->created_at->toDateString())
                ->count();
            $izin = $sesi->absensiHarian()
                ->where('status', 'izin')
                ->whereDate('tanggal', $sesi->created_at->toDateString())
                ->count();
            $sakit = $sesi->absensiHarian()
                ->where('status', 'sakit')
                ->whereDate('tanggal', $sesi->created_at->toDateString())
                ->count();
            $alpa = $sesi->absensiHarian()
                ->where('status', 'alpa')
                ->whereDate('tanggal', $sesi->created_at->toDateString())
                ->count();

            $persentase = $totalSiswa > 0 ? round(($hadir / $totalSiswa) * 100, 2) : 0;

            return [
                'id' => $sesi->id,
                'jadwal_id' => $sesi->jadwal_id,
                'jadwal' => [
                    'mapel' => $sesi->jadwal->mataPelajaran->nama,
                    'kelas' => $sesi->jadwal->kelas->nama_kelas,
                    'hari' => $sesi->jadwal->hari,
                    'jam_mulai' => $sesi->jadwal->jam_mulai,
                    'jam_selesai' => $sesi->jadwal->jam_selesai,
                ],
                'status' => $sesi->status,
                'created_at' => $sesi->created_at->format('d M Y H:i'),
                'expired_at' => $sesi->expired_at->format('H:i'),
                'toleransi' => $sesi->toleransi_keterlambatan ? '15 menit' : '-',
                'total_siswa' => $totalSiswa,
                'hadir' => $hadir,
                'izin' => $izin,
                'sakit' => $sakit,
                'alpa' => $alpa,
                'persentase' => $persentase,
            ];
        });

        return response()->json([
            'success' => true,
            'data' => [
                'report' => $report,
                'summary' => [
                    'total' => $totalSessions,
                    'aktif' => $activeSessions,
                    'selesai' => $completedSessions,
                ],
                'pagination' => [
                    'current_page' => $sesis->currentPage(),
                    'per_page' => $sesis->perPage(),
                    'total' => $sesis->total(),
                ],
            ],
        ]);
    }

    public function dashboard()
    {
        // For testing without auth, use first guru
        $guru = Guru::where('user_id', auth()->id())->first();
        if (!$guru) {
            return response()->json(['success' => false, 'message' => 'Profil guru tidak ditemukan.'], 404);
        }

        // Total kelas
        $totalKelas = JadwalPelajaran::where('guru_id', $guru->id)
            ->distinct('kelas_id')
            ->count('kelas_id');

        // Total siswa
        $kelasIds = JadwalPelajaran::where('guru_id', $guru->id)
            ->distinct('kelas_id')
            ->pluck('kelas_id');
        
        $totalSiswa = Siswa::whereIn('kelas_id', $kelasIds)->count();

        // Kehadiran hari ini
        $today = now()->toDateString();
        $hadirHariIni = AbsensiHarian::whereHas('jadwal', function ($q) use ($guru) {
            $q->where('guru_id', $guru->id);
        })->where('tanggal', $today)->where('status', 'hadir')->count();

        // Tugas menunggu dinilai
        $tugasMenunggu = Penugasan::whereHas('jadwal', function ($q) use ($guru) {
            $q->where('guru_id', $guru->id);
        })->whereHas('pengumpulan', function ($q) {
            $q->where('status', 'tepat_waktu');
        })->whereDoesntHave('pengumpulan.nilai')->count();

        // Tahun ajaran aktif
        $periode = \App\Models\PeriodeAkademik::where('is_active', true)->first();
        $tahunAjaran = $periode ? $periode->tahun_ajaran : '2024/2025';

        return response()->json([
            'success' => true,
            'data' => [
                'nama_guru' => $guru->nama_lengkap,
                'tahun_ajaran' => $tahunAjaran,
                'total_kelas' => $totalKelas,
                'total_siswa' => $totalSiswa,
                'kehadiran' => $hadirHariIni,
                'tugas_menunggu' => $tugasMenunggu,
            ],
        ]);
    }

    public function materiIndex()
    {
        $guru = Guru::where('user_id', auth()->id())->first();
        if (!$guru) return response()->json(['success' => false, 'message' => 'Profil guru tidak ditemukan.'], 404);

        $materi = \App\Models\Materi::whereHas('jadwal', function ($q) use ($guru) {
            $q->where('guru_id', $guru->id);
        })->with(['jadwal.kelas', 'jadwal.mataPelajaran'])->latest()->get();

        return response()->json(['success' => true, 'data' => $materi]);
    }

    public function materiStore(Request $request)
    {
        $guru = Guru::where('user_id', auth()->id())->first();
        if (!$guru) {
            return response()->json(['success' => false, 'message' => 'Profil guru tidak ditemukan.'], 404);
        }

        $validated = $request->validate([
            'jadwal_id' => 'required|integer|exists:jadwal_pelajaran,id',
            'judul' => 'required|string|max:255',
            'deskripsi' => 'nullable|string',
            'tipe' => 'required|in:pdf,video,link',
            'file_path' => 'nullable|string|max:255',
            'file' => 'nullable|file|max:10240',
            'link' => 'nullable|url|max:2048',
        ]);

        // Jangan izinkan guru membuat materi pada jadwal milik guru lain.
        $jadwal = JadwalPelajaran::where('guru_id', $guru->id)
            ->find($validated['jadwal_id']);
        if (!$jadwal) {
            return response()->json([
                'success' => false,
                'message' => 'Jadwal tersebut bukan bagian dari kelas mengajar Anda.',
            ], 403);
        }

        $filePath = $validated['file_path'] ?? null;
        $link = $validated['link'] ?? null;

        if ($validated['tipe'] === 'link') {
            if (!$link) {
                return response()->json([
                    'success' => false,
                    'message' => 'URL wajib diisi untuk materi bertipe link.',
                    'errors' => ['link' => ['URL wajib diisi untuk materi bertipe link.']],
                ], 422);
            }
            $filePath = null;
        } else {
            if ($request->hasFile('file')) {
                $extensionRule = $validated['tipe'] === 'pdf'
                    ? 'required|file|mimes:pdf|max:10240'
                    : 'required|file|mimes:mp4,mov,webm|max:10240';
                $request->validate(['file' => $extensionRule]);
                $filePath = $request->file('file')->store('materi', 'public');
            } elseif (!$filePath) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unggah file materi terlebih dahulu.',
                    'errors' => ['file' => ['File materi wajib diunggah.']],
                ], 422);
            }
            $link = null;
        }

        $materi = \App\Models\Materi::create([
            'jadwal_id' => $jadwal->id,
            'guru_id' => $guru->id,
            'judul' => $validated['judul'],
            'deskripsi' => $validated['deskripsi'] ?? null,
            'tipe' => $validated['tipe'],
            'file_path' => $filePath,
            'link' => $link,
        ])->load(['jadwal.kelas', 'jadwal.mataPelajaran']);

        return response()->json([
            'success' => true,
            'data' => $materi,
            'message' => 'Materi berhasil ditambahkan.',
        ], 201);
    }

    public function materiUpdate(Request $request, $id)
    {
        $guru = Guru::where('user_id', auth()->id())->firstOrFail();
        $materi = \App\Models\Materi::where('guru_id', $guru->id)->findOrFail($id);

        $request->validate([
            'judul' => 'sometimes|required|string|max:255',
            'deskripsi' => 'nullable|string',
            'tipe' => 'sometimes|required|in:pdf,video,link',
            'link' => 'nullable|url',
            'file' => 'nullable|file|mimes:pdf,mp4,mov,webm|max:10240',
        ]);

        $materi->fill($request->only(['judul', 'deskripsi', 'tipe', 'link']));

        if ($request->hasFile('file')) {
            if ($materi->file_path) {
                Storage::disk('public')->delete($materi->file_path);
            }
            $materi->file_path = $request->file('file')->store('materi', 'public');
            $materi->link = null;
        } elseif ($request->input('tipe') === 'link') {
            if ($materi->file_path) {
                Storage::disk('public')->delete($materi->file_path);
            }
            $materi->file_path = null;
        }

        $materi->save();
        return response()->json([
            'success' => true,
            'data' => $materi,
            'message' => 'Materi berhasil diupdate',
        ]);
    }

    public function materiDestroy($id)
    {
        $guru = Guru::where('user_id', auth()->id())->firstOrFail();
        $materi = \App\Models\Materi::where('guru_id', $guru->id)->findOrFail($id);

        if ($materi->file_path) {
            Storage::disk('public')->delete($materi->file_path);
        }
        $materi->delete();

        return response()->json(['success' => true, 'message' => 'Materi berhasil dihapus.']);
    }

    public function tugasIndex()
    {
        $guru = Guru::where('user_id', auth()->id())->first();
        if (!$guru) return response()->json(['success' => false, 'message' => 'Profil guru tidak ditemukan.'], 404);

        $tugas = \App\Models\Penugasan::whereHas('jadwal', function ($q) use ($guru) {
            $q->where('guru_id', $guru->id);
        })->with(['jadwal.kelas', 'jadwal.mataPelajaran'])->latest()->get();

        return response()->json(['success' => true, 'data' => $tugas]);
    }

    public function tugasStore(Request $request)
    {
        $guru = Guru::where('user_id', auth()->id())->first();
        if (!$guru) return response()->json(['success' => false, 'message' => 'Profil guru tidak ditemukan.'], 404);

        $request->validate([
            'jadwal_id' => 'required|exists:jadwal_pelajaran,id',
            'judul' => 'required|string|max:255',
            'deskripsi' => 'nullable|string',
            'jenis' => 'required|in:tugas,quiz,uts,uas',
            'deadline' => 'required|date',
            'file_materi' => 'nullable|string',
            'bobot' => 'nullable|integer|min:1|max:100',
        ]);

        JadwalPelajaran::where('guru_id', $guru->id)->findOrFail($request->jadwal_id);
        $tugas = \App\Models\Penugasan::create(array_merge($request->only([
            'jadwal_id', 'judul', 'deskripsi', 'jenis', 'deadline', 'file_materi', 'bobot',
        ]), ['guru_id' => $guru->id]));

        return response()->json(['success' => true, 'data' => $tugas, 'message' => 'Tugas berhasil ditambahkan']);
    }

    public function tugasUpdate(Request $request, $id)
    {
        $guru = Guru::where('user_id', auth()->id())->firstOrFail();
        $tugas = \App\Models\Penugasan::where('guru_id', $guru->id)->findOrFail($id);
        $tugas->update($request->only(['judul', 'deskripsi', 'jenis', 'deadline', 'file_materi', 'bobot']));
        return response()->json(['success' => true, 'data' => $tugas, 'message' => 'Tugas berhasil diupdate']);
    }

    public function tugasDestroy($id)
    {
        $guru = Guru::where('user_id', auth()->id())->firstOrFail();
        \App\Models\Penugasan::where('guru_id', $guru->id)->findOrFail($id)->delete();
        return response()->json(['success' => true, 'message' => 'Tugas berhasil dihapus']);
    }

    public function tugasByJadwal($jadwalId)
    {
        $guru = Guru::where('user_id', auth()->id())->firstOrFail();
        $jadwal = JadwalPelajaran::where('guru_id', $guru->id)->findOrFail($jadwalId);
        $tugas = Penugasan::where('jadwal_id', $jadwal->id)
            ->with(['jadwal.kelas', 'jadwal.mataPelajaran', 'pengumpulan.nilai'])
            ->latest()
            ->get();
        return response()->json(['success' => true, 'data' => $tugas]);
    }

    public function nilaiIndex()
    {
        $guru = Guru::where('user_id', auth()->id())->first();
        if (!$guru) {
            return response()->json(['success' => false, 'message' => 'Profil guru tidak ditemukan.'], 404);
        }

        $tugas = Penugasan::whereHas('jadwal', function ($query) use ($guru) {
                $query->where('guru_id', $guru->id);
            })
            ->with([
                'jadwal.kelas',
                'jadwal.mataPelajaran',
                'pengumpulan.siswa',
                'pengumpulan.nilai',
            ])
            ->latest()
            ->get()
            ->map(function ($item) {
                $jadwal = $item->jadwal;
                $pengumpulan = $item->pengumpulan;

                return [
                    'id' => $item->id,
                    'jadwal_id' => $item->jadwal_id,
                    'judul' => $item->judul,
                    'deskripsi' => $item->deskripsi,
                    'jenis' => $item->jenis,
                    'deadline' => $item->deadline,
                    'bobot' => $item->bobot,
                    'mata_pelajaran' => $jadwal?->mataPelajaran?->nama,
                    'kelas' => $jadwal?->kelas?->nama_kelas,
                    'total_siswa' => $jadwal
                        ? Siswa::where('kelas_id', $jadwal->kelas_id)->count()
                        : 0,
                    'pengumpulan' => $pengumpulan->map(function ($submission) {
                        return [
                            'id' => $submission->id,
                            'siswa_id' => $submission->siswa_id,
                            'nama_siswa' => $submission->siswa?->nama_lengkap,
                            'status' => $submission->nilai ? 'graded' : 'submitted',
                            'nilai' => $submission->nilai?->nilai,
                        ];
                    })->values(),
                    'dinilai_count' => $pengumpulan->filter(
                        fn ($submission) => $submission->nilai !== null
                    )->count(),
                ];
            });

        return response()->json(['success' => true, 'data' => $tugas]);
    }


    public function nilaiDetail($tugasId)
    {
        $guru = Guru::where('user_id', auth()->id())->firstOrFail();
        $tugas = Penugasan::whereHas('jadwal', function ($query) use ($guru) {
                $query->where('guru_id', $guru->id);
            })
            ->with(['jadwal.kelas', 'jadwal.mataPelajaran', 'pengumpulan.siswa', 'pengumpulan.nilai'])
            ->findOrFail($tugasId);

        return response()->json(['success' => true, 'data' => $tugas]);
    }


    public function nilaiStore(Request $request)
    {
        $validated = $request->validate([
            'pengumpulan_id' => 'required|exists:pengumpulan_tugas,id',
            'nilai' => 'required|numeric|min:0|max:100',
            'catatan' => 'nullable|string',
        ]);

        $guru = Guru::where('user_id', auth()->id())->firstOrFail();
        $pengumpulan = PengumpulanTugas::whereKey($validated['pengumpulan_id'])
            ->whereHas('penugasan.jadwal', function ($query) use ($guru) {
                $query->where('guru_id', $guru->id);
            })
            ->firstOrFail();

        $nilai = \App\Models\Nilai::updateOrCreate(
            ['pengumpulan_id' => $pengumpulan->id],
            [
                'nilai' => $validated['nilai'],
                'catatan' => $validated['catatan'] ?? null,
                'guru_id' => $guru->id,
                'tanggal_penilaian' => now(),
            ]
        );

        return response()->json([
            'success' => true,
            'data' => $nilai,
            'message' => 'Nilai berhasil disimpan',
        ]);
    }


    public function rekapPresensi(Request $request)
    {
        $guru = Guru::where('user_id', auth()->id())->first();
        if (!$guru) return response()->json(['success' => false, 'message' => 'Profil guru tidak ditemukan.'], 404);

        $query = AbsensiHarian::with(['siswa', 'jadwal.guru', 'jadwal.mataPelajaran', 'jadwal.kelas'])
            ->whereHas('jadwal', function ($q) use ($guru) {
                $q->where('guru_id', $guru->id);
            });

        if ($request->filled('periode')) {
            $query->whereDate('tanggal', '>=', Carbon::parse($request->periode)->startOfMonth())
                  ->whereDate('tanggal', '<=', Carbon::parse($request->periode)->endOfMonth());
        }

        if ($request->filled('kelas')) {
            $query->whereHas('jadwal', function($q) use ($request) {
                $q->where('kelas_id', $request->kelas);
            });
        }

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        // Ringkasan harus menggunakan filter periode/kelas/status yang sama
        // dengan daftar detail, bukan seluruh histori guru.
        $summary = (clone $query)
            ->reorder()
            ->select('status', \DB::raw('count(*) as total'))
            ->groupBy('status')
            ->pluck('total', 'status')
            ->toArray();

        $absensis = $query->orderBy('tanggal', 'desc')->paginate(20);

        $totalHadir = $summary['hadir'] ?? 0;
        $totalIzin = $summary['izin'] ?? 0;
        $totalSakit = $summary['sakit'] ?? 0;
        $totalAlpa = $summary['alpa'] ?? 0;
        $total = $totalHadir + $totalIzin + $totalSakit + $totalAlpa;
        $persentaseHadir = $total > 0 ? round(($totalHadir / $total) * 100, 2) : 0;

        $kelasIds = JadwalPelajaran::where('guru_id', $guru->id)->distinct('kelas_id')->pluck('kelas_id');
        $kelasList = \App\Models\Kelas::whereIn('id', $kelasIds)->get();

        return response()->json([
            'success' => true,
            'data' => [
                'absensis' => $absensis,
                'summary' => [
                    'hadir' => $totalHadir,
                    'izin' => $totalIzin,
                    'sakit' => $totalSakit,
                    'alpa' => $totalAlpa,
                    'total' => $total,
                    'persentase_hadir' => $persentaseHadir,
                ],
                'kelas_list' => $kelasList,
            ],
        ]);
    }

    public function suratVerifikasi(Request $request)
    {
        $guru = Guru::where('user_id', auth()->id())->first();
        if (!$guru) return response()->json(['success' => false, 'message' => 'Profil guru tidak ditemukan.'], 404);

        $query = SuratAbsensi::with(['siswa.kelas', 'verifikator'])
            ->whereHas('siswa.kelas.jadwalPelajaran', function ($q) use ($guru) {
                $q->where('guru_id', $guru->id);
            })
            ->orderBy('created_at', 'desc');

        if ($request->filled('status')) {
            $query->where('status_verifikasi', $request->status);
        }

        $surats = $query->paginate(15);

        $totalPending = SuratAbsensi::where('status_verifikasi', 'pending')
            ->whereHas('siswa.kelas.jadwalPelajaran', function ($q) use ($guru) {
                $q->where('guru_id', $guru->id);
            })->count();
        $totalDisetujui = SuratAbsensi::where('status_verifikasi', 'disetujui')
            ->whereHas('siswa.kelas.jadwalPelajaran', function ($q) use ($guru) {
                $q->where('guru_id', $guru->id);
            })->count();
        $totalDitolak = SuratAbsensi::where('status_verifikasi', 'ditolak')
            ->whereHas('siswa.kelas.jadwalPelajaran', function ($q) use ($guru) {
                $q->where('guru_id', $guru->id);
            })->count();

        return response()->json([
            'success' => true,
            'data' => [
                'surats' => $surats,
                'summary' => [
                    'pending' => $totalPending,
                    'disetujui' => $totalDisetujui,
                    'ditolak' => $totalDitolak,
                ],
            ],
        ]);
    }

    public function approveSurat($id)
    {
        $guru = Guru::where('user_id', auth()->id())->firstOrFail();
        $surat = SuratAbsensi::whereHas('siswa.kelas.jadwalPelajaran', function ($query) use ($guru) {
            $query->where('guru_id', $guru->id);
        })->findOrFail($id);
        $surat->update([
            'status_verifikasi' => 'disetujui',
            'verifikator_id' => auth()->id(),
            'tanggal_verifikasi' => now(),
        ]);

        return response()->json(['success' => true, 'message' => 'Surat berhasil disetujui']);
    }

    public function rejectSurat(Request $request, $id)
    {
        $request->validate([
            'catatan' => 'required|string|max:500',
        ]);

        $guru = Guru::where('user_id', auth()->id())->firstOrFail();
        $surat = SuratAbsensi::whereHas('siswa.kelas.jadwalPelajaran', function ($query) use ($guru) {
            $query->where('guru_id', $guru->id);
        })->findOrFail($id);
        $surat->update([
            'status_verifikasi' => 'ditolak',
            'verifikator_id' => auth()->id(),
            'tanggal_verifikasi' => now(),
            'catatan_verifikasi' => $request->catatan,
        ]);

        return response()->json(['success' => true, 'message' => 'Surat ditolak']);
    }

    public function getSubmissions($id)
    {
        $guru = Guru::where('user_id', auth()->id())->firstOrFail();
        $tugas = Penugasan::whereHas('jadwal', function ($query) use ($guru) {
                $query->where('guru_id', $guru->id);
            })
            ->with('jadwal')
            ->findOrFail($id);

        $jadwal = $tugas->jadwal;
        $submissions = PengumpulanTugas::where('penugasan_id', $tugas->id)
            ->with('nilai')
            ->get()
            ->keyBy('siswa_id');

        $students = Siswa::where('kelas_id', $jadwal->kelas_id)
            ->orderBy('nama_lengkap')
            ->get()
            ->map(function ($student) use ($submissions) {
                $submission = $submissions->get($student->id);
                $nilai = $submission?->nilai;

                return [
                    'pengumpulan_id' => $submission?->id,
                    'siswa_id' => $student->id,
                    'nama_siswa' => $student->nama_lengkap,
                    'nis' => $student->nis,
                    'status' => !$submission
                        ? 'not_submitted'
                        : ($nilai ? 'graded' : 'submitted'),
                    'status_pengumpulan' => $submission?->status,
                    'jawaban' => $submission?->jawaban,
                    'file_jawaban' => $submission?->file_jawaban,
                    'waktu_pengumpulan' => $submission?->waktu_pengumpulan,
                    'nilai' => $nilai?->nilai,
                    'catatan' => $nilai?->catatan,
                    'tanggal_penilaian' => $nilai?->tanggal_penilaian,
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $students,
            'meta' => [
                'total_siswa' => $students->count(),
                'total_mengumpulkan' => $students->filter(fn ($student) => $student['pengumpulan_id'] !== null)->count(),
                'total_dinilai' => $students->where('status', 'graded')->count(),
            ],
        ]);
    }


}

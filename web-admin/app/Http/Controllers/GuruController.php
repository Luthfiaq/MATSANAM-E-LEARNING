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
use App\Services\MatsanamNotificationService;
use App\Services\SuratAbsensiApprovalService;
use App\Services\SuratAbsensiFileService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Carbon\Carbon;

class GuruController extends Controller
{
    /** Close QR sessions whose validity window has passed so they do not block a new session. */
    private function expireStaleAbsensiSessions(?int $guruId = null, ?int $jadwalId = null): int
    {
        $now = Carbon::now('UTC');
        $query = AbsensiSesi::query()
            ->where('status', 'aktif')
            ->where(function ($expiry) use ($now) {
                $expiry->where(function ($withExpiry) use ($now) {
                    $withExpiry->whereNotNull('expired_at')
                        ->where('expired_at', '<=', $now);
                })->orWhereNull('expired_at');
            });

        if ($guruId !== null) {
            $query->where('guru_id', $guruId);
        }
        if ($jadwalId !== null) {
            $query->where('jadwal_id', $jadwalId);
        }

        return $query->update([
            'status' => 'selesai',
            'selesai_at' => $now,
            'updated_at' => $now,
        ]);
    }

    private function suratStorageDisk(?string $path): ?string
    {
        return app(SuratAbsensiFileService::class)->diskFor($path);
    }

    public function mapelKelas()
    {
        $guru = Guru::where('user_id', auth()->id())->first();
        if (!$guru) {
            return response()->json(['success' => false, 'message' => 'Profil guru tidak ditemukan.'], 404);
        }

        $this->expireStaleAbsensiSessions($guru->id);

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
            'mode_lokasi' => 'nullable|in:mts,bebas',
            'lokasi_latitude' => 'nullable|numeric|between:-90,90',
            'lokasi_longitude' => 'nullable|numeric|between:-180,180',
            'radius_meter' => 'nullable|integer|min:50|max:500',
            'toleransi_keterlambatan' => 'sometimes|boolean',
        ]);

        $validated['mode_lokasi'] = $validated['mode_lokasi'] ?? 'mts';

        // For school mode, the server owns the geofence center. Never trust
        // arbitrary coordinates sent by the teacher's device.
        if ($validated['mode_lokasi'] === 'mts') {
            $validated['lokasi_latitude'] = (float) config('absensi.lokasi_sekolah.latitude');
            $validated['lokasi_longitude'] = (float) config('absensi.lokasi_sekolah.longitude');
            $validated['radius_meter'] = $validated['radius_meter']
                ?? (int) config('absensi.default_radius_meter', 150);
        } else {
            $validated['lokasi_latitude'] = null;
            $validated['lokasi_longitude'] = null;
            $validated['radius_meter'] = (int) config('absensi.default_radius_meter', 150);
        }

        $guru = Guru::where('user_id', auth()->id())->firstOrFail();

        // Lock the schedule row while checking/creating the active session. This
        // prevents two simultaneous Start requests from creating two sessions.
        $result = DB::transaction(function () use ($guru, $validated) {
            $jadwal = JadwalPelajaran::where('guru_id', $guru->id)
                ->with(['guru', 'kelas', 'mataPelajaran'])
                ->lockForUpdate()
                ->findOrFail($validated['jadwal_id']);

            $this->expireStaleAbsensiSessions($guru->id, $jadwal->id);

            $existingSession = AbsensiSesi::where('jadwal_id', $jadwal->id)
                ->where('status', 'aktif')
                ->lockForUpdate()
                ->first();
            if ($existingSession) {
                return ['existing' => $existingSession, 'session' => null];
            }

            $expiredAt = Carbon::now('UTC')->addMinutes(30);
            if (! empty($validated['toleransi_keterlambatan'])) {
                $expiredAt->addMinutes(15);
            }

            $sesi = AbsensiSesi::create([
                'jadwal_id' => $jadwal->id,
                'guru_id' => $guru->id,
                'kelas_id' => $jadwal->kelas_id,
                'mode_lokasi' => $validated['mode_lokasi'] ?? 'mts',
                'lokasi_latitude' => $validated['lokasi_latitude'],
                'lokasi_longitude' => $validated['lokasi_longitude'],
                'radius_meter' => $validated['radius_meter'],
                'toleransi_keterlambatan' => ! empty($validated['toleransi_keterlambatan']),
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
                'expired_at' => $expiredAt->copy()->setTimezone('Asia/Jakarta')->toISOString(),
                'kelas' => $jadwal->kelas?->nama_kelas,
                'mapel' => $jadwal->mataPelajaran?->nama,
                'guru' => $guru->nama_lengkap,
                'mode_lokasi' => $sesi->mode_lokasi,
            ], JSON_UNESCAPED_UNICODE);

            $sesi->update(['qr_data' => $qrData]);

            return ['existing' => null, 'session' => $sesi->fresh()];
        });

        if ($result['existing']) {
            return response()->json([
                'success' => false,
                'message' => 'Sesi absensi masih aktif untuk jadwal ini.',
                'data' => ['sesi_id' => $result['existing']->id, 'status' => 'aktif'],
            ], 409);
        }

        $sesi = $result['session'];
        return response()->json([
            'success' => true,
            'message' => 'Sesi absensi dimulai',
            'data' => [
                'sesi_id' => $sesi->id,
                'session_id' => (string) $sesi->id,
                'qr_code' => null,
                'qr_data' => $sesi->qr_data,
                'expired_at' => $sesi->expired_at?->copy()->setTimezone('Asia/Jakarta')->toISOString(),
                'status' => 'aktif',
            ],
        ], 201);
    }

    public function stopSession(Request $request)
    {
        $validated = $request->validate(['sesi_id' => 'required|integer']);
        $guru = Guru::where('user_id', auth()->id())->firstOrFail();
        $this->expireStaleAbsensiSessions($guru->id);
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
        $this->expireStaleAbsensiSessions($guru->id);
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
        $this->expireStaleAbsensiSessions($guru->id);
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
                'mode_lokasi' => $sesi->mode_lokasi ?? 'mts',
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
        $this->expireStaleAbsensiSessions($guru->id);
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
            'mode_lokasi' => $sesi->mode_lokasi ?? 'mts',
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
        $this->expireStaleAbsensiSessions($guru->id);
        $sesi = AbsensiSesi::where('guru_id', $guru->id)->with('jadwal')->findOrFail($id);
        $tanggal = $sesi->created_at->copy()->setTimezone('Asia/Jakarta')->toDateString();
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

        $this->expireStaleAbsensiSessions($guru->id);

        $query = AbsensiSesi::with(['jadwal.kelas', 'jadwal.mataPelajaran', 'guru'])
            ->where('guru_id', $guru->id)
            ->orderBy('created_at', 'desc');

        $totalSessions = (clone $query)->reorder()->count();
        $activeSessions = (clone $query)->reorder()->where('status', 'aktif')->count();
        $completedSessions = (clone $query)->reorder()->where('status', 'selesai')->count();
        $sesis = $query->paginate(20);

        $report = $sesis->getCollection()->map(function ($sesi) {
            $tanggalSekolah = $sesi->created_at->copy()->setTimezone('Asia/Jakarta')->toDateString();
            $createdAtSekolah = $sesi->created_at->copy()->setTimezone('Asia/Jakarta');
            $expiredAtSekolah = $sesi->expired_at?->copy()->setTimezone('Asia/Jakarta');
            $totalSiswa = $sesi->jadwal->kelas->siswa->count();
            $hadir = $sesi->absensiHarian()
                ->where('status', 'hadir')
                ->whereDate('tanggal', $tanggalSekolah)
                ->count();
            $izin = $sesi->absensiHarian()
                ->where('status', 'izin')
                ->whereDate('tanggal', $tanggalSekolah)
                ->count();
            $sakit = $sesi->absensiHarian()
                ->where('status', 'sakit')
                ->whereDate('tanggal', $tanggalSekolah)
                ->count();
            $alpa = $sesi->absensiHarian()
                ->where('status', 'alpa')
                ->whereDate('tanggal', $tanggalSekolah)
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
                'created_at' => $createdAtSekolah->format('d M Y H:i'),
                'expired_at' => $expiredAtSekolah?->format('H:i'),
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
        $today = Carbon::now('Asia/Jakarta')->toDateString();
        $hadirHariIni = AbsensiHarian::whereHas('jadwal', function ($q) use ($guru) {
            $q->where('guru_id', $guru->id);
        })->where('tanggal', $today)->where('status', 'hadir')->count();

        // Jumlah pengumpulan yang belum dinilai, termasuk pengumpulan terlambat.
        // Hitung per pengumpulan agar tugas dengan sebagian siswa sudah dinilai
        // tetap menampilkan sisa pekerjaan koreksi yang belum selesai.
        $tugasMenunggu = PengumpulanTugas::whereHas('penugasan.jadwal', function ($q) use ($guru) {
            $q->where('guru_id', $guru->id);
        })->whereDoesntHave('nilai')->count();

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
            'file' => 'nullable|file|max:10240',
            'link' => 'nullable|url|max:2048',
        ]);

        $jadwal = JadwalPelajaran::where('guru_id', $guru->id)
            ->with(['kelas', 'mataPelajaran'])
            ->find($validated['jadwal_id']);
        if (!$jadwal) {
            return response()->json([
                'success' => false,
                'message' => 'Jadwal tersebut bukan bagian dari kelas mengajar Anda.',
            ], 403);
        }

        $filePath = null;
        $link = null;
        if ($validated['tipe'] === 'link') {
            if ($request->hasFile('file')) {
                return response()->json([
                    'success' => false,
                    'message' => 'Materi bertipe link tidak boleh menyertakan file.',
                    'errors' => ['file' => ['Hapus lampiran atau pilih tipe PDF/video.']],
                ], 422);
            }

            $request->validate(['link' => 'required|url|max:2048']);
            $link = (string) $request->input('link');
            $scheme = strtolower((string) parse_url($link, PHP_URL_SCHEME));
            if (!in_array($scheme, ['http', 'https'], true)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Tautan materi harus menggunakan HTTP atau HTTPS.',
                    'errors' => ['link' => ['Gunakan URL yang diawali http:// atau https://.']],
                ], 422);
            }
        } else {
            if (filled($request->input('link'))) {
                return response()->json([
                    'success' => false,
                    'message' => 'Materi PDF/video tidak boleh menyertakan tautan.',
                    'errors' => ['link' => ['Kosongkan tautan atau pilih tipe Link.']],
                ], 422);
            }

            $request->validate([
                'file' => $validated['tipe'] === 'pdf'
                    ? 'required|file|mimes:pdf|max:10240'
                    : 'required|file|mimes:mp4,mov,webm|max:10240',
            ]);
            $filePath = $request->file('file')->store('materi', 'public');
            if (!$filePath) {
                throw new \RuntimeException('File materi gagal disimpan.');
            }
        }

        try {
            $materi = DB::transaction(function () use ($jadwal, $guru, $validated, $filePath, $link) {
                return \App\Models\Materi::create([
                    'jadwal_id' => $jadwal->id,
                    'guru_id' => $guru->id,
                    'judul' => $validated['judul'],
                    'deskripsi' => $validated['deskripsi'] ?? null,
                    'tipe' => $validated['tipe'],
                    'file_path' => $filePath,
                    'link' => $link,
                ])->load(['jadwal.kelas', 'jadwal.mataPelajaran']);
            });
        } catch (\Throwable $exception) {
            if ($filePath) {
                Storage::disk('public')->delete($filePath);
            }
            throw $exception;
        }

        app(MatsanamNotificationService::class)->notifyClassStudents(
            (int) $jadwal->kelas_id,
            'materi_baru',
            'Materi baru tersedia',
            $guru->nama_lengkap . ' menerbitkan materi "' . $materi->judul . '" untuk ' . ($jadwal->mataPelajaran?->nama ?? 'mata pelajaran') . '.',
            [
                'materi_id' => $materi->id,
                'mapel_id' => $jadwal->mapel_id,
                'jadwal_id' => $jadwal->id,
                'class_id' => $jadwal->kelas_id,
            ],
        );

        return response()->json([
            'success' => true,
            'data' => $materi,
            'message' => 'Materi berhasil ditambahkan.',
        ], 201);
    }

    public function materiUpdate(Request $request, $id)
    {
        $guru = Guru::where('user_id', auth()->id())->firstOrFail();
        $validated = $request->validate([
            'judul' => 'sometimes|required|string|max:255',
            'deskripsi' => 'sometimes|nullable|string',
            'tipe' => 'sometimes|required|in:pdf,video,link',
            'link' => 'nullable|url|max:2048',
            'file' => 'nullable|file|max:10240',
        ]);

        $materi = \App\Models\Materi::whereHas('jadwal', function ($query) use ($guru) {
            $query->where('guru_id', $guru->id);
        })->findOrFail($id);
        $targetType = $validated['tipe'] ?? $materi->tipe;
        $link = null;
        $newFilePath = null;

        if ($targetType === 'link') {
            if ($request->hasFile('file')) {
                return response()->json([
                    'success' => false,
                    'message' => 'Materi bertipe link tidak boleh menyertakan file.',
                    'errors' => ['file' => ['Hapus lampiran atau pilih tipe PDF/video.']],
                ], 422);
            }
            $link = $validated['link'] ?? $materi->link;
            if (!$link || !filter_var($link, FILTER_VALIDATE_URL) ||
                !in_array(strtolower((string) parse_url($link, PHP_URL_SCHEME)), ['http', 'https'], true)) {
                return response()->json([
                    'success' => false,
                    'message' => 'URL wajib diisi untuk materi bertipe link dan harus memakai HTTP/HTTPS.',
                    'errors' => ['link' => ['Masukkan URL http:// atau https:// yang valid.']],
                ], 422);
            }
        } else {
            if (filled($request->input('link'))) {
                return response()->json([
                    'success' => false,
                    'message' => 'Materi PDF/video tidak boleh menyertakan tautan.',
                    'errors' => ['link' => ['Kosongkan tautan atau pilih tipe Link.']],
                ], 422);
            }

            if ($request->hasFile('file')) {
                $request->validate([
                    'file' => $targetType === 'pdf'
                        ? 'required|file|mimes:pdf|max:10240'
                        : 'required|file|mimes:mp4,mov,webm|max:10240',
                ]);
                $newFilePath = $request->file('file')->store('materi', 'public');
                if (!$newFilePath) {
                    throw new \RuntimeException('File materi pengganti gagal disimpan.');
                }
            } elseif ($targetType !== $materi->tipe || blank($materi->file_path)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unggah file baru untuk tipe materi yang dipilih.',
                    'errors' => ['file' => ['File wajib diunggah untuk tipe materi ini.']],
                ], 422);
            }
        }

        try {
            $result = DB::transaction(function () use ($guru, $id, $validated, $targetType, $link, $newFilePath) {
                $lockedMateri = \App\Models\Materi::whereHas('jadwal', function ($query) use ($guru) {
                    $query->where('guru_id', $guru->id);
                })->lockForUpdate()->findOrFail($id);

                if ($targetType !== 'link' && !$newFilePath &&
                    ($targetType !== $lockedMateri->tipe || blank($lockedMateri->file_path))) {
                    abort(422, 'Unggah file baru untuk tipe materi yang dipilih.');
                }

                $oldFilePath = $lockedMateri->file_path;
                $lockedMateri->fill(collect($validated)->only(['judul', 'deskripsi'])->all());
                $lockedMateri->tipe = $targetType;

                if ($targetType === 'link') {
                    $lockedMateri->link = $link;
                    $lockedMateri->file_path = null;
                } else {
                    $lockedMateri->link = null;
                    if ($newFilePath) {
                        $lockedMateri->file_path = $newFilePath;
                    }
                }

                $lockedMateri->save();
                $lockedMateri->load(['jadwal.kelas', 'jadwal.mataPelajaran']);

                return [
                    'materi' => $lockedMateri,
                    'old_file' => $oldFilePath,
                    'new_file' => $lockedMateri->file_path,
                ];
            });
        } catch (\Throwable $exception) {
            if ($newFilePath) {
                Storage::disk('public')->delete($newFilePath);
            }
            throw $exception;
        }

        if ($result['old_file'] && $result['old_file'] !== $result['new_file']) {
            Storage::disk('public')->delete($result['old_file']);
        }

        return response()->json([
            'success' => true,
            'data' => $result['materi'],
            'message' => 'Materi berhasil diperbarui.',
        ]);
    }

    public function materiFile($id)
    {
        $guru = Guru::where('user_id', auth()->id())->firstOrFail();
        $materi = \App\Models\Materi::whereHas('jadwal', function ($query) use ($guru) {
            $query->where('guru_id', $guru->id);
        })->findOrFail($id);

        abort_if(blank($materi->file_path), 404, 'Berkas materi tidak tersedia.');
        abort_unless(Storage::disk('public')->exists($materi->file_path), 404, 'Berkas materi tidak ditemukan.');

        return Storage::disk('public')->download($materi->file_path, basename($materi->file_path));
    }

    public function materiDestroy($id)
    {
        $guru = Guru::where('user_id', auth()->id())->firstOrFail();
        $result = DB::transaction(function () use ($guru, $id) {
            $materi = \App\Models\Materi::whereHas('jadwal', function ($query) use ($guru) {
                $query->where('guru_id', $guru->id);
            })->lockForUpdate()->findOrFail($id);
            $filePath = $materi->file_path;
            $materi->delete();
            return $filePath;
        });

        if ($result) {
            Storage::disk('public')->delete($result);
        }

        return response()->json(['success' => true, 'message' => 'Materi berhasil dihapus.']);
    }

    /** Build attachment metadata while retaining the legacy single file_materi field. */
    private function taskAttachmentPayload(Penugasan $tugas, string $role = 'guru'): array
    {
        $tugas->loadMissing('files');
        $base = $role === 'siswa' ? '/api/siswa/tugas/' : '/api/guru/tugas/';
        $files = $tugas->files->map(function ($file) use ($tugas, $base) {
            $disk = $file->disk ?: 'public';
            $storage = Storage::disk($disk);
            return [
                'id' => (string) $file->id,
                'file_name' => $file->original_name,
                'file_url' => url($base . $tugas->id . '/files/' . $file->id),
                'mime_type' => $file->mime_type,
                'size_bytes' => (int) $file->size_bytes,
                'is_legacy' => false,
                'available' => $storage->exists($file->file_path),
            ];
        })->values()->all();

        if (filled($tugas->file_materi)) {
            $legacyPath = $tugas->file_materi;
            $legacyAlreadyInRelation = $tugas->files->contains(
                fn ($file) => $file->file_path === $legacyPath,
            );
            if (!$legacyAlreadyInRelation) {
                $storage = Storage::disk('public');
                $files[] = [
                    'id' => 'legacy',
                    'file_name' => basename($legacyPath),
                    'file_url' => url($base . $tugas->id . '/files/legacy'),
                    'mime_type' => $storage->exists($legacyPath) ? $storage->mimeType($legacyPath) : null,
                    'size_bytes' => $storage->exists($legacyPath) ? (int) $storage->size($legacyPath) : null,
                    'is_legacy' => true,
                    'available' => $storage->exists($legacyPath),
                ];
            }
        }

        return array_values($files);
    }

    private function storeTaskAttachmentFiles(Penugasan $tugas, array $uploadedFiles, array &$storedPaths): void
    {
        foreach ($uploadedFiles as $file) {
            if (!$file) {
                continue;
            }
            $path = $file->store('tugas', 'public');
            $storedPaths[] = $path;
            $tugas->files()->create([
                'disk' => 'public',
                'file_path' => $path,
                'original_name' => basename(str_replace('\\', '/', $file->getClientOriginalName())),
                'mime_type' => $file->getMimeType(),
                'size_bytes' => (int) $file->getSize(),
            ]);
        }
    }

    public function tugasIndex()
    {
        $guru = Guru::where('user_id', auth()->id())->first();
        if (!$guru) return response()->json(['success' => false, 'message' => 'Profil guru tidak ditemukan.'], 404);

        $tugas = Penugasan::whereHas('jadwal', function ($q) use ($guru) {
            $q->where('guru_id', $guru->id);
        })->with(['jadwal.kelas', 'jadwal.mataPelajaran', 'files'])->latest()->get();

        $tugas->each(function ($item) {
            $item->setAttribute('lampiran_files', $this->taskAttachmentPayload($item));
        });

        return response()->json(['success' => true, 'data' => $tugas]);
    }

    public function tugasStore(Request $request)
    {
        $guru = Guru::where('user_id', auth()->id())->first();
        if (!$guru) {
            return response()->json(['success' => false, 'message' => 'Profil guru tidak ditemukan.'], 404);
        }

        $validated = $request->validate([
            'jadwal_id' => 'required|integer|exists:jadwal_pelajaran,id',
            'judul' => 'required|string|max:255',
            'deskripsi' => 'required|string',
            'jenis' => 'required|in:tugas,quiz,uts,uas',
            'deadline' => 'required|date',
            'bobot' => 'nullable|integer|min:1|max:100',
            'client_request_id' => 'nullable|string|max:80',
            // A limit of 20 MB applies to each selected attachment.
            'files' => 'sometimes|array|max:20',
            'files.*' => 'file|mimes:pdf,doc,docx,ppt,pptx,xls,xlsx,jpg,jpeg,png,txt,zip|max:20480',
            // Backward compatibility for older app builds that send one `file`.
            'file' => 'nullable|file|mimes:pdf,doc,docx,ppt,pptx,xls,xlsx,jpg,jpeg,png,txt,zip|max:20480',
        ]);

        // Reuse the same request key on a retry after a network timeout so
        // the same task is returned instead of being created a second time.
        $clientRequestId = $validated['client_request_id'] ?? null;
        if ($clientRequestId) {
            $existingTask = Penugasan::where('guru_id', $guru->id)
                ->where('client_request_id', $clientRequestId)
                ->with(['jadwal.kelas', 'jadwal.mataPelajaran', 'files'])
                ->first();
            if ($existingTask) {
                $existingTask->setAttribute('lampiran_files', $this->taskAttachmentPayload($existingTask));
                return response()->json([
                    'success' => true,
                    'data' => $existingTask,
                    'message' => 'Tugas sudah tersimpan dari percobaan sebelumnya.',
                ]);
            }
        }

        $jadwal = JadwalPelajaran::where('guru_id', $guru->id)
            ->with(['kelas', 'mataPelajaran'])
            ->find($validated['jadwal_id']);
        if (!$jadwal) {
            return response()->json([
                'success' => false,
                'message' => 'Jadwal tersebut bukan bagian dari kelas mengajar Anda.',
            ], 403);
        }

        $storedPaths = [];
        try {
            $legacyPath = $request->hasFile('file')
                ? $request->file('file')->store('tugas', 'public')
                : null;
            if ($legacyPath) {
                $storedPaths[] = $legacyPath;
            }

            $tugas = DB::transaction(function () use ($request, $validated, $jadwal, $guru, $legacyPath, $clientRequestId, &$storedPaths) {
                $task = Penugasan::create([
                    'jadwal_id' => $jadwal->id,
                    'guru_id' => $guru->id,
                    'judul' => $validated['judul'],
                    'deskripsi' => $validated['deskripsi'],
                    'jenis' => $validated['jenis'],
                    'deadline' => $validated['deadline'],
                    'bobot' => $validated['bobot'] ?? 100,
                    'file_materi' => $legacyPath,
                    'client_request_id' => $clientRequestId,
                ]);
                $this->storeTaskAttachmentFiles($task, $request->file('files', []), $storedPaths);
                return $task->load(['jadwal.kelas', 'jadwal.mataPelajaran', 'files']);
            });
        } catch (\Throwable $exception) {
            foreach (array_unique($storedPaths) as $path) {
                Storage::disk('public')->delete($path);
            }
            throw $exception;
        }

        $tugas->setAttribute('lampiran_files', $this->taskAttachmentPayload($tugas));
        app(MatsanamNotificationService::class)->notifyClassStudents(
            (int) $jadwal->kelas_id,
            'tugas_baru',
            'Tugas baru diberikan',
            $guru->nama_lengkap . ' memberikan tugas "' . $tugas->judul . '" untuk ' . ($jadwal->mataPelajaran?->nama ?? 'mata pelajaran') . '.',
            [
                'tugas_id' => $tugas->id,
                'mapel_id' => $jadwal->mapel_id,
                'jadwal_id' => $jadwal->id,
                'class_id' => $jadwal->kelas_id,
                'deadline' => $tugas->deadline?->toIso8601String(),
            ],
        );

        return response()->json([
            'success' => true,
            'data' => $tugas,
            'message' => 'Tugas berhasil ditambahkan.',
        ], 201);
    }

    public function tugasUpdate(Request $request, $id)
    {
        $guru = Guru::where('user_id', auth()->id())->firstOrFail();
        $tugas = Penugasan::whereHas('jadwal', function ($query) use ($guru) {
            $query->where('guru_id', $guru->id);
        })->with('files')->findOrFail($id);

        $validated = $request->validate([
            'judul' => 'sometimes|required|string|max:255',
            'deskripsi' => 'sometimes|required|string',
            'jenis' => 'sometimes|required|in:tugas,quiz,uts,uas',
            'deadline' => 'sometimes|required|date',
            'bobot' => 'sometimes|required|integer|min:1|max:100',
            'attachment_batch_id' => 'nullable|string|max:80',
            'files' => 'sometimes|array|max:20',
            'files.*' => 'file|mimes:pdf,doc,docx,ppt,pptx,xls,xlsx,jpg,jpeg,png,txt,zip|max:20480',
            'file' => 'nullable|file|mimes:pdf,doc,docx,ppt,pptx,xls,xlsx,jpg,jpeg,png,txt,zip|max:20480',
        ]);

        $attachmentBatchId = $validated['attachment_batch_id'] ?? null;
        if ($attachmentBatchId && $tugas->last_attachment_batch_id === $attachmentBatchId) {
            $tugas->setAttribute('lampiran_files', $this->taskAttachmentPayload($tugas));
            return response()->json([
                'success' => true,
                'data' => $tugas,
                'message' => 'Perubahan tugas dan lampiran sudah tersimpan dari percobaan sebelumnya.',
            ]);
        }

        $oldLegacyPath = $tugas->file_materi;
        $storedPaths = [];
        try {
            $newLegacyPath = $request->hasFile('file')
                ? $request->file('file')->store('tugas', 'public')
                : null;
            if ($newLegacyPath) {
                $storedPaths[] = $newLegacyPath;
            }

            DB::transaction(function () use ($request, $validated, $tugas, $newLegacyPath, $attachmentBatchId, &$storedPaths) {
                $tugas->fill(collect($validated)->only([
                    'judul', 'deskripsi', 'jenis', 'deadline', 'bobot',
                ])->all());
                if ($newLegacyPath) {
                    $tugas->file_materi = $newLegacyPath;
                }
                if ($attachmentBatchId) {
                    $tugas->last_attachment_batch_id = $attachmentBatchId;
                }
                $tugas->save();
                $this->storeTaskAttachmentFiles($tugas, $request->file('files', []), $storedPaths);
            });
        } catch (\Throwable $exception) {
            foreach (array_unique($storedPaths) as $path) {
                Storage::disk('public')->delete($path);
            }
            throw $exception;
        }

        if ($newLegacyPath && $oldLegacyPath && $oldLegacyPath !== $newLegacyPath) {
            Storage::disk('public')->delete($oldLegacyPath);
        }

        $tugas->refresh()->load(['jadwal.kelas', 'jadwal.mataPelajaran', 'files']);
        $tugas->setAttribute('lampiran_files', $this->taskAttachmentPayload($tugas));

        return response()->json([
            'success' => true,
            'data' => $tugas,
            'message' => 'Tugas berhasil diperbarui.',
        ]);
    }

    public function tugasFile($id)
    {
        $guru = Guru::where('user_id', auth()->id())->firstOrFail();
        $tugas = Penugasan::whereHas('jadwal', function ($query) use ($guru) {
            $query->where('guru_id', $guru->id);
        })->findOrFail($id);

        abort_if(blank($tugas->file_materi), 404, 'Lampiran tugas tidak tersedia.');
        abort_unless(Storage::disk('public')->exists($tugas->file_materi), 404, 'Lampiran tugas tidak ditemukan.');

        return Storage::disk('public')->download($tugas->file_materi, basename($tugas->file_materi));
    }

    public function tugasAttachmentFile($id, string $fileId)
    {
        $guru = Guru::where('user_id', auth()->id())->firstOrFail();
        $tugas = Penugasan::whereHas('jadwal', function ($query) use ($guru) {
            $query->where('guru_id', $guru->id);
        })->findOrFail($id);

        if ($fileId === 'legacy') {
            return $this->tugasFile($id);
        }

        $attachment = $tugas->files()->findOrFail($fileId);
        $disk = Storage::disk($attachment->disk ?: 'public');
        abort_unless($disk->exists($attachment->file_path), 404, 'Lampiran tugas tidak ditemukan.');

        return $disk->download($attachment->file_path, $attachment->original_name);
    }

    public function deleteTugasAttachment($id, string $fileId)
    {
        $guru = Guru::where('user_id', auth()->id())->firstOrFail();
        $tugas = Penugasan::whereHas('jadwal', function ($query) use ($guru) {
            $query->where('guru_id', $guru->id);
        })->findOrFail($id);

        if ($fileId === 'legacy') {
            $path = $tugas->file_materi;
            abort_if(blank($path), 404, 'Lampiran lama tidak tersedia.');
            $tugas->file_materi = null;
            $tugas->save();
            Storage::disk('public')->delete($path);
            return response()->json(['success' => true, 'message' => 'Lampiran berhasil dihapus.']);
        }

        $attachment = $tugas->files()->findOrFail($fileId);
        $path = $attachment->file_path;
        $diskName = $attachment->disk ?: 'public';
        $attachment->delete();
        Storage::disk($diskName)->delete($path);

        return response()->json(['success' => true, 'message' => 'Lampiran berhasil dihapus.']);
    }

    public function deleteAllTugasAttachments($id)
    {
        $guru = Guru::where('user_id', auth()->id())->firstOrFail();
        $tugas = Penugasan::whereHas('jadwal', function ($query) use ($guru) {
            $query->where('guru_id', $guru->id);
        })->with('files')->findOrFail($id);

        $paths = $tugas->files->map(fn ($file) => [
            'disk' => $file->disk ?: 'public',
            'path' => $file->file_path,
        ])->all();
        if (filled($tugas->file_materi)) {
            $paths[] = ['disk' => 'public', 'path' => $tugas->file_materi];
        }

        DB::transaction(function () use ($tugas) {
            $tugas->files()->delete();
            $tugas->file_materi = null;
            $tugas->save();
        });

        foreach ($paths as $entry) {
            Storage::disk($entry['disk'])->delete($entry['path']);
        }

        return response()->json(['success' => true, 'message' => 'Semua lampiran tugas berhasil dihapus.']);
    }

    public function tugasDestroy($id)
    {
        $guru = Guru::where('user_id', auth()->id())->firstOrFail();
        $result = DB::transaction(function () use ($guru, $id) {
            $tugas = Penugasan::whereHas('jadwal', function ($query) use ($guru) {
                $query->where('guru_id', $guru->id);
            })->lockForUpdate()->findOrFail($id);

            if ($tugas->pengumpulan()->exists()) {
                return ['deleted' => false, 'files' => []];
            }

            $filePaths = $tugas->files()->get(['disk', 'file_path'])->map(fn ($file) => [
                'disk' => $file->disk ?: 'public',
                'path' => $file->file_path,
            ])->all();
            if (filled($tugas->file_materi)) {
                $filePaths[] = ['disk' => 'public', 'path' => $tugas->file_materi];
            }
            $tugas->delete();

            return ['deleted' => true, 'files' => $filePaths];
        });

        if (! $result['deleted']) {
            return response()->json([
                'success' => false,
                'message' => 'Tugas tidak dapat dihapus karena sudah memiliki pengumpulan siswa.',
            ], 409);
        }

        foreach ($result['files'] as $entry) {
            Storage::disk($entry['disk'])->delete($entry['path']);
        }

        return response()->json([
            'success' => true,
            'message' => 'Tugas berhasil dihapus.',
        ]);
    }

    public function tugasByJadwal($jadwalId)
    {
        $guru = Guru::where('user_id', auth()->id())->firstOrFail();
        $jadwal = JadwalPelajaran::where('guru_id', $guru->id)->findOrFail($jadwalId);
        $tugas = Penugasan::where('jadwal_id', $jadwal->id)
            ->with([
                'jadwal.kelas',
                'jadwal.mataPelajaran',
                'files',
                // A task belongs to one class. Ignore legacy/orphan submission
                // rows whose student is no longer in that class so the detail
                // sheet and the full student roster report the same totals.
                'pengumpulan' => function ($query) use ($jadwal) {
                    $query->whereHas('siswa', function ($studentQuery) use ($jadwal) {
                        $studentQuery->where('kelas_id', $jadwal->kelas_id);
                    })->with(['siswa', 'nilai']);
                },
            ])
            ->latest()
            ->get();

        $tugas->each(function ($item) {
            $item->setAttribute('lampiran_files', $this->taskAttachmentPayload($item));
        });

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
                $kelasId = $jadwal?->kelas_id;
                $pengumpulan = $item->pengumpulan
                    ->filter(fn ($submission) => $kelasId !== null
                        && (int) $submission->siswa?->kelas_id === (int) $kelasId)
                    ->values();

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

        $kelasId = $tugas->jadwal?->kelas_id;
        $tugas->setRelation(
            'pengumpulan',
            $tugas->pengumpulan
                ->filter(fn ($submission) => $kelasId !== null
                    && (int) $submission->siswa?->kelas_id === (int) $kelasId)
                ->values(),
        );

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
            ->with(['siswa', 'penugasan.jadwal'])
            ->firstOrFail();

        // Do not allow grading legacy submissions from outside the task's class.
        abort_unless(
            $pengumpulan->siswa !== null
                && $pengumpulan->penugasan?->jadwal !== null
                && (int) $pengumpulan->siswa->kelas_id === (int) $pengumpulan->penugasan->jadwal->kelas_id,
            404,
            'Pengumpulan tidak termasuk kelas tugas ini.',
        );

        $nilai = \App\Models\Nilai::updateOrCreate(
            ['pengumpulan_id' => $pengumpulan->id],
            [
                'nilai' => $validated['nilai'],
                'catatan' => $validated['catatan'] ?? null,
                'guru_id' => $guru->id,
                'tanggal_penilaian' => now(),
            ]
        );

        $pengumpulan->loadMissing(['siswa.user', 'penugasan']);
        app(MatsanamNotificationService::class)->send(
            $pengumpulan->siswa?->user,
            'nilai_diterbitkan',
            'Nilai tugas telah tersedia',
            'Tugas "' . ($pengumpulan->penugasan?->judul ?? 'Tugas') . '" telah dinilai oleh ' . $guru->nama_lengkap . '.',
            [
                'tugas_id' => $pengumpulan->penugasan_id,
                'pengumpulan_id' => $pengumpulan->id,
                'nilai_id' => $nilai->id,
                'nilai' => (float) $nilai->nilai,
            ],
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
        if (! $guru) {
            return response()->json(['success' => false, 'message' => 'Profil guru tidak ditemukan.'], 404);
        }

        $status = strtolower((string) $request->query('status', ''));
        $allowedStatuses = ['', 'pending', 'disetujui', 'ditolak'];
        if (! in_array($status, $allowedStatuses, true)) {
            return response()->json(['success' => false, 'message' => 'Filter status tidak valid.'], 422);
        }

        $baseQuery = SuratAbsensi::with(['siswa.kelas', 'verifikator'])
            ->whereHas('siswa.kelas.jadwalPelajaran', function ($query) use ($guru) {
                $query->where('guru_id', $guru->id);
            });

        $summary = [
            'pending' => (clone $baseQuery)->where('status_verifikasi', 'pending')->count(),
            'disetujui' => (clone $baseQuery)->where('status_verifikasi', 'disetujui')->count(),
            'ditolak' => (clone $baseQuery)->where('status_verifikasi', 'ditolak')->count(),
        ];

        $surats = (clone $baseQuery)
            ->when($status !== '', fn ($query) => $query->where('status_verifikasi', $status))
            ->orderByDesc('created_at')
            ->paginate(15)
            ->withQueryString();

        $files = app(SuratAbsensiFileService::class);
        $surats->getCollection()->transform(function ($surat) use ($files) {
            $hasDocument = $files->diskFor($surat->file_surat) !== null;

            return [
                'id' => $surat->id,
                'siswa' => [
                    'id' => $surat->siswa?->id,
                    'nama_lengkap' => $surat->siswa?->nama_lengkap,
                    'nis' => $surat->siswa?->nis,
                    'nisn' => $surat->siswa?->nisn,
                    'kelas' => $surat->siswa?->kelas?->nama_kelas,
                ],
                'jenis' => strtolower((string) $surat->jenis),
                'tanggal_mulai' => $surat->tanggal_mulai?->toDateString(),
                'tanggal_selesai' => $surat->tanggal_selesai?->toDateString(),
                'alasan' => $surat->alasan,
                'status_verifikasi' => strtolower((string) $surat->status_verifikasi),
                'tanggal_pengajuan' => $surat->created_at?->copy()->setTimezone('Asia/Jakarta')->toIso8601String(),
                'tanggal_verifikasi' => $surat->tanggal_verifikasi?->copy()->setTimezone('Asia/Jakarta')->toIso8601String(),
                'verifikator' => $surat->verifikator?->name,
                'catatan_verifikasi' => $surat->catatan_verifikasi,
                'ada_dokumen' => $hasDocument,
                'nama_file' => $hasDocument ? basename($surat->file_surat) : null,
                'dokumen_url' => $hasDocument ? url('/api/guru/surat-verifikasi/' . $surat->id . '/file') : null,
            ];
        });

        return response()->json([
            'success' => true,
            'data' => [
                'surats' => $surats,
                'summary' => $summary,
            ],
        ]);
    }

    public function suratFile(int $id)
    {
        $guru = Guru::where('user_id', auth()->id())->firstOrFail();
        $surat = SuratAbsensi::whereHas('siswa.kelas.jadwalPelajaran', function ($query) use ($guru) {
            $query->where('guru_id', $guru->id);
        })->findOrFail($id);
        abort_if(blank($surat->file_surat), 404, 'Dokumen surat tidak tersedia.');

        return app(SuratAbsensiFileService::class)->download($surat->file_surat);
    }

    public function approveSurat($id)
    {
        $guru = Guru::where('user_id', auth()->id())->firstOrFail();
        $surat = SuratAbsensi::whereHas('siswa.kelas.jadwalPelajaran', function ($query) use ($guru) {
            $query->where('guru_id', $guru->id);
        })->findOrFail($id);
        abort_unless(strtolower((string) $surat->status_verifikasi) === 'pending', 409, 'Surat sudah diproses sebelumnya.');
        $attendanceRows = app(SuratAbsensiApprovalService::class)->approve(
            $surat,
            (int) auth()->id(),
        );

        app(MatsanamNotificationService::class)->send(
            $surat->siswa?->user,
            'status_pengajuan_izin',
            'Pengajuan izin disetujui',
            'Pengajuan ' . $surat->jenis . ' untuk tanggal ' . $surat->tanggal_mulai?->format('d/m/Y') . ' sampai ' . $surat->tanggal_selesai?->format('d/m/Y') . ' telah disetujui.',
            ['surat_id' => $surat->id, 'status' => 'disetujui'],
        );

        return response()->json([
            'success' => true,
            'message' => 'Surat berhasil disetujui dan ' . $attendanceRows . ' catatan presensi diperbarui.',
            'data' => ['catatan_absensi_diperbarui' => $attendanceRows],
        ]);
    }

    public function rejectSurat(Request $request, $id)
    {
        $validated = $request->validate([
            'catatan' => 'required|string|max:500',
        ]);

        $guru = Guru::where('user_id', auth()->id())->firstOrFail();
        $surat = DB::transaction(function () use ($guru, $id, $validated) {
            $surat = SuratAbsensi::whereHas('siswa.kelas.jadwalPelajaran', function ($query) use ($guru) {
                $query->where('guru_id', $guru->id);
            })->lockForUpdate()->findOrFail($id);

            abort_unless(strtolower((string) $surat->status_verifikasi) === 'pending', 409, 'Surat sudah diproses sebelumnya.');
            $surat->update([
                'status_verifikasi' => 'ditolak',
                'verifikator_id' => auth()->id(),
                'tanggal_verifikasi' => now(),
                'catatan_verifikasi' => $validated['catatan'],
            ]);

            return $surat->load('siswa.user');
        });

        app(MatsanamNotificationService::class)->send(
            $surat->siswa?->user,
            'status_pengajuan_izin',
            'Pengajuan izin memerlukan perbaikan',
            'Pengajuan ' . $surat->jenis . ' ditolak. Catatan: ' . $validated['catatan'],
            ['surat_id' => $surat->id, 'status' => 'ditolak'],
        );

        return response()->json(['success' => true, 'message' => 'Surat ditolak', 'data' => ['id' => $surat->id, 'status_verifikasi' => 'ditolak']]);
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
            ->whereHas('siswa', function ($studentQuery) use ($jadwal) {
                $studentQuery->where('kelas_id', $jadwal->kelas_id);
            })
            ->with(['nilai', 'files'])
            ->get()
            ->keyBy('siswa_id');

        $students = Siswa::where('kelas_id', $jadwal->kelas_id)
            ->orderBy('nama_lengkap')
            ->get()
            ->map(function ($student) use ($submissions) {
                $submission = $submissions->get($student->id);
                $nilai = $submission?->nilai;
                $attachments = $submission?->files?->map(function ($file) use ($submission) {
                    return [
                        'id' => $file->id,
                        'name' => $file->original_name,
                        'url' => url('/api/guru/pengumpulan/' . $submission->id . '/lampiran/' . $file->id),
                        'mime_type' => $file->mime_type,
                        'size_bytes' => (int) $file->size_bytes,
                    ];
                })->values() ?? collect();

                if ($attachments->isEmpty() && filled($submission?->file_jawaban)) {
                    $attachments = collect([[
                        'id' => null,
                        'name' => basename($submission->file_jawaban),
                        'url' => url('/api/guru/pengumpulan/' . $submission->id . '/file'),
                        'mime_type' => Storage::disk('local')->mimeType($submission->file_jawaban),
                        'size_bytes' => Storage::disk('local')->exists($submission->file_jawaban)
                            ? (int) Storage::disk('local')->size($submission->file_jawaban)
                            : null,
                    ]]);
                }

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
                    'file_name' => $submission?->file_jawaban ? basename($submission->file_jawaban) : null,
                    'file_url' => $submission?->file_jawaban ? url('/api/guru/pengumpulan/' . $submission->id . '/file') : null,
                    'lampiran_files' => $attachments,
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



    /** Download one attachment from a submission belonging to this Guru's task. */
    public function submissionAttachmentFile($submissionId, $fileId)
    {
        $guru = Guru::where('user_id', auth()->id())->firstOrFail();
        $submission = PengumpulanTugas::whereKey($submissionId)
            ->whereHas('penugasan.jadwal', function ($query) use ($guru) {
                $query->where('guru_id', $guru->id);
            })
            ->with(['siswa', 'penugasan.jadwal'])
            ->firstOrFail();

        abort_unless(
            $submission->siswa !== null
                && $submission->penugasan?->jadwal !== null
                && (int) $submission->siswa->kelas_id === (int) $submission->penugasan->jadwal->kelas_id,
            404,
            'Pengumpulan tidak termasuk kelas tugas ini.',
        );

        $attachment = $submission->files()->whereKey($fileId)->firstOrFail();
        $disk = Storage::disk($attachment->disk ?: 'local');
        abort_unless($disk->exists($attachment->file_path), 404, 'Berkas pengumpulan tidak ditemukan.');

        return $disk->download($attachment->file_path, $attachment->original_name);
    }

    /** Download submission file only when it belongs to a task taught by this Guru. */
    public function submissionFile($submissionId)
    {
        $guru = Guru::where('user_id', auth()->id())->firstOrFail();
        $submission = PengumpulanTugas::whereKey($submissionId)
            ->whereHas('penugasan.jadwal', function ($query) use ($guru) {
                $query->where('guru_id', $guru->id);
            })
            ->with(['siswa', 'penugasan.jadwal'])
            ->firstOrFail();

        abort_unless(
            $submission->siswa !== null
                && $submission->penugasan?->jadwal !== null
                && (int) $submission->siswa->kelas_id === (int) $submission->penugasan->jadwal->kelas_id,
            404,
            'Pengumpulan tidak termasuk kelas tugas ini.',
        );

        abort_if(blank($submission->file_jawaban), 404, 'Berkas pengumpulan tidak tersedia.');
        abort_unless(Storage::disk('local')->exists($submission->file_jawaban), 404, 'Berkas pengumpulan tidak ditemukan.');

        return Storage::disk('local')->download($submission->file_jawaban, basename($submission->file_jawaban));
    }

}

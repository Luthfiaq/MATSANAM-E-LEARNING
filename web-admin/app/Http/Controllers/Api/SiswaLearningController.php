<?php

namespace App\Http\Controllers\Api;

use Barryvdh\DomPDF\Facade\Pdf;

use App\Http\Controllers\Controller;
use App\Models\AbsensiHarian;
use App\Models\AbsensiSesi;
use App\Models\JadwalPelajaran;
use App\Models\Materi;
use App\Models\MataPelajaran;
use App\Models\Penugasan;
use App\Models\PeriodeAkademik;
use App\Models\PengumpulanTugas;
use App\Models\Siswa;
use App\Models\SuratAbsensi;
use App\Services\SuratAbsensiFileService;
use App\Services\MatsanamNotificationService;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;

class SiswaLearningController extends Controller
{
    private function siswa(Request $request): Siswa
    {
        abort_unless($request->user()?->role === 'siswa', 403, 'Fitur ini hanya untuk akun siswa.');

        $siswa = Siswa::with('kelas')->where('user_id', $request->user()->id)->first();
        abort_unless($siswa, 404, 'Profil siswa tidak ditemukan.');

        return $siswa;
    }

    private function periodeAktif()
    {
        return PeriodeAkademik::where('is_active', true)->first();
    }

    private function jadwalKelasQuery(Siswa $siswa)
    {
        $query = JadwalPelajaran::query()->where('kelas_id', $siswa->kelas_id);
        $periode = $this->periodeAktif();

        if ($periode) {
            $query->where('periode_id', $periode->id);
        }

        return $query;
    }

    private function materiDalamKelas(Siswa $siswa, int $id): Materi
    {
        return Materi::with(['jadwal.kelas', 'jadwal.mataPelajaran', 'jadwal.guru', 'guru'])
            ->whereKey($id)
            ->whereHas('jadwal', function ($query) use ($siswa) {
                $query->where('kelas_id', $siswa->kelas_id);
                if ($periode = $this->periodeAktif()) {
                    $query->where('periode_id', $periode->id);
                }
            })
            ->firstOrFail();
    }

    private function penugasanDalamKelas(Siswa $siswa, int $id): Penugasan
    {
        return Penugasan::with(['jadwal.mataPelajaran', 'jadwal.guru', 'guru'])
            ->whereKey($id)
            ->whereHas('jadwal', function ($query) use ($siswa) {
                $query->where('kelas_id', $siswa->kelas_id);
                if ($periode = $this->periodeAktif()) {
                    $query->where('periode_id', $periode->id);
                }
            })
            ->firstOrFail();
    }

    public function mapel(Request $request)
    {
        $siswa = $this->siswa($request);
        $jadwalIds = $this->jadwalKelasQuery($siswa)->pluck('id');

        $items = MataPelajaran::query()
            ->whereHas('jadwalPelajaran', fn ($query) => $query->whereIn('id', $jadwalIds))
            ->with(['jadwalPelajaran' => fn ($query) => $query
                ->whereIn('id', $jadwalIds)
                ->with('guru')])
            ->orderBy('nama')
            ->get()
            ->map(function (MataPelajaran $mapel) use ($jadwalIds) {
                $jadwals = $mapel->jadwalPelajaran;
                $guru = $jadwals->map(fn ($jadwal) => $jadwal->guru?->nama_lengkap)
                    ->filter()->unique()->values();

                return [
                    'id' => $mapel->id,
                    'kode' => $mapel->kode,
                    'nama' => $mapel->nama,
                    'kkm' => (int) $mapel->kkm,
                    'guru' => $guru->implode(', '),
                    'jumlah_materi' => Materi::whereIn('jadwal_id', $jadwals->pluck('id'))->count(),
                    'jumlah_tugas' => Penugasan::whereIn('jadwal_id', $jadwals->pluck('id'))->count(),
                ];
            })->values();

        return response()->json(['success' => true, 'data' => $items]);
    }

    public function materiIndex(Request $request)
    {
        $siswa = $this->siswa($request);
        $validated = $request->validate([
            'mapel_id' => ['nullable', 'integer', 'exists:mata_pelajaran,id'],
            'tipe' => ['nullable', Rule::in(['pdf', 'video', 'link'])],
            'q' => ['nullable', 'string', 'max:120'],
        ]);

        $query = Materi::with(['jadwal.kelas', 'jadwal.mataPelajaran', 'jadwal.guru', 'guru'])
            ->whereHas('jadwal', function ($jadwal) use ($siswa, $validated) {
                $jadwal->where('kelas_id', $siswa->kelas_id);
                if ($periode = $this->periodeAktif()) {
                    $jadwal->where('periode_id', $periode->id);
                }
                if (! empty($validated['mapel_id'])) {
                    $jadwal->where('mapel_id', $validated['mapel_id']);
                }
            })
            ->when(! empty($validated['tipe']), fn ($q) => $q->where('tipe', $validated['tipe']))
            ->when(! empty($validated['q']), fn ($q) => $q->where(function ($search) use ($validated) {
                $term = trim($validated['q']);
                $search->where('judul', 'like', "%{$term}%")
                    ->orWhere('deskripsi', 'like', "%{$term}%");
            }))
            ->latest();

        $materi = $query->get()->map(fn (Materi $item) => $this->formatMateri($item));

        return response()->json(['success' => true, 'data' => $materi]);
    }

    public function materiShow(Request $request, int $id)
    {
        $materi = $this->materiDalamKelas($this->siswa($request), $id);

        return response()->json(['success' => true, 'data' => $this->formatMateri($materi, true)]);
    }

    public function materiFile(Request $request, int $id)
    {
        $materi = $this->materiDalamKelas($this->siswa($request), $id);
        abort_if(blank($materi->file_path), 404, 'Berkas materi tidak tersedia.');
        abort_unless(Storage::disk('public')->exists($materi->file_path), 404, 'Berkas materi tidak ditemukan.');

        return Storage::disk('public')->response($materi->file_path, basename($materi->file_path));
    }

    private function formatMateri(Materi $materi, bool $detail = false): array
    {
        $jadwal = $materi->jadwal;
        $data = [
            'id' => $materi->id,
            'judul' => $materi->judul,
            'deskripsi' => $materi->deskripsi,
            'tipe' => $materi->tipe,
            'mapel' => $jadwal?->mataPelajaran?->nama,
            'mapel_id' => $jadwal?->mapel_id,
            'guru' => $materi->guru?->nama_lengkap ?? $jadwal?->guru?->nama_lengkap,
            'kelas' => $jadwal?->kelas?->nama_kelas,
            'tanggal_dibuat' => $materi->created_at?->toIso8601String(),
            'ada_file' => filled($materi->file_path),
            'ada_link' => filled($materi->link),
            'file_url' => filled($materi->file_path) ? url('/api/siswa/materi/' . $materi->id . '/file') : null,
            'link' => $materi->link,
        ];

        if ($detail) {
            $data['nama_file'] = $materi->file_path ? basename($materi->file_path) : null;
            $data['ekstensi'] = $materi->file_path ? strtolower(pathinfo($materi->file_path, PATHINFO_EXTENSION)) : null;
        }

        return $data;
    }

    public function tugasIndex(Request $request)
    {
        $siswa = $this->siswa($request);
        $validated = $request->validate([
            'status' => ['nullable', Rule::in(['semua', 'belum', 'dikumpulkan', 'dinilai', 'terlambat'])],
            'mapel_id' => ['nullable', 'integer', 'exists:mata_pelajaran,id'],
            'q' => ['nullable', 'string', 'max:120'],
        ]);

        $items = Penugasan::with([
            'jadwal.mataPelajaran', 'jadwal.guru', 'guru', 'files',
            'pengumpulan' => fn ($query) => $query->where('siswa_id', $siswa->id)->with(['nilai', 'files']),
        ])
            ->whereHas('jadwal', function ($jadwal) use ($siswa, $validated) {
                $jadwal->where('kelas_id', $siswa->kelas_id);
                if ($periode = $this->periodeAktif()) {
                    $jadwal->where('periode_id', $periode->id);
                }
                if (! empty($validated['mapel_id'])) {
                    $jadwal->where('mapel_id', $validated['mapel_id']);
                }
            })
            ->when(! empty($validated['q']), fn ($query) => $query->where('judul', 'like', '%' . trim($validated['q']) . '%'))
            ->orderBy('deadline')
            ->get()
            ->map(fn (Penugasan $item) => $this->formatTugas($item))
            ->filter(function (array $item) use ($validated) {
                $filter = $validated['status'] ?? 'semua';
                return match ($filter) {
                    'belum' => $item['status'] === 'belum_dikumpulkan',
                    'dikumpulkan' => in_array($item['status'], ['sudah_dikumpulkan', 'terlambat', 'sudah_dinilai'], true),
                    'dinilai' => $item['status'] === 'sudah_dinilai',
                    'terlambat' => $item['status'] === 'terlambat' || $item['status'] === 'melewati_deadline',
                    default => true,
                };
            })->values();

        return response()->json(['success' => true, 'data' => $items]);
    }

    public function tugasShow(Request $request, int $id)
    {
        $siswa = $this->siswa($request);
        $tugas = $this->penugasanDalamKelas($siswa, $id);
        $tugas->load(['files', 'pengumpulan' => fn ($query) => $query->where('siswa_id', $siswa->id)->with(['nilai', 'files'])]);

        return response()->json(['success' => true, 'data' => $this->formatTugas($tugas, true)]);
    }

    public function tugasFile(Request $request, int $id)
    {
        $tugas = $this->penugasanDalamKelas($this->siswa($request), $id);
        abort_if(blank($tugas->file_materi), 404, 'Lampiran tugas tidak tersedia.');
        abort_unless(Storage::disk('public')->exists($tugas->file_materi), 404, 'Lampiran tugas tidak ditemukan.');

        return Storage::disk('public')->response($tugas->file_materi, basename($tugas->file_materi));
    }

    public function tugasAttachmentFile(Request $request, int $id, string $fileId)
    {
        $tugas = $this->penugasanDalamKelas($this->siswa($request), $id);
        if ($fileId === 'legacy') {
            return $this->tugasFile($request, $id);
        }

        $attachment = $tugas->files()->findOrFail($fileId);
        $disk = Storage::disk($attachment->disk ?: 'public');
        abort_unless($disk->exists($attachment->file_path), 404, 'Lampiran tugas tidak ditemukan.');

        return $disk->download($attachment->file_path, $attachment->original_name);
    }

    public function tugasKumpulkan(Request $request, int $id)
    {
        $siswa = $this->siswa($request);
        $tugas = $this->penugasanDalamKelas($siswa, $id);

        // Every uploaded file has its own 20 MB limit. This is not a combined
        // 20 MB limit for the entire submission.
        $validated = $request->validate([
            'jawaban' => ['nullable', 'string', 'max:10000'],
            'files' => ['sometimes', 'nullable', 'array', 'max:20'],
            'files.*' => ['file', 'mimes:pdf,doc,docx,xls,xlsx,ppt,pptx,jpg,jpeg,png,txt,zip', 'max:20480'],
            // Keep the previous single-file field for older app builds.
            'file_jawaban' => ['nullable', 'file', 'mimes:pdf,doc,docx,xls,xlsx,ppt,pptx,jpg,jpeg,png,txt,zip', 'max:20480'],
            'hapus_file' => ['nullable', 'boolean'],
            'upload_batch_id' => ['nullable', 'string', 'max:80'],
        ], [
            'files.max' => 'Maksimal 20 file dalam satu pengumpulan.',
            'files.*.max' => 'Setiap file pengumpulan maksimal 20 MB.',
            'files.*.mimes' => 'Salah satu file memiliki format yang tidak didukung.',
            'file_jawaban.max' => 'Ukuran file pengumpulan maksimal 20 MB.',
            'file_jawaban.mimes' => 'Format file pengumpulan tidak didukung.',
        ]);

        $uploadBatchId = $validated['upload_batch_id'] ?? null;
        if ($uploadBatchId) {
            $priorSubmission = PengumpulanTugas::where('penugasan_id', $tugas->id)
                ->where('siswa_id', $siswa->id)
                ->with(['nilai', 'files'])
                ->first();
            if ($priorSubmission && hash_equals((string) $priorSubmission->last_upload_batch_id, $uploadBatchId)) {
                return response()->json([
                    'success' => true,
                    'message' => 'Pengumpulan sudah diterima dari percobaan sebelumnya.',
                    'data' => $this->formatSubmission($priorSubmission),
                ]);
            }
        }

        $incomingFiles = $request->file('files', []);
        if (! is_array($incomingFiles)) {
            $incomingFiles = [$incomingFiles];
        }
        $incomingFiles = array_values(array_filter($incomingFiles));

        $legacyFile = $request->file('file_jawaban');
        if ($legacyFile) {
            $incomingFiles[] = $legacyFile;
        }

        $removeOldFiles = (bool) ($validated['hapus_file'] ?? false);
        // A request using the old single-file field retains its old replace-one
        // behavior. The new files[] field appends to the current attachment set.
        $clearExistingFiles = $removeOldFiles || $legacyFile !== null;

        $newFileRows = [];
        $newPaths = [];
        $oldPathsToDelete = [];
        $duplicateBatch = false;

        try {
            foreach ($incomingFiles as $uploadedFile) {
                $path = $uploadedFile->store('pengumpulan-siswa/' . $siswa->id, 'local');
                if (! $path) {
                    throw new \RuntimeException('Salah satu file gagal disimpan. Silakan coba kembali.');
                }

                $newPaths[] = $path;
                $newFileRows[] = [
                    'disk' => 'local',
                    'file_path' => $path,
                    'original_name' => basename(str_replace('\\', '/', $uploadedFile->getClientOriginalName())),
                    'mime_type' => $uploadedFile->getMimeType(),
                    'size_bytes' => (int) $uploadedFile->getSize(),
                ];
            }

            $submission = DB::transaction(function () use (
                $tugas,
                $siswa,
                $validated,
                $newFileRows,
                $newPaths,
                $clearExistingFiles,
                $uploadBatchId,
                &$duplicateBatch,
                &$oldPathsToDelete
            ) {
                // Lock the task row so deletion and submission cannot race.
                $lockedTask = Penugasan::query()
                    ->lockForUpdate()
                    ->findOrFail($tugas->id);

                // Re-check class access inside the transaction.
                abort_unless(
                    $lockedTask->jadwal()
                        ->where('kelas_id', $siswa->kelas_id)
                        ->when($this->periodeAktif(), fn ($query, $periode) => $query->where('periode_id', $periode->id))
                        ->exists(),
                    404,
                    'Tugas tidak ditemukan untuk kelas Anda.'
                );

                $existing = PengumpulanTugas::where('penugasan_id', $lockedTask->id)
                    ->where('siswa_id', $siswa->id)
                    ->with(['nilai', 'files'])
                    ->lockForUpdate()
                    ->first();

                if ($uploadBatchId && $existing && hash_equals((string) $existing->last_upload_batch_id, $uploadBatchId)) {
                    $duplicateBatch = true;
                    return $existing->fresh(['nilai', 'files']);
                }

                abort_if($existing?->nilai, 409, 'Tugas sudah dinilai Guru dan tidak dapat diubah.');

                $jawaban = array_key_exists('jawaban', $validated)
                    ? trim((string) ($validated['jawaban'] ?? ''))
                    : ($existing?->jawaban ?? '');

                $existingFilePaths = $existing?->files?->pluck('file_path')->filter()->values()->all() ?? [];
                $legacyExistingPath = $existing?->file_jawaban;
                if ($legacyExistingPath && ! in_array($legacyExistingPath, $existingFilePaths, true)) {
                    $existingFilePaths[] = $legacyExistingPath;
                }

                $hasRetainedFiles = ! $clearExistingFiles && count($existingFilePaths) > 0;
                $willHaveFiles = $hasRetainedFiles || count($newFileRows) > 0;

                abort_if(
                    $jawaban === '' && ! $willHaveFiles,
                    422,
                    'Isi jawaban atau lampirkan minimal satu file sebelum mengumpulkan.'
                );

                if ($clearExistingFiles && $existing) {
                    $oldPathsToDelete = array_merge($oldPathsToDelete, $existingFilePaths);
                    $existing->files()->delete();
                } elseif ($existing && $legacyExistingPath && $existing->files->isEmpty()) {
                    // Backfill a legacy single-file submission into the new
                    // attachment relation when a new multi-file upload is added.
                    $disk = Storage::disk('local');
                    if ($disk->exists($legacyExistingPath)) {
                        $existing->files()->create([
                            'disk' => 'local',
                            'file_path' => $legacyExistingPath,
                            'original_name' => basename($legacyExistingPath),
                            'mime_type' => $disk->mimeType($legacyExistingPath),
                            'size_bytes' => (int) $disk->size($legacyExistingPath),
                        ]);
                    }
                }

                $now = now();
                $deadline = Carbon::parse($lockedTask->deadline);

                $submission = $existing ?? new PengumpulanTugas([
                    'penugasan_id' => $lockedTask->id,
                    'siswa_id' => $siswa->id,
                ]);
                $submission->jawaban = $jawaban !== '' ? $jawaban : null;
                $submission->waktu_pengumpulan = $now;
                $submission->status = $now->gt($deadline) ? 'terlambat' : 'tepat_waktu';
                if ($uploadBatchId) {
                    $submission->last_upload_batch_id = $uploadBatchId;
                }

                if ($clearExistingFiles) {
                    $submission->file_jawaban = null;
                }
                if (! $clearExistingFiles && blank($submission->file_jawaban) && $existingFilePaths) {
                    $submission->file_jawaban = $existingFilePaths[0];
                }
                if (blank($submission->file_jawaban) && $newPaths) {
                    // Preserve the first attachment in the legacy column so
                    // previous app versions can still download a submission.
                    $submission->file_jawaban = $newPaths[0];
                }

                $submission->save();

                foreach ($newFileRows as $fileRow) {
                    $submission->files()->create($fileRow);
                }

                return $submission->fresh(['nilai', 'files']);
            });
        } catch (\Throwable $exception) {
            foreach ($newPaths as $newPath) {
                Storage::disk('local')->delete($newPath);
            }
            throw $exception;
        }

        if ($duplicateBatch) {
            foreach ($newPaths as $newPath) {
                Storage::disk('local')->delete($newPath);
            }
            return response()->json([
                'success' => true,
                'message' => 'Pengumpulan sudah diterima dari percobaan sebelumnya.',
                'data' => $this->formatSubmission($submission),
            ]);
        }

        foreach (array_unique($oldPathsToDelete) as $oldPath) {
            if (! in_array($oldPath, $newPaths, true)) {
                Storage::disk('local')->delete($oldPath);
            }
        }

        $tugas = $tugas->fresh(['guru.user', 'jadwal.mataPelajaran']);
        app(MatsanamNotificationService::class)->send(
            $tugas->guru?->user,
            'pengumpulan_tugas',
            'Pengumpulan tugas baru',
            $siswa->nama_lengkap . ' mengumpulkan tugas "' . $tugas->judul . '"' . ($tugas->jadwal?->mataPelajaran?->nama ? ' pada ' . $tugas->jadwal->mataPelajaran->nama : '') . '.',
            [
                'tugas_id' => $tugas->id,
                'pengumpulan_id' => $submission->id,
                'siswa_id' => $siswa->id,
            ],
        );

        return response()->json([
            'success' => true,
            'message' => 'Pengumpulan tugas berhasil disimpan.',
            'data' => $this->formatSubmission($submission),
        ]);
    }

    public function pengumpulanAttachmentFile(Request $request, int $id, int $fileId)
    {
        $siswa = $this->siswa($request);
        $submission = PengumpulanTugas::whereKey($id)
            ->where('siswa_id', $siswa->id)
            ->firstOrFail();
        $attachment = $submission->files()->whereKey($fileId)->firstOrFail();
        $disk = Storage::disk($attachment->disk ?: 'local');

        abort_unless($disk->exists($attachment->file_path), 404, 'File pengumpulan tidak ditemukan.');

        return $disk->download($attachment->file_path, $attachment->original_name);
    }

    public function pengumpulanFile(Request $request, int $id)
    {
        $siswa = $this->siswa($request);
        $submission = PengumpulanTugas::whereKey($id)->where('siswa_id', $siswa->id)->firstOrFail();
        abort_if(blank($submission->file_jawaban), 404, 'File pengumpulan tidak tersedia.');
        abort_unless(Storage::disk('local')->exists($submission->file_jawaban), 404, 'File pengumpulan tidak ditemukan.');

        return Storage::disk('local')->download($submission->file_jawaban, basename($submission->file_jawaban));
    }

    private function formatTugas(Penugasan $tugas, bool $detail = false): array
    {
        $jadwal = $tugas->jadwal;
        $submission = $tugas->pengumpulan->first();
        $nilai = $submission?->nilai;
        $deadline = Carbon::parse($tugas->deadline);
        $status = 'belum_dikumpulkan';
        if ($nilai) {
            $status = 'sudah_dinilai';
        } elseif ($submission) {
            $status = $submission->status === 'terlambat' ? 'terlambat' : 'sudah_dikumpulkan';
        } elseif ($deadline->isPast()) {
            $status = 'melewati_deadline';
        }

        $taskAttachments = $this->formatTaskAttachments($tugas);
        $firstTaskAttachment = $taskAttachments[0] ?? null;

        $data = [
            'id' => $tugas->id,
            'judul' => $tugas->judul,
            'deskripsi' => $tugas->deskripsi,
            'jenis' => $tugas->jenis,
            'deadline' => $deadline->toIso8601String(),
            'bobot' => (int) $tugas->bobot,
            'mapel' => $jadwal?->mataPelajaran?->nama,
            'mapel_id' => $jadwal?->mapel_id,
            'guru' => $tugas->guru?->nama_lengkap ?? $jadwal?->guru?->nama_lengkap,
            'kelas' => $jadwal?->kelas?->nama_kelas,
            'kkm' => (int) ($jadwal?->mataPelajaran?->kkm ?? 0),
            'status' => $status,
            'ada_lampiran' => !empty($taskAttachments),
            'lampiran_files' => $taskAttachments,
            // Legacy single-file fields point to the first item for older screens/builds.
            'lampiran_url' => $firstTaskAttachment['file_url'] ?? null,
            'lampiran_nama_file' => $firstTaskAttachment['file_name'] ?? null,
            'pengumpulan' => $submission ? $this->formatSubmission($submission) : null,
        ];

        if ($detail) {
            $data['tanggal_dibuat'] = $tugas->created_at?->toIso8601String();
        }

        return $data;
    }

    private function formatTaskAttachments(Penugasan $tugas): array
    {
        $tugas->loadMissing('files');
        $files = $tugas->files->map(function ($file) use ($tugas) {
            $disk = Storage::disk($file->disk ?: 'public');
            return [
                'id' => (string) $file->id,
                'file_name' => $file->original_name,
                'file_url' => url('/api/siswa/tugas/' . $tugas->id . '/files/' . $file->id),
                'mime_type' => $file->mime_type,
                'size_bytes' => (int) $file->size_bytes,
                'is_legacy' => false,
                'available' => $disk->exists($file->file_path),
            ];
        })->values()->all();

        $legacyAlreadyListed = $tugas->files->contains(
            fn ($file) => $file->file_path === $tugas->file_materi,
        );
        if (filled($tugas->file_materi) && ! $legacyAlreadyListed) {
            $disk = Storage::disk('public');
            $files[] = [
                'id' => 'legacy',
                'file_name' => basename($tugas->file_materi),
                'file_url' => url('/api/siswa/tugas/' . $tugas->id . '/files/legacy'),
                'mime_type' => $disk->exists($tugas->file_materi) ? $disk->mimeType($tugas->file_materi) : null,
                'size_bytes' => $disk->exists($tugas->file_materi) ? (int) $disk->size($tugas->file_materi) : null,
                'is_legacy' => true,
                'available' => $disk->exists($tugas->file_materi),
            ];
        }

        return array_values($files);
    }

    private function formatSubmission(PengumpulanTugas $submission): array
    {
        $submission->loadMissing('files');
        $files = $submission->files->map(function ($file) use ($submission) {
            return [
                'id' => $file->id,
                'file_name' => $file->original_name,
                'file_url' => url('/api/siswa/pengumpulan/' . $submission->id . '/files/' . $file->id),
                'mime_type' => $file->mime_type,
                'size_bytes' => (int) $file->size_bytes,
            ];
        })->values();

        // Old submissions predate pengumpulan_tugas_files. Expose the legacy
        // file as a one-item attachment list without requiring a data migration.
        if ($files->isEmpty() && filled($submission->file_jawaban)) {
            $files = collect([[
                'id' => null,
                'file_name' => basename($submission->file_jawaban),
                'file_url' => url('/api/siswa/pengumpulan/' . $submission->id . '/file'),
                'mime_type' => Storage::disk('local')->mimeType($submission->file_jawaban),
                'size_bytes' => Storage::disk('local')->exists($submission->file_jawaban)
                    ? (int) Storage::disk('local')->size($submission->file_jawaban)
                    : null,
            ]]);
        }

        $primary = $files->first();

        return [
            'id' => $submission->id,
            'jawaban' => $submission->jawaban,
            // Legacy fields remain for older screens and app builds.
            'file_name' => $primary['file_name'] ?? ($submission->file_jawaban ? basename($submission->file_jawaban) : null),
            'file_url' => $primary['file_url'] ?? ($submission->file_jawaban ? url('/api/siswa/pengumpulan/' . $submission->id . '/file') : null),
            'files' => $files,
            'waktu_pengumpulan' => $submission->waktu_pengumpulan?->toIso8601String(),
            'status' => $submission->status,
            'nilai' => $submission->nilai ? [
                'nilai' => (float) $submission->nilai->nilai,
                'catatan' => $submission->nilai->catatan,
                'tanggal_penilaian' => $submission->nilai->tanggal_penilaian?->toIso8601String(),
            ] : null,
        ];
    }

    public function nilaiIndex(Request $request)
    {
        $siswa = $this->siswa($request);
        $jadwalMapelIds = $this->jadwalKelasQuery($siswa)
            ->whereNotNull('mapel_id')
            ->distinct()
            ->pluck('mapel_id');

        $submissions = PengumpulanTugas::with(['penugasan.jadwal.mataPelajaran', 'penugasan.guru', 'nilai.guru'])
            ->where('siswa_id', $siswa->id)
            ->whereHas('penugasan.jadwal', function ($query) use ($siswa) {
                $query->where('kelas_id', $siswa->kelas_id);
                if ($periode = $this->periodeAktif()) $query->where('periode_id', $periode->id);
            })
            ->latest('waktu_pengumpulan')
            ->get();

        $grouped = $submissions->groupBy(fn ($submission) => $submission->penugasan?->jadwal?->mataPelajaran?->id);
        $mapelList = MataPelajaran::whereIn('id', $jadwalMapelIds)->orderBy('nama')->get();
        $mapel = $mapelList->map(function (MataPelajaran $mataPelajaran) use ($grouped) {
            $items = $grouped->get($mataPelajaran->id, collect());
            $graded = $items->filter(fn ($submission) => $submission->nilai !== null);
            $scores = $graded->map(fn ($submission) => (float) $submission->nilai->nilai);

            return [
                'mapel_id' => $mataPelajaran->id,
                'mapel' => $mataPelajaran->nama,
                'kkm' => (int) $mataPelajaran->kkm,
                'jumlah_penilaian' => $items->count(),
                'jumlah_dinilai' => $graded->count(),
                'jumlah_menunggu' => $items->count() - $graded->count(),
                'rata_rata' => $scores->isEmpty() ? null : round($scores->avg(), 2),
                'hasil' => $items->map(fn ($submission) => $this->formatNilai($submission))->values(),
            ];
        })->values();

        return response()->json([
            'success' => true,
            'data' => $mapel,
            'meta' => [
                'jumlah_mapel' => $mapel->count(),
                'jumlah_pengumpulan' => $submissions->count(),
                'jumlah_dinilai' => $submissions->filter(fn ($submission) => $submission->nilai !== null)->count(),
            ],
        ]);
    }

    public function nilaiByMapel(Request $request, int $mapelId)
    {
        $siswa = $this->siswa($request);
        abort_unless($this->jadwalKelasQuery($siswa)->where('mapel_id', $mapelId)->exists(), 404, 'Mata pelajaran tidak ditemukan untuk kelas Anda.');
        $mapel = MataPelajaran::findOrFail($mapelId);
        $items = PengumpulanTugas::with(['penugasan.jadwal.mataPelajaran', 'penugasan.guru', 'nilai.guru'])
            ->where('siswa_id', $siswa->id)
            ->whereHas('penugasan.jadwal', function ($query) use ($siswa, $mapelId) {
                $query->where('kelas_id', $siswa->kelas_id)->where('mapel_id', $mapelId);
                if ($periode = $this->periodeAktif()) $query->where('periode_id', $periode->id);
            })
            ->latest('waktu_pengumpulan')
            ->get();

        $graded = $items->filter(fn ($submission) => $submission->nilai !== null);

        return response()->json([
            'success' => true,
            'data' => [
                'mapel' => ['id' => $mapel->id, 'nama' => $mapel->nama, 'kkm' => (int) $mapel->kkm],
                'rata_rata' => $graded->isEmpty() ? null : round($graded->avg(fn ($submission) => (float) $submission->nilai->nilai), 2),
                'hasil' => $items->map(fn ($submission) => $this->formatNilai($submission))->values(),
            ],
        ]);
    }

    public function nilaiMapelPdf(Request $request, int $mapelId)
    {
        $siswa = $this->siswa($request);
        abort_unless(
            $this->jadwalKelasQuery($siswa)->where('mapel_id', $mapelId)->exists(),
            404,
            'Mata pelajaran tidak ditemukan untuk kelas Anda.'
        );

        $mapel = MataPelajaran::findOrFail($mapelId);
        $items = PengumpulanTugas::with(['penugasan.jadwal.mataPelajaran', 'penugasan.guru', 'nilai.guru'])
            ->where('siswa_id', $siswa->id)
            ->whereHas('penugasan.jadwal', function ($query) use ($siswa, $mapelId) {
                $query->where('kelas_id', $siswa->kelas_id)->where('mapel_id', $mapelId);
                if ($periode = $this->periodeAktif()) {
                    $query->where('periode_id', $periode->id);
                }
            })
            ->latest('waktu_pengumpulan')
            ->get();

        $graded = $items->filter(fn ($submission) => $submission->nilai !== null);
        $hasil = $items->map(fn ($submission) => $this->formatNilai($submission))->values();
        $pdf = Pdf::loadView('pdf.nilai-mapel', [
            'siswa' => $siswa,
            'mapel' => $mapel,
            'hasil' => $hasil,
            'rataRata' => $graded->isEmpty()
                ? null
                : round($graded->avg(fn ($submission) => (float) $submission->nilai->nilai), 2),
            'dicetakPada' => now('Asia/Jakarta'),
        ])->setPaper('a4', 'portrait');

        return $pdf->download('nilai-mapel-' . $mapel->id . '-siswa-' . $siswa->id . '.pdf');
    }

    public function nilaiRekapPdf(Request $request)
    {
        $siswa = $this->siswa($request);
        $mapelIds = $this->jadwalKelasQuery($siswa)
            ->whereNotNull('mapel_id')
            ->distinct()
            ->pluck('mapel_id');

        $submissions = PengumpulanTugas::with(['penugasan.jadwal.mataPelajaran', 'penugasan.guru', 'nilai.guru'])
            ->where('siswa_id', $siswa->id)
            ->whereHas('penugasan.jadwal', function ($query) use ($siswa) {
                $query->where('kelas_id', $siswa->kelas_id);
                if ($periode = $this->periodeAktif()) {
                    $query->where('periode_id', $periode->id);
                }
            })
            ->latest('waktu_pengumpulan')
            ->get();

        $grouped = $submissions->groupBy(fn ($submission) => $submission->penugasan?->jadwal?->mataPelajaran?->id);
        $mapelList = MataPelajaran::whereIn('id', $mapelIds)->orderBy('nama')->get();
        $rekap = $mapelList->map(function (MataPelajaran $mapel) use ($grouped) {
            $items = $grouped->get($mapel->id, collect());
            $graded = $items->filter(fn ($submission) => $submission->nilai !== null);
            return [
                'mapel' => $mapel->nama,
                'kkm' => (int) $mapel->kkm,
                'jumlah' => $items->count(),
                'dinilai' => $graded->count(),
                'menunggu' => $items->count() - $graded->count(),
                'rata_rata' => $graded->isEmpty()
                    ? null
                    : round($graded->avg(fn ($submission) => (float) $submission->nilai->nilai), 2),
            ];
        })->values();

        $gradedAll = $submissions->filter(fn ($submission) => $submission->nilai !== null);
        $overallAverage = $gradedAll->isEmpty()
            ? null
            : round($gradedAll->avg(fn ($submission) => (float) $submission->nilai->nilai), 2);

        $pdf = Pdf::loadView('pdf.nilai-rekap', [
            'siswa' => $siswa,
            'rekap' => $rekap,
            'totalPenilaian' => $submissions->count(),
            'totalDinilai' => $gradedAll->count(),
            'rataRata' => $overallAverage,
            'dicetakPada' => now('Asia/Jakarta'),
        ])->setPaper('a4', 'portrait');

        return $pdf->download('rekap-nilai-siswa-' . $siswa->id . '.pdf');
    }

    private function formatNilai(PengumpulanTugas $submission): array
    {
        $task = $submission->penugasan;
        $mapel = $task?->jadwal?->mataPelajaran;
        $nilai = $submission->nilai;

        return [
            'pengumpulan_id' => $submission->id,
            'tugas_id' => $task?->id,
            'judul_tugas' => $task?->judul,
            'jenis' => $task?->jenis,
            'mapel' => $mapel?->nama,
            'mapel_id' => $mapel?->id,
            'kkm' => (int) ($mapel?->kkm ?? 0),
            'nilai' => $nilai ? (float) $nilai->nilai : null,
            'catatan' => $nilai?->catatan,
            'guru' => $nilai?->guru?->nama_lengkap,
            'tanggal_pengumpulan' => $submission->waktu_pengumpulan?->toIso8601String(),
            'tanggal_penilaian' => $nilai?->tanggal_penilaian?->toIso8601String(),
            'status_pengumpulan' => $submission->status,
            'status_ketuntasan' => $nilai ? ((float) $nilai->nilai >= (float) ($mapel?->kkm ?? 0) ? 'tuntas' : 'belum_tuntas') : 'menunggu_penilaian',
        ];
    }

    public function jadwal(Request $request)
    {
        $siswa = $this->siswa($request);
        $validated = $request->validate([
            'hari' => ['nullable', Rule::in(['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'])],
        ]);
        $jadwal = $this->jadwalKelasQuery($siswa)
            ->with(['mataPelajaran', 'guru'])
            ->when(! empty($validated['hari']), fn ($query) => $query->where('hari', $validated['hari']))
            ->orderByRaw("CASE hari WHEN 'Senin' THEN 1 WHEN 'Selasa' THEN 2 WHEN 'Rabu' THEN 3 WHEN 'Kamis' THEN 4 WHEN 'Jumat' THEN 5 WHEN 'Sabtu' THEN 6 ELSE 7 END")
            ->orderBy('jam_mulai')
            ->get()
            ->map(fn ($item) => [
                'id' => $item->id,
                'hari' => $item->hari,
                'jam_mulai' => substr($item->jam_mulai, 0, 5),
                'jam_selesai' => substr($item->jam_selesai, 0, 5),
                'mapel' => $item->mataPelajaran?->nama,
                'mapel_id' => $item->mapel_id,
                'guru' => $item->guru?->nama_lengkap,
                'ruangan' => $item->ruangan,
            ])->values();

        return response()->json([
            'success' => true,
            'data' => $jadwal,
            'periode' => $this->periodeAktif()?->nama,
        ]);
    }

    public function riwayatAbsensi(Request $request)
    {
        $siswa = $this->siswa($request);
        $validated = $request->validate([
            'dari' => ['nullable', 'date'],
            'sampai' => ['nullable', 'date', 'after_or_equal:dari'],
            'status' => ['nullable', Rule::in(['hadir', 'izin', 'sakit', 'alpa'])],
        ]);

        $baseQuery = AbsensiHarian::with(['jadwal.mataPelajaran', 'jadwal.guru', 'suratAbsensi.verifikator'])
            ->where('siswa_id', $siswa->id)
            ->when(! empty($validated['dari']), fn ($q) => $q->whereDate('tanggal', '>=', $validated['dari']))
            ->when(! empty($validated['sampai']), fn ($q) => $q->whereDate('tanggal', '<=', $validated['sampai']));

        $summary = (clone $baseQuery)
            ->select('status', DB::raw('COUNT(*) as total'))
            ->groupBy('status')
            ->pluck('total', 'status');
        $query = (clone $baseQuery)
            ->when(! empty($validated['status']), fn ($q) => $q->where('status', $validated['status']))
            ->latest('tanggal');
        $items = $query->paginate(20)->withQueryString();
        $items->getCollection()->transform(fn ($item) => [
            'id' => $item->id,
            'tanggal' => $item->tanggal?->toDateString(),
            'status' => $item->status,
            'waktu_absen' => $item->waktu_absen,
            'metode' => $item->metode,
            'keterangan' => $item->keterangan,
            'mapel' => $item->jadwal?->mataPelajaran?->nama,
            'guru' => $item->jadwal?->guru?->nama_lengkap,
            'kelas' => $siswa->kelas?->nama_kelas,
            'jam_mulai' => $item->jadwal?->jam_mulai ? substr($item->jadwal->jam_mulai, 0, 5) : null,
            'surat_id' => $item->suratAbsensi?->id,
            'surat_jenis' => $item->suratAbsensi?->jenis,
            'surat_status_verifikasi' => $item->suratAbsensi?->status_verifikasi,
            'surat_tanggal_verifikasi' => $item->suratAbsensi?->tanggal_verifikasi?->toIso8601String(),
            'surat_verifikator' => $item->suratAbsensi?->verifikator?->name,
            'surat_catatan_verifikasi' => $item->suratAbsensi?->catatan_verifikasi,
        ]);

        return response()->json([
            'success' => true,
            'profile' => [
                'nama_lengkap' => $siswa->nama_lengkap,
                'kelas' => $siswa->kelas?->nama_kelas,
            ],
            'data' => $items,
            'summary' => [
                'hadir' => (int) ($summary['hadir'] ?? 0),
                'izin' => (int) ($summary['izin'] ?? 0),
                'sakit' => (int) ($summary['sakit'] ?? 0),
                'alpa' => (int) ($summary['alpa'] ?? 0),
            ],
        ]);
    }

    public function scanQr(Request $request)
    {
        $siswa = $this->siswa($request);
        $validated = $request->validate([
            'qr_data' => ['required', 'string', 'max:5000'],
            'latitude' => ['required', 'numeric', 'between:-90,90'],
            'longitude' => ['required', 'numeric', 'between:-180,180'],
            'accuracy' => ['nullable', 'numeric', 'min:0', 'max:1000'],
        ]);

        $payload = json_decode($validated['qr_data'], true);
        if (! is_array($payload) || empty($payload['sesi_id']) || empty($payload['qr_token'])) {
            return response()->json([
                'success' => false,
                'message' => 'QR tidak dikenali. Pastikan memindai QR dari sesi Guru yang aktif.',
            ], 422);
        }

        $sesi = AbsensiSesi::with('jadwal')->find($payload['sesi_id']);
        if (! $sesi || $sesi->status !== 'aktif') {
            return response()->json(['success' => false, 'message' => 'Sesi absensi tidak aktif atau tidak ditemukan.'], 409);
        }

        $storedPayload = json_decode((string) $sesi->qr_data, true);
        $storedToken = is_array($storedPayload) ? (string) ($storedPayload['qr_token'] ?? '') : '';
        $providedToken = (string) $payload['qr_token'];
        if ($storedToken === '' || ! hash_equals($storedToken, $providedToken)) {
            return response()->json(['success' => false, 'message' => 'QR sudah diperbarui atau tidak valid. Pindai QR terbaru dari Guru.'], 409);
        }

        $now = Carbon::now('UTC');
        if (! $sesi->expired_at || $sesi->expired_at->lte($now)) {
            AbsensiSesi::whereKey($sesi->id)
                ->where('status', 'aktif')
                ->update([
                    'status' => 'selesai',
                    'selesai_at' => $now,
                    'updated_at' => $now,
                ]);
            return response()->json(['success' => false, 'message' => 'Masa berlaku QR sudah berakhir. Minta Guru membuka sesi baru.'], 410);
        }

        if ((int) $sesi->kelas_id !== (int) $siswa->kelas_id || ! $sesi->jadwal) {
            return response()->json(['success' => false, 'message' => 'QR ini bukan untuk kelas Anda.'], 403);
        }

        $periode = $this->periodeAktif();
        if ($periode && (int) $sesi->jadwal->periode_id !== (int) $periode->id) {
            return response()->json(['success' => false, 'message' => 'Sesi ini bukan bagian dari periode akademik aktif.'], 409);
        }

        $latitude = (float) $validated['latitude'];
        $longitude = (float) $validated['longitude'];
        $distance = $this->distanceMeters(
            $latitude,
            $longitude,
            (float) $sesi->lokasi_latitude,
            (float) $sesi->lokasi_longitude
        );
        $radius = max(1, (int) $sesi->radius_meter);
        $accuracy = isset($validated['accuracy']) ? (float) $validated['accuracy'] : null;
        if ($accuracy !== null && $accuracy > $radius) {
            return response()->json([
                'success' => false,
                'message' => 'Akurasi lokasi belum cukup untuk radius presensi. Pindah ke area terbuka dan coba lagi.',
                'data' => ['akurasi_meter' => (int) round($accuracy), 'radius_meter' => $radius],
            ], 422);
        }
        if ($distance > $radius) {
            return response()->json([
                'success' => false,
                'message' => 'Lokasi Anda berada di luar radius presensi yang ditentukan Guru.',
                'data' => ['jarak_meter' => (int) round($distance), 'radius_meter' => $radius],
            ], 422);
        }

        $schoolDateForDuplicateCheck = null;
        try {
            $result = DB::transaction(function () use ($siswa, $sesi, $validated, $distance, $radius, &$schoolDateForDuplicateCheck) {
                // Re-read and lock the session: a teacher may have stopped it or
                // regenerated its QR after the first validation above.
                $lockedSession = AbsensiSesi::with('jadwal')
                    ->whereKey($sesi->id)
                    ->lockForUpdate()
                    ->first();

                if (! $lockedSession || $lockedSession->status !== 'aktif') {
                    return [
                        'error' => 'Sesi absensi sudah ditutup atau tidak ditemukan.',
                        'status' => 409,
                    ];
                }

                $recordedAtUtc = Carbon::now('UTC');
                if (! $lockedSession->expired_at || $lockedSession->expired_at->lte($recordedAtUtc)) {
                    $lockedSession->update([
                        'status' => 'selesai',
                        'selesai_at' => $recordedAtUtc,
                    ]);

                    return [
                        'error' => 'Masa berlaku QR sudah berakhir. Minta Guru membuka sesi baru.',
                        'status' => 410,
                    ];
                }

                $latestPayload = json_decode((string) $lockedSession->qr_data, true);
                $latestToken = is_array($latestPayload)
                    ? (string) ($latestPayload['qr_token'] ?? '')
                    : '';
                $providedPayload = json_decode($validated['qr_data'], true);
                $providedToken = is_array($providedPayload)
                    ? (string) ($providedPayload['qr_token'] ?? '')
                    : '';

                if (
                    $latestToken === ''
                    || $providedToken === ''
                    || ! hash_equals($latestToken, $providedToken)
                ) {
                    return [
                        'error' => 'QR sudah diperbarui atau tidak valid. Pindai QR terbaru dari Guru.',
                        'status' => 409,
                    ];
                }

                if ((int) $lockedSession->kelas_id !== (int) $siswa->kelas_id) {
                    return [
                        'error' => 'QR ini bukan untuk kelas Anda.',
                        'status' => 403,
                    ];
                }

                $recordedAtSchool = $recordedAtUtc->copy()->setTimezone('Asia/Jakarta');
                $schoolDate = $recordedAtSchool->toDateString();
                $schoolDateForDuplicateCheck = $schoolDate;
                $existing = AbsensiHarian::where('siswa_id', $siswa->id)
                    ->where('jadwal_id', $lockedSession->jadwal_id)
                    ->whereDate('tanggal', $schoolDate)
                    ->first();

                if ($existing) {
                    return [
                        'error' => 'Presensi untuk mata pelajaran ini sudah tercatat hari ini.',
                        'status' => 409,
                        'existing' => [
                            'status' => $existing->status,
                            'waktu_absen' => $existing->waktu_absen,
                        ],
                    ];
                }

                $attendance = AbsensiHarian::create([
                    'siswa_id' => $siswa->id,
                    'jadwal_id' => $lockedSession->jadwal_id,
                    'tanggal' => $schoolDate,
                    'status' => 'hadir',
                    'waktu_absen' => $recordedAtSchool->format('H:i:s'),
                    'metode' => 'qr',
                    'keterangan' => 'Presensi QR sesi #' . $lockedSession->id . ' (jarak ' . (int) round($distance) . ' meter).',
                ]);

                return [
                    'attendance' => $attendance,
                    'tanggal' => $schoolDate,
                    'waktu_absen' => $recordedAtSchool->format('H:i:s'),
                ];
            });

            if (isset($result['error'])) {
                return response()->json([
                    'success' => false,
                    'message' => $result['error'],
                    'data' => $result['existing'] ?? null,
                ], $result['status']);
            }

            $attendance = $result['attendance'];
            $today = $result['tanggal'];
            $recordedTime = $result['waktu_absen'];
        } catch (\Illuminate\Database\QueryException $exception) {
            // The database unique key (siswa_id, jadwal_id, tanggal) is the
            // final guard against simultaneous duplicate scans.
            $schoolDate = $schoolDateForDuplicateCheck
                ?? Carbon::now('Asia/Jakarta')->toDateString();
            $existing = AbsensiHarian::where('siswa_id', $siswa->id)
                ->where('jadwal_id', $sesi->jadwal_id)
                ->whereDate('tanggal', $schoolDate)
                ->first();
            if ($existing) {
                return response()->json([
                    'success' => false,
                    'message' => 'Presensi untuk mata pelajaran ini sudah tercatat hari ini.',
                    'data' => ['status' => $existing->status, 'waktu_absen' => $existing->waktu_absen],
                ], 409);
            }
            throw $exception;
        }

        return response()->json([
            'success' => true,
            'message' => 'Presensi berhasil dicatat.',
            'data' => [
                'absensi_id' => $attendance->id,
                'status' => $attendance->status,
                'waktu_absen' => $recordedTime,
                'tanggal' => $today,
                'mapel' => $sesi->jadwal->mataPelajaran?->nama,
                'jarak_meter' => (int) round($distance),
                'radius_meter' => $radius,
            ],
        ], 201);
    }

    private function distanceMeters(float $lat1, float $lon1, float $lat2, float $lon2): float
    {
        $earthRadius = 6371000.0;
        $latDelta = deg2rad($lat2 - $lat1);
        $lonDelta = deg2rad($lon2 - $lon1);
        $a = sin($latDelta / 2) ** 2
            + cos(deg2rad($lat1)) * cos(deg2rad($lat2)) * sin($lonDelta / 2) ** 2;
        return $earthRadius * 2 * atan2(sqrt($a), sqrt(max(0, 1 - $a)));
    }

    public function suratIndex(Request $request)
    {
        $siswa = $this->siswa($request);
        $fileService = app(SuratAbsensiFileService::class);
        $surat = SuratAbsensi::with('verifikator')
            ->where('siswa_id', $siswa->id)
            ->latest()
            ->get()
            ->map(function ($item) use ($fileService) {
                $hasDocument = $fileService->diskFor($item->file_surat) !== null;

                return [
                    'id' => $item->id,
                    'jenis' => $item->jenis,
                    'tanggal_mulai' => $item->tanggal_mulai?->toDateString(),
                    'tanggal_selesai' => $item->tanggal_selesai?->toDateString(),
                    'alasan' => $item->alasan,
                    'status_verifikasi' => $item->status_verifikasi,
                    'tanggal_verifikasi' => $item->tanggal_verifikasi?->toIso8601String(),
                    'catatan_verifikasi' => $item->catatan_verifikasi,
                    'verifikator' => $item->verifikator?->name,
                    'tanggal_pengajuan' => $item->created_at?->toIso8601String(),
                    'ada_dokumen' => $hasDocument,
                    'nama_file' => $hasDocument ? basename($item->file_surat) : null,
                    'dokumen_url' => $hasDocument ? url('/api/siswa/surat/' . $item->id . '/file') : null,
                ];
            });

        return response()->json(['success' => true, 'data' => $surat]);
    }

    public function suratFile(Request $request, int $id)
    {
        $surat = SuratAbsensi::where('siswa_id', $this->siswa($request)->id)->findOrFail($id);
        abort_if(blank($surat->file_surat), 404, 'Dokumen surat tidak tersedia.');

        return app(SuratAbsensiFileService::class)->download($surat->file_surat);
    }
}

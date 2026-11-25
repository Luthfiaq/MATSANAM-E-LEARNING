<?php

namespace App\Services;

use App\Models\AbsensiHarian;
use App\Models\JadwalPelajaran;
use App\Models\SuratAbsensi;
use Carbon\Carbon;
use Carbon\CarbonPeriod;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

/**
 * Menyelaraskan persetujuan surat dengan catatan absensi per mata pelajaran.
 * Untuk Pulang Lebih Awal, tanggal mulai berlaku sejak jadwal acuan;
 * tanggal berikutnya sampai tanggal selesai berlaku sehari penuh.
 * Kehadiran yang sudah tercatat valid tidak pernah ditimpa oleh surat.
 */
class SuratAbsensiApprovalService
{
    public function approve(SuratAbsensi $surat, int $verifikatorId, ?string $kategori = null): int
    {
        $kategori ??= $surat->jenis;
        if (! in_array($kategori, ['sakit', 'izin'], true)) {
            throw ValidationException::withMessages([
                'kategori_master' => 'Kategori absensi tidak valid.',
            ]);
        }

        return DB::transaction(function () use ($surat, $verifikatorId, $kategori): int {
            /** @var SuratAbsensi $locked */
            $locked = SuratAbsensi::query()
                ->lockForUpdate()
                ->with(['siswa', 'jadwalAcuan'])
                ->findOrFail($surat->id);

            if (strtolower((string) $locked->status_verifikasi) !== 'pending') {
                throw ValidationException::withMessages([
                    'status' => 'Surat ini sudah diproses sebelumnya.',
                ]);
            }

            $coverage = $locked->cakupan ?: 'sehari_penuh';
            if ($coverage !== 'sehari_penuh' && ! $locked->jadwal_acuan_id) {
                throw ValidationException::withMessages([
                    'jadwal_acuan_id' => 'Surat parsial tidak memiliki mata pelajaran acuan yang valid.',
                ]);
            }

            $locked->update([
                'status_verifikasi' => 'disetujui',
                'verifikator_id' => $verifikatorId,
                'tanggal_verifikasi' => now(),
                'catatan_verifikasi' => null,
            ]);

            $student = $locked->siswa;
            if (! $student || ! $student->kelas_id) {
                return 0;
            }

            $schedulesByDay = JadwalPelajaran::query()
                ->where('kelas_id', $student->kelas_id)
                ->whereHas('periode', function ($query) use ($locked) {
                    $query->whereDate('tanggal_mulai', '<=', $locked->tanggal_selesai)
                        ->whereDate('tanggal_selesai', '>=', $locked->tanggal_mulai);
                })
                ->with('periode')
                ->get()
                ->groupBy('hari');

            $dayNames = [
                1 => 'Senin',
                2 => 'Selasa',
                3 => 'Rabu',
                4 => 'Kamis',
                5 => 'Jumat',
                6 => 'Sabtu',
            ];

            $updatedRows = 0;
            $period = CarbonPeriod::create(
                Carbon::parse($locked->tanggal_mulai)->startOfDay(),
                Carbon::parse($locked->tanggal_selesai)->startOfDay(),
            );
            $referenceSchedule = $locked->jadwalAcuan;
            $referenceTime = $referenceSchedule?->jam_mulai
                ? substr((string) $referenceSchedule->jam_mulai, 0, 8)
                : null;

            foreach ($period as $date) {
                $dayName = $dayNames[$date->dayOfWeekIso] ?? null;
                if ($dayName === null) {
                    continue;
                }

                $schedules = $schedulesByDay->get($dayName, collect())->sortBy('jam_mulai');
                foreach ($schedules as $schedule) {
                    $schedulePeriod = $schedule->periode;
                    if (! $schedulePeriod) {
                        continue;
                    }

                    $periodStart = Carbon::parse($schedulePeriod->tanggal_mulai)->startOfDay();
                    $periodEnd = Carbon::parse($schedulePeriod->tanggal_selesai)->startOfDay();
                    if ($date->lt($periodStart) || $date->gt($periodEnd)) {
                        continue;
                    }

                    $scheduleTime = substr((string) $schedule->jam_mulai, 0, 8);
                    if ($coverage === 'mulai_pelajaran') {
                        // Kompatibilitas untuk pengajuan lama yang mungkin masih pending.
                        // Jenis cakupan ini tidak lagi ditawarkan atau diterima oleh API baru.
                        if ((int) $date->format('Ymd') !== (int) Carbon::parse($locked->tanggal_mulai)->format('Ymd')) {
                            continue;
                        }
                        if ($scheduleTime < $referenceTime) {
                            continue;
                        }
                    } elseif ($coverage === 'pulang_lebih_awal') {
                        // Tanggal pertama: izin dimulai dari mata pelajaran yang dipilih.
                        // Tanggal-tanggal berikutnya dalam rentang: seluruh jadwal diproses.
                        $isStartDate = (int) $date->format('Ymd') === (int) Carbon::parse($locked->tanggal_mulai)->format('Ymd');
                        if ($isStartDate && $scheduleTime < $referenceTime) {
                            continue;
                        }
                    }

                    $existing = AbsensiHarian::query()
                        ->where('siswa_id', $student->id)
                        ->where('jadwal_id', $schedule->id)
                        ->whereDate('tanggal', $date->toDateString())
                        ->lockForUpdate()
                        ->first();

                    // Never downgrade a valid attendance record to izin/sakit.
                    if ($existing && $existing->status === 'hadir') {
                        continue;
                    }

                    // Keep a row already linked to another approved letter intact.
                    if ($existing && $existing->surat_absensi_id && (int) $existing->surat_absensi_id !== (int) $locked->id) {
                        continue;
                    }

                    $approvalNote = 'Disetujui berdasarkan surat pengajuan #' . $locked->id . '.';
                    $reason = trim((string) $locked->alasan);
                    if ($reason !== '') {
                        $approvalNote .= ' Keterangan: ' . $reason;
                    }

                    $values = [
                        'status' => $kategori,
                        'waktu_absen' => null,
                        'metode' => 'manual',
                        'keterangan' => $approvalNote,
                        'surat_absensi_id' => $locked->id,
                    ];

                    if ($existing) {
                        $existing->update($values);
                    } else {
                        AbsensiHarian::create(array_merge([
                            'siswa_id' => $student->id,
                            'jadwal_id' => $schedule->id,
                            'tanggal' => $date->toDateString(),
                        ], $values));
                    }
                    $updatedRows++;
                }
            }

            return $updatedRows;
        });
    }
}

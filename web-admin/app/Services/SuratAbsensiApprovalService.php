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
 * Menyatukan proses persetujuan surat agar Admin dan Guru menghasilkan
 * catatan absensi harian yang konsisten dan dapat ditelusuri ke surat asal.
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
            $locked = SuratAbsensi::query()->lockForUpdate()->with('siswa')->findOrFail($surat->id);
            if (strtolower((string) $locked->status_verifikasi) !== 'pending') {
                throw ValidationException::withMessages([
                    'status' => 'Surat ini sudah diproses sebelumnya.',
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

            foreach ($period as $date) {
                $dayName = $dayNames[$date->dayOfWeekIso] ?? null;
                if ($dayName === null) {
                    continue;
                }

                foreach ($schedulesByDay->get($dayName, collect()) as $schedule) {
                    $schedulePeriod = $schedule->periode;
                    if (! $schedulePeriod) {
                        continue;
                    }

                    // Surat can cross an academic-period boundary. Only create
                    // attendance while this exact schedule's period is active.
                    $periodStart = Carbon::parse($schedulePeriod->tanggal_mulai)->startOfDay();
                    $periodEnd = Carbon::parse($schedulePeriod->tanggal_selesai)->startOfDay();
                    if ($date->lt($periodStart) || $date->gt($periodEnd)) {
                        continue;
                    }

                    AbsensiHarian::updateOrCreate(
                        [
                            'siswa_id' => $student->id,
                            'jadwal_id' => $schedule->id,
                            'tanggal' => $date->toDateString(),
                        ],
                        [
                            'status' => $kategori,
                            'waktu_absen' => null,
                            'metode' => 'manual',
                            'keterangan' => 'Disetujui berdasarkan surat pengajuan #' . $locked->id . '.',
                            'surat_absensi_id' => $locked->id,
                        ],
                    );
                    $updatedRows++;
                }
            }

            return $updatedRows;
        });
    }
}

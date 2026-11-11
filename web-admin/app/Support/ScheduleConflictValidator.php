<?php

namespace App\Support;

use App\Models\JadwalPelajaran;
use Illuminate\Validation\ValidationException;

/**
 * Checks that a teacher and a classroom are not assigned to overlapping
 * timetable slots in the same academic period and weekday.
 */
class ScheduleConflictValidator
{
    public static function ensureAvailable(array $data, ?int $ignoreId = null): void
    {
        $overlapping = JadwalPelajaran::query()
            ->where('periode_id', $data['periode_id'])
            ->where('hari', $data['hari'])
            ->where('jam_mulai', '<', $data['jam_selesai'])
            ->where('jam_selesai', '>', $data['jam_mulai'])
            ->when($ignoreId, fn ($query) => $query->where('id', '!=', $ignoreId));

        if ((clone $overlapping)->where('guru_id', $data['guru_id'])->exists()) {
            throw ValidationException::withMessages([
                'guru_id' => 'Guru tersebut sudah memiliki jadwal yang bertabrakan pada hari dan jam yang dipilih.',
            ]);
        }

        if ((clone $overlapping)->where('kelas_id', $data['kelas_id'])->exists()) {
            throw ValidationException::withMessages([
                'kelas_id' => 'Kelas tersebut sudah memiliki pelajaran lain pada hari dan jam yang dipilih.',
            ]);
        }
    }
}

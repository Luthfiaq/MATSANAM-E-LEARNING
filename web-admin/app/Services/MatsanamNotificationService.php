<?php

namespace App\Services;

use App\Models\User;
use App\Notifications\MatsanamNotification;
use Illuminate\Database\Eloquent\Builder;

class MatsanamNotificationService
{
    private const DEFAULT_PREFERENCES = [
        'siswa' => [
            'tugas_baru' => true,
            'nilai' => true,
            'materi_baru' => true,
            'absensi' => true,
            'pengumuman' => true,
        ],
        'guru' => [
            'pengumpulan_tugas' => true,
            'pengajuan_izin' => true,
            'pengumuman' => true,
        ],
        'admin' => [
            'pengajuan_izin' => true,
            'pengumuman' => true,
        ],
    ];

    private const EVENT_PREFERENCE = [
        'materi_baru' => 'materi_baru',
        'tugas_baru' => 'tugas_baru',
        'nilai_diterbitkan' => 'nilai',
        'status_pengajuan_izin' => 'absensi',
        'pengumpulan_tugas' => 'pengumpulan_tugas',
        'pengajuan_izin' => 'pengajuan_izin',
        'pengumuman' => 'pengumuman',
    ];

    public function preferencesFor(User $user): array
    {
        $defaults = self::DEFAULT_PREFERENCES[$user->role] ?? self::DEFAULT_PREFERENCES['siswa'];
        $saved = is_array($user->notification_preferences) ? $user->notification_preferences : [];

        return array_merge($defaults, array_intersect_key($saved, $defaults));
    }

    public function savePreferences(User $user, array $preferences): array
    {
        $current = $this->preferencesFor($user);
        $user->forceFill([
            'notification_preferences' => array_merge($current, array_intersect_key($preferences, $current)),
        ])->save();

        return $this->preferencesFor($user->fresh());
    }

    public function send(
        ?User $user,
        string $eventType,
        string $title,
        string $body,
        array $metadata = [],
    ): bool {
        if (! $user || ! $user->is_active) {
            return false;
        }

        $preference = self::EVENT_PREFERENCE[$eventType] ?? null;
        if ($preference !== null) {
            $preferences = $this->preferencesFor($user);
            if (($preferences[$preference] ?? true) !== true) {
                return false;
            }
        }

        try {
            $user->notify(new MatsanamNotification($eventType, $title, $body, $metadata));
            return true;
        } catch (\Throwable $exception) {
            // A missing/temporarily unavailable notifications table must not turn
            // a successful material, task, grade, or permit action into HTTP 500.
            report($exception);
            return false;
        }
    }

    public function notifyClassStudents(
        int $classId,
        string $eventType,
        string $title,
        string $body,
        array $metadata = [],
    ): int {
        return $this->notifyUsers(
            User::query()
                ->where('role', 'siswa')
                ->where('is_active', true)
                ->whereHas('siswa', fn (Builder $query) => $query->where('kelas_id', $classId)),
            $eventType,
            $title,
            $body,
            $metadata,
        );
    }

    public function notifyAdmins(
        string $eventType,
        string $title,
        string $body,
        array $metadata = [],
    ): int {
        return $this->notifyUsers(
            User::query()
                ->where('role', 'admin')
                ->where('is_active', true),
            $eventType,
            $title,
            $body,
            $metadata,
        );
    }

    public function notifyClassTeachers(
        int $classId,
        string $eventType,
        string $title,
        string $body,
        array $metadata = [],
    ): int {
        return $this->notifyUsers(
            User::query()
                ->where('role', 'guru')
                ->where('is_active', true)
                ->whereHas('guru.jadwalPelajaran', fn (Builder $query) => $query->where('kelas_id', $classId)),
            $eventType,
            $title,
            $body,
            $metadata,
        );
    }

    private function notifyUsers(
        Builder $query,
        string $eventType,
        string $title,
        string $body,
        array $metadata,
    ): int {
        $sent = 0;
        $query->select('users.*')->orderBy('users.id')->chunkById(100, function ($users) use (&$sent, $eventType, $title, $body, $metadata) {
            foreach ($users as $user) {
                if ($this->send($user, $eventType, $title, $body, $metadata)) {
                    $sent++;
                }
            }
        });

        return $sent;
    }
}

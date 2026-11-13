<?php

namespace App\Http\Middleware;

use App\Models\AdminActivityLog;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;
use Symfony\Component\HttpFoundation\Response;
use Throwable;

class LogAdminActivity
{
    public function handle(Request $request, \Closure $next): Response
    {
        $route = $request->route();
        $routeName = (string) ($route?->getName() ?? 'admin.unknown');
        $method = strtoupper($request->method());
        $isExport = Str::contains($routeName, ['.export', '.template', '.credentials']);
        $isMutation = in_array($method, ['POST', 'PUT', 'PATCH', 'DELETE'], true);

        if (! $request->user() || ! ($isMutation || $isExport) || Str::startsWith($routeName, 'admin.notifications.')) {
            return $next($request);
        }

        try {
            $response = $next($request);
            $outcome = null;
            if ($request->hasSession()) {
                if ($request->session()->has('errors')) {
                    $outcome = 'ValidationException';
                } elseif ($request->session()->has('error') || $request->session()->has('warning')) {
                    $outcome = 'ActionFailed';
                }
            }
            $this->writeLog($request, $routeName, $method, $response->getStatusCode(), $outcome);

            return $response;
        } catch (Throwable $exception) {
            $this->writeLog($request, $routeName, $method, 500, class_basename($exception));
            throw $exception;
        }
    }

    private function writeLog(Request $request, string $routeName, string $method, int $statusCode, ?string $exceptionClass): void
    {
        try {
            if (! Schema::hasTable('admin_activity_logs')) {
                return;
            }

            $parts = explode('.', $routeName);
            $moduleKey = $parts[1] ?? 'admin';
            $module = match ($moduleKey) {
                'accounts' => 'Manajemen Akun',
                'master-data' => match ($parts[2] ?? '') {
                    'guru' => 'Master Data Guru',
                    'siswa' => 'Master Data Siswa',
                    'kelas' => 'Master Data Kelas',
                    'mata-pelajaran' => 'Master Data Mata Pelajaran',
                    'periode-akademik' => 'Periode Akademik',
                    'jadwal-pelajaran' => 'Jadwal Pelajaran',
                    default => 'Master Data',
                },
                'materi' => 'Manajemen Materi',
                'tugas' => 'Manajemen Tugas',
                'nilai' => 'Manajemen Nilai',
                'absensi' => 'Absensi',
                'penugasan' => 'Penugasan Guru',
                'pengaturan' => 'Pengaturan',
                'data-transfer' => 'Import / Ekspor',
                'activity-logs' => 'Audit Log',
                default => Str::title(str_replace(['-', '_'], ' ', $moduleKey)),
            };

            $action = $this->resolveAction($routeName, $method, $statusCode, $exceptionClass);
            [$entityType, $entityId, $entityLabel] = $this->resolveEntity($request);

            $description = match ($action) {
                'created' => 'Admin menambahkan data pada ' . $module . '.',
                'updated' => 'Admin memperbarui data pada ' . $module . '.',
                'deleted' => 'Admin menghapus data pada ' . $module . '.',
                'approved' => 'Admin menyetujui permintaan pada ' . $module . '.',
                'rejected' => 'Admin menolak permintaan pada ' . $module . '.',
                'password_reset' => 'Admin mereset password akun.',
                'status_changed' => 'Admin mengubah status data pada ' . $module . '.',
                'imported' => 'Admin mengimpor data melalui ' . $module . '.',
                'exported' => 'Admin mengekspor atau mengunduh data dari ' . $module . '.',
                'restored' => 'Admin memulihkan data pada ' . $module . '.',
                'validation_failed' => 'Permintaan perubahan data pada ' . $module . ' tidak lolos validasi.',
                'previewed' => 'Admin memvalidasi file pada ' . $module . '.',
                'cancelled' => 'Admin membatalkan proses pada ' . $module . '.',
                'failed' => 'Permintaan perubahan data pada ' . $module . ' mengalami kegagalan.',
                default => 'Admin menjalankan aksi pada ' . $module . '.',
            };

            AdminActivityLog::create([
                'actor_id' => $request->user()->id,
                'module' => $module,
                'action' => $action,
                'entity_type' => $entityType,
                'entity_id' => $entityId,
                'entity_label' => $entityLabel,
                'description' => $description,
                // Deliberately do not store request bodies: they may contain passwords or private student data.
                'metadata' => array_filter([
                    'route' => $request->route()?->getName(),
                    'method' => $method,
                    'status_code' => $statusCode,
                    'exception' => $exceptionClass,
                ], static fn ($value) => $value !== null),
                'ip_address' => $request->ip(),
                'user_agent' => Str::limit((string) $request->userAgent(), 500, ''),
            ]);
        } catch (Throwable) {
            // Audit logging must never break the primary administrative operation.
        }
    }

    private function resolveAction(string $routeName, string $method, int $statusCode, ?string $exceptionClass): string
    {
        if ($exceptionClass === 'ValidationException') {
            return 'validation_failed';
        }
        if ($exceptionClass !== null || $statusCode >= 400) {
            return 'failed';
        }
        if (Str::contains($routeName, ['.export', '.template', '.credentials'])) {
            return 'exported';
        }
        if (Str::contains($routeName, ['.reset-password'])) return 'password_reset';
        if (Str::contains($routeName, ['.approve'])) return 'approved';
        if (Str::contains($routeName, ['.reject'])) return 'rejected';
        if (Str::contains($routeName, ['.restore'])) return 'restored';
        if (Str::contains($routeName, ['.status'])) return 'status_changed';
        if (Str::contains($routeName, ['.import'])) return 'imported';
        if (Str::contains($routeName, ['.preview'])) return 'previewed';
        if (Str::contains($routeName, ['.cancel'])) return 'cancelled';
        if (Str::contains($routeName, ['.destroy', '.delete'])) return 'deleted';
        if (Str::contains($routeName, ['.store', '.create'])) return 'created';
        if (Str::contains($routeName, ['.update', '.edit'])) return 'updated';
        if ($method === 'DELETE') return 'deleted';
        if (in_array($method, ['PUT', 'PATCH'], true)) return 'updated';
        return 'performed';
    }

    private function resolveEntity(Request $request): array
    {
        $route = $request->route();
        if (! $route) return [null, null, null];

        foreach ($route->parameters() as $key => $value) {
            if ($value instanceof Model) {
                $label = $value->getAttribute('nama_lengkap')
                    ?? $value->getAttribute('name')
                    ?? $value->getAttribute('nama')
                    ?? $value->getAttribute('judul');

                return [class_basename($value), (string) $value->getKey(), $label ? (string) $label : null];
            }
            if (in_array($key, ['id', 'userId', 'user_id', 'tugas_id', 'submissionId'], true) && is_scalar($value)) {
                return [Str::title(str_replace('_', ' ', $key)), (string) $value, null];
            }
        }

        return [null, null, null];
    }
}

<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AdminActivityLog;
use Illuminate\Http\Request;
use Illuminate\View\View;
use Symfony\Component\HttpFoundation\StreamedResponse;

class AdminActivityLogController extends Controller
{
    public function index(Request $request): View
    {
        $validated = $request->validate([
            'q' => ['nullable', 'string', 'max:120'],
            'module' => ['nullable', 'string', 'max:60'],
            'action' => ['nullable', 'string', 'max:60'],
            'from' => ['nullable', 'date'],
            'to' => ['nullable', 'date'],
        ]);

        $logs = $this->filteredQuery($validated)
            ->with('actor:id,name,email')
            ->latest('id')
            ->paginate(20)
            ->withQueryString();

        $today = AdminActivityLog::whereDate('created_at', today());
        $stats = [
            'today' => (clone $today)->count(),
            'month' => AdminActivityLog::whereMonth('created_at', now()->month)
                ->whereYear('created_at', now()->year)->count(),
            'admins' => AdminActivityLog::where('created_at', '>=', now()->subDays(30))
                ->distinct('actor_id')->count('actor_id'),
            'imports' => AdminActivityLog::where('action', 'imported')
                ->whereMonth('created_at', now()->month)->whereYear('created_at', now()->year)->count(),
        ];

        $modules = AdminActivityLog::query()->select('module')->distinct()->orderBy('module')->pluck('module');
        $actions = [
            'created' => 'Tambah', 'updated' => 'Ubah', 'deleted' => 'Hapus',
            'approved' => 'Disetujui', 'rejected' => 'Ditolak', 'password_reset' => 'Reset Password',
            'status_changed' => 'Ubah Status', 'imported' => 'Import', 'exported' => 'Ekspor',
            'restored' => 'Pulihkan', 'failed' => 'Gagal', 'validation_failed' => 'Validasi Gagal',
            'login' => 'Login', 'logout' => 'Logout', 'previewed' => 'Preview', 'cancelled' => 'Dibatalkan',
            'performed' => 'Aksi Lainnya',
        ];

        return view('admin.activity-logs.index', compact('logs', 'stats', 'modules', 'actions'));
    }

    public function export(Request $request): StreamedResponse
    {
        $validated = $request->validate([
            'q' => ['nullable', 'string', 'max:120'],
            'module' => ['nullable', 'string', 'max:60'],
            'action' => ['nullable', 'string', 'max:60'],
            'from' => ['nullable', 'date'],
            'to' => ['nullable', 'date'],
        ]);

        $query = $this->filteredQuery($validated)->with('actor:id,name,email')->latest('id');

        return response()->streamDownload(function () use ($query) {
            $output = fopen('php://output', 'w');
            fwrite($output, "\xEF\xBB\xBF");
            fputcsv($output, ['Waktu', 'Admin', 'Email Admin', 'Modul', 'Aksi', 'Entitas', 'ID Entitas', 'Deskripsi', 'IP', 'Route', 'Metode', 'Status HTTP']);

            foreach ($query->cursor() as $log) {
                fputcsv($output, [
                    $log->created_at?->format('Y-m-d H:i:s'),
                    $this->safeCsv($log->actor?->name ?? 'Akun dihapus'),
                    $this->safeCsv($log->actor?->email ?? ''),
                    $this->safeCsv($log->module),
                    $this->safeCsv($log->action),
                    $this->safeCsv($log->entity_label ?? $log->entity_type ?? ''),
                    $this->safeCsv($log->entity_id),
                    $this->safeCsv($log->description),
                    $this->safeCsv($log->ip_address),
                    $this->safeCsv($log->metadata['route'] ?? ''),
                    $this->safeCsv($log->metadata['method'] ?? ''),
                    $log->metadata['status_code'] ?? '',
                ]);
            }
            fclose($output);
        }, 'audit-log-' . now()->format('Ymd-His') . '.csv', [
            'Content-Type' => 'text/csv; charset=UTF-8',
            'Cache-Control' => 'no-store, no-cache, must-revalidate',
        ]);
    }

    private function filteredQuery(array $filters)
    {
        return AdminActivityLog::query()
            ->when($filters['module'] ?? null, fn ($query, $module) => $query->where('module', $module))
            ->when($filters['action'] ?? null, fn ($query, $action) => $query->where('action', $action))
            ->when($filters['from'] ?? null, fn ($query, $from) => $query->whereDate('created_at', '>=', $from))
            ->when($filters['to'] ?? null, fn ($query, $to) => $query->whereDate('created_at', '<=', $to))
            ->when($filters['q'] ?? null, function ($query, $term) {
                $query->where(function ($nested) use ($term) {
                    $nested->where('description', 'like', '%' . $term . '%')
                        ->orWhere('entity_label', 'like', '%' . $term . '%')
                        ->orWhere('entity_id', 'like', '%' . $term . '%')
                        ->orWhereHas('actor', fn ($actor) => $actor->where('name', 'like', '%' . $term . '%')
                            ->orWhere('email', 'like', '%' . $term . '%'));
                });
            });
    }

    private function safeCsv(?string $value): string
    {
        $value = (string) $value;
        return preg_match('/^[\s]*[=+\-@]/u', $value) ? "'" . $value : $value;
    }
}

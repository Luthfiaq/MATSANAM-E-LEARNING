@extends('layouts.admin')
@section('title', 'Audit Log')

@section('content')
<div class="max-w-[1600px] mx-auto space-y-5">
    <div class="flex flex-col xl:flex-row xl:items-end xl:justify-between gap-4">
        <div>
            <div class="text-xs text-slate-400 mb-2"><a href="{{ route('admin.dashboard') }}" class="hover:text-blue-600">Dashboard</a> <span class="mx-1">›</span> Audit & Data <span class="mx-1">›</span> Audit Log</div>
            <h1 class="text-2xl md:text-[28px] font-bold tracking-tight text-slate-900 dark:text-slate-100">Audit Log Aktivitas</h1>
            <p class="text-sm text-slate-500 mt-1">Jejak perubahan administratif pada akun, master data, pembelajaran, dan absensi.</p>
        </div>
        <a href="{{ route('admin.activity-logs.export', request()->query()) }}" class="inline-flex items-center justify-center gap-2 rounded-xl bg-blue-600 hover:bg-blue-700 px-4 py-2.5 text-sm font-semibold text-white shadow-sm">↓ Ekspor Log CSV</a>
    </div>

    @if(session('success'))<div class="rounded-xl border border-emerald-200 bg-emerald-50 text-emerald-800 px-4 py-3 text-sm">✓ {{ session('success') }}</div>@endif
    @if(session('warning'))<div class="rounded-xl border border-amber-200 bg-amber-50 text-amber-800 px-4 py-3 text-sm">! {{ session('warning') }}</div>@endif

    <div class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-3">
        <div class="audit-stat"><div><p class="audit-label">Aktivitas Hari Ini</p><p class="audit-value">{{ number_format($stats['today']) }}</p><p class="audit-note">Semua aksi Admin tercatat</p></div><span class="audit-icon bg-blue-50 text-blue-700">◷</span></div>
        <div class="audit-stat"><div><p class="audit-label">Aktivitas Bulan Ini</p><p class="audit-value">{{ number_format($stats['month']) }}</p><p class="audit-note">Bulan berjalan</p></div><span class="audit-icon bg-indigo-50 text-indigo-700">▤</span></div>
        <div class="audit-stat"><div><p class="audit-label">Admin Aktif</p><p class="audit-value">{{ number_format($stats['admins']) }}</p><p class="audit-note">Dalam 30 hari terakhir</p></div><span class="audit-icon bg-emerald-50 text-emerald-700">♙</span></div>
        <div class="audit-stat"><div><p class="audit-label">Proses Import</p><p class="audit-value">{{ number_format($stats['imports']) }}</p><p class="audit-note">Bulan berjalan</p></div><span class="audit-icon bg-amber-50 text-amber-700">⇧</span></div>
    </div>

    <section class="rounded-2xl border border-slate-200 bg-white dark:bg-slate-800 dark:border-slate-700 shadow-sm overflow-hidden">
        <div class="p-4 md:p-5 border-b border-slate-100 dark:border-slate-700 flex flex-col lg:flex-row lg:items-center lg:justify-between gap-2">
            <div><h2 class="font-bold text-slate-900 dark:text-slate-100">Riwayat Aktivitas</h2><p class="text-xs text-slate-500 mt-1">Pencatatan otomatis tidak menyimpan password atau isi formulir pribadi.</p></div>
            <span class="text-xs text-slate-500">{{ $logs->total() }} catatan ditemukan</span>
        </div>
        <form method="GET" action="{{ route('admin.activity-logs.index') }}" class="p-4 md:p-5 grid grid-cols-1 md:grid-cols-2 xl:grid-cols-6 gap-2 border-b border-slate-100 dark:border-slate-700">
            <label class="xl:col-span-2 relative"><span class="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400">⌕</span><input class="audit-field pl-9" type="search" name="q" value="{{ request('q') }}" placeholder="Cari Admin, deskripsi, entitas..."></label>
            <select class="audit-field" name="module"><option value="">Semua Modul</option>@foreach($modules as $module)<option value="{{ $module }}" @selected(request('module') === $module)>{{ $module }}</option>@endforeach</select>
            <select class="audit-field" name="action"><option value="">Semua Aksi</option>@foreach($actions as $key => $label)<option value="{{ $key }}" @selected(request('action') === $key)>{{ $label }}</option>@endforeach</select>
            <input class="audit-field" type="date" name="from" value="{{ request('from') }}" aria-label="Dari tanggal">
            <input class="audit-field" type="date" name="to" value="{{ request('to') }}" aria-label="Sampai tanggal">
            <div class="md:col-span-2 xl:col-span-6 flex justify-end gap-2">
                <a href="{{ route('admin.activity-logs.index') }}" class="rounded-lg bg-slate-100 dark:bg-slate-700 px-4 py-2 text-xs font-semibold text-slate-600 dark:text-slate-200">Reset</a>
                <button class="rounded-lg bg-blue-600 hover:bg-blue-700 px-4 py-2 text-xs font-semibold text-white">Terapkan Filter</button>
            </div>
        </form>

        <div class="overflow-x-auto">
            <table class="w-full min-w-[920px] text-sm">
                <thead class="bg-slate-50 dark:bg-slate-900/70 text-slate-500 dark:text-slate-300 text-[10px] uppercase tracking-wider">
                    <tr><th class="px-5 py-3 text-left">Waktu</th><th class="px-5 py-3 text-left">Admin</th><th class="px-5 py-3 text-left">Modul / Aksi</th><th class="px-5 py-3 text-left">Aktivitas</th><th class="px-5 py-3 text-left">Konteks</th><th class="px-5 py-3 text-left">IP</th></tr>
                </thead>
                <tbody class="divide-y divide-slate-100 dark:divide-slate-700">
                    @forelse($logs as $log)
                        @php
                            $actionLabels = ['created'=>'Tambah','updated'=>'Ubah','deleted'=>'Hapus','approved'=>'Disetujui','rejected'=>'Ditolak','password_reset'=>'Reset Password','status_changed'=>'Ubah Status','imported'=>'Import','exported'=>'Ekspor','restored'=>'Pulihkan','failed'=>'Gagal','validation_failed'=>'Validasi Gagal','login'=>'Login','logout'=>'Logout','previewed'=>'Preview','cancelled'=>'Dibatalkan','performed'=>'Aksi'];
                            $actionTone = in_array($log->action, ['created','approved','restored','imported']) ? 'green' : (in_array($log->action, ['deleted','rejected','failed','validation_failed']) ? 'red' : (in_array($log->action, ['exported','password_reset']) ? 'blue' : 'slate'));
                        @endphp
                        <tr class="hover:bg-slate-50/80 dark:hover:bg-slate-700/40">
                            <td class="px-5 py-4 whitespace-nowrap"><div class="font-semibold text-slate-800 dark:text-slate-100 text-xs">{{ $log->created_at?->format('d M Y') }}</div><div class="text-[11px] text-slate-400 mt-1">{{ $log->created_at?->format('H:i:s') }}</div></td>
                            <td class="px-5 py-4"><div class="font-semibold text-slate-800 dark:text-slate-100 text-xs">{{ $log->actor?->name ?? 'Akun tidak tersedia' }}</div><div class="text-[11px] text-slate-400 mt-1">{{ $log->actor?->email ?? '—' }}</div></td>
                            <td class="px-5 py-4"><div class="text-xs font-semibold text-slate-700 dark:text-slate-200">{{ $log->module }}</div><span class="audit-badge audit-{{ $actionTone }}">{{ $actionLabels[$log->action] ?? ucwords(str_replace('_', ' ', $log->action)) }}</span></td>
                            <td class="px-5 py-4 max-w-[360px]"><p class="text-xs text-slate-700 dark:text-slate-200">{{ $log->description }}</p>@if(!empty($log->metadata['route']))<p class="text-[10px] text-slate-400 mt-1 font-mono">{{ $log->metadata['route'] }}</p>@endif</td>
                            <td class="px-5 py-4"><div class="text-xs text-slate-600 dark:text-slate-300">{{ $log->entity_label ?? $log->entity_type ?? '—' }}</div>@if($log->entity_id)<div class="text-[10px] text-slate-400 mt-1">ID: {{ $log->entity_id }}</div>@endif</td>
                            <td class="px-5 py-4 text-[11px] text-slate-500 font-mono">{{ $log->ip_address ?? '—' }}</td>
                        </tr>
                    @empty
                        <tr><td colspan="6" class="px-5 py-16 text-center"><div class="text-3xl mb-2">▤</div><p class="font-semibold text-slate-700 dark:text-slate-200">Belum ada aktivitas tercatat</p><p class="text-xs text-slate-400 mt-1">Aksi perubahan Admin akan muncul di halaman ini setelah fitur audit diaktifkan.</p></td></tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        <div class="px-5 py-4 border-t border-slate-100 dark:border-slate-700">{{ $logs->links() }}</div>
    </section>
</div>

<style>
.audit-stat{background:#fff;border:1px solid #e2e8f0;border-radius:14px;padding:18px;display:flex;align-items:flex-start;justify-content:space-between;box-shadow:0 1px 2px #0f172a08}.dark .audit-stat{background:#1e293b;border-color:#334155}.audit-label{font-size:10px;letter-spacing:.11em;font-weight:700;color:#64748b;text-transform:uppercase}.audit-value{font-size:29px;font-weight:750;line-height:1.2;color:#0f172a;margin-top:7px}.dark .audit-value{color:#f8fafc}.audit-note{font-size:11px;color:#94a3b8;margin-top:5px}.audit-icon{width:42px;height:42px;border-radius:12px;display:grid;place-items:center;font-size:21px}.audit-field{width:100%;border:1px solid #e2e8f0;background:#fff;border-radius:9px;padding:10px 11px;font-size:12px;color:#334155;outline:none}.audit-field:focus{border-color:#60a5fa;box-shadow:0 0 0 3px #dbeafe}.dark .audit-field{background:#0f172a;border-color:#475569;color:#e2e8f0}.audit-badge{display:inline-flex;margin-top:6px;border-radius:999px;padding:3px 8px;font-size:10px;font-weight:700}.audit-green{background:#ecfdf5;color:#047857}.audit-red{background:#fef2f2;color:#b91c1c}.audit-blue{background:#eff6ff;color:#1d4ed8}.audit-slate{background:#f1f5f9;color:#475569}.dark .audit-slate{background:#334155;color:#cbd5e1}
</style>
@endsection

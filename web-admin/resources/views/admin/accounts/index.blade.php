@extends('layouts.admin')
@section('title', 'Manajemen Akun')

@section('content')
@php
    $activeTab = $role ?? 'all';
    $showDeleted = (bool) ($showDeleted ?? false);
    $tabBase = ['q' => request('q'), 'status' => request('status'), 'class_id' => request('class_id'), 'subject_id' => request('subject_id'), 'show_deleted' => $showDeleted ? 1 : null];
@endphp
<div class="max-w-[1600px] mx-auto space-y-5">
    <div class="flex flex-col xl:flex-row xl:items-end xl:justify-between gap-4">
        <div>
            <div class="text-xs text-slate-400 mb-2"><a href="{{ route('admin.dashboard') }}" class="hover:text-blue-600">Dashboard</a> <span class="mx-1">›</span> Manajemen Akun</div>
            <h1 class="text-2xl md:text-[28px] font-bold tracking-tight text-slate-900">Manajemen Akun</h1>
            <p class="text-sm text-slate-500 mt-1">Kelola akun Guru dan Siswa dalam satu konsol administrasi MTsN 6 Nganjuk.</p>
        </div>
        <div class="flex items-center gap-2 text-xs rounded-xl border border-emerald-200 bg-white px-4 py-3 shadow-sm">
            <span class="w-2 h-2 rounded-full bg-emerald-500"></span><span class="text-slate-500">Database</span><strong class="text-emerald-700">Terhubung</strong>
        </div>
    </div>

    @if(session('success'))
        <div class="rounded-xl border border-emerald-200 bg-emerald-50 text-emerald-800 px-4 py-3 text-sm flex items-start gap-2"><span>✓</span><span>{{ session('success') }}</span></div>
    @endif

    <div class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-3">
        <div class="stat-card"><div><p class="stat-label">Total Guru</p><p class="stat-value">{{ number_format($stats['guru']) }}</p><p class="stat-note">Akun tenaga pendidik</p></div><div class="stat-icon bg-blue-50 text-blue-600">♙</div></div>
        <div class="stat-card"><div><p class="stat-label">Total Siswa</p><p class="stat-value">{{ number_format($stats['siswa']) }}</p><p class="stat-note">Akun peserta didik</p></div><div class="stat-icon bg-emerald-50 text-emerald-600">♧</div></div>
        <div class="stat-card"><div><p class="stat-label">Akun Aktif</p><p class="stat-value text-emerald-700">{{ number_format($stats['active']) }}</p><p class="stat-note">Dapat mengakses aplikasi</p></div><div class="stat-icon bg-emerald-50 text-emerald-600">✓</div></div>
        <div class="stat-card"><div><p class="stat-label">Akun Nonaktif</p><p class="stat-value text-amber-600">{{ number_format($stats['inactive']) }}</p><p class="stat-note">Perlu ditinjau Admin</p></div><div class="stat-icon bg-amber-50 text-amber-600">Ⅱ</div></div>
    </div>

    <div class="bg-white rounded-xl border border-slate-200 p-4 shadow-sm space-y-4">
        <div class="flex flex-col lg:flex-row lg:items-center justify-between gap-3">
            <div class="inline-flex p-1 bg-slate-100 rounded-xl gap-1">
                <a href="{{ route('admin.accounts.index', array_merge($tabBase, ['role' => 'all'])) }}" class="tab-link {{ $activeTab === 'all' ? 'tab-active' : '' }}">Semua Akun <span>{{ $stats['guru'] + $stats['siswa'] }}</span></a>
                <a href="{{ route('admin.accounts.index', array_merge($tabBase, ['role' => 'guru'])) }}" class="tab-link {{ $activeTab === 'guru' ? 'tab-active' : '' }}">Guru <span>{{ $stats['guru'] }}</span></a>
                <a href="{{ route('admin.accounts.index', array_merge($tabBase, ['role' => 'siswa'])) }}" class="tab-link {{ $activeTab === 'siswa' ? 'tab-active' : '' }}">Siswa <span>{{ $stats['siswa'] }}</span></a>
            </div>
            <div class="flex flex-wrap gap-2">
                <a href="{{ route('admin.accounts.index', ['role' => $activeTab, 'show_deleted' => $showDeleted ? null : 1]) }}" class="btn-light">{{ $showDeleted ? '← Akun Aktif & Nonaktif' : '♻ Akun Terhapus' }}</a>
                @unless($showDeleted)
                    <a href="{{ route('admin.accounts.create', 'guru') }}" class="btn-primary">＋ Tambah Guru</a>
                    <a href="{{ route('admin.accounts.create', 'siswa') }}" class="btn-outline">＋ Tambah Siswa</a>
                @endunless
            </div>
        </div>
        <form method="GET" action="{{ route('admin.accounts.index') }}" class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-5 gap-2">
            <input type="hidden" name="role" value="{{ $activeTab }}">
            @if($showDeleted)<input type="hidden" name="show_deleted" value="1">@endif
            <label class="xl:col-span-2 relative"><span class="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400">⌕</span><input name="q" value="{{ request('q') }}" placeholder="Cari nama, email, NIP, NIS, atau NISN..." class="field pl-9"></label>
            <select name="status" class="field"><option value="">Semua Status</option><option value="active" @selected(request('status') === 'active')>Aktif</option><option value="inactive" @selected(request('status') === 'inactive')>Nonaktif</option></select>
            <select name="class_id" class="field"><option value="">Semua Kelas</option>@foreach($classes as $class)<option value="{{ $class->id }}" @selected((string)request('class_id') === (string)$class->id)>{{ $class->nama_kelas }}</option>@endforeach</select>
            <select name="subject_id" class="field"><option value="">Semua Mata Pelajaran</option>@foreach($subjects as $subject)<option value="{{ $subject->id }}" @selected((string)request('subject_id') === (string)$subject->id)>{{ $subject->nama }}</option>@endforeach</select>
            <div class="md:col-span-2 xl:col-span-5 flex justify-end gap-2">
                <a href="{{ route('admin.accounts.index', ['role' => $activeTab, 'show_deleted' => $showDeleted ? 1 : null]) }}" class="btn-light">Reset Filter</a>
                <button class="btn-outline" type="submit">Terapkan Filter</button>
            </div>
        </form>
    </div>

    <div class="bg-white border border-slate-200 rounded-xl shadow-sm overflow-hidden">
        <div class="px-5 py-4 border-b border-slate-100 flex flex-col sm:flex-row sm:items-center justify-between gap-2">
            <div><h2 class="font-semibold text-slate-900">{{ $showDeleted ? 'Akun Terhapus' : 'Daftar Akun Pengguna' }}</h2><p class="text-xs text-slate-500 mt-0.5">{{ $showDeleted ? 'Akun disembunyikan dari akses login; data akademik tetap dipertahankan.' : 'Data diambil langsung dari database MATSANAM.' }}</p></div>
            <span class="text-xs text-slate-400">{{ $accounts->total() }} akun ditemukan</span>
        </div>
        <div class="overflow-x-auto">
            <table class="min-w-[980px] w-full text-sm">
                <thead class="bg-slate-50 text-slate-500 text-[11px] uppercase tracking-wide"><tr><th class="text-left px-5 py-3">Pengguna</th><th class="text-left px-4 py-3">Email</th><th class="text-left px-4 py-3">Role</th><th class="text-left px-4 py-3">Identitas</th><th class="text-left px-4 py-3">Kelas / Mapel</th><th class="text-left px-4 py-3">Status</th><th class="text-left px-4 py-3">Terakhir Login</th><th class="text-right px-5 py-3">Aksi</th></tr></thead>
                <tbody class="divide-y divide-slate-100">
                    @forelse($accounts as $account)
                        @php
                            $profile = $account->role === 'guru' ? $account->guru : $account->siswa;
                            $displayName = $profile?->nama_lengkap ?: $account->name;
                            $identity = $account->role === 'guru' ? ($profile?->nip ?? '—') : ($profile?->nisn ?? $profile?->nis ?? '—');
                            $context = $account->role === 'guru'
                                ? $account->guru?->jadwalPelajaran->map(fn ($jadwal) => $jadwal->mataPelajaran?->nama)->filter()->unique()->implode(', ')
                                : $account->siswa?->kelas?->nama_kelas;
                        @endphp
                        <tr class="hover:bg-slate-50/80">
                            <td class="px-5 py-3.5"><div class="flex items-center gap-3"><div class="avatar {{ $account->role === 'guru' ? 'avatar-blue' : 'avatar-green' }}">{{ mb_strtoupper(mb_substr($displayName, 0, 2)) }}</div><div><a href="{{ route('admin.accounts.show', $account) }}" class="font-semibold text-slate-800 hover:text-blue-700">{{ $displayName }}</a><div class="text-[11px] text-slate-400 mt-0.5">ID #{{ $account->id }}</div></div></div></td>
                            <td class="px-4 py-3.5 text-slate-600">{{ $account->email }}</td>
                            <td class="px-4 py-3.5"><span class="role-badge {{ $account->role === 'guru' ? 'role-blue' : 'role-green' }}">{{ $account->role === 'guru' ? 'GURU' : 'SISWA' }}</span></td>
                            <td class="px-4 py-3.5 font-medium text-slate-700 tabular-nums">{{ $identity }}</td>
                            <td class="px-4 py-3.5 text-slate-600 max-w-[180px]"><span class="line-clamp-2">{{ $context ?: 'Belum ada data jadwal' }}</span></td>
                            <td class="px-4 py-3.5">
                                @if($account->trashed())
                                    <span class="status-badge" style="background:#fef2f2;color:#b91c1c"><span class="w-1.5 h-1.5 rounded-full bg-red-500"></span>Dihapus</span>
                                @else
                                    <span class="status-badge {{ $account->is_active ? 'status-active' : 'status-inactive' }}"><span class="w-1.5 h-1.5 rounded-full {{ $account->is_active ? 'bg-emerald-500' : 'bg-amber-500' }}"></span>{{ $account->is_active ? 'Aktif' : 'Nonaktif' }}</span>
                                @endif
                            </td>
                            <td class="px-4 py-3.5 text-xs text-slate-500">{{ $account->last_login_at?->format('d M Y, H:i') ?? 'Belum pernah login' }}</td>
                            <td class="px-5 py-3.5 text-right">
                                @if($account->trashed())
                                    <form method="POST" action="{{ route('admin.accounts.restore', $account->id) }}" class="inline" onsubmit="return confirm('Pulihkan akun {{ e($displayName) }}?')">
                                        @csrf
                                        <button type="submit" class="text-emerald-700 hover:text-emerald-900 font-semibold text-xs">Pulihkan</button>
                                    </form>
                                @else
                                    <a href="{{ route('admin.accounts.show', $account) }}" class="text-blue-700 hover:text-blue-900 font-semibold text-xs">Detail →</a>
                                @endif
                            </td>
                        </tr>
                    @empty
                        <tr><td colspan="8" class="px-5 py-16 text-center"><div class="text-3xl mb-2">⌕</div><p class="font-semibold text-slate-700">{{ $showDeleted ? 'Tidak ada akun terhapus' : 'Akun tidak ditemukan' }}</p><p class="text-xs text-slate-400 mt-1">{{ $showDeleted ? 'Akun yang dihapus akan muncul di sini dan dapat dipulihkan.' : 'Ubah kata kunci atau filter, atau buat akun baru.' }}</p></td></tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        <div class="px-5 py-4 border-t border-slate-100">{{ $accounts->links() }}</div>
    </div>
</div>

<style>
.stat-card{background:#fff;border:1px solid #e2e8f0;border-radius:14px;padding:18px;display:flex;align-items:flex-start;justify-content:space-between;box-shadow:0 1px 2px #0f172a08}
.stat-label{font-size:10px;letter-spacing:.11em;font-weight:700;color:#64748b;text-transform:uppercase}.stat-value{font-size:30px;font-weight:750;line-height:1.2;color:#0f172a;margin-top:7px}.stat-note{font-size:11px;color:#94a3b8;margin-top:5px}.stat-icon{width:42px;height:42px;border-radius:12px;display:grid;place-items:center;font-size:22px}
.tab-link{display:inline-flex;align-items:center;gap:8px;padding:9px 13px;border-radius:9px;color:#64748b;font-size:12px;font-weight:600}.tab-link span{font-size:10px;background:#e2e8f0;color:#475569;padding:2px 6px;border-radius:10px}.tab-active{background:#fff;color:#1d4ed8;box-shadow:0 1px 4px #0f172a12}.tab-active span{background:#eff6ff;color:#1d4ed8}
.field{width:100%;border:1px solid #e2e8f0;background:#fff;border-radius:9px;padding:10px 12px;font-size:12px;color:#334155;outline:none}.field:focus{border-color:#60a5fa;box-shadow:0 0 0 3px #dbeafe}.btn-primary,.btn-outline,.btn-light{display:inline-flex;align-items:center;justify-content:center;gap:7px;padding:9px 13px;border-radius:9px;font-size:12px;font-weight:650;transition:.15s}.btn-primary{background:#2563eb;color:white}.btn-primary:hover{background:#1d4ed8}.btn-outline{border:1px solid #dbe3ef;background:#fff;color:#334155}.btn-outline:hover,.btn-light:hover{background:#f8fafc}.btn-light{background:#f1f5f9;color:#475569}
.avatar{width:38px;height:38px;display:grid;place-items:center;border-radius:11px;font-weight:700;font-size:12px;flex-shrink:0}.avatar-blue{background:#eff6ff;color:#1d4ed8;border:1px solid #bfdbfe}.avatar-green{background:#ecfdf5;color:#047857;border:1px solid #a7f3d0}.role-badge,.status-badge{display:inline-flex;align-items:center;gap:5px;border-radius:999px;padding:4px 8px;font-size:10px;font-weight:700;white-space:nowrap}.role-blue{background:#eff6ff;color:#1d4ed8}.role-green{background:#ecfdf5;color:#047857}.status-active{background:#ecfdf5;color:#047857}.status-inactive{background:#fffbeb;color:#b45309}
</style>
@endsection

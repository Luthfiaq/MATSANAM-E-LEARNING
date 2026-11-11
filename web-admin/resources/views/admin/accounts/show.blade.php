@extends('layouts.admin')
@section('title', 'Detail Akun')
@section('content')
@php
    $profile = $user->role === 'guru' ? $user->guru : $user->siswa;
    $fullName = $profile?->nama_lengkap ?: $user->name;
    $isGuru = $user->role === 'guru';
@endphp
<div class="max-w-[1250px] mx-auto space-y-5">
    <div class="text-xs text-slate-400"><a href="{{ route('admin.dashboard') }}" class="hover:text-blue-600">Dashboard</a> <span class="mx-1">›</span><a href="{{ route('admin.accounts.index') }}" class="hover:text-blue-600">Manajemen Akun</a> <span class="mx-1">›</span> Detail Pengguna</div>
    @if(session('success'))<div class="rounded-xl border border-emerald-200 bg-emerald-50 text-emerald-800 px-4 py-3 text-sm flex gap-2"><span>✓</span>{{ session('success') }}</div>@endif
    <div class="flex flex-col md:flex-row md:items-center justify-between gap-3"><div><h1 class="text-2xl font-bold text-slate-900">Detail Akun Pengguna</h1><p class="text-sm text-slate-500 mt-1">Informasi profil, status akses, dan riwayat tindakan administratif.</p></div><div class="flex gap-2"><a href="{{ route('admin.accounts.index', ['role' => $user->role]) }}" class="btn-light">← Daftar Akun</a><a href="{{ route('admin.accounts.edit', $user) }}" class="btn-primary">✎ Edit Akun</a></div></div>

    @if(session('created_credentials') || session('reset_credentials'))
        @php $credentials = session('created_credentials') ?? session('reset_credentials'); @endphp
        <div class="rounded-xl border border-blue-200 bg-blue-50 p-4">
            <div class="flex items-start gap-3"><div class="w-9 h-9 rounded-lg bg-blue-100 text-blue-700 grid place-items-center font-bold">✓</div><div class="flex-1"><h2 class="font-bold text-blue-950">{{ session('created_credentials') ? 'Akun berhasil dibuat' : 'Password berhasil direset' }}</h2><p class="text-xs text-blue-800 mt-1">Password sementara hanya ditampilkan pada halaman ini. Salin dan sampaikan melalui kanal aman. Setelah meninggalkan halaman, password tidak akan ditampilkan kembali.</p></div></div>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-3 mt-4"><div class="credential-box"><span>Email</span><strong>{{ $credentials['email'] }}</strong><button type="button" onclick="copyText('{{ $credentials['email'] }}')">Salin</button></div><div class="credential-box"><span>Password sementara</span><strong id="temporaryPassword">{{ $credentials['password'] }}</strong><button type="button" onclick="copyText(document.getElementById('temporaryPassword').textContent)">Salin</button></div></div>
            @if($credentials['must_change_password'] ?? true)<p class="text-xs text-blue-800 mt-3">Pengguna ditandai untuk mengganti password sementara. Alur penggantian password di aplikasi Guru/Siswa perlu mendukung flag ini.</p>@endif
        </div>
    @endif

    <div class="grid grid-cols-1 xl:grid-cols-3 gap-5">
        <section class="bg-white border border-slate-200 rounded-xl p-5 shadow-sm">
            <div class="flex items-center gap-3"><div class="w-14 h-14 rounded-2xl grid place-items-center text-lg font-bold {{ $isGuru ? 'bg-blue-50 text-blue-700' : 'bg-emerald-50 text-emerald-700' }}">{{ mb_strtoupper(mb_substr($fullName,0,2)) }}</div><div class="min-w-0"><h2 class="font-bold text-slate-900 leading-tight">{{ $fullName }}</h2><p class="text-xs text-slate-500 mt-1">{{ $isGuru ? 'Tenaga Pendidik' : 'Peserta Didik' }}</p></div></div>
            <div class="mt-4 flex flex-wrap gap-2"><span class="role-badge {{ $isGuru ? 'role-blue' : 'role-green' }}">{{ strtoupper($user->role) }}</span><span class="status-badge {{ $user->is_active ? 'status-active' : 'status-inactive' }}">{{ $user->is_active ? '● Aktif' : '● Nonaktif' }}</span></div>
            <div class="border-t border-slate-100 mt-5 pt-4 space-y-3 text-xs"><div><p class="detail-label">Email Resmi</p><p class="detail-value break-all">{{ $user->email }}</p></div><div><p class="detail-label">ID Pengguna</p><p class="detail-value">#{{ $user->id }}</p></div><div><p class="detail-label">Akun Dibuat</p><p class="detail-value">{{ $user->created_at?->format('d M Y, H:i') ?? '—' }}</p></div><div><p class="detail-label">Terakhir Login</p><p class="detail-value">{{ $user->last_login_at?->format('d M Y, H:i') ?? 'Belum pernah login' }}</p></div><div><p class="detail-label">Terakhir Reset Password</p><p class="detail-value">{{ $user->last_password_reset_at?->format('d M Y, H:i') ?? 'Belum pernah direset' }}</p></div><div><p class="detail-label">Permintaan Ganti Password</p><p class="detail-value">{{ $user->must_change_password ? 'Wajib mengganti password' : 'Tidak diwajibkan' }}</p></div></div>
            <div class="border-t border-slate-100 mt-5 pt-4 space-y-2">
                <button type="button" onclick="openModal('resetModal')" class="action-button">↻ Reset Password</button>
                <button type="button" onclick="openModal('statusModal')" class="action-button {{ $user->is_active ? 'text-amber-700' : 'text-emerald-700' }}">{{ $user->is_active ? 'Ⅱ Nonaktifkan Akun' : '✓ Aktifkan Akun' }}</button>
                <button type="button" onclick="openModal('deleteModal')" class="action-button text-red-700 border-red-200 hover:bg-red-50">⌫ Hapus Akun</button>
            </div>
        </section>

        <section class="xl:col-span-2 space-y-5">
            <div class="bg-white border border-slate-200 rounded-xl p-5 shadow-sm">
                <div class="flex items-center justify-between mb-4"><h2 class="font-bold text-slate-900">Informasi {{ $isGuru ? 'Guru' : 'Siswa' }}</h2><span class="text-[10px] uppercase tracking-wider text-slate-400">Data profil</span></div>
                <div class="grid grid-cols-1 sm:grid-cols-2 gap-x-6 gap-y-4 text-xs">
                    @if($isGuru)
                        <div><p class="detail-label">NIP</p><p class="detail-value">{{ $profile?->nip ?? '—' }}</p></div>
                        <div><p class="detail-label">Jenis Kelamin</p><p class="detail-value">{{ $profile?->jenis_kelamin === 'L' ? 'Laki-laki' : ($profile?->jenis_kelamin === 'P' ? 'Perempuan' : '—') }}</p></div>
                        <div><p class="detail-label">Nomor Telepon</p><p class="detail-value">{{ $profile?->telepon ?? '—' }}</p></div>
                        <div><p class="detail-label">Mata Pelajaran</p><p class="detail-value">{{ $user->guru?->jadwalPelajaran->map(fn ($jadwal) => $jadwal->mataPelajaran?->nama)->filter()->unique()->implode(', ') ?: 'Belum ada penugasan' }}</p></div>
                        <div class="sm:col-span-2"><p class="detail-label">Kelas Mengajar</p><p class="detail-value">{{ $user->guru?->jadwalPelajaran->map(fn ($jadwal) => $jadwal->kelas?->nama_kelas)->filter()->unique()->implode(', ') ?: 'Belum ada penugasan' }}</p></div>
                    @else
                        <div><p class="detail-label">NIS</p><p class="detail-value">{{ $profile?->nis ?? '—' }}</p></div>
                        <div><p class="detail-label">NISN</p><p class="detail-value">{{ $profile?->nisn ?? '—' }}</p></div>
                        <div><p class="detail-label">Kelas</p><p class="detail-value">{{ $profile?->kelas?->nama_kelas ?? 'Belum ditentukan' }}</p></div>
                        <div><p class="detail-label">Jenis Kelamin</p><p class="detail-value">{{ $profile?->jenis_kelamin === 'L' ? 'Laki-laki' : ($profile?->jenis_kelamin === 'P' ? 'Perempuan' : '—') }}</p></div>
                        <div><p class="detail-label">Tempat, Tanggal Lahir</p><p class="detail-value">{{ $profile?->tempat_lahir ?? '—' }}{{ $profile?->tanggal_lahir ? ', '.$profile->tanggal_lahir->format('d M Y') : '' }}</p></div>
                        <div><p class="detail-label">Orang Tua / Wali</p><p class="detail-value">{{ $profile?->nama_wali ?? '—' }}</p></div>
                        <div><p class="detail-label">Telepon Wali</p><p class="detail-value">{{ $profile?->telepon_wali ?? '—' }}</p></div>
                    @endif
                    <div class="sm:col-span-2"><p class="detail-label">Alamat</p><p class="detail-value">{{ $profile?->alamat ?? '—' }}</p></div>
                </div>
            </div>
            <div class="bg-white border border-slate-200 rounded-xl shadow-sm overflow-hidden">
                <div class="px-5 py-4 border-b border-slate-100"><h2 class="font-bold text-slate-900">Riwayat Aktivitas Akun</h2><p class="text-xs text-slate-500 mt-1">Perubahan akun, reset password, dan status dicatat untuk audit.</p></div>
                <div class="divide-y divide-slate-100">
                    @forelse($logs as $log)
                        <div class="px-5 py-3.5 flex gap-3"><div class="w-8 h-8 rounded-lg bg-slate-100 text-slate-600 grid place-items-center">{{ $log->action === 'password_reset' ? '↻' : ($log->action === 'account_deactivated' ? 'Ⅱ' : ($log->action === 'account_deleted' ? '⌫' : ($log->action === 'account_restored' ? '↶' : '✓'))) }}</div><div class="flex-1"><p class="text-xs font-semibold text-slate-800">{{ $log->description }}</p><p class="text-[11px] text-slate-400 mt-1">{{ $log->actor?->name ?? 'Sistem' }} · {{ $log->created_at?->format('d M Y, H:i') }}</p></div></div>
                    @empty
                        <div class="px-5 py-10 text-center text-xs text-slate-400">Belum ada aktivitas tercatat untuk akun ini.</div>
                    @endforelse
                </div>
                <div class="px-5 py-3 border-t border-slate-100">{{ $logs->links() }}</div>
            </div>
        </section>
    </div>
</div>

<div id="resetModal" class="modal-backdrop hidden" role="dialog" aria-modal="true" aria-labelledby="resetTitle"><div class="modal-card"><div class="flex items-start justify-between"><div><h2 id="resetTitle" class="text-lg font-bold text-slate-900">Reset Password Pengguna</h2><p class="text-xs text-slate-500 mt-1">Password lama tidak dapat dilihat. Buat password sementara yang baru.</p></div><button type="button" onclick="closeModal('resetModal')" class="modal-close">×</button></div><div class="mt-4 rounded-lg bg-slate-50 border border-slate-200 p-3 text-xs"><strong>{{ $fullName }}</strong><p class="text-slate-500 mt-1">{{ $user->email }} · {{ ucfirst($user->role) }}</p></div><form method="POST" action="{{ route('admin.accounts.reset-password', $user) }}" class="mt-4 space-y-3">@csrf<label class="block"><span class="field-label">Password Baru <b>*</b></span><input type="password" name="password" class="field" minlength="10" required autocomplete="new-password"></label><label class="block"><span class="field-label">Konfirmasi Password <b>*</b></span><input type="password" name="password_confirmation" class="field" minlength="10" required autocomplete="new-password"></label><label class="flex items-start gap-2 text-xs text-slate-600"><input type="checkbox" name="must_change_password" value="1" class="mt-0.5 accent-blue-600" checked>Wajibkan pengguna mengganti password sementara.</label><p class="text-[11px] text-amber-700 bg-amber-50 rounded-lg p-3">Semua sesi aplikasi aktif pengguna akan dicabut setelah password direset.</p><div class="flex justify-end gap-2 pt-2"><button type="button" class="btn-light" onclick="closeModal('resetModal')">Batal</button><button class="btn-primary">Reset Password</button></div></form></div></div>

<div id="statusModal" class="modal-backdrop hidden" role="dialog" aria-modal="true"><div class="modal-card"><div class="flex items-start justify-between"><div><h2 class="text-lg font-bold text-slate-900">{{ $user->is_active ? 'Nonaktifkan Akun?' : 'Aktifkan Akun?' }}</h2><p class="text-xs text-slate-500 mt-1">{{ $user->is_active ? 'Pengguna tidak dapat login selama akun dinonaktifkan. Data dan riwayat tetap disimpan.' : 'Pengguna akan dapat login kembali setelah akun diaktifkan.' }}</p></div><button type="button" onclick="closeModal('statusModal')" class="modal-close">×</button></div><div class="mt-4 rounded-lg bg-slate-50 border border-slate-200 p-3 text-xs"><strong>{{ $fullName }}</strong><p class="text-slate-500 mt-1">{{ $user->email }}</p></div><form method="POST" action="{{ route('admin.accounts.status', $user) }}" class="mt-4 space-y-3">@csrf<input type="hidden" name="is_active" value="{{ $user->is_active ? 0 : 1 }}">@if($user->is_active)<label class="block"><span class="field-label">Alasan Penonaktifan (opsional)</span><textarea name="reason" class="field min-h-[80px]" placeholder="Tuliskan alasan administratif"></textarea></label>@endif<div class="flex justify-end gap-2 pt-2"><button type="button" class="btn-light" onclick="closeModal('statusModal')">Batal</button><button class="{{ $user->is_active ? 'btn-danger' : 'btn-primary' }}">{{ $user->is_active ? 'Nonaktifkan Akun' : 'Aktifkan Akun' }}</button></div></form></div></div>


<div id="deleteModal" class="modal-backdrop hidden" role="dialog" aria-modal="true" aria-labelledby="deleteTitle">
    <div class="modal-card">
        <div class="flex items-start justify-between gap-4">
            <div>
                <h2 id="deleteTitle" class="text-lg font-bold text-slate-900">Hapus Akun Pengguna?</h2>
                <p class="text-xs text-slate-500 mt-1">Akun akan disembunyikan dari daftar utama dan tidak dapat login.</p>
            </div>
            <button type="button" onclick="closeModal('deleteModal')" class="modal-close">×</button>
        </div>
        <div class="mt-4 rounded-lg bg-red-50 border border-red-100 p-3 text-xs text-red-800">
            <strong>{{ $fullName }}</strong>
            <p class="mt-1">{{ $user->email }} · {{ strtoupper($user->role) }}</p>
        </div>
        <div class="mt-3 rounded-lg bg-slate-50 border border-slate-200 p-3 text-xs text-slate-600">
            Data profil, nilai, absensi, pengumpulan tugas, dan riwayat akademik tidak dihapus permanen. Akun dapat dipulihkan melalui menu <strong>Akun Terhapus</strong>.
        </div>
        <form method="POST" action="{{ route('admin.accounts.destroy', $user) }}" class="mt-4 flex justify-end gap-2">
            @csrf
            @method('DELETE')
            <button type="button" class="btn-light" onclick="closeModal('deleteModal')">Batal</button>
            <button type="submit" class="btn-danger">Hapus Akun</button>
        </form>
    </div>
</div>

<style>
.role-badge,.status-badge{display:inline-flex;align-items:center;gap:5px;border-radius:999px;padding:4px 8px;font-size:10px;font-weight:700}.role-blue{background:#eff6ff;color:#1d4ed8}.role-green{background:#ecfdf5;color:#047857}.status-active{background:#ecfdf5;color:#047857}.status-inactive{background:#fffbeb;color:#b45309}.detail-label{font-size:10px;letter-spacing:.07em;color:#94a3b8;text-transform:uppercase;font-weight:700}.detail-value{font-size:13px;color:#334155;font-weight:550;margin-top:4px}.action-button{width:100%;text-align:left;border:1px solid #e2e8f0;border-radius:9px;padding:10px 12px;font-size:12px;font-weight:650;color:#334155}.action-button:hover{background:#f8fafc}.btn-primary,.btn-light,.btn-danger{display:inline-flex;align-items:center;justify-content:center;padding:9px 14px;border-radius:9px;font-size:12px;font-weight:650}.btn-primary{background:#2563eb;color:#fff}.btn-light{background:#f1f5f9;color:#475569}.btn-danger{background:#dc2626;color:#fff}.modal-backdrop{position:fixed;inset:0;z-index:100;background:#0f172a80;display:flex;align-items:center;justify-content:center;padding:20px}.modal-backdrop.hidden{display:none}.modal-card{width:min(100%,480px);background:white;border-radius:16px;padding:24px;box-shadow:0 24px 70px #0f172a40}.modal-close{width:30px;height:30px;border-radius:8px;background:#f1f5f9;color:#64748b;font-size:22px}.credential-box{background:#fff;border:1px solid #bfdbfe;border-radius:10px;padding:10px;display:grid;grid-template-columns:1fr auto;gap:3px 8px}.credential-box span{font-size:10px;color:#64748b;grid-column:1 / -1}.credential-box strong{font-size:13px;color:#0f172a;overflow-wrap:anywhere}.credential-box button{font-size:11px;color:#1d4ed8;font-weight:700}
</style>
<script>
function openModal(id){document.getElementById(id)?.classList.remove('hidden');document.body.classList.add('overflow-hidden')}
function closeModal(id){document.getElementById(id)?.classList.add('hidden');document.body.classList.remove('overflow-hidden')}
function copyText(text){if(navigator.clipboard){navigator.clipboard.writeText(text).then(()=>alert('Tersalin ke clipboard.')).catch(()=>alert('Gagal menyalin.'))}else{alert('Browser tidak mendukung salin otomatis.')}}
window.addEventListener('keydown',e=>{if(e.key==='Escape'){document.querySelectorAll('.modal-backdrop:not(.hidden)').forEach(m=>m.classList.add('hidden'));document.body.classList.remove('overflow-hidden')}})
</script>
@endsection

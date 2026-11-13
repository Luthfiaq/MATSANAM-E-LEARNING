@extends('layouts.admin')
@section('title', 'Import / Ekspor Data')

@section('content')
<div class="max-w-[1500px] mx-auto space-y-5">
    <div class="flex flex-col xl:flex-row xl:items-end xl:justify-between gap-4">
        <div>
            <div class="text-xs text-slate-400 mb-2"><a href="{{ route('admin.dashboard') }}" class="hover:text-blue-600">Dashboard</a> <span class="mx-1">›</span> Audit & Data <span class="mx-1">›</span> Import / Ekspor</div>
            <h1 class="text-2xl md:text-[28px] font-bold tracking-tight text-slate-900 dark:text-slate-100">Import & Ekspor Data</h1>
            <p class="text-sm text-slate-500 mt-1">Kelola data Guru dan Siswa secara massal dengan validasi sebelum disimpan.</p>
        </div>
        <a href="{{ route('admin.activity-logs.index') }}" class="inline-flex items-center gap-2 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 px-4 py-2.5 text-sm font-semibold text-slate-700 dark:text-slate-200">▤ Lihat Audit Log</a>
    </div>

    @if(session('success'))<div class="rounded-xl border border-emerald-200 bg-emerald-50 text-emerald-800 px-4 py-3 text-sm">✓ {{ session('success') }}</div>@endif
    @if(session('warning'))<div class="rounded-xl border border-amber-200 bg-amber-50 text-amber-800 px-4 py-3 text-sm">! {{ session('warning') }}</div>@endif
    @if($errors->any())<div class="rounded-xl border border-red-200 bg-red-50 text-red-800 px-4 py-3 text-sm"><p class="font-semibold mb-1">Periksa kembali data yang dikirim:</p><ul class="list-disc pl-5 space-y-1">@foreach($errors->all() as $error)<li>{{ $error }}</li>@endforeach</ul></div>@endif

    <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
        <div class="transfer-stat"><div><p class="transfer-label">Total Akun Guru</p><p class="transfer-value">{{ number_format($guruCount) }}</p><p class="transfer-note">Master akun Guru terdaftar</p></div><span class="transfer-icon bg-blue-50 text-blue-700">♙</span></div>
        <div class="transfer-stat"><div><p class="transfer-label">Total Akun Siswa</p><p class="transfer-value">{{ number_format($siswaCount) }}</p><p class="transfer-note">Master akun Siswa terdaftar</p></div><span class="transfer-icon bg-emerald-50 text-emerald-700">♧</span></div>
    </div>

    @if($credentialsAvailable)
        <section class="rounded-2xl border border-emerald-200 bg-emerald-50 p-4 md:p-5 flex flex-col md:flex-row md:items-center md:justify-between gap-3">
            <div><h2 class="font-bold text-emerald-900">Impor berhasil diselesaikan</h2><p class="text-sm text-emerald-800 mt-1">File kredensial sementara tersedia satu kali. Password tidak akan ditampilkan kembali setelah file diunduh.</p></div>
            <a href="{{ route('admin.data-transfer.credentials') }}" class="inline-flex items-center justify-center gap-2 rounded-xl bg-emerald-700 hover:bg-emerald-800 px-4 py-2.5 text-sm font-semibold text-white">↓ Unduh Kredensial Satu Kali</a>
        </section>
    @endif

    <div class="grid grid-cols-1 xl:grid-cols-2 gap-4">
        @foreach(['guru' => ['title' => 'Data Guru', 'description' => 'NIP, nama, email akun, jenis kelamin, telepon, dan alamat.', 'count' => $guruCount, 'icon' => '♙'], 'siswa' => ['title' => 'Data Siswa', 'description' => 'NIS, NISN, identitas, tanggal lahir, kelas, dan data wali.', 'count' => $siswaCount, 'icon' => '♧']] as $role => $config)
            <section class="transfer-card">
                <div class="flex items-start justify-between gap-3">
                    <div><div class="flex items-center gap-2"><span class="transfer-role-icon">{{ $config['icon'] }}</span><h2 class="text-lg font-bold text-slate-900 dark:text-slate-100">{{ $config['title'] }}</h2></div><p class="text-xs text-slate-500 mt-2">{{ $config['description'] }}</p></div>
                    <span class="rounded-full bg-slate-100 dark:bg-slate-700 px-3 py-1 text-xs font-bold text-slate-600 dark:text-slate-200">{{ number_format($config['count']) }} akun</span>
                </div>
                <div class="grid grid-cols-1 sm:grid-cols-2 gap-2 mt-5">
                    <a href="{{ route('admin.data-transfer.template', $role) }}" class="transfer-secondary">↓ Unduh Template CSV</a>
                    <a href="{{ route('admin.data-transfer.export', $role) }}" class="transfer-secondary">⇩ Ekspor Data CSV</a>
                </div>
                <div class="mt-5 border-t border-slate-100 dark:border-slate-700 pt-4">
                    <form method="POST" action="{{ route('admin.data-transfer.preview') }}" enctype="multipart/form-data" class="space-y-3">
                        @csrf
                        <input type="hidden" name="role" value="{{ $role }}">
                        <label class="block"><span class="block text-xs font-semibold text-slate-700 dark:text-slate-200 mb-2">Pilih file CSV</span><input type="file" name="file" accept=".csv,text/csv" required class="transfer-file"><span class="block text-[11px] text-slate-400 mt-1">CSV UTF-8, maksimal 5 MB dan 2.000 baris.</span></label>
                        <button type="submit" class="w-full rounded-xl bg-blue-600 hover:bg-blue-700 text-white py-3 text-sm font-semibold">Preview & Validasi {{ $role === 'guru' ? 'Guru' : 'Siswa' }}</button>
                    </form>
                </div>
            </section>
        @endforeach
    </div>

    <details class="rounded-2xl border border-slate-200 bg-white dark:bg-slate-800 dark:border-slate-700 shadow-sm p-4 md:p-5">
        <summary class="cursor-pointer flex items-center justify-between gap-3 text-sm font-bold text-slate-800 dark:text-slate-100">
            <span>Referensi ID Kelas untuk Import Siswa</span><span class="text-xs font-semibold text-blue-600">Lihat daftar kelas ▾</span>
        </summary>
        <p class="text-xs text-slate-500 mt-3">Gunakan angka pada kolom ID Kelas di file CSV. Nama kelas hanya ditampilkan sebagai bantuan pencarian.</p>
        <div class="overflow-x-auto mt-3">
            <table class="w-full min-w-[420px] text-xs">
                <thead class="bg-slate-50 dark:bg-slate-900/70 text-slate-500"><tr><th class="px-3 py-2 text-left">ID Kelas</th><th class="px-3 py-2 text-left">Nama Kelas</th><th class="px-3 py-2 text-left">Tingkat</th></tr></thead>
                <tbody class="divide-y divide-slate-100 dark:divide-slate-700">
                    @forelse($classes as $class)<tr><td class="px-3 py-2 font-mono text-slate-600 dark:text-slate-300">{{ $class->id }}</td><td class="px-3 py-2 font-semibold text-slate-700 dark:text-slate-100">{{ $class->nama_kelas }}</td><td class="px-3 py-2 text-slate-500">{{ $class->tingkat }}</td></tr>
                    @empty<tr><td colspan="3" class="px-3 py-5 text-center text-slate-400">Master kelas belum tersedia. Buat kelas terlebih dahulu.</td></tr>@endforelse
                </tbody>
            </table>
        </div>
    </details>

    @if(is_array($pending))
        <section class="rounded-2xl border border-slate-200 bg-white dark:bg-slate-800 dark:border-slate-700 shadow-sm overflow-hidden">
            <div class="p-4 md:p-5 border-b border-slate-100 dark:border-slate-700 flex flex-col md:flex-row md:items-center md:justify-between gap-3">
                <div><div class="text-xs text-blue-600 font-bold uppercase tracking-wider">Tahap 2 · Preview Impor</div><h2 class="text-lg font-bold text-slate-900 dark:text-slate-100 mt-1">Validasi {{ strtoupper($pending['role']) }}</h2><p class="text-xs text-slate-500 mt-1">Tidak ada data yang disimpan sebelum kamu menekan tombol konfirmasi.</p></div>
                <form method="POST" action="{{ route('admin.data-transfer.cancel') }}">@csrf<button class="rounded-lg border border-slate-200 dark:border-slate-600 px-3 py-2 text-xs font-semibold text-slate-600 dark:text-slate-200">Batalkan Preview</button></form>
            </div>
            <div class="grid grid-cols-1 sm:grid-cols-3 gap-3 p-4 md:p-5">
                <div class="preview-stat"><span>Total Baris</span><strong>{{ number_format($pending['rows']) }}</strong></div>
                <div class="preview-stat"><span>Valid</span><strong class="text-emerald-700">{{ number_format($pending['valid']) }}</strong></div>
                <div class="preview-stat"><span>Perlu Diperbaiki</span><strong class="{{ $pending['invalid'] ? 'text-red-600' : 'text-emerald-700' }}">{{ number_format($pending['invalid']) }}</strong></div>
            </div>
            @if(!empty($pending['errors']))
                <div class="mx-4 md:mx-5 mb-4 rounded-xl border border-red-200 bg-red-50 p-3 text-xs text-red-800"><p class="font-bold mb-2">Kesalahan ditemukan — impor belum dapat dilanjutkan.</p><ul class="list-disc pl-5 space-y-1">@foreach($pending['errors'] as $error)<li>Baris {{ $error['row'] }}: {{ implode(' ', $error['messages']) }}</li>@endforeach</ul>@if($pending['invalid'] > count($pending['errors']))<p class="mt-2 text-red-700">Menampilkan maksimal 30 baris kesalahan pertama.</p>@endif</div>
            @endif
            <div class="overflow-x-auto border-t border-slate-100 dark:border-slate-700">
                <table class="w-full min-w-[650px] text-sm">
                    <thead class="bg-slate-50 dark:bg-slate-900/70 text-slate-500 text-[10px] uppercase tracking-wider"><tr><th class="px-5 py-3 text-left">Baris</th><th class="px-5 py-3 text-left">Nama</th><th class="px-5 py-3 text-left">NIP / NIS</th><th class="px-5 py-3 text-left">Email</th><th class="px-5 py-3 text-left">Status Validasi</th></tr></thead>
                    <tbody class="divide-y divide-slate-100 dark:divide-slate-700">@foreach($pending['preview'] as $row)<tr><td class="px-5 py-3 text-xs text-slate-500">{{ $row['row'] }}</td><td class="px-5 py-3 text-xs font-semibold text-slate-800 dark:text-slate-100">{{ $row['name'] }}</td><td class="px-5 py-3 text-xs text-slate-600 dark:text-slate-300">{{ $row['identifier'] }}</td><td class="px-5 py-3 text-xs text-slate-600 dark:text-slate-300">{{ $row['email'] }}</td><td class="px-5 py-3">@if($row['valid'])<span class="transfer-status transfer-valid">✓ Valid</span>@else<span class="transfer-status transfer-invalid">Perlu revisi</span><p class="text-[10px] text-red-600 mt-1">{{ implode(' ', $row['errors']) }}</p>@endif</td></tr>@endforeach</tbody>
                </table>
            </div>
            @if($pending['rows'] > count($pending['preview']))<p class="px-5 py-3 text-[11px] text-slate-400">Menampilkan {{ count($pending['preview']) }} baris pertama dari {{ $pending['rows'] }} baris. Seluruh baris sudah divalidasi di server.</p>@endif
            <div class="p-4 md:p-5 border-t border-slate-100 dark:border-slate-700 flex flex-col md:flex-row md:items-center md:justify-between gap-3">
                <p class="text-xs text-slate-500">{{ $pending['invalid'] === 0 ? 'Semua baris valid. Impor akan membuat akun dengan password sementara acak.' : 'Perbaiki seluruh baris invalid, lalu unggah ulang CSV.' }}</p>
                @if($pending['invalid'] === 0 && $pending['valid'] > 0)
                    <form method="POST" action="{{ route('admin.data-transfer.import') }}" onsubmit="return confirm('Impor {{ $pending['valid'] }} akun {{ strtoupper($pending['role']) }} sekarang? Tindakan ini akan membuat akun login baru.')">
                        @csrf<input type="hidden" name="import_token" value="{{ $pending['token'] }}"><button class="rounded-xl bg-emerald-600 hover:bg-emerald-700 px-5 py-3 text-sm font-bold text-white">✓ Konfirmasi & Impor {{ $pending['valid'] }} Data</button>
                    </form>
                @endif
            </div>
        </section>
    @endif

    <section class="rounded-2xl border border-blue-100 bg-blue-50/70 dark:bg-slate-800 dark:border-slate-700 p-4 md:p-5">
        <h3 class="font-bold text-slate-800 dark:text-slate-100 text-sm">Panduan dan keamanan data</h3>
        <ul class="mt-2 grid grid-cols-1 lg:grid-cols-2 gap-x-6 gap-y-2 text-xs text-slate-600 dark:text-slate-300 list-disc pl-4">
            <li>Gunakan template CSV sesuai role. Tanggal lahir Siswa menggunakan format <code>YYYY-MM-DD</code>. Atur kolom NIP/NIS/NISN sebagai Text di Excel agar nol di depan tidak hilang.</li>
            <li>Untuk Siswa, isi <code>kelas_id</code> sesuai ID pada master Kelas. Kolom nama kelas hanya informasi saat ekspor.</li>
            <li>Seluruh data harus valid dan unik sebelum satu batch dapat diimpor. Jika ada kesalahan, tidak ada baris yang disimpan.</li>
            <li>Akun baru memperoleh password sementara acak dan wajib menggantinya pada login pertama.</li>
            <li>Unduh file kredensial satu kali, simpan dengan aman, lalu bagikan kepada pemilik akun melalui kanal yang aman.</li>
            <li>Ekspor data tidak menyertakan password, token, atau kredensial login.</li>
            <li>Impor saat ini mendukung CSV UTF-8. File XLSX belum didukung dan harus disimpan sebagai CSV terlebih dahulu.</li>
        </ul>
    </section>
</div>

<style>
.transfer-stat{background:#fff;border:1px solid #e2e8f0;border-radius:14px;padding:18px;display:flex;align-items:flex-start;justify-content:space-between;box-shadow:0 1px 2px #0f172a08}.dark .transfer-stat{background:#1e293b;border-color:#334155}.transfer-label{font-size:10px;letter-spacing:.11em;font-weight:700;color:#64748b;text-transform:uppercase}.transfer-value{font-size:29px;font-weight:750;line-height:1.2;color:#0f172a;margin-top:7px}.dark .transfer-value{color:#f8fafc}.transfer-note{font-size:11px;color:#94a3b8;margin-top:5px}.transfer-icon{width:42px;height:42px;border-radius:12px;display:grid;place-items:center;font-size:22px}.transfer-card{background:#fff;border:1px solid #e2e8f0;border-radius:16px;padding:20px;box-shadow:0 1px 2px #0f172a08}.dark .transfer-card{background:#1e293b;border-color:#334155}.transfer-role-icon{width:38px;height:38px;display:grid;place-items:center;border-radius:11px;background:#eff6ff;color:#1d4ed8;font-size:21px}.dark .transfer-role-icon{background:#334155;color:#bfdbfe}.transfer-secondary{display:flex;align-items:center;justify-content:center;gap:7px;border:1px solid #dbe3ef;border-radius:10px;padding:10px;font-size:11px;font-weight:700;color:#334155;background:#fff}.transfer-secondary:hover{background:#f8fafc;border-color:#bfdbfe;color:#1d4ed8}.dark .transfer-secondary{background:#0f172a;border-color:#475569;color:#cbd5e1}.transfer-file{display:block;width:100%;border:1px dashed #cbd5e1;border-radius:10px;padding:12px;background:#f8fafc;color:#64748b;font-size:11px}.dark .transfer-file{background:#0f172a;border-color:#475569}.preview-stat{padding:13px 15px;border-radius:12px;background:#f8fafc;border:1px solid #e2e8f0;display:flex;align-items:center;justify-content:space-between}.dark .preview-stat{background:#0f172a;border-color:#334155}.preview-stat span{font-size:11px;color:#64748b;font-weight:600}.preview-stat strong{font-size:22px;color:#0f172a}.dark .preview-stat strong{color:#f8fafc}.transfer-status{display:inline-flex;border-radius:999px;padding:4px 8px;font-size:10px;font-weight:700}.transfer-valid{background:#ecfdf5;color:#047857}.transfer-invalid{background:#fef2f2;color:#b91c1c}
</style>
@endsection

@php
    $isEdit = isset($user);
    $user = $user ?? null;
    $profile = $role === 'guru' ? ($user->guru ?? null) : ($user->siswa ?? null);
    $value = fn ($key, $default = '') => old($key, $default);
    $activeDefault = $isEdit ? (int) $user->is_active : 1;
@endphp
<div class="grid grid-cols-1 lg:grid-cols-3 gap-5">
    <div class="lg:col-span-2 space-y-5">
        <section class="form-panel">
            <div class="form-section-title"><span class="section-number">1</span><div><h2>Identitas {{ $role === 'guru' ? 'Pendidik' : 'Peserta Didik' }}</h2><p>Informasi utama yang terhubung dengan akun login.</p></div></div>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <label class="md:col-span-2"><span class="field-label">Nama Lengkap <b>*</b></span><input class="field" name="nama_lengkap" value="{{ $value('nama_lengkap', $profile?->nama_lengkap ?? $user->name ?? '') }}" placeholder="Masukkan nama lengkap" required>@error('nama_lengkap')<small class="error-text">{{ $message }}</small>@enderror</label>
                <label><span class="field-label">{{ $role === 'guru' ? 'NIP' : 'NIS' }} <b>*</b></span><input class="field" name="{{ $role === 'guru' ? 'nip' : 'nis' }}" value="{{ $value($role === 'guru' ? 'nip' : 'nis', $role === 'guru' ? ($profile?->nip ?? '') : ($profile?->nis ?? '')) }}" placeholder="Nomor identitas" required>@error($role === 'guru' ? 'nip' : 'nis')<small class="error-text">{{ $message }}</small>@enderror</label>
                @if($role === 'siswa')
                    <label><span class="field-label">NISN <b>*</b></span><input class="field" name="nisn" value="{{ $value('nisn', $profile?->nisn ?? '') }}" placeholder="10 digit NISN" required>@error('nisn')<small class="error-text">{{ $message }}</small>@enderror</label>
                @endif
                @if($role === 'siswa')
                    <label><span class="field-label">Jenis Kelamin <b>*</b></span><select class="field" name="jenis_kelamin" required><option value="">Pilih jenis kelamin</option><option value="L" @selected($value('jenis_kelamin', $profile?->jenis_kelamin ?? '') === 'L')>Laki-laki</option><option value="P" @selected($value('jenis_kelamin', $profile?->jenis_kelamin ?? '') === 'P')>Perempuan</option></select>@error('jenis_kelamin')<small class="error-text">{{ $message }}</small>@enderror</label>
                    <label><span class="field-label">Tempat Lahir <b>*</b></span><input class="field" name="tempat_lahir" value="{{ $value('tempat_lahir', $profile?->tempat_lahir ?? '') }}" placeholder="Kota kelahiran" required>@error('tempat_lahir')<small class="error-text">{{ $message }}</small>@enderror</label>
                    <label><span class="field-label">Tanggal Lahir <b>*</b></span><input class="field" type="date" name="tanggal_lahir" value="{{ $value('tanggal_lahir', $profile?->tanggal_lahir?->format('Y-m-d') ?? '') }}" required>@error('tanggal_lahir')<small class="error-text">{{ $message }}</small>@enderror</label>
                    <label><span class="field-label">Kelas <b>*</b></span><select class="field" name="kelas_id" required><option value="">Pilih kelas</option>@foreach($classes as $class)<option value="{{ $class->id }}" @selected((string)$value('kelas_id', $profile?->kelas_id ?? '') === (string)$class->id)>{{ $class->nama_kelas }}</option>@endforeach</select>@error('kelas_id')<small class="error-text">{{ $message }}</small>@enderror</label>
                @endif
                @if($role === 'guru')
                    <label><span class="field-label">Jenis Kelamin <b>*</b></span><select class="field" name="jenis_kelamin" required><option value="">Pilih jenis kelamin</option><option value="L" @selected($value('jenis_kelamin', $profile?->jenis_kelamin ?? '') === 'L')>Laki-laki</option><option value="P" @selected($value('jenis_kelamin', $profile?->jenis_kelamin ?? '') === 'P')>Perempuan</option></select>@error('jenis_kelamin')<small class="error-text">{{ $message }}</small>@enderror</label>
                @endif
            </div>
        </section>

        <section class="form-panel">
            <div class="form-section-title"><span class="section-number">2</span><div><h2>Informasi Kontak</h2><p>Kontak digunakan untuk kebutuhan administrasi sekolah.</p></div></div>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <label class="md:col-span-2"><span class="field-label">Email Resmi <b>*</b></span><input type="email" class="field" name="email" value="{{ $value('email', $user->email ?? '') }}" placeholder="nama@mtsn6nganjuk.sch.id" required>@error('email')<small class="error-text">{{ $message }}</small>@enderror</label>
                @if($role === 'guru')
                    <label><span class="field-label">Nomor Telepon</span><input class="field" name="telepon" value="{{ $value('telepon', $profile?->telepon ?? '') }}" placeholder="08xxxxxxxxxx">@error('telepon')<small class="error-text">{{ $message }}</small>@enderror</label>
                @else
                    <label><span class="field-label">Nama Orang Tua / Wali</span><input class="field" name="nama_wali" value="{{ $value('nama_wali', $profile?->nama_wali ?? '') }}" placeholder="Nama orang tua atau wali">@error('nama_wali')<small class="error-text">{{ $message }}</small>@enderror</label>
                    <label><span class="field-label">Nomor Telepon Wali</span><input class="field" name="telepon_wali" value="{{ $value('telepon_wali', $profile?->telepon_wali ?? '') }}" placeholder="08xxxxxxxxxx">@error('telepon_wali')<small class="error-text">{{ $message }}</small>@enderror</label>
                @endif
                <label class="md:col-span-2"><span class="field-label">Alamat</span><textarea class="field min-h-[88px]" name="alamat" placeholder="Alamat domisili">{{ $value('alamat', $profile?->alamat ?? '') }}</textarea>@error('alamat')<small class="error-text">{{ $message }}</small>@enderror</label>
            </div>
        </section>

        @if($role === 'guru')
        <div class="form-info-note rounded-xl border border-blue-200 bg-blue-50 px-4 py-3 flex gap-3 text-sm text-blue-900"><span class="text-lg">ℹ</span><div><strong>Penugasan mengajar dikelola terpisah.</strong><p class="text-xs text-blue-700 mt-1">Mata pelajaran dan kelas Guru diambil dari jadwal/penugasan mengajar. Setelah akun dibuat, atur jadwal melalui menu List Penugasan Guru.</p></div></div>
        @endif
    </div>

    <aside class="space-y-5">
        @unless($isEdit)
        <section class="form-panel">
            <div class="form-section-title"><span class="section-number">3</span><div><h2>Kredensial Awal</h2><p>Password sementara untuk login pertama.</p></div></div>
            <label class="block mb-4"><span class="field-label">Password Awal <b>*</b></span><input type="password" class="field" name="password" minlength="10" autocomplete="new-password" placeholder="Minimal 10 karakter" required>@error('password')<small class="error-text">{{ $message }}</small>@enderror</label>
            <label class="block"><span class="field-label">Konfirmasi Password <b>*</b></span><input type="password" class="field" name="password_confirmation" minlength="10" autocomplete="new-password" placeholder="Ulangi password" required></label>
            <p class="text-[11px] text-slate-400 mt-3">Password hanya ditampilkan satu kali setelah akun berhasil dibuat. Simpan dan sampaikan melalui kanal yang aman.</p>
        </section>
        @endunless

        <section class="form-panel">
            <div class="form-section-title"><span class="section-number">{{ $isEdit ? '3' : '4' }}</span><div><h2>Status & Keamanan</h2><p>Atur akses akun ke aplikasi.</p></div></div>
            <label class="block mb-3"><span class="field-label">Status Akun</span><select name="is_active" class="field"><option value="1" @selected((string)$value('is_active', $activeDefault) === '1')>Aktif — dapat login</option><option value="0" @selected((string)$value('is_active', $activeDefault) === '0')>Nonaktif — akses diblokir</option></select></label>
            @unless($isEdit)
            <label class="must-change-password flex items-start gap-3 p-3 rounded-lg border border-blue-100 bg-blue-50"><input type="checkbox" name="must_change_password" value="1" class="mt-1 accent-blue-600" checked><span><strong class="block text-sm text-slate-800">Wajib ganti password</strong><span class="text-xs text-slate-500">Tandai akun agar password sementara diganti pada alur penggantian password yang didukung aplikasi.</span></span></label>
            @else
            <div class="p-3 rounded-lg bg-slate-50 text-xs text-slate-600">Status permintaan ganti password: <strong>{{ $user->must_change_password ? 'Wajib diganti' : 'Tidak diwajibkan' }}</strong>. Untuk mengubah password, gunakan aksi Reset Password pada detail akun.</div>
            @endunless
        </section>
    </aside>
</div>

<style>
/* Account create/edit form surfaces use the shared Admin theme tokens. */
.form-panel {
    background: var(--admin-surface, #fff);
    color: var(--admin-text, #0f172a);
    border: 1px solid var(--admin-border, #e2e8f0);
    border-radius: 14px;
    padding: 21px;
    box-shadow: var(--admin-shadow, 0 1px 2px rgba(15,23,42,.04), 0 8px 20px rgba(15,23,42,.035));
    transition: background-color .18s ease, border-color .18s ease, color .18s ease;
}
.form-section-title { display:flex; align-items:flex-start; gap:11px; margin-bottom:20px; }
.section-number {
    width:27px; height:27px; display:grid; place-items:center; border-radius:8px;
    background:#eff6ff; color:#2563eb; font-size:12px; font-weight:800; flex-shrink:0;
}
.form-section-title h2 { font-size:15px; font-weight:700; color:var(--admin-text, #0f172a); }
.form-section-title p { font-size:11px; color:var(--admin-text-muted, #64748b); margin-top:3px; }
.field-label { display:block; font-size:11px; font-weight:650; color:var(--admin-text-secondary, #334155); margin-bottom:7px; }
.field-label b { color:#dc2626; }
.error-text { display:block; color:#dc2626; font-size:11px; margin-top:5px; }
.field {
    width:100%; min-height:42px; border:1px solid var(--admin-border, #dbe3ef);
    background:var(--admin-surface-soft, #f8fafc); border-radius:9px;
    padding:11px 12px; color:var(--admin-text, #1e293b); font-size:12px; outline:none;
    transition: background-color .15s ease, border-color .15s ease, box-shadow .15s ease, color .15s ease;
}
.field:focus {
    background:var(--admin-surface-raised, #fff); border-color:#60a5fa;
    box-shadow:0 0 0 3px var(--admin-focus, #dbeafe);
}
.field::placeholder { color:var(--admin-text-muted, #94a3b8); opacity:1; }
.form-info-note { color:var(--admin-alert-info-text, #1e40af); background:var(--admin-alert-info-bg, #eff6ff); border-color:var(--admin-border, #bfdbfe); }
.form-info-note p { color:inherit; }
.must-change-password { color:var(--admin-text-secondary, #475569); background:var(--admin-alert-info-bg, #eff6ff); border-color:var(--admin-border, #dbeafe); }
.must-change-password strong { color:var(--admin-text, #0f172a); }
.must-change-password span { color:var(--admin-text-secondary, #475569); }

html[data-theme="dark"] .form-panel {
    background:#1e293b !important;
    color:#f1f5f9 !important;
    border-color:#334155 !important;
    box-shadow:0 10px 28px rgba(0,0,0,.16);
}
html[data-theme="dark"] .form-section-title h2 { color:#f8fafc !important; }
html[data-theme="dark"] .form-section-title p { color:#94a3b8 !important; }
html[data-theme="dark"] .field-label { color:#cbd5e1 !important; }
html[data-theme="dark"] .field-label b { color:#fca5a5 !important; }
html[data-theme="dark"] .section-number { background:rgba(37,99,235,.2) !important; color:#93c5fd !important; }
html[data-theme="dark"] .field,
html[data-theme="dark"] .form-panel input.field,
html[data-theme="dark"] .form-panel select.field,
html[data-theme="dark"] .form-panel textarea.field {
    background:#0f172a !important;
    color:#f1f5f9 !important;
    border-color:#475569 !important;
    color-scheme:dark;
}
html[data-theme="dark"] .field:focus {
    background:#111f35 !important;
    color:#f8fafc !important;
    border-color:#60a5fa !important;
    box-shadow:0 0 0 3px rgba(96,165,250,.2) !important;
}
html[data-theme="dark"] .field::placeholder { color:#94a3b8 !important; }
html[data-theme="dark"] .field option { background:#0f172a; color:#e2e8f0; }
html[data-theme="dark"] .must-change-password {
    background:rgba(30,64,175,.22) !important;
    border-color:rgba(96,165,250,.35) !important;
    color:#cbd5e1 !important;
}
html[data-theme="dark"] .must-change-password strong { color:#f8fafc !important; }
html[data-theme="dark"] .must-change-password span { color:#cbd5e1 !important; }
html[data-theme="dark"] .form-info-note {
    background:rgba(30,64,175,.2) !important;
    border-color:rgba(96,165,250,.34) !important;
    color:#dbeafe !important;
}
html[data-theme="dark"] .form-info-note p { color:#bfdbfe !important; }

@media (max-width: 640px) {
    .form-panel { padding:16px; border-radius:12px; }
}
</style>

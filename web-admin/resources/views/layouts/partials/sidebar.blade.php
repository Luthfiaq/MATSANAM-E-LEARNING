@php
    $accountRouteUser = request()->route('user');
    $accountRole = $accountRouteUser instanceof \App\Models\User
        ? $accountRouteUser->role
        : (request()->route('role') ?? request('role', 'all'));

    if (request()->boolean('show_deleted')) {
        $accountActive = 'deleted';
    } elseif (request()->routeIs('admin.accounts.show', 'admin.accounts.edit', 'admin.accounts.reset-password', 'admin.accounts.status', 'admin.accounts.destroy')) {
        $accountActive = $accountRole;
    } elseif (request()->routeIs('admin.accounts.create', 'admin.accounts.store')) {
        $accountActive = $accountRole;
    } elseif (request()->routeIs('admin.accounts.index')) {
        $accountActive = request('role', 'all');
    } else {
        $accountActive = '';
    }
@endphp

<aside id="adminSidebar" class="w-64 shrink-0 bg-white dark:bg-slate-800 border-r border-slate-200 dark:border-slate-700 flex flex-col h-full overflow-y-auto">
    <div class="h-[69px] px-5 flex items-center gap-3 border-b border-slate-100 dark:border-slate-700 shrink-0">
        <div class="w-10 h-10 rounded-xl bg-blue-600 text-white grid place-items-center font-bold text-xl shadow-sm">M</div>
        <div class="leading-tight min-w-0">
            <div class="font-bold text-slate-900 dark:text-white tracking-tight">MTsN 6 Nganjuk</div>
            <div class="text-[10px] text-slate-500 font-semibold tracking-wide">MATSANAM ADMIN PORTAL</div>
        </div>
    </div>

    <nav class="flex-1 p-3 space-y-5 text-sm">
        <section>
            <p class="px-3 mb-2 text-[10px] font-bold tracking-[.12em] text-slate-400">NAVIGASI UTAMA</p>
            <a href="{{ route('admin.dashboard') }}" class="nav-link {{ request()->routeIs('admin.dashboard') ? 'nav-active' : '' }}">
                <span class="nav-icon">▦</span><span>Dashboard Utama</span>
            </a>
        </section>

        <section>
            <div class="px-3 mb-2 flex items-center justify-between text-[10px] font-bold tracking-[.12em] text-slate-400">
                <span>MANAJEMEN AKUN</span>
            </div>
            <a href="{{ route('admin.accounts.index') }}" class="nav-link {{ $accountActive === 'all' ? 'nav-active' : '' }}">
                <span class="nav-icon">▣</span><span>Semua Akun</span>
            </a>
            <a href="{{ route('admin.accounts.index', ['role' => 'guru']) }}" class="nav-link {{ $accountActive === 'guru' ? 'nav-active' : '' }}">
                <span class="nav-icon">♙</span><span>Akun Guru</span>
            </a>
            <a href="{{ route('admin.accounts.index', ['role' => 'siswa']) }}" class="nav-link {{ $accountActive === 'siswa' ? 'nav-active' : '' }}">
                <span class="nav-icon">♧</span><span>Akun Siswa</span>
            </a>
            <a href="{{ route('admin.accounts.index', ['show_deleted' => 1]) }}" class="nav-link {{ $accountActive === 'deleted' ? 'nav-active' : '' }}">
                <span class="nav-icon">♲</span><span>Akun Terhapus</span>
            </a>
        </section>

        <section>
            <p class="px-3 mb-2 text-[10px] font-bold tracking-[.12em] text-slate-400">MANAJEMEN GURU & KELAS</p>
            <a href="{{ route('admin.penugasan.index') }}" class="nav-link {{ request()->routeIs('admin.penugasan.index', 'admin.penugasan.edit', 'admin.penugasan.update', 'admin.penugasan.destroy') ? 'nav-active' : '' }}">
                <span class="nav-icon">▤</span><span>List Penugasan Guru</span>
            </a>
            <a href="{{ route('admin.penugasan.create') }}" class="nav-link {{ request()->routeIs('admin.penugasan.create', 'admin.penugasan.store') ? 'nav-active' : '' }}">
                <span class="nav-icon">＋</span><span>Atur Penugasan Baru</span>
            </a>
        </section>

        <section>
            <p class="px-3 mb-2 text-[10px] font-bold tracking-[.12em] text-slate-400">MASTER DATA</p>
            <a href="{{ route('admin.master-data.guru.index') }}" class="nav-link {{ request()->routeIs('admin.master-data.guru.*') ? 'nav-active' : '' }}"><span class="nav-icon">♙</span><span>Data Guru</span></a>
            <a href="{{ route('admin.master-data.siswa.index') }}" class="nav-link {{ request()->routeIs('admin.master-data.siswa.*') ? 'nav-active' : '' }}"><span class="nav-icon">♧</span><span>Data Siswa</span></a>
            <a href="{{ route('admin.master-data.kelas.index') }}" class="nav-link {{ request()->routeIs('admin.master-data.kelas.*') ? 'nav-active' : '' }}"><span class="nav-icon">▦</span><span>Data Kelas</span></a>
            <a href="{{ route('admin.master-data.mata-pelajaran.index') }}" class="nav-link {{ request()->routeIs('admin.master-data.mata-pelajaran.*') ? 'nav-active' : '' }}"><span class="nav-icon">▤</span><span>Mata Pelajaran</span></a>
            <a href="{{ route('admin.master-data.periode-akademik.index') }}" class="nav-link {{ request()->routeIs('admin.master-data.periode-akademik.*') ? 'nav-active' : '' }}"><span class="nav-icon">◷</span><span>Periode Akademik</span></a>
            <a href="{{ route('admin.master-data.jadwal-pelajaran.index') }}" class="nav-link {{ request()->routeIs('admin.master-data.jadwal-pelajaran.*') ? 'nav-active' : '' }}"><span class="nav-icon">▦</span><span>Jadwal Pelajaran</span></a>
        </section>

        {{-- Menu Pembelajaran disembunyikan sementara sesuai permintaan.
        <section>
            <p class="px-3 mb-2 text-[10px] font-bold tracking-[.12em] text-slate-400">PEMBELAJARAN</p>
            <a href="{{ route('admin.materi.index') }}" class="nav-link {{ request()->routeIs('admin.materi.*') ? 'nav-active' : '' }}"><span class="nav-icon">▧</span><span>Manajemen Materi</span></a>
            <a href="{{ route('admin.tugas.index') }}" class="nav-link {{ request()->routeIs('admin.tugas.*') ? 'nav-active' : '' }}"><span class="nav-icon">☷</span><span>Manajemen Tugas</span></a>
            <a href="{{ route('admin.nilai.index') }}" class="nav-link {{ request()->routeIs('admin.nilai.*') ? 'nav-active' : '' }}"><span class="nav-icon">▤</span><span>Manajemen Nilai</span></a>
        </section>
        --}}

        <section>
            <p class="px-3 mb-2 text-[10px] font-bold tracking-[.12em] text-slate-400">VERIFIKASI & IZIN</p>
            <a href="{{ route('admin.absensi.verifikasi') }}" class="nav-link {{ request()->routeIs('admin.absensi.verifikasi') ? 'nav-active' : '' }}">
                <span class="nav-icon">▤</span><span>Verifikasi Surat</span>
                @if(($suratPending ?? 0) > 0)<span class="ml-auto text-[10px] bg-amber-50 text-amber-700 px-2 py-0.5 rounded-full">{{ $suratPending }}</span>@endif
            </a>
            <a href="{{ route('admin.absensi.histori') }}" class="nav-link {{ request()->routeIs('admin.absensi.histori') ? 'nav-active' : '' }}"><span class="nav-icon">◷</span><span>Histori Verifikasi</span></a>
        </section>

        <section>
            <p class="px-3 mb-2 text-[10px] font-bold tracking-[.12em] text-slate-400">PRESENSI & LAPORAN</p>
            <a href="{{ route('admin.absensi.rekap') }}" class="nav-link {{ request()->routeIs('admin.absensi.rekap') ? 'nav-active' : '' }}"><span class="nav-icon">▧</span><span>Rekap Absensi Siswa</span></a>
        </section>

        <section>
            <p class="px-3 mb-2 text-[10px] font-bold tracking-[.12em] text-slate-400">KONFIGURASI</p>
            <a href="{{ route('admin.pengaturan') }}" class="nav-link {{ request()->routeIs('admin.pengaturan') ? 'nav-active' : '' }}"><span class="nav-icon">⚙</span><span>Pengaturan</span></a>
        </section>
    </nav>

    <div class="p-3 border-t border-slate-100 dark:border-slate-700 shrink-0">
        <div class="flex items-center gap-2 p-3 rounded-xl bg-slate-50 dark:bg-slate-700 border border-slate-200 dark:border-slate-600">
            <span class="w-2 h-2 rounded-full bg-emerald-500"></span>
            <div><p class="text-xs font-semibold text-slate-700 dark:text-slate-100">Server TU Aktif</p><p class="text-[10px] text-slate-400">MATSANAM E-Learning</p></div>
        </div>
    </div>
</aside>

<style>
.nav-link{display:flex;align-items:center;gap:.7rem;padding:.62rem .78rem;border-radius:.65rem;color:#334155;font-size:.82rem;transition:background-color .15s ease,color .15s ease,box-shadow .15s ease;margin:.12rem 0}
.dark .nav-link{color:#cbd5e1}
.nav-link:not(.nav-active):hover{background:#eff6ff;color:#1d4ed8}
.dark .nav-link:not(.nav-active):hover{background:#334155;color:#bfdbfe}
.nav-link.nav-active,.nav-link.nav-active:hover,.nav-link.nav-active:focus{background:#2563eb!important;color:#fff!important;box-shadow:0 3px 8px #2563eb24}
.nav-link.nav-active .nav-icon{color:#fff!important}
.nav-icon{display:inline-grid;place-items:center;width:20px;font-size:17px;line-height:1;flex:none}
</style>

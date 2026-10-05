<div class="bg-white w-72 flex-shrink-0 shadow-sm overflow-y-auto">
    <!-- Logo -->
    <div class="flex items-center bg-white py-3 px-6 border-b border-gray-100">
        <div class="w-9 h-9 mr-2 rounded-lg bg-blue-600 flex items-center justify-center">
            <span class="text-white text-xl font-bold">M</span>
        </div>
        <div>
            <div class="text-slate-900 text-base font-bold">Matsanam</div>
            <div class="text-slate-400 text-[11px] font-bold">Digital Academic</div>
        </div>
    </div>

    <!-- Navigation -->
    <nav class="p-4">
        <!-- Navigasi Utama -->
        <div class="mb-4">
            <div class="mb-2 pl-2 text-slate-400 text-[11px] font-bold">NAVIGASI UTAMA</div>
            <a href="{{ route('admin.dashboard') }}" 
               class="flex items-center py-2 px-4 rounded-lg {{ request()->routeIs('admin.dashboard') ? 'bg-blue-600 text-white' : 'text-[#434655] hover:bg-gray-50' }}">
                <span class="text-lg mr-2">📊</span>
                <span class="text-sm">Dashboard Utama</span>
            </a>
        </div>

        <!-- Manajemen Guru -->
        <div class="mb-4">
            <div class="mb-2 pl-2 text-slate-400 text-[11px] font-bold">MANAJEMEN GURU</div>
            <a href="{{ route('admin.penugasan.index') }}" 
               class="flex items-center py-2 px-4 rounded-lg {{ request()->routeIs('admin.penugasan.index', 'admin.penugasan.edit') ? 'bg-blue-600 text-white' : 'text-[#434655] hover:bg-gray-50' }}">
                <span class="text-lg mr-2">👨‍🏫</span>
                <span class="text-sm">List Penugasan Guru</span>
            </a>
            <a href="{{ route('admin.penugasan.create') }}" 
               class="flex items-center py-2 px-4 rounded-lg {{ request()->routeIs('admin.penugasan.create') ? 'bg-blue-600 text-white' : 'text-[#434655] hover:bg-gray-50' }}">
                <span class="text-lg mr-2">➕</span>
                <span class="text-sm">Atur Penugasan Baru</span>
            </a>
        </div>

        <!-- Verifikasi & Izin -->
        <div class="mb-4">
            <div class="mb-2 pl-2 text-slate-400 text-[11px] font-bold">VERIFIKASI & IZIN</div>
            <a href="#" class="flex justify-between items-center py-2 px-4 rounded-lg text-[#434655] hover:bg-gray-50">
                <div class="flex items-center gap-2">
                    <span class="text-lg">✉️</span>
                    <span class="text-sm">Verifikasi Surat</span>
                </div>
                @if($suratPending ?? 0 > 0)
                <span class="bg-[#F59E0B33] text-[#F59E0B] text-[11px] font-bold py-0.5 px-1.5 rounded-xl">
                    {{ $suratPending }}
                </span>
                @endif
            </a>
            <a href="#" class="flex items-center py-2 px-4 rounded-lg text-[#434655] hover:bg-gray-50">
                <span class="text-lg mr-2">📋</span>
                <span class="text-sm">Histori Verifikasi</span>
            </a>
        </div>

        <!-- Presensi & Laporan -->
        <div class="mb-4">
            <div class="mb-2 pl-2 text-slate-400 text-[11px] font-bold">PRESENSI & LAPORAN</div>
            <a href="#" class="flex items-center py-2 px-4 rounded-lg text-[#434655] hover:bg-gray-50">
                <span class="text-lg mr-2">📊</span>
                <span class="text-sm">Rekap Absensi Siswa</span>
            </a>
        </div>

        <!-- Konfigurasi -->
        <div class="mb-4">
            <div class="mb-2 pl-2 text-slate-400 text-[11px] font-bold">KONFIGURASI</div>
            <a href="#" class="flex items-center py-2 px-4 gap-2 rounded-lg text-[#434655] hover:bg-gray-50">
                <span class="text-lg">⚙️</span>
                <span class="text-sm">Pengaturan & Master Data</span>
            </a>
        </div>
    </nav>

    <!-- Status Footer -->
    <div class="p-4 bg-[#F2F3FF]">
        <div class="bg-white p-2 rounded-lg border border-slate-200 flex justify-between items-center">
            <div>
                <div class="text-slate-400 text-[11px] font-bold">Koneksi Database</div>
                <div class="flex items-center gap-1">
                    <div class="bg-[#006C4A] w-2 h-2 rounded-full"></div>
                    <span class="text-[#006C4A] text-xs">Terhubung Aktif</span>
                </div>
            </div>
            <span class="text-2xl">🗄️</span>
        </div>
    </div>
</div>

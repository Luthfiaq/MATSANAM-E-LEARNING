<div
    class="bg-white dark:bg-slate-800
           w-72 flex-shrink-0
           shadow-sm
           overflow-y-auto
           border-r border-gray-100 dark:border-slate-700
           transition-colors duration-200">


    <!-- ========================================= -->
    <!-- LOGO -->
    <!-- ========================================= -->

    <div
        class="flex items-center
               bg-white dark:bg-slate-800
               py-3 px-6
               border-b border-gray-100 dark:border-slate-700
               transition-colors duration-200">

        <div
            class="w-9 h-9 mr-2 rounded-lg
                   bg-blue-600
                   flex items-center justify-center">

            <span class="text-white text-xl font-bold">
                M
            </span>

        </div>


        <div>

            <div
                class="text-slate-900 dark:text-white
                       text-base font-bold">

                Matsanam

            </div>


            <div
                class="text-slate-400 dark:text-slate-400
                       text-[11px] font-bold">

                Digital Academic

            </div>

        </div>

    </div>


    <!-- ========================================= -->
    <!-- NAVIGATION -->
    <!-- ========================================= -->

    <nav class="p-4">


        <!-- ========================================= -->
        <!-- NAVIGASI UTAMA -->
        <!-- ========================================= -->

        <div class="mb-4">

            <div
                class="mb-2 pl-2
                       text-slate-400
                       text-[11px] font-bold">

                NAVIGASI UTAMA

            </div>


            <a
                href="{{ route('admin.dashboard') }}"
                class="flex items-center py-2 px-4 rounded-lg transition
                {{ request()->routeIs('admin.dashboard')
                    ? 'bg-blue-600 text-white'
                    : 'text-slate-700 dark:text-slate-200 hover:bg-gray-50 dark:hover:bg-slate-700' }}">

                <span class="text-lg mr-2">
                    📊
                </span>

                <span class="text-sm">
                    Dashboard Utama
                </span>

            </a>

        </div>



        <!-- ========================================= -->
        <!-- MANAJEMEN GURU -->
        <!-- ========================================= -->

        <div class="mb-4">

            <div
                class="mb-2 pl-2
                       text-slate-400
                       text-[11px] font-bold">

                MANAJEMEN GURU

            </div>


            <!-- List Penugasan Guru -->

            <a
                href="{{ route('admin.penugasan.index') }}"
                class="flex items-center py-2 px-4 rounded-lg transition
                {{ request()->routeIs('admin.penugasan.index', 'admin.penugasan.edit')
                    ? 'bg-blue-600 text-white'
                    : 'text-slate-700 dark:text-slate-200 hover:bg-gray-50 dark:hover:bg-slate-700' }}">

                <span class="text-lg mr-2">
                    👨‍🏫
                </span>

                <span class="text-sm">
                    List Penugasan Guru
                </span>

            </a>


            <!-- Atur Penugasan Baru -->

            <a
                href="{{ route('admin.penugasan.create') }}"
                class="flex items-center py-2 px-4 rounded-lg transition
                {{ request()->routeIs('admin.penugasan.create')
                    ? 'bg-blue-600 text-white'
                    : 'text-slate-700 dark:text-slate-200 hover:bg-gray-50 dark:hover:bg-slate-700' }}">

                <span class="text-lg mr-2">
                    ➕
                </span>

                <span class="text-sm">
                    Atur Penugasan Baru
                </span>

            </a>

        </div>



        <!-- ========================================= -->
        <!-- VERIFIKASI & IZIN -->
        <!-- ========================================= -->

        <div class="mb-4">

            <div
                class="mb-2 pl-2
                       text-slate-400
                       text-[11px] font-bold">

                VERIFIKASI & IZIN

            </div>


            <!-- Verifikasi Surat -->

            <a
                href="{{ route('admin.absensi.verifikasi') }}"
                class="flex justify-between items-center py-2 px-4 rounded-lg transition
                {{ request()->routeIs('admin.absensi.verifikasi')
                    ? 'bg-blue-600 text-white'
                    : 'text-slate-700 dark:text-slate-200 hover:bg-gray-50 dark:hover:bg-slate-700' }}">

                <div class="flex items-center gap-2">

                    <span class="text-lg">
                        ✉️
                    </span>

                    <span class="text-sm">
                        Verifikasi Surat
                    </span>

                </div>


                @if($suratPending ?? 0 > 0)

                    <span
                        class="bg-[#F59E0B33] text-[#F59E0B]
                               text-[11px] font-bold
                               py-0.5 px-1.5 rounded-xl">

                        {{ $suratPending }}

                    </span>

                @endif

            </a>


            <!-- Histori Verifikasi -->

            <a
                href="{{ route('admin.absensi.histori') }}"
                class="flex items-center py-2 px-4 rounded-lg transition
                {{ request()->routeIs('admin.absensi.histori')
                    ? 'bg-blue-600 text-white'
                    : 'text-slate-700 dark:text-slate-200 hover:bg-gray-50 dark:hover:bg-slate-700' }}">

                <span class="text-lg mr-2">
                    📋
                </span>

                <span class="text-sm">
                    Histori Verifikasi
                </span>

            </a>

        </div>



        <!-- ========================================= -->
        <!-- PRESENSI & LAPORAN -->
        <!-- ========================================= -->

        <div class="mb-4">

            <div
                class="mb-2 pl-2
                       text-slate-400
                       text-[11px] font-bold">

                PRESENSI & LAPORAN

            </div>


            <!-- Rekap Absensi -->

            <a
                href="{{ route('admin.absensi.rekap') }}"
                class="flex items-center py-2 px-4 rounded-lg transition
                {{ request()->routeIs('admin.absensi.rekap')
                    ? 'bg-blue-600 text-white'
                    : 'text-slate-700 dark:text-slate-200 hover:bg-gray-50 dark:hover:bg-slate-700' }}">

                <span class="text-lg mr-2">
                    📊
                </span>

                <span class="text-sm">
                    Rekap Absensi Siswa
                </span>

            </a>

        </div>



        <!-- ========================================= -->
        <!-- MASTER DATA -->
        <!-- ========================================= -->

        <div class="mb-4">

            <div
                class="mb-2 pl-2
                       text-slate-400
                       text-[11px] font-bold">

                MASTER DATA

            </div>


            <!-- Guru -->

            <a
                href="{{ route('admin.master-data.guru.index') }}"
                class="flex items-center py-2 px-4 gap-2 rounded-lg transition
                {{ request()->routeIs('admin.master-data.guru.*')
                    ? 'bg-blue-600 text-white'
                    : 'text-slate-700 dark:text-slate-200 hover:bg-gray-50 dark:hover:bg-slate-700' }}">

                <span class="text-lg">
                    👨‍🏫
                </span>

                <span class="text-sm">
                    Guru
                </span>

            </a>


            <!-- Siswa -->

            <a
                href="{{ route('admin.master-data.siswa.index') }}"
                class="flex items-center py-2 px-4 gap-2 rounded-lg transition
                {{ request()->routeIs('admin.master-data.siswa.*')
                    ? 'bg-blue-600 text-white'
                    : 'text-slate-700 dark:text-slate-200 hover:bg-gray-50 dark:hover:bg-slate-700' }}">

                <span class="text-lg">
                    👨‍🎓
                </span>

                <span class="text-sm">
                    Siswa
                </span>

            </a>


            <!-- Kelas -->

            <a
                href="{{ route('admin.master-data.kelas.index') }}"
                class="flex items-center py-2 px-4 gap-2 rounded-lg transition
                {{ request()->routeIs('admin.master-data.kelas.*')
                    ? 'bg-blue-600 text-white'
                    : 'text-slate-700 dark:text-slate-200 hover:bg-gray-50 dark:hover:bg-slate-700' }}">

                <span class="text-lg">
                    🏫
                </span>

                <span class="text-sm">
                    Kelas
                </span>

            </a>


            <!-- Mata Pelajaran -->

            <a
                href="{{ route('admin.master-data.mata-pelajaran.index') }}"
                class="flex items-center py-2 px-4 gap-2 rounded-lg transition
                {{ request()->routeIs('admin.master-data.mata-pelajaran.*')
                    ? 'bg-blue-600 text-white'
                    : 'text-slate-700 dark:text-slate-200 hover:bg-gray-50 dark:hover:bg-slate-700' }}">

                <span class="text-lg">
                    📚
                </span>

                <span class="text-sm">
                    Mata Pelajaran
                </span>

            </a>


            <!-- Periode Akademik -->

            <a
                href="{{ route('admin.master-data.periode-akademik.index') }}"
                class="flex items-center py-2 px-4 gap-2 rounded-lg transition
                {{ request()->routeIs('admin.master-data.periode-akademik.*')
                    ? 'bg-blue-600 text-white'
                    : 'text-slate-700 dark:text-slate-200 hover:bg-gray-50 dark:hover:bg-slate-700' }}">

                <span class="text-lg">
                    📅
                </span>

                <span class="text-sm">
                    Periode Akademik
                </span>

            </a>


            <!-- Jadwal Pelajaran -->

            <a
                href="{{ route('admin.master-data.jadwal-pelajaran.index') }}"
                class="flex items-center py-2 px-4 gap-2 rounded-lg transition
                {{ request()->routeIs('admin.master-data.jadwal-pelajaran.*')
                    ? 'bg-blue-600 text-white'
                    : 'text-slate-700 dark:text-slate-200 hover:bg-gray-50 dark:hover:bg-slate-700' }}">

                <span class="text-lg">
                    🗓️
                </span>

                <span class="text-sm">
                    Jadwal Pelajaran
                </span>

            </a>

        </div>



        <!-- ========================================= -->
        <!-- KONFIGURASI -->
        <!-- ========================================= -->

        <div class="mb-4">

            <div
                class="mb-2 pl-2
                       text-slate-400
                       text-[11px] font-bold">

                KONFIGURASI

            </div>


            <!-- Pengaturan -->

            <a
                href="{{ route('admin.pengaturan') }}"
                class="flex items-center py-2 px-4 gap-2 rounded-lg transition
                {{ request()->routeIs('admin.pengaturan')
                    ? 'bg-blue-600 text-white'
                    : 'text-slate-700 dark:text-slate-200 hover:bg-gray-50 dark:hover:bg-slate-700' }}">

                <span class="text-lg">
                    ⚙️
                </span>

                <span class="text-sm">
                    Pengaturan
                </span>

            </a>

        </div>

    </nav>



    <!-- ========================================= -->
    <!-- STATUS FOOTER -->
    <!-- ========================================= -->

    <div
        class="p-4
               bg-[#F2F3FF]
               dark:bg-slate-900
               transition-colors duration-200">

        <div
            class="bg-white dark:bg-slate-800
                   p-2 rounded-lg
                   border border-slate-200 dark:border-slate-700
                   flex justify-between items-center
                   transition-colors duration-200">

            <div>

                <div
                    class="text-slate-400
                           text-[11px] font-bold">

                    Koneksi Database

                </div>


                <div class="flex items-center gap-1">

                    <div
                        class="bg-[#006C4A]
                               w-2 h-2 rounded-full">
                    </div>

                    <span
                        class="text-[#006C4A] dark:text-green-400
                               text-xs">

                        Terhubung Aktif

                    </span>

                </div>

            </div>


            <span class="text-2xl">
                🗄️
            </span>

        </div>

    </div>

</div>
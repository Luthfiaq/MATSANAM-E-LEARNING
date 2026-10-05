@extends('layouts.admin')

@section('title', 'Dashboard')

@section('content')
<!-- Welcome Banner -->
<div class="relative overflow-hidden rounded-xl p-6 mb-6" style="background: linear-gradient(180deg, #004ac6, #2563eb, #0053db);">
    <div class="flex-1 bg-[#FFFFFF1A] w-[216px] absolute top-0 bottom-0 right-0 rounded-xl blur-[40px]"></div>
    <div class="bg-[#82F5C133] w-32 h-32 absolute top-0 right-40 rounded-xl blur-[24px]"></div>
    
    <div class="flex justify-between items-center relative">
        <div class="max-w-2xl">
            <div class="mb-2">
                <div class="flex items-center bg-[#FFFFFF26] py-0.5 px-2 gap-1 rounded-xl inline-flex">
                    <span class="text-white">⚡</span>
                    <span class="text-white text-[11px] font-bold">EMIS & Simpatika Synced 08:30 WIB</span>
                </div>
            </div>
            <h1 class="text-white text-2xl font-bold mb-2">
                Selamat Datang di Portal Administrasi Akademik MTsN Matsanam
            </h1>
            <p class="text-[#EEEFFF] text-sm">
                Pusat komando digital madrasah: kelola SK penugasan guru, verifikasi berkas
                perizinan siswa real-time, dan pantau rekapitulasi kehadiran madrasah hari ini.
            </p>
        </div>
        
        <div class="flex items-center bg-[#FFFFFF1A] py-2 px-4 gap-4 rounded-lg">
            <div class="w-10 h-10 rounded-xl bg-white/20 flex items-center justify-center">
                <span class="text-2xl">🛡️</span>
            </div>
            <div>
                <div class="text-white text-[11px] font-bold">OTORITAS SESI</div>
                <div class="text-white text-base font-bold">Super Admin<br/>TU</div>
            </div>
        </div>
    </div>
</div>

<!-- Stats Cards -->
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
    <!-- Total Guru -->
    <div class="bg-white p-4 rounded-lg shadow-sm">
        <div class="flex justify-between items-start">
            <div>
                <div class="text-slate-400 text-xs">Total Guru Aktif</div>
                <div class="flex items-start gap-2 mt-1">
                    <span class="text-slate-900 text-4xl font-bold">{{ $totalGuru }}</span>
                    <span class="text-slate-600 text-xs mt-6">Guru</span>
                </div>
            </div>
            <img src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/gpqi4lun_expires_30_days.png"
                 class="w-[41px] h-11 rounded-lg object-fill" />
        </div>
        <div class="flex items-center gap-1 mt-4">
            <img src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/ufqi5jqr_expires_30_days.png"
                 class="w-[13px] h-[13px] object-fill" />
            <span class="text-[#006C4A] text-[11px] font-bold">142 Penugasan Kelas</span>
            <span class="text-slate-400 text-[11px] font-bold ml-1">Rasio 100% Terisi</span>
        </div>
    </div>

    <!-- Verifikasi Surat -->
    <div class="bg-white p-4 rounded-lg shadow-sm">
        <div class="flex items-start gap-3">
            <div class="flex-1">
                <div class="text-slate-400 text-xs">Verifikasi Surat Absensi</div>
                <div class="flex items-start gap-1.5 mt-1">
                    <span class="text-[#F59E0B] text-4xl font-bold">{{ $suratPending }}</span>
                    <span class="text-slate-600 text-xs mt-6">Menunggu Approval</span>
                </div>
            </div>
            <img src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/pauqay7x_expires_30_days.png"
                 class="w-11 h-11 rounded-lg object-fill" />
        </div>
        <div class="flex items-center gap-1 mt-4">
            <div class="flex items-center bg-[#F59E0B26] py-0.5 px-2 gap-1 rounded-xl flex-1">
                <img src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/0r7qeuou_expires_30_days.png"
                     class="w-2.5 h-3 rounded-xl object-fill" />
                <span class="text-[#F59E0B] text-[11px] font-bold">Waspada Batas Jam 12:00</span>
            </div>
            <span class="text-slate-400 text-[11px] font-bold">4 Sakit • 3 Izin</span>
        </div>
    </div>

    <!-- Kehadiran Hari Ini -->
    <div class="bg-white p-4 rounded-lg shadow-sm">
        <div class="flex items-start gap-4">
            <div class="flex-1">
                <div class="text-slate-400 text-xs">Kehadiran Siswa Hari Ini</div>
                <div class="text-[#006C4A] text-4xl font-bold mt-1">{{ $persentaseKehadiran }}%</div>
            </div>
            <img src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/9qwwvat9_expires_30_days.png"
                 class="w-[35px] h-11 rounded-lg object-fill" />
        </div>
        <div class="mt-4">
            <span class="text-slate-900 text-[11px] font-bold">{{ $absensiHariIni }} dari {{ $totalSiswaAbsen }} Siswa</span>
        </div>
    </div>

    <!-- Rombel & Kelas -->
    <div class="bg-white p-4 rounded-lg shadow-sm">
        <div class="flex items-start gap-2">
            <div class="flex-1 relative">
                <div class="text-slate-400 text-xs">Rombel & Kelas Aktif</div>
                <div class="text-slate-900 text-4xl font-bold mt-1">24</div>
                <span class="text-slate-600 text-xs absolute bottom-0 right-0">Rombongan Belajar</span>
            </div>
            <img src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/o1247a6g_expires_30_days.png"
                 class="w-[41px] h-11 rounded-lg object-fill" />
        </div>
        <div class="flex items-center justify-between mt-4">
            <span class="text-slate-400 text-[11px] font-bold">Kelas 7 (8) • Kelas 8 (8) • Kelas 9 (8)</span>
            <span class="text-[#004AC6] text-[11px] font-bold">100% Siap</span>
        </div>
    </div>
</div>

<!-- Quick Actions -->
<div class="mb-6">
    <div class="flex justify-between items-center mb-4">
        <div class="flex items-center gap-1">
            <img src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/g49fpzoy_expires_30_days.png"
                 class="w-3.5 h-[18px] object-fill" />
            <span class="text-slate-900 text-lg font-bold">Aksi Cepat & Alur Kerja Utama</span>
        </div>
        <span class="text-slate-400 text-[11px] font-bold">Sesuai SOP Administrasi Madrasah</span>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <!-- Atur Penugasan -->
        <div class="bg-white p-6 rounded-lg shadow-sm relative overflow-hidden">
            <div class="bg-[#EFF6FF99] w-24 h-32 absolute bottom-3 right-[-24px] rounded-bl-xl"></div>
            <div class="relative">
                <img src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/r1a3daeg_expires_30_days.png"
                     class="w-12 h-12 rounded-lg object-fill mb-2" />
                <h3 class="text-slate-900 text-base font-bold mb-1">Atur Penugasan Guru</h3>
                <p class="text-slate-600 text-xs mb-4">
                    Plotting jam mengajar, tambah/edit/hapus penugasan kelas, dan sinkronkan beban SKS
                </p>
                <div class="flex items-start gap-2">
                    <div class="flex items-center gap-1">
                        <img src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/nxchmwyl_expires_30_days.png"
                             class="w-[13px] h-[13px] object-fill" />
                        <span class="text-slate-400 text-[11px] font-bold">Update Kemarin</span>
                    </div>
                    <a href="{{ route('admin.penugasan.create') }}" 
                       class="flex-1 flex justify-between items-center bg-[#004AC6] py-1.5 px-4 rounded-lg">
                        <span class="text-white text-xs font-bold">Buka Kelola Penugasan</span>
                        <img src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/g66qobqo_expires_30_days.png"
                             class="w-3 h-3 rounded-lg object-fill" />
                    </a>
                </div>
            </div>
        </div>

        <!-- Verifikasi Surat -->
        <div class="bg-white p-6 rounded-lg shadow-sm relative overflow-hidden">
            <div class="bg-[#F59E0B1A] w-24 h-32 absolute bottom-3 right-[-24px] rounded-bl-xl"></div>
            <div class="relative">
                <img src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/anyalo3j_expires_30_days.png"
                     class="w-12 h-12 rounded-lg object-fill mb-2" />
                <div class="flex items-center gap-2 mb-1">
                    <h3 class="text-slate-900 text-base font-bold">Verifikasi Surat Izin/Sakit</h3>
                    <span class="bg-[#F59E0B33] text-[#F59E0B] text-[11px] font-bold py-0.5 px-2 rounded-xl">7 Baru</span>
                </div>
                <p class="text-slate-600 text-xs mb-4">
                    Validasi dokumen PDF/foto dokter dari orang tua/wali siswa. Setujui atau tolak izin disertai
                </p>
                <div class="flex items-start gap-2">
                    <div class="flex items-center gap-1">
                        <img src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/9f96e97p_expires_30_days.png"
                             class="w-[13px] h-[13px] object-fill" />
                        <span class="text-[#F59E0B] text-[11px] font-bold">Butuh aksi segera</span>
                    </div>
                    <a href="#" class="flex-1 flex justify-between items-center bg-[#004AC6] py-1.5 px-4 rounded-lg">
                        <span class="text-white text-xs font-bold">Tinjau 7 Surat Pending</span>
                        <img src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/rnfapdko_expires_30_days.png"
                             class="w-3 h-3 rounded-lg object-fill" />
                    </a>
                </div>
            </div>
        </div>

        <!-- Rekap Absensi -->
        <div class="bg-white p-6 rounded-lg shadow-sm relative overflow-hidden">
            <div class="bg-[#006C4A1A] w-24 h-32 absolute bottom-3 right-[-24px] rounded-bl-xl"></div>
            <div class="relative">
                <img src="{{ asset('assets/icons/rekap.png') }}"
                     class="w-12 h-12 rounded-lg object-fill mb-2" />
                <h3 class="text-slate-900 text-base font-bold mb-1">Rekap Absensi Siswa</h3>
                <p class="text-slate-600 text-xs mb-4">
                    Filter data kehadiran berdasarkan semester, rombel, kelas, bulan, belajar, dan unduh...
                </p>
                <div class="flex items-start gap-2">
                    <div class="flex items-center gap-1">
                        <img src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/iuh66k5c_expires_30_days.png"
                             class="w-[13px] h-[13px] object-fill" />
                        <span class="text-slate-400 text-[11px] font-bold">Format Tersedia Madrasah</span>
                    </div>
                    <a href="#" class="flex-1 flex justify-between items-center bg-[#004AC6] py-1.5 px-4 rounded-lg">
                        <span class="text-white text-xs font-bold">Buka Menu Rekap</span>
                        <img src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/gj35d6qa_expires_30_days.png"
                             class="w-3 h-3 rounded-lg object-fill" />
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Pending Surat Table -->
<div class="bg-white rounded-lg shadow-sm">
    <div class="flex items-center gap-2 border-b border-gray-100 px-6 py-4">
        <span class="text-xl">📋</span>
        <h2 class="flex-1 text-base font-semibold text-gray-900">
            Antrean Validasi Surat Perizinan Siswa
        </h2>
        <div class="flex items-center gap-3">
            <button class="text-sm text-gray-500 hover:text-gray-700">🔍 Filter Status</button>
            <a href="#" class="text-sm font-medium text-blue-600 hover:text-blue-700">
                Lihat Semua ({{ $pendingSurat->count() }}) →
            </a>
        </div>
    </div>

    <div class="border-b border-gray-100 bg-gray-50 px-6 py-2 text-xs text-gray-500">
        Menampilkan persyaratan yang perlu diverifikasi hari ini
    </div>

    <div class="overflow-x-auto">
        <table class="min-w-full text-sm">
            <thead class="border-b border-gray-100 bg-gray-50">
                <tr>
                    <th class="px-6 py-3 text-left text-xs font-semibold uppercase tracking-wider text-gray-600">Siswa & NISN</th>
                    <th class="px-6 py-3 text-left text-xs font-semibold uppercase tracking-wider text-gray-600">Kelas</th>
                    <th class="px-6 py-3 text-left text-xs font-semibold uppercase tracking-wider text-gray-600">Rentang Izin</th>
                    <th class="px-6 py-3 text-left text-xs font-semibold uppercase tracking-wider text-gray-600">Jenis & Bukti</th>
                    <th class="px-6 py-3 text-center text-xs font-semibold uppercase tracking-wider text-gray-600">Aksi Cepat</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-100 bg-white">
                @forelse($pendingSurat as $surat)
                <tr class="hover:bg-gray-50/50 transition">
                    <td class="px-6 py-4">
                        <div class="flex items-center gap-3">
                            <div class="flex h-10 w-10 items-center justify-center rounded-full bg-blue-100 text-sm font-semibold text-blue-700">
                                {{ strtoupper(substr($surat->siswa->nama_lengkap, 0, 2)) }}
                            </div>
                            <div>
                                <div class="font-semibold text-gray-900">{{ $surat->siswa->nama_lengkap }}</div>
                                <div class="text-xs text-gray-500">NISN: {{ $surat->siswa->nisn }}</div>
                            </div>
                        </div>
                    </td>
                    <td class="px-6 py-4">
                        <span class="rounded-md bg-blue-50 px-2 py-1 text-xs font-medium text-blue-700">
                            {{ $surat->siswa->kelas->nama_kelas ?? '-' }}
                        </span>
                    </td>
                    <td class="px-6 py-4">
                        <div class="text-sm text-gray-900">
                            {{ $surat->tanggal_mulai->diffInDays($surat->tanggal_selesai) + 1 }} Hari
                        </div>
                        <div class="text-xs text-gray-500">{{ $surat->tanggal_mulai->format('d M Y') }}</div>
                    </td>
                    <td class="px-6 py-4">
                        <div class="flex items-center gap-2">
                            <span class="inline-flex items-center gap-1 rounded-full px-2.5 py-1 text-xs font-medium {{ $surat->jenis === 'sakit' ? 'bg-red-50 text-red-700' : 'bg-amber-50 text-amber-700' }}">
                                {{ $surat->jenis === 'sakit' ? '🤒 Sakit Rawat' : '📄 Izin-Keluarga' }}
                            </span>
                            @if($surat->file_surat)
                            <button class="text-blue-600 hover:text-blue-700">📎</button>
                            @endif
                        </div>
                    </td>
                    <td class="px-6 py-4">
                        <div class="flex items-center justify-center gap-2">
                            <button class="inline-flex items-center gap-1 rounded-lg bg-green-600 px-3 py-1.5 text-xs font-medium text-white hover:bg-green-700 transition">
                                ✓ Terima
                            </button>
                            <button class="inline-flex items-center gap-1 rounded-lg bg-red-600 px-3 py-1.5 text-xs font-medium text-white hover:bg-red-700 transition">
                                ✗ Tolak
                            </button>
                        </div>
                    </td>
                </tr>
                @empty
                <tr>
                    <td colSpan="5" class="px-6 py-12 text-center text-gray-500">
                        <div class="flex flex-col items-center gap-2">
                            <span class="text-4xl">📭</span>
                            <span>Tidak ada surat pending</span>
                        </div>
                    </td>
                </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    @if($pendingSurat->count() > 0)
    <div class="border-t border-gray-100 px-6 py-3 text-center">
        <span class="text-sm text-gray-500">Menampilkan {{ $pendingSurat->count() }} surat pending</span>
        <a href="#" class="ml-2 text-sm font-medium text-blue-600 hover:text-blue-700">
            Buka Halaman Verifikasi Penuh →
        </a>
    </div>
    @endif
</div>
@endsection

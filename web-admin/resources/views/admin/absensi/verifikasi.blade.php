{{-- resources/views/admin/absensi/verifikasi.blade.php --}}
@extends('layouts.admin')

@section('title', 'Pusat Verifikasi Surat Absensi Siswa')

@section('content')
@php
    $suratRows = collect($suratAbsensi ?? []);
    $currentStatus = request('status', 'semua');
    
    // Perbaikan logika filter agar akurat membaca status database
    $filteredRows = $suratRows->filter(function($item) use ($currentStatus) {
        $status = strtolower(trim($item->status_verifikasi ?? 'pending'));
        
        if ($currentStatus === 'disetujui') {
            return in_array($status, ['disetujui', 'approved', 'valid']);
        }
        if ($currentStatus === 'ditolak') {
            return in_array($status, ['ditolak', 'rejected', 'invalid']);
        }
        
        // Untuk "Semua / Pending", tampilkan yang statusnya pending / belum diputuskan
        return in_array($status, ['pending', 'menunggu', '']);
    });

    // Jika filter aktif kosong, fallback ke semua data agar list kiri tidak pernah kosong melompong
    if ($filteredRows->isEmpty() && $currentStatus === 'semua') {
        $filteredRows = $suratRows;
    }

    $selectedId = request('selected', $filteredRows->first()->id ?? ($suratRows->first()->id ?? 0));
    $selectedItem = $suratRows->firstWhere('id', $selectedId) ?? $filteredRows->first() ?? $suratRows->first();
@endphp

<div class="min-h-screen bg-slate-50 text-slate-800 pb-12">
    {{-- Header Halaman --}}
    <header class="mx-auto max-w-[1600px] px-4 py-5 sm:px-6 lg:px-8">
        <div class="flex flex-col gap-5 xl:flex-row xl:items-center xl:justify-between">
            <div>
                <p class="mb-2 text-xs font-semibold uppercase tracking-[0.12em] text-blue-700">Modul Tata Usaha &amp; Kesiswaan</p>
                <h1 class="text-2xl font-bold tracking-tight text-slate-900 sm:text-3xl">Pusat Verifikasi Surat Absensi Siswa</h1>
                <p class="mt-2 text-sm text-slate-500">Tinjau keabsahan dokumen izin dokter atau surat wali murid dan perbarui status absensi master siswa.</p>
            </div>

            <div class="grid grid-cols-2 gap-3 sm:min-w-[400px]">
                <div class="rounded-xl border border-slate-200 bg-white px-4 py-3 shadow-sm">
                    <p class="text-xs font-medium text-slate-500">Antrean Validasi</p>
                    <p class="mt-1 text-lg font-bold text-orange-600">{{ count($suratAbsensi) }} Surat Hari Ini</p>
                </div>
                <div class="rounded-xl border border-slate-200 bg-white px-4 py-3 shadow-sm">
                    <p class="text-xs font-medium text-slate-500">Selesai Diverifikasi</p>
                    <p class="mt-1 text-lg font-bold text-emerald-700">{{ $totalDisetujui ?? 0 }} Surat Pekan Ini</p>
                </div>
            </div>
        </div>
    </header>

    {{-- SPLIT VIEW UTAMA: 2 Kolom Sejajar --}}
    <main class="mx-auto grid max-w-[1600px] grid-cols-1 gap-5 px-4 sm:px-6 lg:grid-cols-12 lg:px-8 items-start">
        
        {{-- KOLOM KIRI: Daftar Antrean Surat --}}
        <section class="lg:col-span-4 space-y-3">
            <div class="rounded-xl border border-slate-200 bg-white p-3 shadow-sm">
                <div class="grid grid-cols-3 gap-1.5" role="tablist">
                    <a href="{{ route('admin.absensi.verifikasi', ['status' => 'semua']) }}" 
                        class="{{ $currentStatus === 'semua' ? 'bg-blue-600 text-white shadow-sm' : 'bg-slate-100 text-slate-600 hover:bg-slate-200' }} rounded-lg px-2 py-2 text-center text-xs font-semibold transition">
                        Semua / Pending
                    </a>
                    <a href="{{ route('admin.absensi.verifikasi', ['status' => 'disetujui']) }}" 
                        class="{{ $currentStatus === 'disetujui' ? 'bg-blue-600 text-white shadow-sm' : 'bg-slate-100 text-slate-600 hover:bg-slate-200' }} rounded-lg px-2 py-2 text-center text-xs font-semibold transition">
                        Disetujui
                    </a>
                    <a href="{{ route('admin.absensi.verifikasi', ['status' => 'ditolak']) }}" 
                        class="{{ $currentStatus === 'ditolak' ? 'bg-blue-600 text-white shadow-sm' : 'bg-slate-100 text-slate-600 hover:bg-slate-200' }} rounded-lg px-2 py-2 text-center text-xs font-semibold transition">
                        Ditolak
                    </a>
                </div>
            </div>

            <div class="space-y-2.5">
                @forelse($filteredRows as $item)
                    @php
                        $namaSiswa = $item->siswa->nama_lengkap ?? 'Siswa';
                        $initials = strtoupper(substr($namaSiswa, 0, 2));
                        $namaKelas = $item->siswa->kelas->nama_kelas ?? '-';
                        $nisnSiswa = $item->siswa->nisn ?? '-';
                        $jenisSurat = ucfirst($item->jenis ?? 'Sakit');
                        $statusVerif = strtoupper($item->status_verifikasi ?? 'PENDING');
                        $tglMulai = $item->tanggal_mulai ? \Carbon\Carbon::parse($item->tanggal_mulai)->format('d M Y') : '-';
                        $tglUpload = $item->created_at ? $item->created_at->format('d M Y, H:i') . ' WIB' : '-';
                        $isActive = (int)$item->id === (int)$selectedId;
                    @endphp
                    <a href="{{ route('admin.absensi.verifikasi', ['status' => $currentStatus, 'selected' => $item->id]) }}"
                        class="block w-full rounded-xl border p-3.5 text-left shadow-sm transition cursor-pointer {{ $isActive ? 'border-blue-600 bg-white ring-2 ring-blue-100 shadow-md' : 'border-slate-200 bg-white hover:border-blue-200' }}">
                        <div class="flex items-start gap-3">
                            <span class="grid h-10 w-10 shrink-0 place-items-center rounded-xl bg-blue-600 text-white text-sm font-bold shadow-sm">{{ $initials }}</span>
                            <div class="min-w-0 flex-1">
                                <div class="flex items-start justify-between gap-1">
                                    <p class="truncate text-sm font-bold text-slate-900">{{ $namaSiswa }}</p>
                                    <span class="rounded-full bg-orange-50 px-2 py-0.5 text-[10px] font-semibold text-orange-600">{{ $jenisSurat }}</span>
                                </div>
                                <p class="text-[11px] text-slate-500 mt-0.5">Kelas {{ $namaKelas }} • NISN: {{ $nisnSiswa }}</p>
                                
                                <div class="mt-2.5 flex items-center justify-between text-[11px] text-slate-600 border-t border-slate-100 pt-2">
                                    <span class="font-medium text-slate-700">{{ $tglMulai }}</span>
                                    <span class="text-blue-600 font-semibold">{{ $item->file_surat ? '1 Dokumen PDF' : 'Surat Tertulis' }}</span>
                                </div>
                                <div class="mt-1 flex items-center justify-between text-[10px] text-slate-400">
                                    <span>Diupload: {{ $tglUpload }}</span>
                                    <span class="text-amber-600 font-semibold uppercase tracking-wider">{{ $statusVerif }}</span>
                                </div>
                            </div>
                        </div>
                    </a>
                @empty
                    <div class="rounded-xl border border-dashed border-slate-300 p-6 text-center text-sm text-slate-500 bg-white">
                        Tidak ada surat yang sesuai dengan filter ini.
                    </div>
                @endforelse
            </div>
        </section>

        {{-- KOLOM KANAN: Detail & Pratinjau Dokumen Berdasarkan Item yang Dipilih --}}
        <section class="min-w-0 lg:col-span-8">
            @if($selectedItem)
                @php
                    $namaSiswa = $selectedItem->siswa->nama_lengkap ?? 'Siswa';
                    $initials = strtoupper(substr($namaSiswa, 0, 2));
                    $namaKelas = $selectedItem->siswa->kelas->nama_kelas ?? '-';
                    $nisnSiswa = $selectedItem->siswa->nisn ?? '-';
                    $waliKelas = $selectedItem->siswa->kelas->waliKelas->name ?? 'Wali Kelas';
                    $jenisSurat = ucfirst($selectedItem->jenis ?? 'Sakit');
                    $alasan = $selectedItem->alasan ?? 'Tidak ada keterangan';
                    $statusVerif = strtoupper($selectedItem->status_verifikasi ?? 'PENDING');
                    $tglMulai = $selectedItem->tanggal_mulai ? \Carbon\Carbon::parse($selectedItem->tanggal_mulai)->format('d M Y') : '-';
                    $tglSelesai = $selectedItem->tanggal_selesai ? \Carbon\Carbon::parse($selectedItem->tanggal_selesai) : null;
                    $durasiHari = ($tglMulai && $tglSelesai) ? (\Carbon\Carbon::parse($selectedItem->tanggal_mulai)->diffInDays($selectedItem->tanggal_selesai) + 1) . ' Hari' : '1 Hari';
                    $fileUrl = $selectedItem->file_surat ? asset('storage/' . $selectedItem->file_surat) : null;
                @endphp
                <div x-data="{ decision: 'valid' }" class="space-y-4 rounded-xl border border-slate-200 bg-white p-5 shadow-sm">
                    
                    {{-- Header Detail Siswa --}}
                    <div class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between border-b border-slate-100 pb-4">
                        <div class="flex items-center gap-3.5">
                            <span class="grid h-12 w-12 shrink-0 place-items-center rounded-xl bg-blue-600 text-lg font-bold text-white shadow-sm">{{ $initials }}</span>
                            <div>
                                <h2 class="text-lg font-bold text-slate-900">{{ $namaSiswa }}</h2>
                                <p class="text-xs text-slate-500">NISN: {{ $nisnSiswa }}</p>
                            </div>
                        </div>
                        <div class="flex items-center gap-4 text-xs">
                            <div class="rounded-lg bg-slate-50 border border-slate-100 px-3 py-2">
                                <p class="text-[10px] font-medium text-slate-400 uppercase">Kelas</p>
                                <p class="font-bold text-slate-800">{{ $namaKelas }}</p>
                            </div>
                            <div class="rounded-lg bg-slate-50 border border-slate-100 px-3 py-2">
                                <p class="text-[10px] font-medium text-slate-400 uppercase">Wali Kelas</p>
                                <p class="font-bold text-slate-800">{{ $waliKelas }}</p>
                            </div>
                            <div class="rounded-lg bg-slate-50 border border-slate-100 px-3 py-2">
                                <p class="text-[10px] font-medium text-slate-400 uppercase">Orang Tua / Wali</p>
                                <a href="tel:08123456789" class="font-bold text-blue-700 hover:underline">0812-3456-7890</a>
                            </div>
                        </div>
                    </div>

                    {{-- Informasi Ringkas Permohonan --}}
                    <div class="grid grid-cols-4 gap-3 text-xs bg-slate-50 p-3.5 rounded-xl border border-slate-100">
                        <div>
                            <p class="text-[10px] uppercase font-semibold text-slate-400">Jenis Permohonan</p>
                            <p class="font-bold text-slate-800 mt-0.5">{{ $jenisSurat }} (Dokter)</p>
                        </div>
                        <div>
                            <p class="text-[10px] uppercase font-semibold text-slate-400">Rentang Tanggal</p>
                            <p class="font-bold text-slate-800 mt-0.5">{{ $tglMulai }}</p>
                        </div>
                        <div>
                            <p class="text-[10px] uppercase font-semibold text-slate-400">Total Hari Efektif</p>
                            <p class="font-bold text-blue-700 mt-0.5">{{ $durasiHari }}</p>
                        </div>
                        <div>
                            <p class="text-[10px] uppercase font-semibold text-slate-400">Kontak Wali</p>
                            <p class="font-bold text-slate-800 mt-0.5">0812-3456-7890</p>
                        </div>
                    </div>

                    {{-- Pratinjau Dokumen Terlampir --}}
                    <section>
                        <div class="mb-3 flex items-center justify-between">
                            <h3 class="text-sm font-bold text-slate-900 flex items-center gap-1.5">
                                <span>📄</span> Pratinjau Dokumen Surat Terlampir
                            </h3>
                            <a href="#" @click.prevent="alert('Mengunduh berkas dokumen...')" class="rounded-lg bg-indigo-50 px-3 py-1.5 text-xs font-semibold text-blue-700 hover:bg-indigo-100 transition">
                                Unduh Berkas
                            </a>
                        </div>

                        <div class="rounded-xl border border-indigo-100 bg-indigo-50/40 p-4">
                            @if($fileUrl)
                                <div class="text-center">
                                    <img src="{{ $fileUrl }}" alt="Bukti Surat" class="mx-auto max-h-[420px] rounded-lg border shadow-sm bg-white">
                                </div>
                            @else
                                <article class="mx-auto max-w-xl rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
                                    <div class="flex items-center justify-between border-b pb-3">
                                        <div>
                                            <h4 class="text-xs font-extrabold text-slate-900">KLINIK PRATAMA SEHAT MEDIKA</h4>
                                            <p class="text-[10px] text-slate-400">SIP Dokter: 445/098/DKK/SIP/2024 • Jl. Pemuda No. 42</p>
                                        </div>
                                        <span class="rounded bg-blue-50 px-2.5 py-1 text-[10px] font-bold text-blue-700">SURAT KETERANGAN DOKTER</span>
                                    </div>
                                    <div class="mt-4 space-y-3 text-xs text-slate-700">
                                        <p class="italic">Menerangkan dengan sebenarnya bahwa:</p>
                                        <div class="grid grid-cols-[120px_1fr] gap-x-3 gap-y-1 font-medium text-slate-900">
                                            <span class="text-slate-400">Nama Pasien</span>: {{ $namaSiswa }}
                                            <span class="text-slate-400">Kelas / NISN</span>: {{ $namaKelas }} / {{ $nisnSiswa }}
                                            <span class="text-slate-400">Diagnosa</span>: {{ $alasan }}
                                            <span class="text-slate-400">Keterangan</span>: Perlu diberikan istirahat selama {{ $durasiHari }} terhitung mulai tanggal tersebut.
                                        </div>
                                    </div>
                                </article>
                            @endif
                        </div>
                    </section>

                    {{-- Blok Keputusan Tata Usaha --}}
                    <div class="border-t pt-4">
                        <div class="flex items-center justify-between mb-3">
                            <h3 class="text-sm font-bold text-slate-900">Blok Keputusan Tata Usaha</h3>
                            <span class="text-[11px] text-slate-400">Status Saat Ini: <strong class="uppercase text-blue-600">{{ $statusVerif }}</strong></span>
                        </div>

                        <div class="grid grid-cols-2 gap-3 mb-4">
                            <button type="button" @click="decision = 'valid'"
                                :class="decision === 'valid' ? 'ring-2 ring-emerald-400 bg-emerald-100/80 border-emerald-300' : 'bg-emerald-50/60 border-emerald-100'"
                                class="rounded-xl p-3.5 text-left border transition hover:bg-emerald-100 cursor-pointer">
                                <span class="block text-sm font-bold text-emerald-900">✅ Surat Valid</span>
                                <span class="text-[11px] text-emerald-700">Setujui &amp; Perbarui Absensi Siswa</span>
                            </button>
                            <button type="button" @click="decision = 'invalid'"
                                :class="decision === 'invalid' ? 'ring-2 ring-rose-400 bg-rose-100/80 border-rose-300' : 'bg-rose-50/60 border-rose-100'"
                                class="rounded-xl p-3.5 text-left border transition hover:bg-rose-100 cursor-pointer">
                                <span class="block text-sm font-bold text-rose-800">❌ Surat Tidak Valid</span>
                                <span class="text-[11px] text-rose-700">Tolak &amp; Minta Perbaikan Dokumen</span>
                            </button>
                        </div>

                        {{-- Form Konfirmasi Persetujuan (Approve) --}}
                        <form x-show="decision === 'valid'" action="{{ route('admin.absensi.surat.approve', $selectedItem->id) }}" method="POST" class="rounded-xl border border-emerald-200 bg-emerald-50/50 p-4 space-y-3">
                            @csrf
                            <div class="flex items-center justify-between">
                                <p class="text-xs font-bold text-emerald-900">Form Konfirmasi Persetujuan Surat Absensi</p>
                                <span class="rounded bg-emerald-100 px-2 py-0.5 text-[10px] font-bold text-emerald-800">Status: {{ $statusVerif }}</span>
                            </div>
                            
                            <div>
                                <label class="block text-[11px] font-bold text-slate-700 mb-1">Pilih Kategori Keterangan Absensi Master:</label>
                                <div class="flex items-center gap-6 text-xs font-medium text-slate-800">
                                    <label class="flex items-center gap-2 cursor-pointer">
                                        <input type="radio" name="kategori_master" value="sakit" checked class="text-emerald-600 focus:ring-emerald-500"> Sakit Resmi (S)
                                    </label>
                                    <label class="flex items-center gap-2 cursor-pointer">
                                        <input type="radio" name="kategori_master" value="izin" class="text-emerald-600 focus:ring-emerald-500"> Izin Tertulis (I)
                                    </label>
                                    <label class="flex items-center gap-2 cursor-pointer">
                                        <input type="radio" name="kategori_master" value="disensasi" class="text-emerald-600 focus:ring-emerald-500"> Dispensasi (D)
                                    </label>
                                </div>
                            </div>

                            <button type="submit" class="w-full rounded-xl bg-emerald-700 hover:bg-emerald-800 px-4 py-2.5 text-xs font-bold text-white shadow transition flex items-center justify-center gap-2 cursor-pointer">
                                <span>💾 Simpan &amp; Setujui Persetujuan Surat</span>
                            </button>
                        </form>

                        {{-- Form Konfirmasi Penolakan (Reject) --}}
                        <form x-show="decision === 'invalid'" action="{{ route('admin.absensi.surat.reject', $selectedItem->id) }}" method="POST" class="rounded-xl border border-rose-200 bg-rose-50/50 p-4 space-y-3">
                            @csrf
                            <p class="text-xs font-bold text-rose-900">Alasan Penolakan / Catatan Perbaikan Dokumen:</p>
                            <textarea name="catatan" rows="2" required placeholder="Tulis catatan penolakan untuk wali murid..." class="w-full rounded-lg border border-slate-300 p-2.5 text-xs bg-white focus:ring-2 focus:ring-rose-500 focus:outline-none"></textarea>
                            
                            <button type="submit" class="w-full rounded-xl bg-rose-600 hover:bg-rose-700 px-4 py-2.5 text-xs font-bold text-white shadow transition flex items-center justify-center gap-2 cursor-pointer">
                                <span>📤 Kirim Penolakan &amp; Notifikasi ke Siswa</span>
                            </button>
                        </form>
                    </div>
                </div>
            @else
                <div class="rounded-xl border border-slate-200 bg-white p-8 text-center text-sm text-slate-500 shadow-sm">
                    Belum ada data detail surat yang dipilih.
                </div>
            @endif
        </section>
    </main>
</div>
@endsection
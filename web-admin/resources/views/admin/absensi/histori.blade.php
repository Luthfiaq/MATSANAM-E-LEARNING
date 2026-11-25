@extends('layouts.admin')

@section('title', 'Histori Verifikasi Surat')

@section('content')
<div class="space-y-6">
    <div class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
            <p class="text-xs font-semibold uppercase tracking-wider text-blue-600">Verifikasi &amp; Izin</p>
            <h1 class="mt-1 text-2xl font-bold text-gray-900">Histori Verifikasi Surat</h1>
            <p class="mt-1 text-sm text-gray-500">Arsip pengajuan izin dan sakit beserta alasan serta catatan keputusan verifikasi.</p>
        </div>
        <a href="{{ route('admin.absensi.histori.export', request()->query()) }}"
           class="inline-flex items-center justify-center rounded-lg bg-blue-600 px-4 py-2.5 text-sm font-semibold text-white shadow-sm transition hover:bg-blue-700">
            <span class="mr-2">↓</span> Export CSV
        </a>
    </div>

    <div class="grid grid-cols-2 gap-3 lg:grid-cols-4">
        <div class="rounded-xl border border-gray-200 bg-white p-4 shadow-sm">
            <p class="text-xs font-medium text-gray-500">Semua Pengajuan</p>
            <p class="mt-2 text-2xl font-bold text-gray-900">{{ number_format($totalSemua) }}</p>
        </div>
        <div class="rounded-xl border border-amber-100 bg-white p-4 shadow-sm">
            <p class="text-xs font-medium text-gray-500">Pending</p>
            <p class="mt-2 text-2xl font-bold text-amber-600">{{ number_format($totalPending) }}</p>
        </div>
        <div class="rounded-xl border border-green-100 bg-white p-4 shadow-sm">
            <p class="text-xs font-medium text-gray-500">Disetujui</p>
            <p class="mt-2 text-2xl font-bold text-green-600">{{ number_format($totalDisetujui) }}</p>
        </div>
        <div class="rounded-xl border border-red-100 bg-white p-4 shadow-sm">
            <p class="text-xs font-medium text-gray-500">Ditolak</p>
            <p class="mt-2 text-2xl font-bold text-red-600">{{ number_format($totalDitolak) }}</p>
        </div>
    </div>

    <div class="rounded-xl border border-gray-200 bg-white p-4 shadow-sm">
        <form method="GET" action="{{ route('admin.absensi.histori') }}" class="space-y-4">
            <div class="grid grid-cols-1 gap-3 md:grid-cols-2 xl:grid-cols-4">
                <div class="xl:col-span-2">
                    <label for="q" class="mb-1.5 block text-xs font-semibold text-gray-600">Pencarian siswa</label>
                    <input id="q" name="q" type="search" value="{{ $filters['q'] ?? '' }}"
                           placeholder="Cari nama, NIS, atau NISN..."
                           class="w-full rounded-lg border border-gray-300 px-3 py-2.5 text-sm outline-none transition focus:border-blue-500 focus:ring-2 focus:ring-blue-100">
                </div>
                <div>
                    <label for="status" class="mb-1.5 block text-xs font-semibold text-gray-600">Status verifikasi</label>
                    <select id="status" name="status" class="w-full rounded-lg border border-gray-300 px-3 py-2.5 text-sm outline-none focus:border-blue-500">
                        <option value="semua" @selected(($filters['status'] ?? 'semua') === 'semua')>Semua status</option>
                        <option value="pending" @selected(($filters['status'] ?? '') === 'pending')>Pending</option>
                        <option value="disetujui" @selected(($filters['status'] ?? '') === 'disetujui')>Disetujui</option>
                        <option value="ditolak" @selected(($filters['status'] ?? '') === 'ditolak')>Ditolak</option>
                    </select>
                </div>
                <div>
                    <label for="kelas" class="mb-1.5 block text-xs font-semibold text-gray-600">Kelas</label>
                    <select id="kelas" name="kelas" class="w-full rounded-lg border border-gray-300 px-3 py-2.5 text-sm outline-none focus:border-blue-500">
                        <option value="">Semua kelas</option>
                        @foreach($kelasList as $kelas)
                            <option value="{{ $kelas->id }}" @selected((string) ($filters['kelas'] ?? '') === (string) $kelas->id)>{{ $kelas->nama_kelas }}</option>
                        @endforeach
                    </select>
                </div>
                <div>
                    <label for="jenis" class="mb-1.5 block text-xs font-semibold text-gray-600">Jenis pengajuan</label>
                    <select id="jenis" name="jenis" class="w-full rounded-lg border border-gray-300 px-3 py-2.5 text-sm outline-none focus:border-blue-500">
                        <option value="">Semua jenis</option>
                        <option value="sakit" @selected(($filters['jenis'] ?? '') === 'sakit')>Sakit</option>
                        <option value="izin" @selected(($filters['jenis'] ?? '') === 'izin')>Izin</option>
                    </select>
                </div>
                <div>
                    <label for="semester" class="mb-1.5 block text-xs font-semibold text-gray-600">Semester</label>
                    <select id="semester" name="semester" class="w-full rounded-lg border border-gray-300 px-3 py-2.5 text-sm outline-none focus:border-blue-500">
                        <option value="">Semua semester</option>
                        <option value="1" @selected(($filters['semester'] ?? '') === '1')>Semester 1 (Juli–Desember)</option>
                        <option value="2" @selected(($filters['semester'] ?? '') === '2')>Semester 2 (Januari–Juni)</option>
                    </select>
                </div>
                <div>
                    <label for="tahun" class="mb-1.5 block text-xs font-semibold text-gray-600">Tahun</label>
                    <input id="tahun" name="tahun" type="number" min="2000" max="2100" value="{{ $filters['tahun'] ?? '' }}"
                           placeholder="Semua tahun"
                           class="w-full rounded-lg border border-gray-300 px-3 py-2.5 text-sm outline-none focus:border-blue-500">
                </div>
            </div>
            <div class="flex flex-wrap items-center gap-2">
                <button type="submit" class="rounded-lg bg-blue-600 px-4 py-2 text-sm font-semibold text-white transition hover:bg-blue-700">Terapkan Filter</button>
                <a href="{{ route('admin.absensi.histori') }}" class="rounded-lg border border-gray-300 px-4 py-2 text-sm font-semibold text-gray-700 transition hover:bg-gray-50">Reset</a>
                <span class="ml-auto text-xs text-gray-500">{{ $surats->total() }} data ditemukan</span>
            </div>
        </form>
    </div>

    <div class="overflow-hidden rounded-xl border border-gray-200 bg-white shadow-sm">
        <div class="border-b border-gray-200 px-4 py-3 sm:px-5">
            <h2 class="text-sm font-bold text-gray-900">Daftar Histori Pengajuan</h2>
            <p class="mt-1 text-xs text-gray-500">Alasan pengajuan dan catatan penolakan ditampilkan untuk kebutuhan audit.</p>
        </div>
        <div class="overflow-x-auto">
            <table class="min-w-[1450px] divide-y divide-gray-200 text-left">
                <thead class="bg-gray-50">
                    <tr>
                        <th class="px-4 py-3 text-[11px] font-bold uppercase tracking-wide text-gray-500">ID / Tanggal</th>
                        <th class="px-4 py-3 text-[11px] font-bold uppercase tracking-wide text-gray-500">Siswa</th>
                        <th class="px-4 py-3 text-[11px] font-bold uppercase tracking-wide text-gray-500">Pengajuan</th>
                        <th class="px-4 py-3 text-[11px] font-bold uppercase tracking-wide text-gray-500">Alasan Pengajuan</th>
                        <th class="px-4 py-3 text-[11px] font-bold uppercase tracking-wide text-gray-500">Status</th>
                        <th class="px-4 py-3 text-[11px] font-bold uppercase tracking-wide text-gray-500">Catatan Verifikasi</th>
                        <th class="px-4 py-3 text-[11px] font-bold uppercase tracking-wide text-gray-500">Verifikator</th>
                        <th class="px-4 py-3 text-[11px] font-bold uppercase tracking-wide text-gray-500">Dokumen</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-100 bg-white">
                    @forelse($surats as $surat)
                        @php
                            $statusKey = strtolower((string) $surat->status_verifikasi);
                            $statusStyles = [
                                'pending' => 'bg-amber-50 text-amber-700 ring-amber-200',
                                'disetujui' => 'bg-green-50 text-green-700 ring-green-200',
                                'ditolak' => 'bg-red-50 text-red-700 ring-red-200',
                            ];
                            $statusLabels = ['pending' => 'Pending', 'disetujui' => 'Disetujui', 'ditolak' => 'Ditolak'];
                        @endphp
                        <tr class="align-top hover:bg-gray-50/70">
                            <td class="whitespace-nowrap px-4 py-4">
                                <div class="text-xs font-bold text-gray-900">#{{ $surat->id }}</div>
                                <div class="mt-1 text-xs text-gray-500">{{ $surat->created_at?->format('d M Y') ?? '-' }}</div>
                                <div class="text-[11px] text-gray-400">{{ $surat->created_at?->format('H:i') ?? '' }}</div>
                            </td>
                            <td class="px-4 py-4">
                                <div class="min-w-[170px]">
                                    <div class="text-sm font-semibold text-gray-900">{{ $surat->siswa?->nama_lengkap ?? 'Data siswa tidak tersedia' }}</div>
                                    <div class="mt-1 text-xs text-gray-500">NIS: {{ $surat->siswa?->nis ?? '-' }} · NISN: {{ $surat->siswa?->nisn ?? '-' }}</div>
                                    <div class="mt-1 text-xs text-blue-700">{{ $surat->siswa?->kelas?->nama_kelas ?? 'Tanpa kelas' }}</div>
                                </div>
                            </td>
                            <td class="px-4 py-4">
                                <div class="text-sm font-semibold capitalize text-gray-800">{{ $surat->jenis }}</div>
                                <div class="mt-1 whitespace-nowrap text-xs text-gray-500">{{ $surat->tanggal_mulai?->format('d M Y') ?? '-' }}</div>
                                <div class="text-xs text-gray-500">s.d. {{ $surat->tanggal_selesai?->format('d M Y') ?? '-' }}</div>
                            </td>
                            <td class="max-w-[240px] px-4 py-4">
                                <p class="whitespace-normal break-words text-xs leading-5 text-gray-700">{{ $surat->alasan ?: 'Tidak ada alasan tertulis.' }}</p>
                            </td>
                            <td class="px-4 py-4">
                                <span class="inline-flex whitespace-nowrap rounded-full px-2.5 py-1 text-[11px] font-semibold ring-1 ring-inset {{ $statusStyles[$statusKey] ?? 'bg-gray-50 text-gray-600 ring-gray-200' }}">
                                    {{ $statusLabels[$statusKey] ?? ucfirst($statusKey ?: 'Tidak diketahui') }}
                                </span>
                            </td>
                            <td class="max-w-[250px] px-4 py-4">
                                @if($statusKey === 'ditolak')
                                    <p class="whitespace-normal break-words text-xs leading-5 text-red-700">{{ $surat->catatan_verifikasi ?: 'Alasan penolakan belum dicatat.' }}</p>
                                @elseif($surat->catatan_verifikasi)
                                    <p class="whitespace-normal break-words text-xs leading-5 text-gray-600">{{ $surat->catatan_verifikasi }}</p>
                                @else
                                    <span class="text-xs text-gray-400">—</span>
                                @endif
                            </td>
                            <td class="px-4 py-4">
                                <div class="whitespace-nowrap text-xs text-gray-700">{{ $surat->verifikator?->name ?? 'Belum diverifikasi' }}</div>
                                <div class="mt-1 whitespace-nowrap text-[11px] text-gray-400">{{ $surat->tanggal_verifikasi?->format('d M Y, H:i') ?? '-' }}</div>
                            </td>
                            <td class="px-4 py-4">
                                @if($surat->file_surat)
                                    <div class="flex min-w-[130px] flex-col items-start gap-2">
                                        <a href="{{ route('admin.absensi.surat.file', ['id' => $surat->id]) }}" target="_blank" rel="noopener noreferrer"
                                           class="text-xs font-semibold text-blue-700 hover:underline">Lihat dokumen</a>
                                        <a href="{{ route('admin.absensi.surat.file', ['id' => $surat->id, 'download' => 1]) }}"
                                           class="text-xs font-semibold text-gray-600 hover:text-blue-700">Unduh berkas</a>
                                    </div>
                                @else
                                    <span class="text-xs text-gray-400">Tanpa lampiran</span>
                                @endif
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="8" class="px-6 py-14 text-center">
                                <div class="text-3xl">📭</div>
                                <p class="mt-3 text-sm font-semibold text-gray-700">Tidak ada histori yang cocok</p>
                                <p class="mt-1 text-xs text-gray-500">Coba ubah kata kunci atau filter yang digunakan.</p>
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        @if($surats->hasPages())
            <div class="border-t border-gray-200 px-4 py-4 sm:px-5">
                {{ $surats->links() }}
            </div>
        @endif
    </div>
</div>
@endsection

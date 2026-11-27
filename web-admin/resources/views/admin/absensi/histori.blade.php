@extends('layouts.admin')

@section('title', 'Histori Verifikasi Surat')

@section('content')
<div class="space-y-6">
    <div class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
            <p class="text-xs font-semibold uppercase tracking-wider text-blue-600">Verifikasi &amp; Izin</p>
            <h1 class="mt-1 text-2xl font-bold text-gray-900">Histori Verifikasi Surat Absensi</h1>
            <p class="mt-1 text-sm text-gray-500">Arsip pengajuan izin dan sakit beserta alasan serta catatan keputusan verifikasi.</p>
        </div>
        <a href="{{ route('admin.absensi.histori.export', request()->query()) }}"
           class="inline-flex items-center justify-center rounded-lg bg-blue-600 px-4 py-2.5 text-sm font-semibold text-white shadow-sm transition hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2">
            <span class="mr-2">↓</span> Export Log (.csv)
        </a>
    </div>

    <div class="grid grid-cols-2 gap-3 lg:grid-cols-4">
        <div class="rounded-xl border border-gray-200 bg-white p-4 shadow-sm">
            <p class="text-xs font-medium text-gray-500">Total Surat Diproses</p>
            <p class="mt-2 text-2xl font-bold text-gray-900">{{ number_format($totalSemua) }}</p>
            <p class="mt-1 text-xs text-gray-400">Seluruh arsip surat absensi</p>
        </div>
        <div class="rounded-xl border border-amber-100 bg-white p-4 shadow-sm">
            <p class="text-xs font-medium text-gray-500">Pending</p>
            <p class="mt-2 text-2xl font-bold text-amber-600">{{ number_format($totalPending) }}</p>
            <p class="mt-1 text-xs text-gray-400">Menunggu verifikasi</p>
        </div>
        <div class="rounded-xl border border-green-100 bg-white p-4 shadow-sm">
            <p class="text-xs font-medium text-gray-500">Disetujui</p>
            <p class="mt-2 text-2xl font-bold text-green-600">{{ number_format($totalDisetujui) }}</p>
            <p class="mt-1 text-xs text-gray-400">Pengajuan disahkan</p>
        </div>
        <div class="rounded-xl border border-red-100 bg-white p-4 shadow-sm">
            <p class="text-xs font-medium text-gray-500">Ditolak / Gugur</p>
            <p class="mt-2 text-2xl font-bold text-red-600">{{ number_format($totalDitolak) }}</p>
            <p class="mt-1 text-xs text-gray-400">Pengajuan ditolak</p>
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
            <h2 class="text-sm font-bold text-gray-900">Daftar Audit Dokumen Verifikasi</h2>
            <p class="mt-1 text-xs text-gray-500">Menampilkan {{ $surats->count() }} dari {{ $surats->total() }} arsip pada hasil pencarian. Pilih Lihat Detail untuk membuka dokumen dalam popup.</p>
        </div>
        <div class="overflow-x-auto">
            <table class="min-w-[1050px] w-full divide-y divide-gray-200 text-left">
                <thead class="bg-gray-50">
                    <tr>
                        <th class="px-4 py-3 text-[11px] font-bold uppercase tracking-wide text-gray-500">No &amp; ID Berkas</th>
                        <th class="px-4 py-3 text-[11px] font-bold uppercase tracking-wide text-gray-500">Siswa &amp; Rombel</th>
                        <th class="px-4 py-3 text-[11px] font-bold uppercase tracking-wide text-gray-500">Jenis &amp; Durasi Izin</th>
                        <th class="px-4 py-3 text-[11px] font-bold uppercase tracking-wide text-gray-500">Status Keputusan</th>
                        <th class="px-4 py-3 text-[11px] font-bold uppercase tracking-wide text-gray-500">Catatan</th>
                        <th class="px-4 py-3 text-center text-[11px] font-bold uppercase tracking-wide text-gray-500">Detail</th>
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
                            $berkasId = 'VRF-' . ($surat->created_at?->format('Y') ?? now()->format('Y')) . '-' . str_pad((string) $surat->id, 4, '0', STR_PAD_LEFT);
                        @endphp
                        <tr class="align-top transition hover:bg-gray-50/70">
                            <td class="whitespace-nowrap px-4 py-4">
                                <div class="text-xs font-semibold text-gray-500">#{{ $surats->firstItem() + $loop->index }}</div>
                                <div class="mt-1 text-xs font-bold text-blue-700">{{ $berkasId }}</div>
                            </td>
                            <td class="px-4 py-4">
                                <div class="min-w-[185px]">
                                    <div class="text-sm font-semibold text-gray-900">{{ $surat->siswa?->nama_lengkap ?? 'Data siswa tidak tersedia' }}</div>
                                    <div class="mt-1 text-xs text-gray-500">{{ $surat->siswa?->kelas?->nama_kelas ?? 'Tanpa kelas' }}</div>
                                    <div class="mt-1 text-[11px] text-gray-400">NISN: {{ $surat->siswa?->nisn ?? '-' }}</div>
                                </div>
                            </td>
                            <td class="px-4 py-4">
                                <div class="text-sm font-semibold capitalize text-gray-800">{{ $surat->jenis }}</div>
                                <div class="mt-1 whitespace-nowrap text-xs text-gray-500">{{ $surat->tanggal_mulai?->format('d M Y') ?? '-' }}</div>
                                <div class="text-xs text-gray-500">s.d. {{ $surat->tanggal_selesai?->format('d M Y') ?? '-' }}</div>
                            </td>
                            <td class="px-4 py-4">
                                <span class="inline-flex whitespace-nowrap rounded-full px-2.5 py-1 text-[11px] font-semibold ring-1 ring-inset {{ $statusStyles[$statusKey] ?? 'bg-gray-50 text-gray-600 ring-gray-200' }}">
                                    {{ $statusLabels[$statusKey] ?? ucfirst($statusKey ?: 'Tidak diketahui') }}
                                </span>
                            </td>
                            <td class="max-w-[240px] px-4 py-4">
                                @if($statusKey === 'ditolak')
                                    <p class="line-clamp-2 break-words text-xs leading-5 text-red-700">{{ $surat->catatan_verifikasi ?: 'Alasan penolakan belum dicatat.' }}</p>
                                @elseif($surat->catatan_verifikasi)
                                    <p class="line-clamp-2 break-words text-xs leading-5 text-gray-600">{{ $surat->catatan_verifikasi }}</p>
                                @else
                                    <span class="text-xs text-gray-400">—</span>
                                @endif
                            </td>
                            <td class="px-4 py-4 text-center">
                                <button type="button"
                                        data-open-surat-detail
                                        data-template-id="surat-detail-template-{{ $surat->id }}"
                                        class="inline-flex items-center justify-center rounded-lg border border-blue-100 bg-blue-50 px-3 py-2 text-xs font-semibold text-blue-700 transition hover:bg-blue-100 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2">
                                    Lihat Detail
                                </button>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="6" class="px-6 py-14 text-center">
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

{{-- Konten detail dirender oleh Blade agar seluruh nilai tetap di-escape oleh Laravel. --}}
<div class="hidden" aria-hidden="true">
    @foreach($surats as $surat)
        @php
            $statusKey = strtolower((string) $surat->status_verifikasi);
            $statusStyles = [
                'pending' => 'bg-amber-50 text-amber-700 ring-amber-200',
                'disetujui' => 'bg-green-50 text-green-700 ring-green-200',
                'ditolak' => 'bg-red-50 text-red-700 ring-red-200',
            ];
            $statusLabels = ['pending' => 'Pending', 'disetujui' => 'Disetujui', 'ditolak' => 'Ditolak'];
            $berkasId = 'VRF-' . ($surat->created_at?->format('Y') ?? now()->format('Y')) . '-' . str_pad((string) $surat->id, 4, '0', STR_PAD_LEFT);
        @endphp
        <template id="surat-detail-template-{{ $surat->id }}">
            <div class="space-y-0">
                <div class="border-b border-gray-100 py-3">
                    <p class="text-[11px] font-semibold text-gray-400">ID Berkas</p>
                    <p class="mt-1 text-sm font-medium text-gray-900">{{ $berkasId }}</p>
                </div>
                <div class="border-b border-gray-100 py-3">
                    <p class="text-[11px] font-semibold text-gray-400">Nama Siswa</p>
                    <p class="mt-1 text-sm font-medium text-gray-900">{{ $surat->siswa?->nama_lengkap ?? 'Data siswa tidak tersedia' }}</p>
                </div>
                <div class="grid grid-cols-1 gap-3 border-b border-gray-100 py-3 sm:grid-cols-2">
                    <div>
                        <p class="text-[11px] font-semibold text-gray-400">NIS</p>
                        <p class="mt-1 text-sm text-gray-800">{{ $surat->siswa?->nis ?? '-' }}</p>
                    </div>
                    <div>
                        <p class="text-[11px] font-semibold text-gray-400">NISN</p>
                        <p class="mt-1 text-sm text-gray-800">{{ $surat->siswa?->nisn ?? '-' }}</p>
                    </div>
                </div>
                <div class="border-b border-gray-100 py-3">
                    <p class="text-[11px] font-semibold text-gray-400">Kelas</p>
                    <p class="mt-1 text-sm text-gray-800">{{ $surat->siswa?->kelas?->nama_kelas ?? 'Tanpa kelas' }}</p>
                </div>
                <div class="border-b border-gray-100 py-3">
                    <p class="text-[11px] font-semibold text-gray-400">Jenis Surat</p>
                    <p class="mt-1 text-sm capitalize text-gray-800">{{ $surat->jenis }}</p>
                </div>
                <div class="grid grid-cols-1 gap-3 border-b border-gray-100 py-3 sm:grid-cols-2">
                    <div>
                        <p class="text-[11px] font-semibold text-gray-400">Tanggal Mulai</p>
                        <p class="mt-1 text-sm text-gray-800">{{ $surat->tanggal_mulai?->format('d M Y') ?? '-' }}</p>
                    </div>
                    <div>
                        <p class="text-[11px] font-semibold text-gray-400">Tanggal Selesai</p>
                        <p class="mt-1 text-sm text-gray-800">{{ $surat->tanggal_selesai?->format('d M Y') ?? '-' }}</p>
                    </div>
                </div>
                <div class="border-b border-gray-100 py-3">
                    <p class="text-[11px] font-semibold text-gray-400">Alasan Pengajuan</p>
                    <p class="mt-1 whitespace-pre-line break-words text-sm leading-6 text-gray-800">{{ $surat->alasan ?: 'Tidak ada alasan tertulis.' }}</p>
                </div>
                <div class="border-b border-gray-100 py-3">
                    <p class="text-[11px] font-semibold text-gray-400">Waktu Verifikasi</p>
                    <p class="mt-1 text-sm text-gray-800">{{ $surat->tanggal_verifikasi?->format('d M Y H:i') ?? 'Belum diverifikasi' }}</p>
                </div>
                <div class="border-b border-gray-100 py-3">
                    <p class="text-[11px] font-semibold text-gray-400">Status Keputusan</p>
                    <span class="mt-2 inline-flex rounded-full px-2.5 py-1 text-xs font-semibold ring-1 ring-inset {{ $statusStyles[$statusKey] ?? 'bg-gray-50 text-gray-600 ring-gray-200' }}">
                        {{ $statusLabels[$statusKey] ?? ucfirst($statusKey ?: 'Tidak diketahui') }}
                    </span>
                </div>
                <div class="border-b border-gray-100 py-3">
                    <p class="text-[11px] font-semibold text-gray-400">Catatan Verifikasi</p>
                    <p class="mt-1 whitespace-pre-line break-words text-sm leading-6 {{ $statusKey === 'ditolak' ? 'text-red-700' : 'text-gray-800' }}">{{ $surat->catatan_verifikasi ?: '—' }}</p>
                </div>
                <div class="py-3">
                    <p class="text-[11px] font-semibold text-gray-400">Berkas Terlampir</p>
                    @if($surat->file_surat)
                        <div class="mt-2 flex flex-wrap gap-2">
                            <a href="{{ route('admin.absensi.surat.file', ['id' => $surat->id]) }}" target="_blank" rel="noopener noreferrer"
                               class="inline-flex items-center rounded-lg bg-blue-50 px-3 py-2 text-xs font-semibold text-blue-700 transition hover:bg-blue-100">
                                Lihat Berkas
                            </a>
                            <a href="{{ route('admin.absensi.surat.file', ['id' => $surat->id, 'download' => 1]) }}"
                               class="inline-flex items-center rounded-lg border border-gray-200 px-3 py-2 text-xs font-semibold text-gray-700 transition hover:bg-gray-50">
                                Unduh Berkas
                            </a>
                        </div>
                    @else
                        <p class="mt-1 text-sm text-gray-500">Tidak ada berkas terlampir.</p>
                    @endif
                </div>
            </div>
        </template>
    @endforeach
</div>

{{-- Modal detail surat --}}
<div id="surat-detail-modal"
     class="fixed inset-0 z-[100] hidden items-center justify-center bg-slate-950/55 p-3 sm:p-5"
     role="dialog" aria-modal="true" aria-hidden="true" aria-labelledby="surat-detail-title">
    <div class="flex max-h-[88vh] w-full max-w-xl flex-col overflow-hidden rounded-2xl bg-white shadow-2xl">
        <div class="flex shrink-0 items-center justify-between border-b border-gray-100 px-5 py-4">
            <h2 id="surat-detail-title" class="text-base font-semibold text-gray-900">Detail Dokumen Verifikasi</h2>
            <button type="button" data-close-surat-detail
                    class="inline-flex h-9 w-9 items-center justify-center rounded-lg text-gray-500 transition hover:bg-gray-100 hover:text-gray-800 focus:outline-none focus:ring-2 focus:ring-blue-500"
                    aria-label="Tutup detail">
                <svg viewBox="0 0 24 24" class="h-5 w-5" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M6 6l12 12M18 6L6 18" />
                </svg>
            </button>
        </div>
        <div id="surat-detail-content" class="min-h-0 overflow-y-auto px-5 py-1"></div>
    </div>
</div>
@endsection

@push('scripts')
<script>
(() => {
    const modal = document.getElementById('surat-detail-modal');
    const content = document.getElementById('surat-detail-content');
    if (!modal || !content) return;

    let lastFocusedElement = null;

    const openModal = (button) => {
        const templateId = button.getAttribute('data-template-id');
        const template = templateId ? document.getElementById(templateId) : null;
        if (!(template instanceof HTMLTemplateElement)) return;

        content.replaceChildren(template.content.cloneNode(true));
        lastFocusedElement = button;
        modal.classList.remove('hidden');
        modal.classList.add('flex');
        modal.setAttribute('aria-hidden', 'false');
        document.body.classList.add('overflow-hidden');
        modal.querySelector('[data-close-surat-detail]')?.focus();
    };

    const closeModal = () => {
        modal.classList.add('hidden');
        modal.classList.remove('flex');
        modal.setAttribute('aria-hidden', 'true');
        document.body.classList.remove('overflow-hidden');
        content.replaceChildren();
        lastFocusedElement?.focus();
        lastFocusedElement = null;
    };

    document.addEventListener('click', (event) => {
        const openButton = event.target.closest('[data-open-surat-detail]');
        if (openButton) {
            openModal(openButton);
            return;
        }

        if (event.target.closest('[data-close-surat-detail]')) {
            closeModal();
            return;
        }

        if (event.target === modal) closeModal();
    });

    document.addEventListener('keydown', (event) => {
        if (event.key === 'Escape' && !modal.classList.contains('hidden')) {
            closeModal();
        }
    });
})();
</script>
@endpush

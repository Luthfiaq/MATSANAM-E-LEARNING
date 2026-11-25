@extends('layouts.admin')

@section('title', 'Rekap Presensi Siswa')

@section('content')
<div class="mb-6 flex flex-col gap-4">
    <div class="flex flex-col justify-between gap-2 md:flex-row md:items-center">
        <div>
            <h1 class="text-2xl font-bold text-gray-900">Rekap Presensi Siswa</h1>
            <p class="text-sm text-gray-500">Statistik kehadiran siswa berdasarkan periode, tanggal, dan kelas</p>
        </div>
        <div class="flex flex-wrap gap-2">
            <a href="{{ route('admin.absensi.export', ['format' => 'excel', 'periode' => $periode, 'tanggal' => $tanggalFilter, 'kelas' => $request->input('kelas'), 'q' => $search, 'semua_periode' => $semuaPeriode ? 1 : null]) }}"
               class="rounded-lg bg-green-600 px-4 py-2 text-sm font-medium text-white hover:bg-green-700">
                📊 Unduh Excel
            </a>
            <a href="{{ route('admin.absensi.export', ['format' => 'pdf', 'periode' => $periode, 'tanggal' => $tanggalFilter, 'kelas' => $request->input('kelas'), 'q' => $search, 'semua_periode' => $semuaPeriode ? 1 : null]) }}"
               class="rounded-lg bg-red-600 px-4 py-2 text-sm font-medium text-white hover:bg-red-700">
                🖨️ Cetak / PDF
            </a>
        </div>
    </div>

    <form id="rekap-filter-form" method="GET" action="{{ route('admin.absensi.rekap') }}" class="rounded-lg border border-gray-200 bg-white p-4 shadow-sm">
        <input type="hidden" name="semua_periode" id="rekap-semua-periode" value="{{ $semuaPeriode ? '1' : '0' }}">
        <div class="grid grid-cols-1 gap-3 md:grid-cols-2 xl:grid-cols-5 xl:items-end">
            <div>
                <label for="rekap-search" class="mb-1.5 block text-xs font-semibold text-gray-600">Cari Nama / NIS / NISN</label>
                <input id="rekap-search" type="search" name="q" value="{{ $search }}"
                       placeholder="Masukkan nama atau nomor induk..."
                       class="w-full rounded-lg border border-gray-300 px-3 py-2.5 text-sm focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-100">
            </div>
            <div>
                <label for="rekap-periode" class="mb-1.5 block text-xs font-semibold text-gray-600">Periode Bulanan</label>
                <input id="rekap-periode" type="month" name="periode" value="{{ $semuaPeriode ? '' : ($periode ?? '') }}"
                       class="w-full rounded-lg border border-gray-300 px-3 py-2.5 text-sm focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-100">
            </div>
            <div>
                <label for="rekap-tanggal" class="mb-1.5 block text-xs font-semibold text-gray-600">Tanggal Harian</label>
                <input id="rekap-tanggal" type="date" name="tanggal" value="{{ $tanggalFilter ?? '' }}"
                       class="w-full rounded-lg border border-gray-300 px-3 py-2.5 text-sm focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-100">
            </div>
            <div>
                <label for="rekap-kelas" class="mb-1.5 block text-xs font-semibold text-gray-600">Filter Kelas</label>
                <select id="rekap-kelas" name="kelas"
                        class="w-full rounded-lg border border-gray-300 px-3 py-2.5 text-sm focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-100">
                    <option value="">Semua Kelas</option>
                    @foreach($kelasList as $kelas)
                        <option value="{{ $kelas->id }}" {{ (string) $request->input('kelas') === (string) $kelas->id ? 'selected' : '' }}>
                            {{ $kelas->nama_kelas }}
                        </option>
                    @endforeach
                </select>
            </div>
            <div class="flex gap-2">
                <button type="submit" class="flex-1 rounded-lg bg-blue-600 px-4 py-2.5 text-sm font-semibold text-white hover:bg-blue-700">Terapkan</button>
                <button type="button" id="rekap-reset-all" class="rounded-lg border border-gray-300 px-4 py-2.5 text-sm font-semibold text-gray-600 hover:bg-gray-50">Reset</button>
            </div>
        </div>
        <div class="mt-3 flex flex-wrap items-center gap-2">
            <span class="mr-1 text-xs font-semibold text-gray-500">Filter cepat:</span>
            <button type="button" id="rekap-hari-ini" class="rounded-lg border border-blue-200 px-3 py-1.5 text-xs font-semibold text-blue-700 hover:bg-blue-50">Hari Ini</button>
            @if($semuaPeriode)
                <span class="text-xs text-gray-500">Menampilkan semua periode.</span>
            @endif
        </div>
    </form>
</div>

<div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
    <div class="bg-white p-4 rounded-lg shadow-sm">
        <div class="text-gray-500 text-xs mb-1">Hadir</div>
        <div class="text-3xl font-bold text-green-600">{{ $totalHadir }}</div>
        <div class="text-xs text-gray-400 mt-1">
            {{ $total > 0 ? round(($totalHadir / $total) * 100, 1) : 0 }}% dari total
        </div>
    </div>
    <div class="bg-white p-4 rounded-lg shadow-sm">
        <div class="text-gray-500 text-xs mb-1">Sakit</div>
        <div class="text-3xl font-bold text-red-600">{{ $totalSakit }}</div>
        <div class="text-xs text-gray-400 mt-1">
            {{ $total > 0 ? round(($totalSakit / $total) * 100, 1) : 0 }}% dari total
        </div>
    </div>
    <div class="bg-white p-4 rounded-lg shadow-sm">
        <div class="text-gray-500 text-xs mb-1">Izin</div>
        <div class="text-3xl font-bold text-amber-600">{{ $totalIzin }}</div>
        <div class="text-xs text-gray-400 mt-1">
            {{ $total > 0 ? round(($totalIzin / $total) * 100, 1) : 0 }}% dari total
        </div>
    </div>
    <div class="bg-white p-4 rounded-lg shadow-sm">
        <div class="text-gray-500 text-xs mb-1">Alpa</div>
        <div class="text-3xl font-bold text-red-800">{{ $totalAlpa }}</div>
        <div class="text-xs text-gray-400 mt-1">
            {{ $total > 0 ? round(($totalAlpa / $total) * 100, 1) : 0 }}% dari total
        </div>
    </div>
</div>

<div class="bg-white rounded-lg shadow-sm overflow-hidden mb-6">
    <div class="px-6 py-4 border-b border-gray-200">
        <div class="flex justify-between items-center">
            <h3 class="text-lg font-semibold text-gray-900">Detail Presensi</h3>
            <span class="text-sm text-gray-500">Menampilkan {{ $absensis->total() }} data</span>
        </div>
    </div>

    <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
                <tr>
                    <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Siswa</th>
                    <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Kelas</th>
                    <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Mata Pelajaran</th>
                    <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Guru</th>
                    <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Tanggal</th>
                    <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Status</th>
                    <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Keterangan</th>
                </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
                @forelse($absensis as $absen)
                <tr class="hover:bg-gray-50">
                    <td class="px-6 py-4">
                        <div class="text-sm font-medium text-gray-900">{{ $absen->siswa->nama_lengkap }}</div>
                        <div class="text-xs text-gray-500">NISN: {{ $absen->siswa->nisn }}</div>
                    </td>
                    <td class="px-6 py-4">
                        <span class="inline-flex rounded-full bg-blue-50 px-2 py-1 text-xs font-medium text-blue-700">
                            {{ $absen->jadwal->kelas->nama_kelas ?? '-' }}
                        </span>
                    </td>
                    <td class="px-6 py-4 text-sm text-gray-600">
                        {{ $absen->jadwal->mataPelajaran->nama ?? '-' }}
                    </td>
                    <td class="px-6 py-4 text-sm text-gray-600">
                        {{ $absen->jadwal->guru->nama_lengkap ?? '-' }}
                    </td>
                    <td class="px-6 py-4 text-sm text-gray-600">
                        {{ $absen->tanggal->format('d M Y') }}
                    </td>
                    <td class="px-6 py-4">
                        @php
                            $statusMap = [
                                'hadir' => ['bg-green-50 text-green-700', '✓ Hadir'],
                                'sakit' => ['bg-red-50 text-red-700', '🤒 Sakit'],
                                'izin' => ['bg-amber-50 text-amber-700', '📄 Izin'],
                                'alpa' => ['bg-red-800 text-red-100', '❌ Alpa'],
                            ];
                            $status = $statusMap[$absen->status] ?? ['bg-gray-50 text-gray-700', '-'];
                        @endphp
                        <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium {{ $status[0] }}">
                            {{ $status[1] }}
                        </span>
                    </td>
                    <td class="px-6 py-4 text-sm text-gray-600">
                        {{ $absen->keterangan ?: '-' }}
                    </td>
                </tr>
                @empty
                <tr>
                    <td colspan="7" class="px-6 py-12 text-center text-gray-500">
                        <div class="flex flex-col items-center gap-2">
                            <span class="text-4xl">📋</span>
                            <span>Tidak ada data presensi</span>
                        </div>
                    </td>
                </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    @if($absensis->hasPages())
    <div class="px-6 py-4 border-t border-gray-200">
        {{ $absensis->links() }}
    </div>
    @endif
</div>

<script>
document.addEventListener('DOMContentLoaded', function () {
    const form = document.getElementById('rekap-filter-form');
    const searchInput = document.getElementById('rekap-search');
    const periodeInput = document.getElementById('rekap-periode');
    const tanggalInput = document.getElementById('rekap-tanggal');
    const kelasInput = document.getElementById('rekap-kelas');
    const semuaPeriodeInput = document.getElementById('rekap-semua-periode');

    const localDateValue = (date) => {
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        return `${year}-${month}-${day}`;
    };

    const applyQuickDate = (offsetDays) => {
        const date = new Date();
        date.setDate(date.getDate() + offsetDays);
        const value = localDateValue(date);
        tanggalInput.value = value;
        periodeInput.value = value.slice(0, 7);
        semuaPeriodeInput.value = '0';
        form.requestSubmit();
    };

    tanggalInput?.addEventListener('change', function () {
        if (this.value) {
            periodeInput.value = this.value.slice(0, 7);
            semuaPeriodeInput.value = '0';
        }
    });

    periodeInput?.addEventListener('change', function () {
        tanggalInput.value = '';
        semuaPeriodeInput.value = '0';
    });

    document.getElementById('rekap-hari-ini')?.addEventListener('click', () => applyQuickDate(0));
    document.getElementById('rekap-reset-all')?.addEventListener('click', function () {
        searchInput.value = '';
        periodeInput.value = '';
        tanggalInput.value = '';
        kelasInput.value = '';
        semuaPeriodeInput.value = '1';
        form.requestSubmit();
    });
});
</script>
@endsection

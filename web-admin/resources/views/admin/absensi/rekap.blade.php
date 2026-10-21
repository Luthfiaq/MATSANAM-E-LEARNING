@extends('layouts.admin')

@section('title', 'Rekap Presensi Siswa')

@section('content')
<div class="mb-6 flex items-center justify-between flex-col md:flex-row gap-4">
    <div>
        <h1 class="text-2xl font-bold text-gray-900">Rekap Presensi Siswa</h1>
        <p class="text-sm text-gray-500">Statistik kehadiran siswa berdasarkan periode & kelas</p>
    </div>
    <form method="GET" class="flex items-center gap-3 flex-wrap">
        <input type="month" name="periode" value="{{ $request->periode ?? date('Y-m') }}" 
               class="rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none">
        <select name="kelas" class="rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none">
            <option value="">Semua Kelas</option>
            @foreach($kelasList as $kelas)
            <option value="{{ $kelas->id }}" {{ $request->kelas == $kelas->id ? 'selected' : '' }}>
                {{ $kelas->nama_kelas }}
            </option>
            @endforeach
        </select>
        <button type="submit" class="px-4 py-2 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700">
            Filter
        </button>
        <a href="{{ route('admin.absensi.export', ['format' => 'excel', 'periode' => $request->periode ?? date('Y-m'), 'kelas' => $request->kelas]) }}" 
           class="px-4 py-2 bg-green-600 text-white rounded-lg text-sm font-medium hover:bg-green-700">
            📊 Excel
        </a>
        <a href="{{ route('admin.absensi.export', ['format' => 'pdf', 'periode' => $request->periode ?? date('Y-m'), 'kelas' => $request->kelas]) }}" 
           class="px-4 py-2 bg-red-600 text-white rounded-lg text-sm font-medium hover:bg-red-700">
            📄 PDF
        </a>
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
                </tr>
                @empty
                <tr>
                    <td colspan="6" class="px-6 py-12 text-center text-gray-500">
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
function exportPresensi(format) {
    const periode = document.querySelector('input[name="periode"]').value;
    const kelas = document.querySelector('select[name="kelas"]').value;
    
    window.location.href = `/admin/absensi/export?format=${format}&periode=${periode}&kelas=${kelas}`;
}
</script>
@endsection

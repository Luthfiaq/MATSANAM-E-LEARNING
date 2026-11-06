@extends('layouts.admin')

@section('title', 'Manajemen Nilai')

@section('content')
<div class="mb-6 flex items-center justify-between">
    <div>
        <h1 class="text-2xl font-bold text-gray-900">Manajemen Nilai</h1>
        <p class="text-sm text-gray-500">Input dan kelola nilai siswa</p>
    </div>
</div>

@if(session('success'))
<div class="mb-4 rounded-lg bg-green-50 border border-green-200 p-4">
    <p class="text-sm text-green-700">✓ {{ session('success') }}</p>
</div>
@endif

<div class="bg-white rounded-lg shadow-sm overflow-hidden">
    <div class="border-b border-gray-200 px-6 py-4 flex flex-col md:flex-row md:items-center gap-4">
        <form method="GET" class="flex-1 flex flex-col md:flex-row gap-4">
            <input type="text" name="search" value="{{ request('search') }}" placeholder="Cari tugas..." 
                   class="rounded-lg border border-gray-300 px-4 py-2 text-sm focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20 flex-1">
            <select name="jenis" class="rounded-lg border border-gray-300 px-4 py-2 text-sm focus:border-blue-500 focus:outline-none">
                <option value="">Semua Jenis</option>
                <option value="tugas" {{ request('jenis') === 'tugas' ? 'selected' : '' }}>Tugas</option>
                <option value="quiz" {{ request('jenis') === 'quiz' ? 'selected' : '' }}>Quiz</option>
                <option value="uts" {{ request('jenis') === 'uts' ? 'selected' : '' }}>UTS</option>
                <option value="uas" {{ request('jenis') === 'uas' ? 'selected' : '' }}>UAS</option>
            </select>
            <button type="submit" class="px-4 py-2 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700">
                Cari
            </button>
        </form>
    </div>

    <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
                <tr>
                    <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Tugas</th>
                    <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Mapel</th>
                    <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Kelas</th>
                    <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Jenis</th>
                    <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Deadline</th>
                    <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Terkumpul</th>
                    <th class="px-6 py-3 text-center text-xs font-semibold text-gray-600 uppercase tracking-wider">Aksi</th>
                </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
                @forelse($tugas as $item)
                <tr class="hover:bg-gray-50">
                    <td class="px-6 py-4 whitespace-nowrap">
                        <div class="text-sm font-medium text-gray-900">{{ $item->judul }}</div>
                        <div class="text-xs text-gray-500">{{ $item->jadwal->mataPelajaran->kode }}</div>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap">
                        <div class="text-sm text-gray-900">{{ $item->jadwal->mataPelajaran->nama }}</div>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap">
                        <span class="inline-flex rounded-full bg-blue-100 px-2 py-1 text-xs font-medium text-blue-800">
                            {{ $item->jadwal->kelas->nama_kelas }}
                        </span>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap">
                        <span class="inline-flex items-center gap-1 rounded-full px-2.5 py-1 text-xs font-medium 
                            {{ $item->jenis === 'tugas' ? 'bg-blue-50 text-blue-700' : ($item->jenis === 'quiz' ? 'bg-yellow-50 text-yellow-700' : ($item->jenis === 'uts' ? 'bg-purple-50 text-purple-700' : 'bg-red-50 text-red-700')) }}">
                            {{ ucfirst($item->jenis) }}
                        </span>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                        {{ $item->deadline->format('d M Y H:i') }}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap">
                        <span class="inline-flex items-center gap-1 rounded-full px-2.5 py-1 text-xs font-medium 
                            {{ $item->pengumpulan->count() >= 0 ? 'bg-green-50 text-green-700' : 'bg-gray-50 text-gray-700' }}">
                            {{ $item->pengumpulan->count() }}/{{ $item->jadwal->kelas->siswa->count() }}
                        </span>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-center text-sm">
                        <a href="{{ route('admin.nilai.detail', $item->id) }}" 
                           class="text-blue-600 hover:text-blue-900 font-medium">
                            Input Nilai
                        </a>
                    </td>
                </tr>
                @empty
                <tr>
                    <td colspan="7" class="px-6 py-12 text-center text-gray-500">
                        <div class="flex flex-col items-center gap-2">
                            <span class="text-4xl">📭</span>
                            <span>Belum ada data tugas</span>
                        </div>
                    </td>
                </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    @if($tugas->hasPages())
    <div class="px-6 py-4 border-t border-gray-200">
        {{ $tugas->links() }}
    </div>
    @endif
</div>
@endsection
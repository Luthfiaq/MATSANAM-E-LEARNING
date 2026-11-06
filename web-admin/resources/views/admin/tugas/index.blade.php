@extends('layouts.admin')

@section('title', 'Manajemen Tugas')

@section('content')
<div class="mb-6 flex items-center justify-between">
    <div>
        <h1 class="text-2xl font-bold text-gray-900">Manajemen Tugas</h1>
        <p class="text-sm text-gray-500">Kelola tugas pembelajaran</p>
    </div>
    <a href="{{ route('admin.tugas.create') }}" 
       class="inline-flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700 transition">
        <span>+</span>
        <span>Tambah Tugas</span>
    </a>
</div>

@if(session('success'))
<div class="mb-4 rounded-lg bg-green-50 border border-green-200 p-4">
    <p class="text-sm text-green-700">✓ {{ session('success') }}</p>
</div>
@endif

<div class="bg-white rounded-lg shadow-sm overflow-hidden">
    <div class="border-b border-gray-200 px-6 py-4 flex flex-col md:flex-row md:items-center gap-4">
        <form method="GET" class="flex-1">
            <input type="text" name="search" value="{{ request('search') }}" placeholder="Cari tugas..." 
                   class="rounded-lg border border-gray-300 px-4 py-2 text-sm focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20 w-full md:w-64">
        </form>
    </div>

    <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
                <tr>
                    <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Judul</th>
                    <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Mapel</th>
                    <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Kelas</th>
                    <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Jenis</th>
                    <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Deadline</th>
                    <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Bobot</th>
                    <th class="px-6 py-3 text-center text-xs font-semibold text-gray-600 uppercase tracking-wider">Aksi</th>
                </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
                @forelse($tugas as $item)
                <tr class="hover:bg-gray-50">
                    <td class="px-6 py-4 whitespace-nowrap">
                        <div class="text-sm font-medium text-gray-900">{{ $item->judul }}</div>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap">
                        <div class="text-sm text-gray-900">{{ $item->jadwal->mataPelajaran->nama }}</div>
                        <div class="text-xs text-gray-500">{{ $item->jadwal->mataPelajaran->kode }}</div>
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
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                        {{ $item->bobot }}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-center text-sm">
                        <div class="flex items-center justify-center gap-2">
                            <a href="{{ route('admin.tugas.edit', $item->id) }}" 
                               class="text-blue-600 hover:text-blue-900" title="Edit">
                                ✏️
                            </a>
                            <form action="{{ route('admin.tugas.destroy', $item->id) }}" 
                                  method="POST" 
                                  onsubmit="return confirm('Yakin ingin menghapus tugas ini?')"
                                  class="inline">
                                @csrf
                                @method('DELETE')
                                <button type="submit" class="text-red-600 hover:text-red-900" title="Hapus">
                                    🗑️
                                </button>
                            </form>
                        </div>
                    </td>
                </tr>
                @empty
                <tr>
                    <td colspan="7" class="px-6 py-12 text-center text-gray-500">
                        <div class="flex flex-col items-center gap-2">
                            <span class="text-4xl">📭</span>
                            <span>Belum ada data tugas</span>
                            <a href="{{ route('admin.tugas.create') }}" class="text-blue-600 hover:text-blue-700 text-sm font-medium">
                                Tambah Tugas Baru →
                            </a>
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
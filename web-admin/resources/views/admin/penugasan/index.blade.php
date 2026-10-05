@extends('layouts.admin')

@section('title', 'List Penugasan Guru')

@section('content')
<div class="mb-6 flex items-center justify-between">
    <div>
        <h1 class="text-2xl font-bold text-gray-900">List Penugasan Guru</h1>
        <p class="text-sm text-gray-500">Kelola penugasan mengajar guru</p>
    </div>
    <a href="{{ route('admin.penugasan.create') }}" 
       class="inline-flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700 transition">
        <span>➕</span>
        <span>Tambah Penugasan</span>
    </a>
</div>

@if(session('success'))
<div class="mb-4 rounded-lg bg-green-50 border border-green-200 p-4">
    <p class="text-sm text-green-700">✓ {{ session('success') }}</p>
</div>
@endif

<div class="bg-white rounded-lg shadow-sm overflow-hidden">
    <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
                <tr>
                    <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">No</th>
                    <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Guru</th>
                    <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Mata Pelajaran</th>
                    <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Kelas</th>
                    <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Jadwal</th>
                    <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Ruangan</th>
                    <th class="px-6 py-3 text-center text-xs font-semibold text-gray-600 uppercase tracking-wider">Aksi</th>
                </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
                @forelse($jadwal as $index => $item)
                <tr class="hover:bg-gray-50">
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {{ $jadwal->firstItem() + $index }}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap">
                        <div class="text-sm font-medium text-gray-900">{{ $item->guru->nama_lengkap }}</div>
                        <div class="text-xs text-gray-500">NIP: {{ $item->guru->nip }}</div>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap">
                        <div class="text-sm text-gray-900">{{ $item->mataPelajaran->nama }}</div>
                        <div class="text-xs text-gray-500">{{ $item->mataPelajaran->kode }}</div>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap">
                        <span class="inline-flex rounded-full bg-blue-100 px-2 py-1 text-xs font-medium text-blue-800">
                            {{ $item->kelas->nama_kelas }}
                        </span>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap">
                        <div class="text-sm text-gray-900">{{ $item->hari }}</div>
                        <div class="text-xs text-gray-500">
                            {{ Carbon\Carbon::parse($item->jam_mulai)->format('H:i') }} - 
                            {{ Carbon\Carbon::parse($item->jam_selesai)->format('H:i') }}
                        </div>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {{ $item->ruangan ?? '-' }}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-center text-sm">
                        <div class="flex items-center justify-center gap-2">
                            <a href="{{ route('admin.penugasan.edit', $item->id) }}" 
                               class="text-blue-600 hover:text-blue-900" title="Edit">
                                ✏️
                            </a>
                            <form action="{{ route('admin.penugasan.destroy', $item->id) }}" 
                                  method="POST" 
                                  onsubmit="return confirm('Yakin ingin menghapus penugasan ini?')"
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
                            <span>Belum ada data penugasan</span>
                            <a href="{{ route('admin.penugasan.create') }}" class="text-blue-600 hover:text-blue-700 text-sm font-medium">
                                Tambah Penugasan Baru →
                            </a>
                        </div>
                    </td>
                </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    @if($jadwal->hasPages())
    <div class="px-6 py-4 border-t border-gray-200">
        {{ $jadwal->links() }}
    </div>
    @endif
</div>
@endsection

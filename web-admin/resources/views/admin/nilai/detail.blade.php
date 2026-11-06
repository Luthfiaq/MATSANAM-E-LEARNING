@extends('layouts.admin')

@section('title', 'Input Nilai - {{ $tugas->judul }}')

@section('content')
<div class="mb-6 flex items-center justify-between">
    <div>
        <h1 class="text-2xl font-bold text-gray-900">{{ $tugas->judul }}</h1>
        <p class="text-sm text-gray-500">{{ $tugas->jadwal->mataPelajaran->nama }} - {{ $tugas->jadwal->kelas->nama_kelas }}</p>
    </div>
    <a href="{{ route('admin.nilai.index') }}" 
       class="px-4 py-2 border border-gray-300 rounded-lg text-sm font-medium text-gray-700 hover:bg-gray-50 transition">
        ← Kembali
    </a>
</div>

@if(session('success'))
<div class="mb-4 rounded-lg bg-green-50 border border-green-200 p-4">
    <p class="text-sm text-green-700">✓ {{ session('success') }}</p>
</div>
@endif

<div class="bg-white rounded-lg shadow-sm overflow-hidden">
    <div class="border-b border-gray-200 px-6 py-4 bg-gray-50">
        <div class="grid grid-cols-4 gap-4 text-sm">
            <div>
                <span class="text-gray-500">Jenis</span>
                <div class="font-medium capitalize">{{ $tugas->jenis }}</div>
            </div>
            <div>
                <span class="text-gray-500">Deadline</span>
                <div class="font-medium">{{ $tugas->deadline->format('d M Y H:i') }}</div>
            </div>
            <div>
                <span class="text-gray-500">Bobot</span>
                <div class="font-medium">{{ $tugas->bobot }}</div>
            </div>
            <div>
                <span class="text-gray-500">Status</span>
                <div class="font-medium">{{ $tugas->pengumpulan->count() }}/{{ $tugas->jadwal->kelas->siswa->count() }} Terkumpul</div>
            </div>
        </div>
    </div>

    <div class="p-6">
        @if($pengumpulan->isEmpty())
        <div class="text-center py-12">
            <span class="text-4xl">📭</span>
            <p class="text-gray-500 mt-2">Belum ada siswa yang mengumpulkan tugas ini</p>
        </div>
        @else
        <form action="{{ route('admin.nilai.store') }}" method="POST" class="space-y-4">
            @csrf
            <input type="hidden" name="tugas_id" value="{{ $tugas->id }}">

            <div class="overflow-x-auto">
                <table class="min-w-full divide-y divide-gray-200">
                    <thead class="bg-gray-50">
                        <tr>
                            <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Siswa</th>
                            <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Status</th>
                            <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">File</th>
                            <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Waktu Kumpul</th>
                            <th class="px-6 py-3 text-center text-xs font-semibold text-gray-600 uppercase tracking-wider">Nilai (0-{{ $tugas->bobot }})</th>
                            <th class="px-6 py-3 text-center text-xs font-semibold text-gray-600 uppercase tracking-wider">Catatan</th>
                        </tr>
                    </thead>
                    <tbody class="bg-white divide-y divide-gray-200">
                        @foreach($pengumpulan as $p)
                        <tr class="hover:bg-gray-50">
                            <td class="px-6 py-4 whitespace-nowrap">
                                <div class="text-sm font-medium text-gray-900">{{ $p->siswa->nama_lengkap }}</div>
                                <div class="text-xs text-gray-500">{{ $p->siswa->nisn }}</div>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap">
                                <span class="inline-flex items-center gap-1 rounded-full px-2.5 py-1 text-xs font-medium 
                                    {{ $p->status === 'tepat_waktu' ? 'bg-green-50 text-green-700' : 'bg-yellow-50 text-yellow-700' }}">
                                    {{ $p->status === 'tepat_waktu' ? 'Tepat Waktu' : 'Terlambat' }}
                                </span>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap">
                                @if($p->file_jawaban)
                                <a href="{{ asset('storage/' . $p->file_jawaban) }}" target="_blank" class="text-blue-600 hover:text-blue-900 text-sm">
                                    📄 {{ basename($p->file_jawaban) }}
                                </a>
                                @else
                                <span class="text-gray-400 text-sm">-</span>
                                @endif
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                                {{ $p->waktu_pengumpulan->format('d M Y H:i') }}
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-center">
                                <input type="number" 
                                       name="nilai[{{ $p->id }}]" 
                                       min="0" 
                                       max="{{ $tugas->bobot }}" 
                                       step="0.5"
                                       value="{{ $p->nilai->nilai ?? '' }}"
                                       class="w-24 px-3 py-2 border border-gray-300 rounded-lg text-center focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20">
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-center">
                                <input type="text" 
                                       name="catatan[{{ $p->id }}]" 
                                       value="{{ $p->nilai->catatan ?? '' }}"
                                       placeholder="Catatan..."
                                       class="w-32 px-3 py-2 border border-gray-300 rounded-lg text-sm focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20">
                            </td>
                        </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>

            <div class="flex justify-end pt-4 border-t border-gray-200">
                <button type="submit" 
                        class="px-6 py-2 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700 transition">
                    Simpan Semua Nilai
                </button>
            </div>
        </form>
        @endif
    </div>
</div>
@endsection
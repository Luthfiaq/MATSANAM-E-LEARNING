@extends('layouts.admin')

@section('title', 'Detail Tugas')

@section('content')
<div class="mb-6">
    <h1 class="text-2xl font-bold text-gray-900">Detail Tugas</h1>
    <p class="text-sm text-gray-500">Informasi lengkap tugas</p>
</div>
<div class="bg-white rounded-lg shadow-sm p-6">
    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div><strong>Judul:</strong> {{ $tugas->judul }}</div>
        <div><strong>Mapel:</strong> {{ $tugas->jadwal->mataPelajaran->nama }}</div>
        <div><strong>Kelas:</strong> {{ $tugas->jadwal->kelas->nama_kelas }}</div>
        <div><strong>Jenis:</strong> {{ ucfirst($tugas->jenis) }}</div>
        <div><strong>Deadline:</strong> {{ $tugas->deadline->format('d M Y H:i') }}</div>
        <div><strong>Bobot:</strong> {{ $tugas->bobot }}</div>
        <div class="col-span-2"><strong>Deskripsi:</strong> {{ $tugas->deskripsi }}</div>
        @if($tugas->file_materi)
        <div class="col-span-2">
            <strong>File Materi:</strong>
            <a href="{{ Storage::url($tugas->file_materi) }}" target="_blank" class="text-blue-600 hover:underline">Download</a>
        </div>
        @endif
    </div>
    <div class="mt-6 flex space-x-4">
        <a href="{{ route('admin.tugas.edit', $tugas->id) }}" class="px-4 py-2 bg-blue-600 text-white rounded">Edit</a>
        <form action="{{ route('admin.tugas.destroy', $tugas->id) }}" method="POST" onsubmit="return confirm('Yakin ingin menghapus tugas ini?')" class="inline">
            @csrf
            @method('DELETE')
            <button type="submit" class="px-4 py-2 bg-red-600 text-white rounded">Hapus</button>
        </form>
        <a href="{{ route('admin.tugas.index') }}" class="px-4 py-2 bg-gray-200 rounded">Kembali</a>
    </div>
</div>
@endsection
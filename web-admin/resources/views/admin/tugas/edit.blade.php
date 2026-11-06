@extends('layouts.admin')

@section('title', 'Edit Tugas')

@section('content')
<div class="mb-6">
    <h1 class="text-2xl font-bold text-gray-900">Edit Tugas</h1>
    <p class="text-sm text-gray-500">Perbarui informasi tugas pembelajaran</p>
</div>

<div class="bg-white rounded-lg shadow-sm p-6">
    <form action="{{ route('admin.tugas.update', $tugas->id) }}" method="POST" class="space-y-6" enctype="multipart/form-data">
        @csrf
        @method('PUT')

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <!-- Judul -->
            <div>
                <label for="judul" class="block text-sm font-medium text-gray-700 mb-2">
                    Judul Tugas <span class="text-red-500">*</span>
                </label>
                <input 
                    type="text" 
                    id="judul" 
                    name="judul" 
                    required
                    value="{{ $tugas->judul }}"
                    placeholder="Contoh: Soal Ujian Tengah Semester"
                    class="w-full rounded-lg border border-gray-300 px-4 py-2 focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20"
                />
                @error('judul')
                <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                @enderror
            </div>

            <!-- Jenis Tugas -->
            <div>
                <label for="jenis" class="block text-sm font-medium text-gray-700 mb-2">
                    Jenis Tugas <span class="text-red-500">*</span>
                </label>
                <select 
                    id="jenis" 
                    name="jenis" 
                    required
                    class="w-full rounded-lg border border-gray-300 px-4 py-2 focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20"
                >
                    <option value="tugas" {{ $tugas->jenis === 'tugas' ? 'selected' : '' }}>Tugas</option>
                    <option value="quiz" {{ $tugas->jenis === 'quiz' ? 'selected' : '' }}>Quiz</option>
                    <option value="uts" {{ $tugas->jenis === 'uts' ? 'selected' : '' }}>UTS</option>
                    <option value="uas" {{ $tugas->jenis === 'uas' ? 'selected' : '' }}>UAS</option>
                </select>
                @error('jenis')
                <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                @enderror
            </div>
        </div>

        <!-- Deskripsi -->
        <div>
            <label for="deskripsi" class="block text-sm font-medium text-gray-700 mb-2">
                Deskripsi / Instruksi
            </label>
            <textarea 
                id="deskripsi" 
                name="deskripsi" 
                rows="4"
                placeholder="Masukkan instruksi pengerjaan..."
                class="w-full rounded-lg border border-gray-300 px-4 py-2 focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20"
            >{{ $tugas->deskripsi }}</textarea>
            @error('deskripsi')
            <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
            @enderror
        </div>

        <!-- Deadline & Bobot -->
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
                <label for="deadline" class="block text-sm font-medium text-gray-700 mb-2">
                    Deadline <span class="text-red-500">*</span>
                </label>
                <input 
                    type="datetime-local" 
                    id="deadline" 
                    name="deadline" 
                    required
                    value="{{ $tugas->deadline->format('Y-m-d\TH:i') }}"
                    class="w-full rounded-lg border border-gray-300 px-4 py-2 focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20"
                />
                @error('deadline')
                <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                @enderror
            </div>

            <div>
                <label for="bobot" class="block text-sm font-medium text-gray-700 mb-2">
                    Bobot Nilai <span class="text-red-500">*</span>
                </label>
                <input 
                    type="number" 
                    id="bobot" 
                    name="bobot" 
                    required
                    min="1"
                    max="100"
                    value="{{ $tugas->bobot }}"
                    class="w-full rounded-lg border border-gray-300 px-4 py-2 focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20"
                />
                @error('bobot')
                <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                @enderror
            </div>
        </div>

        <!-- File Materi -->
        <div>
            <label for="file_materi" class="block text-sm font-medium text-gray-700 mb-2">
                File Materi
            </label>
            @if($tugas->file_materi)
            <div class="mb-2">
                <span class="inline-flex items-center px-3 py-1 bg-green-50 text-green-700 rounded-full text-sm">
                    ✓ {{ basename($tugas->file_materi) }}
                </span>
            </div>
            @endif
            <input 
                type="file" 
                id="file_materi" 
                name="file_materi" 
                accept=".pdf,.doc,.docx,.ppt,.pptx,.zip,.rar"
                class="w-full rounded-lg border border-gray-300 px-4 py-2 focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20"
            />
            <p class="mt-1 text-xs text-gray-500">Format: PDF, DOC, PPT, ZIP (Maks. 10MB). Kosongkan jika tidak ingin mengubah file.</p>
        </div>

        <!-- Mapel & Kelas -->
        <div>
            <label for="jadwal_id" class="block text-sm font-medium text-gray-700 mb-2">
                Mapel & Kelas <span class="text-red-500">*</span>
            </label>
            <select 
                id="jadwal_id" 
                name="jadwal_id" 
                required
                class="w-full rounded-lg border border-gray-300 px-4 py-2 focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20"
            >
                <option value="">Pilih Mapel & Kelas</option>
                @foreach($jadwal as $j)
                <option value="{{ $j->id }}" {{ $tugas->jadwal_id == $j->id ? 'selected' : '' }}>
                    {{ $j->mataPelajaran->nama }} - {{ $j->kelas->nama_kelas }} ({{ $j->hari }} {{ $j->jam_mulai }} - {{ $j->jam_selesai }})
                </option>
                @endforeach
            </select>
            @error('jadwal_id')
            <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
            @enderror
        </div>

        <!-- Action Buttons -->
        <div class="flex items-center justify-end gap-4 pt-6 border-t border-gray-200">
            <a href="{{ route('admin.tugas.index') }}" 
               class="px-6 py-2 border border-gray-300 rounded-lg text-sm font-medium text-gray-700 hover:bg-gray-50 transition">
                Batal
            </a>
            <button type="submit" 
                    class="px-6 py-2 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700 transition">
                Simpan Perubahan
            </button>
        </div>
    </form>
</div>
@endsection
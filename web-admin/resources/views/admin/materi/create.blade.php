@extends('layouts.admin')

@section('title', 'Tambah Materi Baru')

@section('content')
<div class="mb-6">
    <h1 class="text-2xl font-bold text-gray-900">Tambah Materi Baru</h1>
    <p class="text-sm text-gray-500">Isi form di bawah untuk menambah materi pembelajaran</p>
</div>

<div class="bg-white rounded-lg shadow-sm p-6">
    <form action="{{ route('admin.materi.store') }}" method="POST" class="space-y-6" enctype="multipart/form-data">
        @csrf

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <!-- Judul -->
            <div>
                <label for="judul" class="block text-sm font-medium text-gray-700 mb-2">
                    Judul Materi <span class="text-red-500">*</span>
                </label>
                <input 
                    type="text" 
                    id="judul" 
                    name="judul" 
                    required
                    value="{{ old('judul') }}"
                    placeholder="Contoh: Modul Trigonometri"
                    class="w-full rounded-lg border border-gray-300 px-4 py-2 focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20"
                />
                @error('judul')
                <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                @enderror
            </div>

            <!-- Tipe Materi -->
            <div>
                <label for="tipe" class="block text-sm font-medium text-gray-700 mb-2">
                    Tipe Materi <span class="text-red-500">*</span>
                </label>
                <select 
                    id="tipe" 
                    name="tipe" 
                    required
                    class="w-full rounded-lg border border-gray-300 px-4 py-2 focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20"
                >
                    <option value="">Pilih Tipe</option>
                    <option value="pdf" {{ old('tipe') === 'pdf' ? 'selected' : '' }}>PDF</option>
                    <option value="video" {{ old('tipe') === 'video' ? 'selected' : '' }}>Video</option>
                    <option value="link" {{ old('tipe') === 'link' ? 'selected' : '' }}>Link URL</option>
                </select>
                @error('tipe')
                <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                @enderror
            </div>
        </div>

        <!-- Deskripsi -->
        <div>
            <label for="deskripsi" class="block text-sm font-medium text-gray-700 mb-2">
                Deskripsi
            </label>
            <textarea 
                id="deskripsi" 
                name="deskripsi" 
                rows="4"
                placeholder="Masukkan deskripsi materi..."
                class="w-full rounded-lg border border-gray-300 px-4 py-2 focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20"
            >{{ old('deskripsi') }}</textarea>
            @error('deskripsi')
            <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
            @enderror
        </div>

        <!-- File/Link Section -->
        <div id="fileSection" class="hidden">
            <label for="file_path" class="block text-sm font-medium text-gray-700 mb-2">
                File Materi <span class="text-red-500">*</span>
            </label>
            <input 
                type="file" 
                id="file_path" 
                name="file_path" 
                accept=".pdf,.doc,.docx,.ppt,.pptx"
                class="w-full rounded-lg border border-gray-300 px-4 py-2 focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20"
            />
            <p class="mt-1 text-xs text-gray-500">Format: PDF, DOC, PPT (Maks. 10MB)</p>
        </div>

        <div id="videoSection" class="hidden">
            <label for="file_path_video" class="block text-sm font-medium text-gray-700 mb-2">
                File Video <span class="text-red-500">*</span>
            </label>
            <input 
                type="file" 
                id="file_path_video" 
                name="file_path" 
                accept=".mp4,.mov,.avi"
                class="w-full rounded-lg border border-gray-300 px-4 py-2 focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20"
            />
            <p class="mt-1 text-xs text-gray-500">Format: MP4, MOV, AVI (Maks. 50MB)</p>
        </div>

        <div id="linkSection" class="hidden">
            <label for="link" class="block text-sm font-medium text-gray-700 mb-2">
                Link URL <span class="text-red-500">*</span>
            </label>
            <input 
                type="url" 
                id="link" 
                name="link" 
                placeholder="https://example.com/materi"
                class="w-full rounded-lg border border-gray-300 px-4 py-2 focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20"
            />
        </div>

        <!-- Mapel & Kelas -->
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
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
                    <option value="{{ $j->id }}" {{ old('jadwal_id') == $j->id ? 'selected' : '' }}>
                        {{ $j->mataPelajaran->nama }} - {{ $j->kelas->nama_kelas }} ({{ $j->hari }} {{ $j->jam_mulai }} - {{ $j->jam_selesai }})
                    </option>
                    @endforeach
                </select>
                @error('jadwal_id')
                <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                @enderror
            </div>
        </div>

        <!-- Action Buttons -->
        <div class="flex items-center justify-end gap-4 pt-6 border-t border-gray-200">
            <a href="{{ route('admin.materi.index') }}" 
               class="px-6 py-2 border border-gray-300 rounded-lg text-sm font-medium text-gray-700 hover:bg-gray-50 transition">
                Batal
            </a>
            <button type="submit" 
                    class="px-6 py-2 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700 transition">
                Simpan Materi
            </button>
        </div>
    </form>
</div>

@if(session('success'))
<div class="fixed bottom-4 right-4 bg-green-50 border border-green-200 rounded-lg p-4 shadow-lg">
    <p class="text-sm text-green-700">✓ {{ session('success') }}</p>
</div>
@endif
@endsection

@push('scripts')
<script>
    document.getElementById('tipe').addEventListener('change', function() {
        const tipe = this.value;
        const fileSection = document.getElementById('fileSection');
        const videoSection = document.getElementById('videoSection');
        const linkSection = document.getElementById('linkSection');
        
        fileSection.classList.add('hidden');
        videoSection.classList.add('hidden');
        linkSection.classList.add('hidden');
        
        if (tipe === 'pdf') {
            fileSection.classList.remove('hidden');
        } else if (tipe === 'video') {
            videoSection.classList.remove('hidden');
        } else if (tipe === 'link') {
            linkSection.classList.remove('hidden');
        }
    });
</script>
@endpush
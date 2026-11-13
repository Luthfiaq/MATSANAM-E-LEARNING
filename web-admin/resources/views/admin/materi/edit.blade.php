@extends('layouts.admin')

@section('title', 'Edit Materi')

@section('content')
<div class="mb-6">
    <h1 class="text-2xl font-bold text-gray-900">Edit Materi</h1>
    <p class="text-sm text-gray-500">Perbarui informasi materi pembelajaran</p>
</div>

<div class="bg-white rounded-lg shadow-sm p-6">
    <form action="{{ route('admin.materi.update', $materi->id) }}" method="POST" class="space-y-6" enctype="multipart/form-data">
        @csrf
        @method('PUT')

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
                    value="{{ old('judul', $materi->judul) }}"
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
                    <option value="pdf" {{ old('tipe', $materi->tipe) === 'pdf' ? 'selected' : '' }}>PDF</option>
                    <option value="video" {{ old('tipe', $materi->tipe) === 'video' ? 'selected' : '' }}>Video</option>
                    <option value="link" {{ old('tipe', $materi->tipe) === 'link' ? 'selected' : '' }}>Link URL</option>
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
            >{{ old('deskripsi', $materi->deskripsi) }}</textarea>
            @error('deskripsi')
            <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
            @enderror
        </div>

        <!-- File/Link Section -->
        <div id="fileSection" class="{{ $materi->tipe === 'pdf' ? '' : 'hidden' }}">
            <label for="file_path" class="block text-sm font-medium text-gray-700 mb-2">
                File Materi
            </label>
            @if($materi->file_path)
            <div class="mb-2">
                <span class="inline-flex items-center px-3 py-1 bg-green-50 text-green-700 rounded-full text-sm">
                    ✓ {{ basename($materi->file_path) }}
                </span>
            </div>
            @endif
            <input 
                type="file" 
                id="file_path" 
                name="file_path" 
                accept=".pdf"
                class="w-full rounded-lg border border-gray-300 px-4 py-2 focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20"
            />
            <p class="mt-1 text-xs text-gray-500">Format: PDF (Maks. 10MB). Kosongkan jika tidak ingin mengubah file.</p>
        </div>

        <div id="videoSection" class="{{ $materi->tipe === 'video' ? '' : 'hidden' }}">
            <label for="file_path_video" class="block text-sm font-medium text-gray-700 mb-2">
                File Video
            </label>
            @if($materi->file_path)
            <div class="mb-2">
                <span class="inline-flex items-center px-3 py-1 bg-orange-50 text-orange-700 rounded-full text-sm">
                    ✓ {{ basename($materi->file_path) }}
                </span>
            </div>
            @endif
            <input 
                type="file" 
                id="file_path_video" 
                name="file_path" 
                accept=".mp4,.mov,.webm"
                class="w-full rounded-lg border border-gray-300 px-4 py-2 focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20"
            />
            <p class="mt-1 text-xs text-gray-500">Format: MP4, MOV, WEBM (Maks. 10MB). Kosongkan jika tidak ingin mengubah file.</p>
        </div>

        <div id="linkSection" class="{{ $materi->tipe === 'link' ? '' : 'hidden' }}">
            <label for="link" class="block text-sm font-medium text-gray-700 mb-2">
                Link URL
            </label>
            <input 
                type="url" 
                id="link" 
                name="link" 
                value="{{ old('link', $materi->link) }}"
                placeholder="https://example.com/materi"
                class="w-full rounded-lg border border-gray-300 px-4 py-2 focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20"
            />
        </div>

        @error('file_path')
        <p class="text-sm text-red-600">{{ $message }}</p>
        @enderror
        @error('link')
        <p class="text-sm text-red-600">{{ $message }}</p>
        @enderror

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
                    <option value="{{ $j->id }}" {{ old('jadwal_id', $materi->jadwal_id) == $j->id ? 'selected' : '' }}>
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
                Simpan Perubahan
            </button>
        </div>
    </form>
</div>
@endsection

@push('scripts')
<script>
    (() => {
        const typeInput = document.getElementById('tipe');
        const pdfSection = document.getElementById('fileSection');
        const videoSection = document.getElementById('videoSection');
        const linkSection = document.getElementById('linkSection');
        const pdfFile = document.getElementById('file_path');
        const videoFile = document.getElementById('file_path_video');
        const linkInput = document.getElementById('link');
        const originalType = @json($materi->tipe);
        const hasCurrentFile = @json((bool) $materi->file_path);

        const updateSections = () => {
            const type = typeInput.value;
            pdfSection.classList.toggle('hidden', type !== 'pdf');
            videoSection.classList.toggle('hidden', type !== 'video');
            linkSection.classList.toggle('hidden', type !== 'link');
            pdfFile.disabled = type !== 'pdf';
            videoFile.disabled = type !== 'video';
            const needsReplacement = type !== originalType || !hasCurrentFile;
            pdfFile.required = type === 'pdf' && needsReplacement;
            videoFile.required = type === 'video' && needsReplacement;
            linkInput.disabled = type !== 'link';
            linkInput.required = type === 'link';
        };

        typeInput.addEventListener('change', () => {
            pdfFile.value = '';
            videoFile.value = '';
            updateSections();
        });
        updateSections();
    })();
</script>
@endpush
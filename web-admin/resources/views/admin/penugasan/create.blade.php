@extends('layouts.admin')

@section('title', 'Atur Penugasan Baru')

@section('content')
<div class="mb-6">
    <h1 class="text-2xl font-bold text-gray-900">Atur Penugasan Baru</h1>
    <p class="text-sm text-gray-500">Tambah penugasan guru untuk mata pelajaran tertentu</p>
</div>

<div class="bg-white rounded-lg shadow-sm p-6">
    <form action="{{ route('admin.penugasan.store') }}" method="POST" class="space-y-6">
        @csrf

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <!-- Periode Akademik -->
            <div>
                <label for="periode_id" class="block text-sm font-medium text-gray-700 mb-2">
                    Periode Akademik <span class="text-red-500">*</span>
                </label>
                <select 
                    id="periode_id" 
                    name="periode_id" 
                    required
                    class="w-full rounded-lg border border-gray-300 px-4 py-2 focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20"
                >
                    <option value="">Pilih Periode</option>
                    @foreach($periode as $p)
                    <option value="{{ $p->id }}" {{ old('periode_id') == $p->id ? 'selected' : '' }}>
                        {{ $p->nama }} ({{ $p->is_active ? 'Aktif' : 'Tidak Aktif' }})
                    </option>
                    @endforeach
                </select>
                @error('periode_id')
                <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                @enderror
            </div>

            <!-- Kelas -->
            <div>
                <label for="kelas_id" class="block text-sm font-medium text-gray-700 mb-2">
                    Kelas <span class="text-red-500">*</span>
                </label>
                <select 
                    id="kelas_id" 
                    name="kelas_id" 
                    required
                    class="w-full rounded-lg border border-gray-300 px-4 py-2 focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20"
                >
                    <option value="">Pilih Kelas</option>
                    @foreach($kelas as $k)
                    <option value="{{ $k->id }}" {{ old('kelas_id') == $k->id ? 'selected' : '' }}>
                        {{ $k->nama_kelas }} (Kapasitas: {{ $k->kapasitas }})
                    </option>
                    @endforeach
                </select>
                @error('kelas_id')
                <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                @enderror
            </div>

            <!-- Mata Pelajaran -->
            <div>
                <label for="mapel_id" class="block text-sm font-medium text-gray-700 mb-2">
                    Mata Pelajaran <span class="text-red-500">*</span>
                </label>
                <select 
                    id="mapel_id" 
                    name="mapel_id" 
                    required
                    class="w-full rounded-lg border border-gray-300 px-4 py-2 focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20"
                >
                    <option value="">Pilih Mata Pelajaran</option>
                    @foreach($mataPelajaran as $mapel)
                    <option value="{{ $mapel->id }}" {{ old('mapel_id') == $mapel->id ? 'selected' : '' }}>
                        {{ $mapel->nama }} ({{ $mapel->kode }})
                    </option>
                    @endforeach
                </select>
                @error('mapel_id')
                <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                @enderror
            </div>

            <!-- Guru -->
            <div>
                <label for="guru_id" class="block text-sm font-medium text-gray-700 mb-2">
                    Guru Pengampu <span class="text-red-500">*</span>
                </label>
                <select 
                    id="guru_id" 
                    name="guru_id" 
                    required
                    class="w-full rounded-lg border border-gray-300 px-4 py-2 focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20"
                >
                    <option value="">Pilih Guru</option>
                    @foreach($guru as $g)
                    <option value="{{ $g->id }}" {{ old('guru_id') == $g->id ? 'selected' : '' }}>
                        {{ $g->nama_lengkap }} ({{ $g->nip }})
                    </option>
                    @endforeach
                </select>
                @error('guru_id')
                <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                @enderror
            </div>

            <!-- Hari -->
            <div>
                <label for="hari" class="block text-sm font-medium text-gray-700 mb-2">
                    Hari <span class="text-red-500">*</span>
                </label>
                <select 
                    id="hari" 
                    name="hari" 
                    required
                    class="w-full rounded-lg border border-gray-300 px-4 py-2 focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20"
                >
                    <option value="">Pilih Hari</option>
                    @foreach(['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'] as $hari)
                    <option value="{{ $hari }}" {{ old('hari') == $hari ? 'selected' : '' }}>{{ $hari }}</option>
                    @endforeach
                </select>
                @error('hari')
                <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                @enderror
            </div>

            <!-- Ruangan -->
            <div>
                <label for="ruangan" class="block text-sm font-medium text-gray-700 mb-2">
                    Ruangan
                </label>
                <input 
                    type="text" 
                    id="ruangan" 
                    name="ruangan" 
                    value="{{ old('ruangan') }}"
                    placeholder="Contoh: R1, Lab Komputer"
                    class="w-full rounded-lg border border-gray-300 px-4 py-2 focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20"
                />
                @error('ruangan')
                <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                @enderror
            </div>

            <!-- Jam Mulai -->
            <div>
                <label for="jam_mulai" class="block text-sm font-medium text-gray-700 mb-2">
                    Jam Mulai <span class="text-red-500">*</span>
                </label>
                <input 
                    type="time" 
                    id="jam_mulai" 
                    name="jam_mulai" 
                    value="{{ old('jam_mulai', '07:30') }}"
                    required
                    class="w-full rounded-lg border border-gray-300 px-4 py-2 focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20"
                />
                @error('jam_mulai')
                <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                @enderror
            </div>

            <!-- Jam Selesai -->
            <div>
                <label for="jam_selesai" class="block text-sm font-medium text-gray-700 mb-2">
                    Jam Selesai <span class="text-red-500">*</span>
                </label>
                <input 
                    type="time" 
                    id="jam_selesai" 
                    name="jam_selesai" 
                    value="{{ old('jam_selesai', '09:00') }}"
                    required
                    class="w-full rounded-lg border border-gray-300 px-4 py-2 focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20"
                />
                @error('jam_selesai')
                <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                @enderror
            </div>
        </div>

        <!-- Action Buttons -->
        <div class="flex items-center justify-end gap-4 pt-6 border-t border-gray-200">
            <a href="{{ route('admin.penugasan.index') }}" 
               class="px-6 py-2 border border-gray-300 rounded-lg text-sm font-medium text-gray-700 hover:bg-gray-50 transition">
                Batal
            </a>
            <button type="submit" 
                    class="px-6 py-2 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700 transition">
                Simpan Penugasan
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

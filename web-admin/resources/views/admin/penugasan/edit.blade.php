@extends('layouts.admin')

@section('title', 'Edit Penugasan Guru')

@section('content')
<div class="mb-6">
    <h1 class="text-2xl font-bold text-gray-900">Edit Penugasan Guru</h1>
    <p class="text-sm text-gray-500">Ubah informasi penugasan guru</p>
</div>

<div class="bg-white rounded-lg shadow-sm p-6">
    <form action="{{ route('admin.penugasan.update', $jadwal->id) }}" method="POST" class="space-y-6">
        @csrf
        @method('PUT')

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">

            <!-- Periode Akademik -->
            <div>
                <label for="periode_id" class="block text-sm font-medium text-gray-700 mb-2">
                    Periode Akademik <span class="text-red-500">*</span>
                </label>
                <select id="periode_id" name="periode_id" required
                    class="w-full rounded-lg border border-gray-300 px-4 py-2">
                    <option value="">Pilih Periode</option>
                    @foreach($periode as $p)
                    <option value="{{ $p->id }}" {{ old('periode_id', $jadwal->periode_id) == $p->id ? 'selected' : '' }}>
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
                <select id="kelas_id" name="kelas_id" required
                    class="w-full rounded-lg border border-gray-300 px-4 py-2">
                    <option value="">Pilih Kelas</option>
                    @foreach($kelas as $k)
                    <option value="{{ $k->id }}" {{ old('kelas_id', $jadwal->kelas_id) == $k->id ? 'selected' : '' }}>
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
                <select id="mapel_id" name="mapel_id" required
                    class="w-full rounded-lg border border-gray-300 px-4 py-2">
                    <option value="">Pilih Mata Pelajaran</option>
                    @foreach($mataPelajaran as $mapel)
                    <option value="{{ $mapel->id }}" {{ old('mapel_id', $jadwal->mapel_id) == $mapel->id ? 'selected' : '' }}>
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
                <select id="guru_id" name="guru_id" required
                    class="w-full rounded-lg border border-gray-300 px-4 py-2">
                    <option value="">Pilih Guru</option>
                    @foreach($guru as $g)
                    <option value="{{ $g->id }}" {{ old('guru_id', $jadwal->guru_id) == $g->id ? 'selected' : '' }}>
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
                <select id="hari" name="hari" required
                    class="w-full rounded-lg border border-gray-300 px-4 py-2">
                    <option value="">Pilih Hari</option>
                    @foreach(['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'] as $hari)
                    <option value="{{ $hari }}" {{ old('hari', $jadwal->hari) == $hari ? 'selected' : '' }}>
                        {{ $hari }}
                    </option>
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
                <input type="text" id="ruangan" name="ruangan"
                    value="{{ old('ruangan', $jadwal->ruangan) }}"
                    placeholder="Contoh: R1, Lab Komputer"
                    class="w-full rounded-lg border border-gray-300 px-4 py-2">
                @error('ruangan')
                <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                @enderror
            </div>

            <!-- Jam Mulai -->
<div>
    <label for="jam_mulai_ke" class="block text-sm font-medium text-gray-700 mb-2">
        Jam Mulai <span class="text-red-500">*</span>
    </label>
    <select
        id="jam_mulai_ke"
        name="jam_mulai_ke"
        required
        class="w-full rounded-lg border border-gray-300 px-4 py-2"
    >
        <option value="">Pilih Jam Mulai</option>
        @foreach ([
            1 => '07.15 - 07.55',
            2 => '07.55 - 08.35',
            3 => '08.35 - 09.15',
            4 => '09.15 - 09.55',
            5 => '10.30 - 11.10',
            6 => '11.10 - 11.50',
            7 => '11.50 - 12.30',
            8 => '12.30 - 13.10',
        ] as $jam => $waktu)
            <option value="{{ $jam }}"
                {{ old('jam_mulai_ke', $jamMulaiKe) == $jam ? 'selected' : '' }}>
                Jam ke-{{ $jam }} ({{ $waktu }})
            </option>
        @endforeach
    </select>
    @error('jam_mulai_ke')
    <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
    @enderror
</div>

<!-- Jam Selesai -->
<div>
    <label for="jam_selesai_ke" class="block text-sm font-medium text-gray-700 mb-2">
        Jam Selesai <span class="text-red-500">*</span>
    </label>
    <select
        id="jam_selesai_ke"
        name="jam_selesai_ke"
        required
        class="w-full rounded-lg border border-gray-300 px-4 py-2"
    >
        <option value="">Pilih Jam Selesai</option>
        @foreach ([
            1 => '07.15 - 07.55',
            2 => '07.55 - 08.35',
            3 => '08.35 - 09.15',
            4 => '09.15 - 09.55',
            5 => '10.30 - 11.10',
            6 => '11.10 - 11.50',
            7 => '11.50 - 12.30',
            8 => '12.30 - 13.10',
        ] as $jam => $waktu)
            <option value="{{ $jam }}"
                {{ old('jam_selesai_ke', $jamSelesaiKe) == $jam ? 'selected' : '' }}>
                Jam ke-{{ $jam }} ({{ $waktu }})
            </option>
        @endforeach
    </select>
    @error('jam_selesai_ke')
    <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
    @enderror
</div>

        </div>

        <div class="flex items-center justify-end gap-4 pt-6 border-t border-gray-200">
            <a href="{{ route('admin.penugasan.index') }}"
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
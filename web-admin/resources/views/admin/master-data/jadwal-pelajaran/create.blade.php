@extends('layouts.admin')

@section('content')

@php
    $jamPelajaran = [
        ['nomor' => 1, 'mulai' => '07:15', 'selesai' => '07:55'],
        ['nomor' => 2, 'mulai' => '07:55', 'selesai' => '08:35'],
        ['nomor' => 3, 'mulai' => '08:35', 'selesai' => '09:15'],
        ['nomor' => 4, 'mulai' => '09:15', 'selesai' => '09:55'],
        ['nomor' => 5, 'mulai' => '10:30', 'selesai' => '11:10'],
        ['nomor' => 6, 'mulai' => '11:10', 'selesai' => '11:50'],
        ['nomor' => 7, 'mulai' => '11:50', 'selesai' => '12:30'],
        ['nomor' => 8, 'mulai' => '12:30', 'selesai' => '13:10'],
    ];
@endphp

<div class="p-6">

    <h1 class="text-2xl font-bold text-slate-800 mb-6">
        Tambah Jadwal Pelajaran
    </h1>

    @if($errors->any())
        <div class="mb-5 bg-red-100 text-red-700 px-4 py-3 rounded-lg">
            <ul class="list-disc ml-5">
                @foreach($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
    @endif

    <form action="{{ route('admin.master-data.jadwal-pelajaran.store') }}"
          method="POST"
          class="bg-white rounded-xl border shadow-sm p-6">

        @csrf

        <div class="grid grid-cols-1 md:grid-cols-2 gap-5">

            <div>
                <label class="block text-sm font-semibold mb-2">
                    Periode Akademik
                </label>

                <select name="periode_id"
                        required
                        class="w-full border rounded-lg px-4 py-2.5">

                    <option value="">-- Pilih Periode --</option>

                    @foreach($periode as $item)
                        <option value="{{ $item->id }}"
                            @selected(old('periode_id') == $item->id)>
                            {{ $item->nama }}
                        </option>
                    @endforeach

                </select>
            </div>

            <div>
                <label class="block text-sm font-semibold mb-2">
                    Kelas
                </label>

                <select name="kelas_id"
                        required
                        class="w-full border rounded-lg px-4 py-2.5">

                    <option value="">-- Pilih Kelas --</option>

                    @foreach($kelas as $item)
                        <option value="{{ $item->id }}"
                            @selected(old('kelas_id') == $item->id)>
                            {{ $item->nama_kelas }}
                        </option>
                    @endforeach

                </select>
            </div>

            <div>
                <label class="block text-sm font-semibold mb-2">
                    Mata Pelajaran
                </label>

                <select name="mapel_id"
                        required
                        class="w-full border rounded-lg px-4 py-2.5">

                    <option value="">-- Pilih Mata Pelajaran --</option>

                    @foreach($mataPelajaran as $item)
                        <option value="{{ $item->id }}"
                            @selected(old('mapel_id') == $item->id)>
                            {{ $item->kode }} - {{ $item->nama }}
                        </option>
                    @endforeach

                </select>
            </div>

            <div>
                <label class="block text-sm font-semibold mb-2">
                    Guru
                </label>

                <select name="guru_id"
                        required
                        class="w-full border rounded-lg px-4 py-2.5">

                    <option value="">-- Pilih Guru --</option>

                    @foreach($guru as $item)
                        <option value="{{ $item->id }}"
                            @selected(old('guru_id') == $item->id)>
                            {{ $item->nama_lengkap }}
                        </option>
                    @endforeach

                </select>
            </div>

            <div>
                <label class="block text-sm font-semibold mb-2">
                    Hari
                </label>

                <select name="hari"
                        required
                        class="w-full border rounded-lg px-4 py-2.5">

                    <option value="">-- Pilih Hari --</option>

                    @foreach(['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'] as $hari)
                        <option value="{{ $hari }}"
                            @selected(old('hari') == $hari)>
                            {{ $hari }}
                        </option>
                    @endforeach

                </select>
            </div>

            <div>
                <label class="block text-sm font-semibold mb-2">
                    Ruangan
                </label>

                <input type="text"
                       name="ruangan"
                       value="{{ old('ruangan') }}"
                       class="w-full border rounded-lg px-4 py-2.5"
                       placeholder="Contoh: Lab Komputer">
            </div>

            {{-- Pilihan Jam Pelajaran --}}
            <div class="md:col-span-2">

                <label class="block text-sm font-semibold mb-2">
                    Jam Pelajaran
                </label>

                <select id="jam_pelajaran"
                        required
                        class="w-full border rounded-lg px-4 py-2.5">

                    <option value="">-- Pilih Jam Pelajaran --</option>

                    @foreach($jamPelajaran as $jam)
                        <option
                            value="{{ $jam['nomor'] }}"
                            data-mulai="{{ $jam['mulai'] }}"
                            data-selesai="{{ $jam['selesai'] }}"
                            @selected(
                                old('jam_mulai') === $jam['mulai'] &&
                                old('jam_selesai') === $jam['selesai']
                            )>

                            Jam ke-{{ $jam['nomor'] }}
                            ({{ $jam['mulai'] }} - {{ $jam['selesai'] }})

                        </option>
                    @endforeach

                </select>

                <p class="text-xs text-slate-500 mt-2">
                    Pilih jam pelajaran sesuai jadwal resmi sekolah.
                    Jam mulai dan selesai akan terisi otomatis.
                </p>

            </div>

            {{-- Jam Mulai --}}
            <div>
                <label class="block text-sm font-semibold mb-2">
                    Jam Mulai
                </label>

                <input type="time"
                       id="jam_mulai_display"
                       value="{{ old('jam_mulai') }}"
                       readonly
                       class="w-full border rounded-lg px-4 py-2.5 bg-slate-100 cursor-not-allowed"
                       placeholder="Otomatis">
                       
                <input type="hidden"
                       name="jam_mulai"
                       id="jam_mulai"
                       value="{{ old('jam_mulai') }}">
            </div>

            {{-- Jam Selesai --}}
            <div>
                <label class="block text-sm font-semibold mb-2">
                    Jam Selesai
                </label>

                <input type="time"
                       id="jam_selesai_display"
                       value="{{ old('jam_selesai') }}"
                       readonly
                       class="w-full border rounded-lg px-4 py-2.5 bg-slate-100 cursor-not-allowed"
                       placeholder="Otomatis">

                <input type="hidden"
                       name="jam_selesai"
                       id="jam_selesai"
                       value="{{ old('jam_selesai') }}">
            </div>

        </div>

        <div class="flex gap-3 mt-6">

            <a href="{{ route('admin.master-data.jadwal-pelajaran.index') }}"
               class="px-5 py-2.5 bg-slate-100 rounded-lg">
                Batal
            </a>

            <button type="submit"
                    class="px-5 py-2.5 bg-blue-600 text-white rounded-lg">
                Simpan Jadwal
            </button>

        </div>

    </form>

</div>

<script>
document.addEventListener('DOMContentLoaded', function () {

    const pilihanJam = document.getElementById('jam_pelajaran');

    const jamMulai = document.getElementById('jam_mulai');
    const jamSelesai = document.getElementById('jam_selesai');

    const jamMulaiDisplay = document.getElementById('jam_mulai_display');
    const jamSelesaiDisplay = document.getElementById('jam_selesai_display');

    function updateJam() {

        const selectedOption = pilihanJam.options[pilihanJam.selectedIndex];

        if (!selectedOption || !selectedOption.dataset.mulai) {

            jamMulai.value = '';
            jamSelesai.value = '';

            jamMulaiDisplay.value = '';
            jamSelesaiDisplay.value = '';

            return;
        }

        const mulai = selectedOption.dataset.mulai;
        const selesai = selectedOption.dataset.selesai;

        jamMulai.value = mulai;
        jamSelesai.value = selesai;

        jamMulaiDisplay.value = mulai;
        jamSelesaiDisplay.value = selesai;
    }

    pilihanJam.addEventListener('change', updateJam);

    // Mengisi kembali jam ketika halaman dibuka ulang
    updateJam();

});
</script>

@endsection
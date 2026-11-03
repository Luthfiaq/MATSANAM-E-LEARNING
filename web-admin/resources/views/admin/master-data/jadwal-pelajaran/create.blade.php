@extends('layouts.admin')

@section('content')

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
                        <option value="{{ $item->id }}">
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
                        <option value="{{ $item->id }}">
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
                        <option value="{{ $item->id }}">
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
                        <option value="{{ $item->id }}">
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

                    <option>Senin</option>
                    <option>Selasa</option>
                    <option>Rabu</option>
                    <option>Kamis</option>
                    <option>Jumat</option>
                    <option>Sabtu</option>

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

            <div>
                <label class="block text-sm font-semibold mb-2">
                    Jam Mulai
                </label>

                <input type="time"
                       name="jam_mulai"
                       required
                       class="w-full border rounded-lg px-4 py-2.5">
            </div>

            <div>
                <label class="block text-sm font-semibold mb-2">
                    Jam Selesai
                </label>

                <input type="time"
                       name="jam_selesai"
                       required
                       class="w-full border rounded-lg px-4 py-2.5">
            </div>

        </div>

        <div class="flex gap-3 mt-6">

            <a href="{{ route('admin.master-data.jadwal-pelajaran.index') }}"
               class="px-5 py-2.5 bg-slate-100 rounded-lg">
                Batal
            </a>

            <button class="px-5 py-2.5 bg-blue-600 text-white rounded-lg">
                Simpan Jadwal
            </button>

        </div>

    </form>

</div>

@endsection
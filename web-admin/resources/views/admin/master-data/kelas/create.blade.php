@extends('layouts.admin')

@section('content')

<div class="p-6">

    {{-- HEADER --}}
    <div class="mb-6">

        <a href="{{ route('admin.master-data.kelas.index') }}"
           class="text-sm text-blue-600 hover:text-blue-700">

            ← Kembali ke Data Kelas

        </a>

        <h1 class="text-2xl font-bold text-slate-800 mt-3">
            Tambah Kelas
        </h1>

        <p class="text-sm text-slate-500 mt-1">
            Tambahkan data kelas baru ke sistem Matsanam.
        </p>

    </div>


    {{-- ERROR --}}
    @if($errors->any())

        <div class="mb-5 bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg">

            <ul class="list-disc pl-5">

                @foreach($errors->all() as $error)

                    <li>{{ $error }}</li>

                @endforeach

            </ul>

        </div>

    @endif


    {{-- FORM --}}
    <div class="bg-white rounded-xl shadow-sm border border-slate-200 p-6 max-w-3xl">

        <form action="{{ route('admin.master-data.kelas.store') }}"
              method="POST">

            @csrf


            {{-- NAMA KELAS --}}
            <div class="mb-5">

                <label class="block text-sm font-semibold text-slate-700 mb-2">
                    Nama Kelas
                </label>

                <input
                    type="text"
                    name="nama_kelas"
                    value="{{ old('nama_kelas') }}"
                    placeholder="Contoh: VII A"
                    class="w-full border border-slate-300 rounded-lg px-4 py-2.5 focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none"
                >

            </div>


            {{-- TINGKAT --}}
            <div class="mb-5">

                <label class="block text-sm font-semibold text-slate-700 mb-2">
                    Tingkat
                </label>

                <select
                    name="tingkat"
                    class="w-full border border-slate-300 rounded-lg px-4 py-2.5 focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none"
                >

                    <option value="">
                        -- Pilih Tingkat --
                    </option>

                    <option value="7" {{ old('tingkat') == '7' ? 'selected' : '' }}>
                        VII
                    </option>

                    <option value="8" {{ old('tingkat') == '8' ? 'selected' : '' }}>
                        VIII
                    </option>

                    <option value="9" {{ old('tingkat') == '9' ? 'selected' : '' }}>
                        IX
                    </option>

                </select>

            </div>


            {{-- WALI KELAS --}}
            <div class="mb-5">

                <label class="block text-sm font-semibold text-slate-700 mb-2">
                    Wali Kelas
                </label>

                <select
                    name="wali_kelas_id"
                    class="w-full border border-slate-300 rounded-lg px-4 py-2.5 focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none"
                >

                    <option value="">
                        -- Pilih Wali Kelas --
                    </option>

                    @foreach($guru as $item)

                        <option
                            value="{{ $item->id }}"
                            {{ old('wali_kelas_id') == $item->id ? 'selected' : '' }}
                        >

                            {{ $item->nama_lengkap }}

                        </option>

                    @endforeach

                </select>

            </div>


            {{-- KAPASITAS --}}
            <div class="mb-6">

                <label class="block text-sm font-semibold text-slate-700 mb-2">
                    Kapasitas Siswa
                </label>

                <input
                    type="number"
                    name="kapasitas"
                    value="{{ old('kapasitas', 30) }}"
                    min="1"
                    class="w-full border border-slate-300 rounded-lg px-4 py-2.5 focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none"
                >

            </div>


            {{-- BUTTON --}}
            <div class="flex items-center gap-3">

                <a href="{{ route('admin.master-data.kelas.index') }}"
                   class="px-5 py-2.5 rounded-lg border border-slate-300 text-slate-600 text-sm font-semibold hover:bg-slate-50">

                    Batal

                </a>

                <button
                    type="submit"
                    class="px-5 py-2.5 rounded-lg bg-blue-600 text-white text-sm font-semibold hover:bg-blue-700"
                >

                    Simpan Kelas

                </button>

            </div>

        </form>

    </div>

</div>

@endsection
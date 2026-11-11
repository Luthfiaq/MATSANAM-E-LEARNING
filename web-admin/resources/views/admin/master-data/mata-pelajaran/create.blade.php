@extends('layouts.admin')

@section('content')

<div class="p-6">

    {{-- HEADER --}}
    <div class="mb-6">

        <a href="{{ route('admin.master-data.mata-pelajaran.index') }}"
           class="text-sm text-blue-600 hover:text-blue-700">

            ← Kembali ke Data Mata Pelajaran

        </a>


        <h1 class="text-2xl font-bold text-slate-800 mt-3">
            Tambah Mata Pelajaran
        </h1>


        <p class="text-sm text-slate-500 mt-1">
            Tambahkan data mata pelajaran baru ke sistem Matsanam.
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

        <form
            action="{{ route('admin.master-data.mata-pelajaran.store') }}"
            method="POST"
        >

            @csrf


            {{-- KODE --}}
            <div class="mb-5">

                <label class="block text-sm font-semibold text-slate-700 mb-2">
                    Kode Mata Pelajaran
                </label>

                <input
                    type="text"
                    name="kode"
                    value="{{ old('kode') }}"
                    placeholder="Contoh: MTK"
                    class="w-full border border-slate-300 rounded-lg px-4 py-2.5 focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none"
                >

                <p class="text-xs text-slate-400 mt-1">
                    Kode mata pelajaran harus unik.
                </p>

            </div>


            {{-- NAMA --}}
            <div class="mb-5">

                <label class="block text-sm font-semibold text-slate-700 mb-2">
                    Nama Mata Pelajaran
                </label>

                <input
                    type="text"
                    name="nama"
                    value="{{ old('nama') }}"
                    placeholder="Contoh: Matematika"
                    class="w-full border border-slate-300 rounded-lg px-4 py-2.5 focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none"
                >

            </div>


            {{-- DESKRIPSI --}}
            <div class="mb-5">

                <label class="block text-sm font-semibold text-slate-700 mb-2">
                    Deskripsi
                </label>

                <textarea
                    name="deskripsi"
                    rows="4"
                    placeholder="Masukkan deskripsi mata pelajaran..."
                    class="w-full border border-slate-300 rounded-lg px-4 py-2.5 focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none"
                >{{ old('deskripsi') }}</textarea>

            </div>


            {{-- KKM --}}
            <div class="mb-6">

                <label class="block text-sm font-semibold text-slate-700 mb-2">
                    KKM
                </label>

                <input
                    type="number"
                    name="kkm"
                    value="{{ old('kkm', 75) }}"
                    min="0"
                    max="100"
                    class="w-full border border-slate-300 rounded-lg px-4 py-2.5 focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none"
                >

                <p class="text-xs text-slate-400 mt-1">
                    Nilai KKM antara 0 sampai 100.
                </p>

            </div>


            {{-- BUTTON --}}
            <div class="flex items-center gap-3">

                <a
                    href="{{ route('admin.master-data.mata-pelajaran.index') }}"
                    class="px-5 py-2.5 rounded-lg border border-slate-300 text-slate-600 text-sm font-semibold hover:bg-slate-50"
                >

                    Batal

                </a>


                <button
                    type="submit"
                    class="px-5 py-2.5 rounded-lg bg-blue-600 text-white text-sm font-semibold hover:bg-blue-700"
                >

                    Simpan Mata Pelajaran

                </button>

            </div>

        </form>

    </div>

</div>

@endsection
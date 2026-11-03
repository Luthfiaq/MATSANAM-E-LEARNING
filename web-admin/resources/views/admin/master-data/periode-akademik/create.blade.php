@extends('layouts.admin')

@section('content')

<div class="p-6">

    <h1 class="text-2xl font-bold text-slate-800 mb-6">
        Tambah Periode Akademik
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

    <form action="{{ route('admin.master-data.periode-akademik.store') }}"
          method="POST"
          class="bg-white rounded-xl border shadow-sm p-6">

        @csrf

        <div class="grid grid-cols-1 md:grid-cols-2 gap-5">

            <div>
                <label class="block text-sm font-semibold mb-2">
                    Nama Periode
                </label>

                <input type="text"
                       name="nama"
                       value="{{ old('nama') }}"
                       placeholder="Contoh: Tahun Ajaran 2025/2026"
                       required
                       class="w-full border rounded-lg px-4 py-2.5">
            </div>

            <div>
                <label class="block text-sm font-semibold mb-2">
                    Tahun Ajaran
                </label>

                <input type="text"
                       name="tahun_ajaran"
                       value="{{ old('tahun_ajaran') }}"
                       placeholder="2025/2026"
                       required
                       class="w-full border rounded-lg px-4 py-2.5">
            </div>

            <div>
                <label class="block text-sm font-semibold mb-2">
                    Semester
                </label>

                <select name="semester"
                        class="w-full border rounded-lg px-4 py-2.5">

                    <option value="Ganjil">Ganjil</option>
                    <option value="Genap">Genap</option>

                </select>
            </div>

            <div>
                <label class="block text-sm font-semibold mb-2">
                    Status
                </label>

                <select name="is_active"
                        class="w-full border rounded-lg px-4 py-2.5">

                    <option value="1">Aktif</option>
                    <option value="0">Tidak Aktif</option>

                </select>
            </div>

            <div>
                <label class="block text-sm font-semibold mb-2">
                    Tanggal Mulai
                </label>

                <input type="date"
                       name="tanggal_mulai"
                       required
                       class="w-full border rounded-lg px-4 py-2.5">
            </div>

            <div>
                <label class="block text-sm font-semibold mb-2">
                    Tanggal Selesai
                </label>

                <input type="date"
                       name="tanggal_selesai"
                       required
                       class="w-full border rounded-lg px-4 py-2.5">
            </div>

        </div>

        <div class="flex gap-3 mt-6">

            <a href="{{ route('admin.master-data.periode-akademik.index') }}"
               class="px-5 py-2.5 bg-slate-100 rounded-lg">
                Batal
            </a>

            <button class="px-5 py-2.5 bg-blue-600 text-white rounded-lg">
                Simpan
            </button>

        </div>

    </form>

</div>

@endsection
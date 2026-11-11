@extends('layouts.admin')

@section('content')

<div class="p-6">

    <div class="mb-6">
        <h1 class="text-2xl font-bold text-slate-800">
            Edit Guru
        </h1>

        <p class="text-sm text-slate-500 mt-1">
            Ubah data guru dan akun login.
        </p>
    </div>

    @if($errors->any())
        <div class="mb-5 bg-red-100 text-red-700 px-4 py-3 rounded-lg">
            <ul class="list-disc ml-5">
                @foreach($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
    @endif

    <form action="{{ route('admin.master-data.guru.update', $guru->id) }}"
          method="POST"
          class="bg-white rounded-xl shadow-sm border border-slate-200 p-6">

        @csrf
        @method('PUT')

        <div class="grid grid-cols-1 md:grid-cols-2 gap-5">

            <div>
                <label class="block text-sm font-semibold mb-2">
                    NIP
                </label>

                <input type="text"
                       name="nip"
                       value="{{ old('nip', $guru->nip) }}"
                       required
                       class="w-full border rounded-lg px-4 py-2.5">
            </div>

            <div>
                <label class="block text-sm font-semibold mb-2">
                    Nama Lengkap
                </label>

                <input type="text"
                       name="nama_lengkap"
                       value="{{ old('nama_lengkap', $guru->nama_lengkap) }}"
                       required
                       class="w-full border rounded-lg px-4 py-2.5">
            </div>

            <div>
                <label class="block text-sm font-semibold mb-2">
                    Jenis Kelamin
                </label>

                <select name="jenis_kelamin"
                        required
                        class="w-full border rounded-lg px-4 py-2.5">

                    <option value="L" {{ $guru->jenis_kelamin == 'L' ? 'selected' : '' }}>
                        Laki-laki
                    </option>

                    <option value="P" {{ $guru->jenis_kelamin == 'P' ? 'selected' : '' }}>
                        Perempuan
                    </option>

                </select>
            </div>

            <div>
                <label class="block text-sm font-semibold mb-2">
                    Telepon
                </label>

                <input type="text"
                       name="telepon"
                       value="{{ old('telepon', $guru->telepon) }}"
                       class="w-full border rounded-lg px-4 py-2.5">
            </div>

            <div class="md:col-span-2">
                <label class="block text-sm font-semibold mb-2">
                    Alamat
                </label>

                <textarea name="alamat"
                          rows="3"
                          class="w-full border rounded-lg px-4 py-2.5">{{ old('alamat', $guru->alamat) }}</textarea>
            </div>

            <div class="md:col-span-2">
                <hr>
                <h2 class="font-bold text-slate-700 mt-2">
                    Akun Login
                </h2>
            </div>

            <div>
                <label class="block text-sm font-semibold mb-2">
                    Email
                </label>

                <input type="email"
                       name="email"
                       value="{{ old('email', $guru->user->email ?? '') }}"
                       required
                       class="w-full border rounded-lg px-4 py-2.5">
            </div>

            

            <div>
                <label class="block text-sm font-semibold mb-2">
                    Status
                </label>

                <select name="is_active"
                        class="w-full border rounded-lg px-4 py-2.5">

                    <option value="1" {{ ($guru->user->is_active ?? false) ? 'selected' : '' }}>
                        Aktif
                    </option>

                    <option value="0" {{ !($guru->user->is_active ?? false) ? 'selected' : '' }}>
                        Nonaktif
                    </option>

                </select>
            </div>

        </div>

        <div class="flex gap-3 mt-6">

            <a href="{{ route('admin.master-data.guru.index') }}"
               class="px-5 py-2.5 bg-slate-100 text-slate-700 rounded-lg">
                Batal
            </a>

            <button type="submit"
                    class="px-5 py-2.5 bg-blue-600 text-white rounded-lg">
                Simpan Perubahan
            </button>

        </div>

    </form>

</div>

@endsection
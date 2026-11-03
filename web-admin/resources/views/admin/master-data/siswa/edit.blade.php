@extends('layouts.admin')

@section('content')

<div class="p-6">

    <div class="mb-6">
        <h1 class="text-2xl font-bold text-slate-800">
            Edit Siswa
        </h1>
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

    <form action="{{ route('admin.master-data.siswa.update', $siswa->id) }}"
          method="POST"
          class="bg-white rounded-xl shadow-sm border border-slate-200 p-6">

        @csrf
        @method('PUT')

        <div class="grid grid-cols-1 md:grid-cols-2 gap-5">

            <div>
                <label class="block text-sm font-semibold mb-2">NIS</label>

                <input type="text"
                       name="nis"
                       value="{{ old('nis', $siswa->nis) }}"
                       required
                       class="w-full border rounded-lg px-4 py-2.5">
            </div>

            <div>
                <label class="block text-sm font-semibold mb-2">NISN</label>

                <input type="text"
                       name="nisn"
                       value="{{ old('nisn', $siswa->nisn) }}"
                       required
                       class="w-full border rounded-lg px-4 py-2.5">
            </div>

            <div class="md:col-span-2">
                <label class="block text-sm font-semibold mb-2">
                    Nama Lengkap
                </label>

                <input type="text"
                       name="nama_lengkap"
                       value="{{ old('nama_lengkap', $siswa->nama_lengkap) }}"
                       required
                       class="w-full border rounded-lg px-4 py-2.5">
            </div>

            <div>
                <label class="block text-sm font-semibold mb-2">
                    Jenis Kelamin
                </label>

                <select name="jenis_kelamin"
                        class="w-full border rounded-lg px-4 py-2.5">

                    <option value="L" {{ $siswa->jenis_kelamin == 'L' ? 'selected' : '' }}>
                        Laki-laki
                    </option>

                    <option value="P" {{ $siswa->jenis_kelamin == 'P' ? 'selected' : '' }}>
                        Perempuan
                    </option>

                </select>
            </div>

            <div>
                <label class="block text-sm font-semibold mb-2">
                    Tanggal Lahir
                </label>

                <input type="date"
                       name="tanggal_lahir"
                       value="{{ old('tanggal_lahir', optional($siswa->tanggal_lahir)->format('Y-m-d')) }}"
                       required
                       class="w-full border rounded-lg px-4 py-2.5">
            </div>

            <div>
                <label class="block text-sm font-semibold mb-2">
                    Tempat Lahir
                </label>

                <input type="text"
                       name="tempat_lahir"
                       value="{{ old('tempat_lahir', $siswa->tempat_lahir) }}"
                       required
                       class="w-full border rounded-lg px-4 py-2.5">
            </div>

            <div>
                <label class="block text-sm font-semibold mb-2">
                    Kelas
                </label>

                <select name="kelas_id"
                        class="w-full border rounded-lg px-4 py-2.5">

                    <option value="">-- Belum Ada Kelas --</option>

                    @foreach($kelas as $item)

                        <option value="{{ $item->id }}"
                            {{ $siswa->kelas_id == $item->id ? 'selected' : '' }}>
                            {{ $item->nama_kelas }}
                        </option>

                    @endforeach

                </select>
            </div>

            <div>
                <label class="block text-sm font-semibold mb-2">
                    Nama Wali
                </label>

                <input type="text"
                       name="nama_wali"
                       value="{{ old('nama_wali', $siswa->nama_wali) }}"
                       class="w-full border rounded-lg px-4 py-2.5">
            </div>

            <div>
                <label class="block text-sm font-semibold mb-2">
                    Telepon Wali
                </label>

                <input type="text"
                       name="telepon_wali"
                       value="{{ old('telepon_wali', $siswa->telepon_wali) }}"
                       class="w-full border rounded-lg px-4 py-2.5">
            </div>

            <div class="md:col-span-2">
                <label class="block text-sm font-semibold mb-2">
                    Alamat
                </label>

                <textarea name="alamat"
                          rows="3"
                          class="w-full border rounded-lg px-4 py-2.5">{{ old('alamat', $siswa->alamat) }}</textarea>
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
                       value="{{ old('email', $siswa->user->email ?? '') }}"
                       required
                       class="w-full border rounded-lg px-4 py-2.5">
            </div>

            <div>
                <label class="block text-sm font-semibold mb-2">
                    Password Baru
                </label>

                <input type="password"
                       name="password"
                       class="w-full border rounded-lg px-4 py-2.5"
                       placeholder="Kosongkan jika tidak diubah">
            </div>

            <div>
                <label class="block text-sm font-semibold mb-2">
                    Status
                </label>

                <select name="is_active"
                        class="w-full border rounded-lg px-4 py-2.5">

                    <option value="1" {{ ($siswa->user->is_active ?? false) ? 'selected' : '' }}>
                        Aktif
                    </option>

                    <option value="0" {{ !($siswa->user->is_active ?? false) ? 'selected' : '' }}>
                        Nonaktif
                    </option>

                </select>
            </div>

        </div>

        <div class="flex gap-3 mt-6">

            <a href="{{ route('admin.master-data.siswa.index') }}"
               class="px-5 py-2.5 bg-slate-100 rounded-lg">
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
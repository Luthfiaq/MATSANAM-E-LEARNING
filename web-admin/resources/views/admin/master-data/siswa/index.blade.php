@extends('layouts.admin')

@section('content')

<div class="p-6">

    <div class="flex justify-between items-center mb-6">

        <div>
            <h1 class="text-2xl font-bold text-slate-800">
                Data Siswa
            </h1>

            <p class="text-sm text-slate-500 mt-1">
                Kelola data siswa dan akun siswa.
            </p>
        </div>

        <a href="{{ route('admin.master-data.siswa.create') }}"
           class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg text-sm font-semibold">
            + Tambah Siswa
        </a>

    </div>

    <form method="GET" action="{{ route('admin.master-data.siswa.index') }}" class="mb-5 rounded-xl border border-slate-200 bg-white p-4 shadow-sm">
        <div class="grid grid-cols-1 gap-3 md:grid-cols-2 xl:grid-cols-4 xl:items-end">
            <div>
                <label for="q" class="mb-1 block text-xs font-semibold text-slate-600">Pencarian</label>
                <input id="q" name="q" type="search" value="{{ $search }}" placeholder="Cari nama, NIS, NISN, atau email siswa..."
                       class="w-full rounded-lg border border-slate-300 px-3 py-2.5 text-sm text-slate-800 placeholder:text-slate-400 focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-100">
            </div>
            <div>
                <label for="kelas" class="mb-1 block text-xs font-semibold text-slate-600">Kelas</label>
                <select id="kelas" name="kelas" class="w-full rounded-lg border border-slate-300 px-3 py-2.5 text-sm text-slate-800 focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-100">
                    <option value="">Semua Kelas</option>
                    @foreach($kelasList as $kelasOption)
                        <option value="{{ $kelasOption->id }}" {{ (string) $kelasFilter === (string) $kelasOption->id ? 'selected' : '' }}>{{ $kelasOption->nama_kelas }}</option>
                    @endforeach
                </select>
            </div>
            <div>
                <label for="status" class="mb-1 block text-xs font-semibold text-slate-600">Status</label>
                <select id="status" name="status" class="w-full rounded-lg border border-slate-300 px-3 py-2.5 text-sm text-slate-800 focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-100">
                    <option value="">Semua Status</option>
                    <option value="aktif" {{ ($status) == 'aktif' ? 'selected' : '' }}>Aktif</option>
                    <option value="nonaktif" {{ ($status) == 'nonaktif' ? 'selected' : '' }}>Nonaktif</option>
                </select>
            </div>

            <div class="flex gap-2">
                <button type="submit" class="flex-1 rounded-lg bg-blue-600 px-4 py-2.5 text-sm font-semibold text-white hover:bg-blue-700">Terapkan</button>
                <a href="{{ route('admin.master-data.siswa.index') }}" class="rounded-lg border border-slate-300 px-4 py-2.5 text-sm font-semibold text-slate-600 hover:bg-slate-50">Reset</a>
            </div>
        </div>
    </form>


    @if(session('success'))
        <div class="mb-5 bg-green-100 text-green-700 px-4 py-3 rounded-lg">
            {{ session('success') }}
        </div>
    @endif

    @if($errors->any())
        <div class="mb-5 bg-red-100 text-red-700 px-4 py-3 rounded-lg">
            <ul class="list-disc ml-5">
                @foreach($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
    @endif

    <div class="bg-white rounded-xl shadow-sm border border-slate-200 overflow-hidden">

        <div class="overflow-x-auto">

            <table class="w-full text-sm">

                <thead class="bg-slate-50 border-b">

                    <tr>
                        <th class="px-5 py-4 text-left">No</th>
                        <th class="px-5 py-4 text-left">NIS</th>
                        <th class="px-5 py-4 text-left">NISN</th>
                        <th class="px-5 py-4 text-left">Nama</th>
                        <th class="px-5 py-4 text-left">Jenis Kelamin</th>
                        <th class="px-5 py-4 text-left">Kelas</th>
                        <th class="px-5 py-4 text-left">Email</th>
                        <th class="px-5 py-4 text-left">Status</th>
                        <th class="px-5 py-4 text-left">Aksi</th>
                    </tr>

                </thead>

                <tbody>

                    @forelse($siswa as $item)

                        <tr class="border-b hover:bg-slate-50">

                            <td class="px-5 py-4">
                                {{ $siswa->firstItem() + $loop->index }}
                            </td>

                            <td class="px-5 py-4">
                                {{ $item->nis }}
                            </td>

                            <td class="px-5 py-4">
                                {{ $item->nisn }}
                            </td>

                            <td class="px-5 py-4 font-semibold">
                                {{ $item->nama_lengkap }}
                            </td>

                            <td class="px-5 py-4">
                                {{ $item->jenis_kelamin == 'L' ? 'Laki-laki' : 'Perempuan' }}
                            </td>

                            <td class="px-5 py-4">
                                {{ $item->kelas->nama_kelas ?? '-' }}
                            </td>

                            <td class="px-5 py-4">
                                {{ $item->user->email ?? '-' }}
                            </td>

                            <td class="px-5 py-4">

                                @if($item->user && $item->user->is_active)

                                    <span class="px-2 py-1 rounded-full text-xs font-semibold bg-green-100 text-green-700">
                                        Aktif
                                    </span>

                                @else

                                    <span class="px-2 py-1 rounded-full text-xs font-semibold bg-red-100 text-red-700">
                                        Nonaktif
                                    </span>

                                @endif

                            </td>

                            <td class="px-5 py-4">

                                <div class="flex gap-2">

                                    <a href="{{ route('admin.master-data.siswa.edit', $item->id) }}"
                                       class="px-3 py-1.5 bg-yellow-100 text-yellow-700 rounded-lg text-xs font-semibold">
                                        Edit
                                    </a>

                                    <form action="{{ route('admin.master-data.siswa.destroy', $item->id) }}"
                                          method="POST"
                                          onsubmit="return confirm('Yakin ingin menghapus data siswa ini?')">

                                        @csrf
                                        @method('DELETE')

                                        <button type="submit"
                                                class="px-3 py-1.5 bg-red-100 text-red-700 rounded-lg text-xs font-semibold">
                                            Hapus
                                        </button>

                                    </form>

                                </div>

                            </td>

                        </tr>

                    @empty

                        <tr>
                            <td colspan="9" class="px-5 py-10 text-center text-slate-400">
                                Tidak ada data siswa yang cocok dengan pencarian atau filter.
                            </td>
                        </tr>

                    @endforelse

                </tbody>

            </table>

        </div>

    </div>

</div>


<div class="mt-5">{{ $siswa->links() }}</div>

@endsection
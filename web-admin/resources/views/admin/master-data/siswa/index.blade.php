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
                                {{ $loop->iteration }}
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
                                Belum ada data siswa.
                            </td>
                        </tr>

                    @endforelse

                </tbody>

            </table>

        </div>

    </div>

</div>

@endsection
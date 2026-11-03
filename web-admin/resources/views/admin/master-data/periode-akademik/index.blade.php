@extends('layouts.admin')

@section('content')

<div class="p-6">

    <div class="flex justify-between items-center mb-6">

        <div>
            <h1 class="text-2xl font-bold text-slate-800">
                Periode Akademik
            </h1>

            <p class="text-sm text-slate-500 mt-1">
                Kelola tahun ajaran dan semester akademik.
            </p>
        </div>

        <a href="{{ route('admin.master-data.periode-akademik.create') }}"
           class="bg-blue-600 text-white px-4 py-2 rounded-lg">
            + Tambah Periode
        </a>

    </div>

    @if(session('success'))
        <div class="mb-5 bg-green-100 text-green-700 px-4 py-3 rounded-lg">
            {{ session('success') }}
        </div>
    @endif

    <div class="bg-white rounded-xl shadow-sm border overflow-hidden">

        <div class="overflow-x-auto">

            <table class="w-full text-sm">

                <thead class="bg-slate-50 border-b">

                    <tr>
                        <th class="px-5 py-4 text-left">No</th>
                        <th class="px-5 py-4 text-left">Nama</th>
                        <th class="px-5 py-4 text-left">Tahun Ajaran</th>
                        <th class="px-5 py-4 text-left">Semester</th>
                        <th class="px-5 py-4 text-left">Mulai</th>
                        <th class="px-5 py-4 text-left">Selesai</th>
                        <th class="px-5 py-4 text-left">Status</th>
                        <th class="px-5 py-4 text-left">Aksi</th>
                    </tr>

                </thead>

                <tbody>

                    @forelse($periode as $item)

                        <tr class="border-b hover:bg-slate-50">

                            <td class="px-5 py-4">
                                {{ $loop->iteration }}
                            </td>

                            <td class="px-5 py-4 font-semibold">
                                {{ $item->nama }}
                            </td>

                            <td class="px-5 py-4">
                                {{ $item->tahun_ajaran }}
                            </td>

                            <td class="px-5 py-4">
                                {{ $item->semester }}
                            </td>

                            <td class="px-5 py-4">
                                {{ optional($item->tanggal_mulai)->format('d-m-Y') }}
                            </td>

                            <td class="px-5 py-4">
                                {{ optional($item->tanggal_selesai)->format('d-m-Y') }}
                            </td>

                            <td class="px-5 py-4">

                                @if($item->is_active)

                                    <span class="px-2 py-1 rounded-full bg-green-100 text-green-700 text-xs font-semibold">
                                        Aktif
                                    </span>

                                @else

                                    <span class="px-2 py-1 rounded-full bg-slate-100 text-slate-500 text-xs font-semibold">
                                        Tidak Aktif
                                    </span>

                                @endif

                            </td>

                            <td class="px-5 py-4">

                                <div class="flex gap-2">

                                    <a href="{{ route('admin.master-data.periode-akademik.edit', $item->id) }}"
                                       class="px-3 py-1.5 bg-yellow-100 text-yellow-700 rounded-lg text-xs">
                                        Edit
                                    </a>

                                    <form action="{{ route('admin.master-data.periode-akademik.destroy', $item->id) }}"
                                          method="POST"
                                          onsubmit="return confirm('Yakin ingin menghapus periode ini?')">

                                        @csrf
                                        @method('DELETE')

                                        <button class="px-3 py-1.5 bg-red-100 text-red-700 rounded-lg text-xs">
                                            Hapus
                                        </button>

                                    </form>

                                </div>

                            </td>

                        </tr>

                    @empty

                        <tr>
                            <td colspan="8" class="text-center py-10 text-slate-400">
                                Belum ada periode akademik.
                            </td>
                        </tr>

                    @endforelse

                </tbody>

            </table>

        </div>

    </div>

</div>

@endsection
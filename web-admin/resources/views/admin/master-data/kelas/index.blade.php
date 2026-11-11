@extends('layouts.admin')

@section('content')

<div class="p-6">

    {{-- HEADER --}}
    <div class="mb-6">

        <div class="flex items-center justify-between">

            <div>
                <h1 class="text-2xl font-bold text-slate-800">
                    Master Data Kelas
                </h1>

                <p class="text-sm text-slate-500 mt-1">
                    Kelola data kelas pada sistem Matsanam.
                </p>
            </div>

            <a href="{{ route('admin.master-data.kelas.create') }}"
               class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg text-sm font-semibold">

                + Tambah Kelas

            </a>

        </div>

    </div>


    {{-- SUCCESS MESSAGE --}}
    @if(session('success'))

        <div class="mb-5 bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-lg">

            {{ session('success') }}

        </div>

    @endif


    {{-- ERROR MESSAGE --}}
    @if($errors->any())

        <div class="mb-5 bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg">

            <ul class="list-disc pl-5">

                @foreach($errors->all() as $error)

                    <li>{{ $error }}</li>

                @endforeach

            </ul>

        </div>

    @endif


    {{-- TABLE --}}
    <div class="bg-white rounded-xl shadow-sm border border-slate-200 overflow-hidden">

        <div class="px-6 py-4 border-b border-slate-200">

            <h2 class="text-lg font-semibold text-slate-800">
                Data Kelas
            </h2>

            <p class="text-sm text-slate-500 mt-1">
                Total {{ $kelas->count() }} kelas
            </p>

        </div>


        <div class="overflow-x-auto">

            <table class="w-full text-sm">

                <thead class="bg-slate-50 border-b border-slate-200">

                    <tr>

                        <th class="px-6 py-4 text-left font-semibold text-slate-600">
                            No
                        </th>

                        <th class="px-6 py-4 text-left font-semibold text-slate-600">
                            Nama Kelas
                        </th>

                        <th class="px-6 py-4 text-left font-semibold text-slate-600">
                            Tingkat
                        </th>

                        <th class="px-6 py-4 text-left font-semibold text-slate-600">
                            Wali Kelas
                        </th>

                        <th class="px-6 py-4 text-left font-semibold text-slate-600">
                            Kapasitas
                        </th>

                        <th class="px-6 py-4 text-center font-semibold text-slate-600">
                            Aksi
                        </th>

                    </tr>

                </thead>


                <tbody class="divide-y divide-slate-100">

                    @forelse($kelas as $item)

                        <tr class="hover:bg-slate-50">

                            <td class="px-6 py-4">
                                {{ $loop->iteration }}
                            </td>

                            <td class="px-6 py-4 font-semibold text-slate-700">
                                {{ $item->nama_kelas }}
                            </td>

                            <td class="px-6 py-4">
                                {{ $item->tingkat }}
                            </td>

                            <td class="px-6 py-4">
                                {{ $item->waliKelas->nama_lengkap ?? '-' }}
                            </td>

                            <td class="px-6 py-4">
                                {{ $item->kapasitas }} siswa
                            </td>

                            <td class="px-6 py-4">

                                <div class="flex justify-center gap-2">

                                    {{-- EDIT --}}
                                    <a href="{{ route('admin.master-data.kelas.edit', $item->id) }}"
                                       class="px-3 py-1.5 rounded-lg bg-yellow-50 text-yellow-600 text-xs font-semibold hover:bg-yellow-100">

                                        Edit

                                    </a>


                                    {{-- DELETE --}}
                                    <form action="{{ route('admin.master-data.kelas.destroy', $item->id) }}"
                                          method="POST"
                                          onsubmit="return confirm('Yakin ingin menghapus data kelas ini?')">

                                        @csrf

                                        @method('DELETE')

                                        <button type="submit"
                                                class="px-3 py-1.5 rounded-lg bg-red-50 text-red-600 text-xs font-semibold hover:bg-red-100">

                                            Hapus

                                        </button>

                                    </form>

                                </div>

                            </td>

                        </tr>

                    @empty

                        <tr>

                            <td colspan="6" class="px-6 py-12 text-center">

                                <div class="text-4xl mb-3">
                                    🏫
                                </div>

                                <p class="text-slate-600 font-semibold">
                                    Belum ada data kelas
                                </p>

                                <p class="text-slate-400 text-sm mt-1">
                                    Silakan tambahkan data kelas baru.
                                </p>

                            </td>

                        </tr>

                    @endforelse

                </tbody>

            </table>

        </div>

    </div>

</div>


<div class="mt-5">{{ $kelas->links() }}</div>

@endsection
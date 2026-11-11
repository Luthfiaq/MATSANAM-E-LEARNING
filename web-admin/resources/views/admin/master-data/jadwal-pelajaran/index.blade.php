@extends('layouts.admin')

@section('content')

<div class="p-6">

    <div class="flex justify-between items-center mb-6">

        <div>
            <h1 class="text-2xl font-bold text-slate-800">
                Jadwal Pelajaran
            </h1>

            <p class="text-sm text-slate-500 mt-1">
                Kelola jadwal pelajaran sekolah.
            </p>
        </div>

        <a href="{{ route('admin.master-data.jadwal-pelajaran.create') }}"
           class="bg-blue-600 text-white px-4 py-2 rounded-lg">
            + Tambah Jadwal
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
                        <th class="px-5 py-4 text-left">Hari</th>
                        <th class="px-5 py-4 text-left">Jam</th>
                        <th class="px-5 py-4 text-left">Kelas</th>
                        <th class="px-5 py-4 text-left">Mata Pelajaran</th>
                        <th class="px-5 py-4 text-left">Guru</th>
                        <th class="px-5 py-4 text-left">Ruangan</th>
                        <th class="px-5 py-4 text-left">Periode</th>
                        <th class="px-5 py-4 text-left">Aksi</th>
                    </tr>

                </thead>

                <tbody>

                    @forelse($jadwal as $item)

                        <tr class="border-b hover:bg-slate-50">

                            <td class="px-5 py-4">
                                {{ $loop->iteration }}
                            </td>

                            <td class="px-5 py-4 font-semibold">
                                {{ $item->hari }}
                            </td>

                            <td class="px-5 py-4">
                                {{ substr($item->jam_mulai, 0, 5) }}
                                -
                                {{ substr($item->jam_selesai, 0, 5) }}
                            </td>

                            <td class="px-5 py-4">
                                {{ $item->kelas->nama_kelas ?? '-' }}
                            </td>

                            <td class="px-5 py-4">
                                {{ $item->mataPelajaran->nama ?? '-' }}
                            </td>

                            <td class="px-5 py-4">
                                {{ $item->guru->nama_lengkap ?? '-' }}
                            </td>

                            <td class="px-5 py-4">
                                {{ $item->ruangan ?? '-' }}
                            </td>

                            <td class="px-5 py-4">
                                {{ $item->periode->nama ?? '-' }}
                            </td>

                            <td class="px-5 py-4">

                                <div class="flex gap-2">

                                    <a href="{{ route('admin.master-data.jadwal-pelajaran.edit', $item->id) }}"
                                       class="px-3 py-1.5 bg-yellow-100 text-yellow-700 rounded-lg text-xs">
                                        Edit
                                    </a>

                                    <form action="{{ route('admin.master-data.jadwal-pelajaran.destroy', $item->id) }}"
                                          method="POST"
                                          onsubmit="return confirm('Yakin ingin menghapus jadwal ini?')">

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
                            <td colspan="9" class="text-center py-10 text-slate-400">
                                Belum ada jadwal pelajaran.
                            </td>
                        </tr>

                    @endforelse

                </tbody>

            </table>

        </div>

    </div>

</div>


<div class="mt-5">{{ $jadwal->links() }}</div>

@endsection
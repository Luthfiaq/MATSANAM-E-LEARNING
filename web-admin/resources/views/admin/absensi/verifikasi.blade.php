@extends('layouts.admin')

@section('title', 'Verifikasi Surat Absensi')

@section('content')
<div class="mb-6 flex items-center justify-between">
    <div>
        <h1 class="text-2xl font-bold text-gray-900">Verifikasi Surat Absensi</h1>
        <p class="text-sm text-gray-500">Validasi surat izin/sakit siswa</p>
    </div>
</div>

<div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
    <div class="bg-white p-4 rounded-lg shadow-sm text-center">
        <div class="text-3xl font-bold text-amber-600">{{ $totalPending }}</div>
        <div class="text-xs text-gray-500 mt-1">Pending</div>
    </div>
    <div class="bg-white p-4 rounded-lg shadow-sm text-center">
        <div class="text-3xl font-bold text-green-600">{{ $totalDisetujui }}</div>
        <div class="text-xs text-gray-500 mt-1">Disetujui</div>
    </div>
    <div class="bg-white p-4 rounded-lg shadow-sm text-center">
        <div class="text-3xl font-bold text-red-600">{{ $totalDitolak }}</div>
        <div class="text-xs text-gray-500 mt-1">Ditolak</div>
    </div>
    <div class="bg-white p-4 rounded-lg shadow-sm text-center">
        <div class="text-3xl font-bold text-blue-600">{{ $totalPending + $totalDisetujui + $totalDitolak }}</div>
        <div class="text-xs text-gray-500 mt-1">Total</div>
    </div>
</div>

<div class="bg-white rounded-lg shadow-sm overflow-hidden">
    <div class="border-b border-gray-200 px-6 py-4 flex flex-col md:flex-row md:items-center gap-4">
        <select id="filterStatus" class="rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none">
            <option value="">Semua Status</option>
            <option value="pending">Pending</option>
            <option value="disetujui">Disetujui</option>
            <option value="ditolak">Ditolak</option>
        </select>
        <input type="text" id="searchSiswa" placeholder="Cari nama/nisn siswa..." class="flex-1 rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none">
    </div>

    <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
                <tr>
                    <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Siswa</th>
                    <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Kelas</th>
                    <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Rentang Tanggal</th>
                    <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Jenis & Alasan</th>
                    <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Bukti</th>
                    <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Status</th>
                    <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 uppercase tracking-wider">Aksi</th>
                </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200" id="suratTableBody">
                @forelse($surats as $surat)
                <tr class="hover:bg-gray-50" data-status="{{ $surat->status_verifikasi }}">
                    <td class="px-6 py-4">
                        <div class="flex items-center gap-3">
                            <div class="flex h-10 w-10 items-center justify-center rounded-full bg-blue-100 text-sm font-semibold text-blue-700">
                                {{ strtoupper(substr($surat->siswa->nama_lengkap, 0, 2)) }}
                            </div>
                            <div>
                                <div class="font-semibold text-gray-900">{{ $surat->siswa->nama_lengkap }}</div>
                                <div class="text-xs text-gray-500">NISN: {{ $surat->siswa->nisn }}</div>
                            </div>
                        </div>
                    </td>
                    <td class="px-6 py-4">
                        <span class="inline-flex rounded-full bg-blue-50 px-2 py-1 text-xs font-medium text-blue-700">
                            {{ $surat->siswa->kelas->nama_kelas ?? '-' }}
                        </span>
                    </td>
                    <td class="px-6 py-4">
                        <div class="text-sm text-gray-900">
                            {{ $surat->tanggal_mulai->diffInDays($surat->tanggal_selesai) + 1 }} hari
                        </div>
                        <div class="text-xs text-gray-500">
                            {{ $surat->tanggal_mulai->format('d M Y') }} - {{ $surat->tanggal_selesai->format('d M Y') }}
                        </div>
                    </td>
                    <td class="px-6 py-4">
                        <div class="flex items-center gap-2 mb-1">
                            <span class="inline-flex items-center gap-1 rounded-full px-2.5 py-1 text-xs font-medium {{ $surat->jenis === 'sakit' ? 'bg-red-50 text-red-700' : 'bg-amber-50 text-amber-700' }}">
                                {{ $surat->jenis === 'sakit' ? '🤒 Sakit' : '📄 Izin' }}
                            </span>
                        </div>
                        <div class="text-xs text-gray-600 line-clamp-2">{{ $surat->alasan }}</div>
                    </td>
                    <td class="px-6 py-4">
                        @if($surat->file_surat)
                        <a href="{{ asset('storage/' . $surat->file_surat) }}" 
                           target="_blank" 
                           class="text-blue-600 hover:text-blue-700 flex items-center gap-1 text-sm">
                            <span>📎</span> Lihat Surat
                        </a>
                        @else
                        <span class="text-xs text-gray-400">-</span>
                        @endif
                    </td>
                    <td class="px-6 py-4">
                        @php
                            $statusLabel = match($surat->status_verifikasi) {
                                'pending' => ['Pending', 'bg-amber-50 text-amber-700'],
                                'disetujui' => ['Disetujui', 'bg-green-50 text-green-700'],
                                'ditolak' => ['Ditolak', 'bg-red-50 text-red-700'],
                            };
                        @endphp
                        <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium {{ $statusLabel[1] }}">
                            {{ $statusLabel[0] }}
                        </span>
                    </td>
                    <td class="px-6 py-4 text-right">
                        @if($surat->status_verifikasi === 'pending')
                        <div class="flex items-center justify-end gap-2">
                            <button onclick="approveSurat({{ $surat->id }})" 
                                    class="inline-flex items-center gap-1 rounded-lg bg-green-600 px-3 py-1.5 text-xs font-medium text-white hover:bg-green-700 transition">
                                ✓ Terima
                            </button>
                            <button onclick="rejectSurat({{ $surat->id }})" 
                                    class="inline-flex items-center gap-1 rounded-lg bg-red-600 px-3 py-1.5 text-xs font-medium text-white hover:bg-red-700 transition">
                                ✗ Tolak
                            </button>
                        </div>
                        @elseif($surat->status_verifikasi === 'disetujui')
                        <div class="text-xs text-green-600 font-medium">
                            {{ $surat->verifikator ? 'Oleh: ' . $surat->verifikator->name : 'Sistem' }}
                        </div>
                        @elseif($surat->status_verifikasi === 'ditolak')
                        <div class="text-xs text-red-600 font-medium">
                            {{ $surat->catatan_verifikasi ?? 'Alasan tidak tercatat' }}
                        </div>
                        @endif
                    </td>
                </tr>
                @empty
                <tr>
                    <td colspan="7" class="px-6 py-12 text-center text-gray-500">
                        <div class="flex flex-col items-center gap-2">
                            <span class="text-4xl">📭</span>
                            <span>Tidak ada data surat absensi</span>
                        </div>
                    </td>
                </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    @if($surats->hasPages())
    <div class="px-6 py-4 border-t border-gray-200">
        {{ $surats->links() }}
    </div>
    @endif
</div>

<script>
function approveSurat(id) {
    if (confirm('Setujui surat ini?')) {
        fetch(`/admin/absensi/surat/${id}/approve`, {
            method: 'POST',
            headers: {
                'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
            }
        })
        .then(response => response.json())
        .then(data => {
            location.reload();
        })
        .catch(error => {
            alert('Gagal menyetujui surat');
        });
    }
}

function rejectSurat(id) {
    const catatan = prompt('Masukkan alasan penolakan:');
    if (catatan === null) return;

    fetch(`/admin/absensi/surat/${id}/reject`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
        },
        body: JSON.stringify({ catatan })
    })
    .then(response => response.json())
    .then(data => {
        location.reload();
    })
    .catch(error => {
        alert('Gagal menolak surat');
    });
}

document.getElementById('filterStatus').addEventListener('change', function() {
    const status = this.value;
    const rows = document.querySelectorAll('#suratTableBody tr');
    
    rows.forEach(row => {
        if (status === '' || row.dataset.status === status) {
            row.style.display = '';
        } else {
            row.style.display = 'none';
        }
    });
});

document.getElementById('searchSiswa').addEventListener('input', function() {
    const query = this.value.toLowerCase();
    const rows = document.querySelectorAll('#suratTableBody tr');
    
    rows.forEach(row => {
        const text = row.innerText.toLowerCase();
        row.style.display = text.includes(query) ? '' : 'none';
    });
});
</script>
@endsection

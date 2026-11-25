<!doctype html>
<html lang="id">
<head>
<meta charset="utf-8">
<title>Rincian Nilai Mata Pelajaran</title>
<style>
    @page { margin: 28px 32px; }
    body { font-family: DejaVu Sans, sans-serif; color: #172033; font-size: 10px; }
    h1 { margin: 0; font-size: 18px; text-align: center; }
    .subtitle { text-align: center; color: #475569; margin: 4px 0 18px; }
    .meta { width: 100%; border-collapse: collapse; margin-bottom: 14px; }
    .meta td { padding: 5px 7px; border: 1px solid #dbe3ee; }
    .summary { background: #eff6ff; border: 1px solid #bfdbfe; padding: 10px; margin-bottom: 14px; }
    table.data { width: 100%; border-collapse: collapse; }
    .data th, .data td { border: 1px solid #cbd5e1; padding: 7px; text-align: left; vertical-align: top; }
    .data th { background: #eaf0f8; }
    .muted { color: #64748b; }
    .footer { margin-top: 18px; text-align: right; color: #64748b; font-size: 9px; }
</style>
</head>
<body>
    <h1>MTsN 6 NGANJUK</h1>
    <div class="subtitle">RINCIAN HASIL PENILAIAN MATA PELAJARAN</div>
    <table class="meta">
        <tr><td><strong>Nama Siswa</strong></td><td>{{ $siswa->nama_lengkap ?? '-' }}</td><td><strong>Kelas</strong></td><td>{{ $siswa->kelas?->nama_kelas ?? '-' }}</td></tr>
        <tr><td><strong>Mata Pelajaran</strong></td><td>{{ $mapel->nama ?? '-' }}</td><td><strong>KKM</strong></td><td>{{ $mapel->kkm ?? '-' }}</td></tr>
    </table>
    <div class="summary">
        <strong>Rata-rata nilai:</strong> {{ $rataRata === null ? 'Belum tersedia' : number_format((float) $rataRata, 1, ',', '.') }}
        &nbsp; | &nbsp; <strong>Jumlah penilaian:</strong> {{ count($hasil) }}
    </div>
    <table class="data">
        <thead><tr><th style="width:28px">No.</th><th>Tugas / Penilaian</th><th>Jenis</th><th>Nilai</th><th>Status</th><th>Catatan Guru</th></tr></thead>
        <tbody>
        @forelse($hasil as $i => $item)
            <tr>
                <td>{{ $i + 1 }}</td>
                <td>{{ $item['judul_tugas'] ?? '-' }}<br><span class="muted">{{ $item['tanggal_penilaian'] ? \Carbon\Carbon::parse($item['tanggal_penilaian'])->timezone('Asia/Jakarta')->format('d/m/Y') : 'Belum dinilai' }}</span></td>
                <td>{{ $item['jenis'] ?? 'Tugas' }}</td>
                <td>{{ $item['nilai'] === null ? '-' : number_format((float) $item['nilai'], 1, ',', '.') }}</td>
                <td>{{ $item['status_ketuntasan'] === 'tuntas' ? 'Tuntas' : ($item['status_ketuntasan'] === 'belum_tuntas' ? 'Belum Tuntas' : 'Menunggu') }}</td>
                <td>{{ $item['catatan'] ?: '-' }}</td>
            </tr>
        @empty
            <tr><td colspan="6" style="text-align:center">Belum ada penilaian untuk mata pelajaran ini.</td></tr>
        @endforelse
        </tbody>
    </table>
    <div class="footer">Dicetak pada {{ $dicetakPada->format('d/m/Y H:i') }} WIB</div>
</body>
</html>

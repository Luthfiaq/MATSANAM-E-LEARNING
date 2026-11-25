<!doctype html>
<html lang="id">
<head>
<meta charset="utf-8">
<title>Rekap Nilai Siswa</title>
<style>
    @page { margin: 28px 32px; }
    body { font-family: DejaVu Sans, sans-serif; color: #172033; font-size: 10px; }
    h1 { margin: 0; font-size: 18px; text-align: center; }
    .subtitle { text-align: center; color: #475569; margin: 4px 0 18px; }
    table.meta, table.data { width: 100%; border-collapse: collapse; margin-bottom: 14px; }
    .meta td, .data th, .data td { border: 1px solid #cbd5e1; padding: 7px; text-align: left; }
    .data th { background: #eaf0f8; }
    .summary { background: #eff6ff; border: 1px solid #bfdbfe; padding: 10px; margin-bottom: 14px; }
    .footer { margin-top: 18px; text-align: right; color: #64748b; font-size: 9px; }
</style>
</head>
<body>
    <h1>MTsN 6 NGANJUK</h1>
    <div class="subtitle">REKAPITULASI NILAI AKADEMIK SISWA</div>
    <table class="meta">
        <tr><td><strong>Nama Siswa</strong></td><td>{{ $siswa->nama_lengkap ?? '-' }}</td><td><strong>Kelas</strong></td><td>{{ $siswa->kelas?->nama_kelas ?? '-' }}</td></tr>
    </table>
    <div class="summary">
        <strong>Total penilaian:</strong> {{ $totalPenilaian }} &nbsp; | &nbsp;
        <strong>Sudah dinilai:</strong> {{ $totalDinilai }} &nbsp; | &nbsp;
        <strong>Rata-rata keseluruhan:</strong> {{ $rataRata === null ? 'Belum tersedia' : number_format((float) $rataRata, 1, ',', '.') }}
    </div>
    <table class="data">
        <thead><tr><th style="width:28px">No.</th><th>Mata Pelajaran</th><th>KKM</th><th>Penilaian</th><th>Dinilai</th><th>Menunggu</th><th>Rata-rata</th></tr></thead>
        <tbody>
        @forelse($rekap as $i => $item)
            <tr>
                <td>{{ $i + 1 }}</td><td>{{ $item['mapel'] }}</td><td>{{ $item['kkm'] }}</td>
                <td>{{ $item['jumlah'] }}</td><td>{{ $item['dinilai'] }}</td><td>{{ $item['menunggu'] }}</td>
                <td>{{ $item['rata_rata'] === null ? '-' : number_format((float) $item['rata_rata'], 1, ',', '.') }}</td>
            </tr>
        @empty
            <tr><td colspan="7" style="text-align:center">Belum ada data penilaian.</td></tr>
        @endforelse
        </tbody>
    </table>
    <div class="footer">Dicetak pada {{ $dicetakPada->format('d/m/Y H:i') }} WIB</div>
</body>
</html>

<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Rekap Absensi {{ $periode }} - MATSANAM</title>
    <style>
        * { box-sizing: border-box; }
        body { margin: 24px; color: #0f172a; font-family: Arial, Helvetica, sans-serif; font-size: 12px; }
        .toolbar { display: flex; justify-content: space-between; gap: 12px; margin-bottom: 20px; }
        button, a { border: 0; border-radius: 6px; padding: 9px 14px; background: #2563eb; color: #fff; text-decoration: none; cursor: pointer; font-size: 12px; }
        a { background: #64748b; }
        header { text-align: center; border-bottom: 2px solid #0f172a; padding-bottom: 14px; margin-bottom: 18px; }
        h1 { margin: 0 0 6px; font-size: 20px; }
        p { margin: 4px 0; }
        .meta { margin: 14px 0; display: flex; justify-content: space-between; gap: 12px; }
        table { width: 100%; border-collapse: collapse; }
        th, td { border: 1px solid #cbd5e1; padding: 7px 8px; text-align: left; vertical-align: top; }
        th { background: #e2e8f0; font-weight: 700; }
        tbody tr:nth-child(even) { background: #f8fafc; }
        .empty { padding: 24px; text-align: center; color: #64748b; }
        @media print {
            body { margin: 10mm; font-size: 10px; }
            .toolbar { display: none; }
            thead { display: table-header-group; }
            tr { page-break-inside: avoid; }
        }
    </style>
</head>
<body>
    <div class="toolbar">
        <a href="{{ route('admin.absensi.rekap', ['periode' => $periode, 'kelas' => $kelas->id ?? null]) }}">Kembali ke Rekap</a>
        <button type="button" onclick="window.print()">Cetak / Simpan sebagai PDF</button>
    </div>

    <header>
        <h1>MTsN 6 NGANJUK</h1>
        <p><strong>LAPORAN REKAPITULASI PRESENSI SISWA</strong></p>
        <p>Periode: {{ \Carbon\Carbon::createFromFormat('Y-m', $periode)->translatedFormat('F Y') }}</p>
    </header>

    <div class="meta">
        <span>Kelas: <strong>{{ $kelas->nama_kelas ?? 'Semua Kelas' }}</strong></span>
        <span>Dicetak: <strong>{{ now()->format('d-m-Y H:i') }}</strong></span>
        <span>Total catatan: <strong>{{ $absensis->count() }}</strong></span>
    </div>

    <table>
        <thead>
            <tr>
                <th style="width:30px">No</th>
                <th>Nama Siswa</th>
                <th>NISN</th>
                <th>Kelas</th>
                <th>Mata Pelajaran</th>
                <th>Guru</th>
                <th>Tanggal</th>
                <th>Status</th>
                <th>Metode</th>
                <th>Keterangan</th>
            </tr>
        </thead>
        <tbody>
            @forelse($absensis as $index => $absen)
                <tr>
                    <td>{{ $index + 1 }}</td>
                    <td>{{ $absen->siswa->nama_lengkap ?? '-' }}</td>
                    <td>{{ $absen->siswa->nisn ?? '-' }}</td>
                    <td>{{ $absen->jadwal->kelas->nama_kelas ?? '-' }}</td>
                    <td>{{ $absen->jadwal->mataPelajaran->nama ?? '-' }}</td>
                    <td>{{ $absen->jadwal->guru->nama_lengkap ?? '-' }}</td>
                    <td>{{ optional($absen->tanggal)->format('d-m-Y') ?? '-' }}</td>
                    <td>{{ ucfirst($absen->status ?? '-') }}</td>
                    <td>{{ strtoupper($absen->metode ?? '-') }}</td>
                    <td>{{ $absen->keterangan ?: '-' }}</td>
                </tr>
            @empty
                <tr><td colspan="10" class="empty">Tidak ada data presensi pada periode dan kelas yang dipilih.</td></tr>
            @endforelse
        </tbody>
    </table>

    <script>
        window.addEventListener('load', () => window.setTimeout(() => window.print(), 250));
    </script>
</body>
</html>

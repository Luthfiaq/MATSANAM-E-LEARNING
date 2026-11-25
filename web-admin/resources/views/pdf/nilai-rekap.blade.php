<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <title>Rekap Nilai Semester</title>
    <style>
        body { font-family: DejaVu Sans, sans-serif; font-size: 12px; color: #0f172a; }
        h2 { margin: 0 0 4px 0; }
        .meta { margin-bottom: 14px; color: #475569; font-size: 11px; }
        .box { background: #eff6ff; border: 1px solid #bfdbfe; padding: 10px 12px; border-radius: 6px; margin-bottom: 14px; }
        table { width: 100%; border-collapse: collapse; margin-top: 8px; }
        th, td { border: 1px solid #cbd5e1; padding: 7px 8px; text-align: left; }
        th { background: #f1f5f9; font-weight: bold; }
        .num { text-align: center; }
    </style>
</head>
<body>
    <h2>Rekap Nilai Semester Siswa</h2>
    <div class="meta">
        Nama Siswa: <strong>{{ $siswa->nama_lengkap }}</strong> |
        Kelas: <strong>{{ $siswa->kelas?->nama_kelas ?? '-' }}</strong> |
        Periode: <strong>{{ $periode?->nama ?? 'Semester Aktif' }}</strong>
    </div>

    <div class="box">
        <strong>Rata-Rata Keseluruhan:</strong>
        {{ $rataKeseluruhan !== null ? number_format($rataKeseluruhan, 2) : '-' }} / 100
    </div>

    <table>
        <thead>
            <tr>
                <th>No</th>
                <th>Mata Pelajaran</th>
                <th class="num">KKM</th>
                <th class="num">Dinilai</th>
                <th class="num">Rata-Rata</th>
            </tr>
        </thead>
        <tbody>
            @forelse ($rekapMapel as $i => $row)
                <tr>
                    <td class="num">{{ $i + 1 }}</td>
                    <td>{{ $row['mapel'] }}</td>
                    <td class="num">{{ $row['kkm'] }}</td>
                    <td class="num">{{ $row['jumlah_dinilai'] }} / {{ $row['jumlah_total'] }}</td>
                    <td class="num">{{ $row['rata_rata'] !== null ? number_format($row['rata_rata'], 2) : '-' }}</td>
                </tr>
            @empty
                <tr>
                    <td colspan="5" class="num">Belum ada data rekap nilai.</td>
                </tr>
            @endforelse
        </tbody>
    </table>
</body>
</html>
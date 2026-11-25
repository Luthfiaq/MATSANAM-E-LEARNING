<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <title>Rincian Nilai Mapel</title>
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
    <h2>Rincian Nilai Mata Pelajaran — {{ $mapel->nama }}</h2>
    <div class="meta">
        Nama Siswa: <strong>{{ $siswa->nama_lengkap }}</strong> |
        Kelas: <strong>{{ $siswa->kelas?->nama_kelas ?? '-' }}</strong> |
        Periode: <strong>{{ $periode?->nama ?? 'Semester Aktif' }}</strong> |
        KKM: <strong>{{ $mapel->kkm }}</strong>
    </div>

    <div class="box">
        <strong>Rata-Rata Nilai Mapel:</strong>
        {{ $rataRata !== null ? number_format($rataRata, 2) : '-' }} / 100
    </div>

    <table>
        <thead>
            <tr>
                <th>No</th>
                <th>Judul Penilaian</th>
                <th>Jenis</th>
                <th class="num">Nilai</th>
                <th>Status</th>
                <th>Catatan Guru</th>
            </tr>
        </thead>
        <tbody>
            @forelse ($items as $i => $row)
                <tr>
                    <td class="num">{{ $i + 1 }}</td>
                    <td>{{ $row['judul_tugas'] ?? '-' }}</td>
                    <td>{{ $row['jenis'] ?? '-' }}</td>
                    <td class="num">{{ $row['nilai'] !== null ? $row['nilai'] : '-' }}</td>
                    <td>{{ str_replace('_', ' ', ucfirst($row['status_ketuntasan'] ?? '-')) }}</td>
                    <td>{{ $row['catatan'] ?? '-' }}</td>
                </tr>
            @empty
                <tr>
                    <td colspan="6" class="num">Belum ada data nilai pada mata pelajaran ini.</td>
                </tr>
            @endforelse
        </tbody>
    </table>
</body>
</html>
<?php

namespace App\Exports;

use App\Models\AbsensiHarian;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithMapping;
use Maatwebsite\Excel\Concerns\WithStyles;
use PhpOffice\PhpSpreadsheet\Worksheet\Worksheet;

class AbsensiExport implements FromCollection, WithHeadings, WithMapping, WithStyles
{
    protected $absensis;

    public function __construct($absensis)
    {
        $this->absensis = $absensis;
    }

    public function collection()
    {
        return $this->absensis;
    }

    public function headings(): array
    {
        return [
            'No',
            'Nama Siswa',
            'NISN',
            'Kelas',
            'Mata Pelajaran',
            'Guru',
            'Tanggal',
            'Status',
            'Metode Absen',
            'Waktu Absen',
            'Keterangan',
        ];
    }

    public function map($absen): array
    {
        return [
            $absen->siswa->nama_lengkap,
            $absen->siswa->nisn,
            $absen->jadwal->kelas->nama_kelas ?? '-',
            $absen->jadwal->mataPelajaran->nama ?? '-',
            $absen->jadwal->guru->nama_lengkap ?? '-',
            $absen->tanggal->format('d M Y'),
            $this->getStatusLabel($absen->status),
            strtoupper($absen->metode),
            $absen->waktu_absen ?? '-',
            $absen->keterangan ?? '-',
        ];
    }

    private function getStatusLabel($status)
    {
        return match($status) {
            'hadir' => 'Hadir',
            'sakit' => 'Sakit',
            'izin' => 'Izin',
            'alpa' => 'Alpa',
            default => '-',
        };
    }

    public function styles(Worksheet $sheet)
    {
        return [
            1 => ['font' => ['bold' => true, 'size' => 12]],
        ];
    }
}

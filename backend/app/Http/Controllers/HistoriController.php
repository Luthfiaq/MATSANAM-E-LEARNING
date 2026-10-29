<?php

namespace App\Http\Controllers;

use App\Models\SuratAbsensi;
use Illuminate\View\View;

class HistoriController extends Controller
{
    public function index(): View
    {
        $surat = SuratAbsensi::with(['siswa', 'verifikator'])
            ->orderByDesc('created_at')
            ->get();

        $totalArsip = $surat->count();

        $totalDiproses = $surat
            ->where('status_verifikasi', 'pending')
            ->count();

        $totalDiterima = $surat
            ->where('status_verifikasi', 'disetujui')
            ->count();

        $totalDitolak = $surat
            ->where('status_verifikasi', 'ditolak')
            ->count();

        // Membuat daftar semester berdasarkan tanggal mulai surat
        $daftarSemester = $surat
            ->filter(fn ($item) => $item->tanggal_mulai !== null)
            ->map(function ($item) {
                $tanggal = $item->tanggal_mulai;
                $tahun = $tanggal->year;
                $bulan = $tanggal->month;

                if ($bulan >= 7) {
                    $tahunAjaran = $tahun . '/' . ($tahun + 1);
                    $semester = 'Ganjil';
                } else {
                    $tahunAjaran = ($tahun - 1) . '/' . $tahun;
                    $semester = 'Genap';
                }

                return [
                    'nilai' => $semester . ' ' . $tahunAjaran,
                    'label' => 'Semester ' . $semester . ' ' . $tahunAjaran,
                ];
            })
            ->unique('nilai')
            ->sortByDesc('nilai')
            ->values();

        return view('histori', compact(
            'surat',
            'totalArsip',
            'totalDiproses',
            'totalDiterima',
            'totalDitolak',
            'daftarSemester'
        ));
    }
}

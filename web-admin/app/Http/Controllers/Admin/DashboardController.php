<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Guru;
use App\Models\Siswa;
use App\Models\SuratAbsensi;
use App\Models\AbsensiHarian;
use Carbon\Carbon;

class DashboardController extends Controller
{
    public function index()
    {
        // Stats
        $totalGuru = Guru::count();
        $totalSiswa = Siswa::count();
        $suratPending = SuratAbsensi::where('status_verifikasi', 'pending')->count();
        
        // Absensi hari ini
        $today = Carbon::now()->format('Y-m-d');
        $absensiHariIni = AbsensiHarian::where('tanggal', $today)
            ->where('status', 'hadir')
            ->count();
            
        // Total siswa untuk persentase
        $totalSiswaAbsen = AbsensiHarian::where('tanggal', $today)->count();
        $persentaseKehadiran = $totalSiswaAbsen > 0 
            ? round(($absensiHariIni / $totalSiswaAbsen) * 100, 1) 
            : 0;

        // Pending surat
        $pendingSurat = SuratAbsensi::where('status_verifikasi', 'pending')
            ->with('siswa.kelas')
            ->orderBy('created_at', 'desc')
            ->limit(4)
            ->get();

        return view('admin.dashboard', compact(
            'totalGuru',
            'totalSiswa',
            'suratPending',
            'absensiHariIni',
            'persentaseKehadiran',
            'totalSiswaAbsen',
            'pendingSurat'
        ));
    }
}

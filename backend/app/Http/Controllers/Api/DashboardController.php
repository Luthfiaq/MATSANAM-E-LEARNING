<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Guru;
use App\Models\Siswa;
use App\Models\SuratAbsensi;
use App\Models\AbsensiHarian;
use Carbon\Carbon;

class DashboardController extends Controller
{
    public function index()
    {
        // 1. Stats Cards
        $totalGuru = Guru::count();
        $totalSiswa = Siswa::count();
        $suratPending = SuratAbsensi::where('status_verifikasi', 'pending')->count();
        
        // Absensi hari ini
        $today = Carbon::now()->format('Y-m-d');
        $absensiHariIni = AbsensiHarian::where('tanggal', $today)
            ->where('status', 'hadir')
            ->count();

        $stats = [
            ['label' => 'Total Guru', 'value' => $totalGuru, 'href' => '/dashboard/guru'],
            ['label' => 'Total Siswa', 'value' => $totalSiswa, 'href' => '/dashboard/siswa'],
            ['label' => 'Surat Pending', 'value' => $suratPending, 'href' => '/dashboard/verifikasi-absensi'],
            ['label' => 'Absensi Hari Ini', 'value' => $absensiHariIni],
        ];

        // 2. Attendance Weekly Chart
        $startDate = Carbon::now()->startOfWeek();
        $attendanceWeekly = [];
        $days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];

        for ($i = 0; $i < 6; $i++) {
            $date = $startDate->copy()->addDays($i);
            $dateStr = $date->format('Y-m-d');

            $hadir = AbsensiHarian::where('tanggal', $dateStr)->where('status', 'hadir')->count();
            $izin = AbsensiHarian::where('tanggal', $dateStr)->where('status', 'izin')->count();
            $sakit = AbsensiHarian::where('tanggal', $dateStr)->where('status', 'sakit')->count();
            $alpa = AbsensiHarian::where('tanggal', $dateStr)->where('status', 'alpa')->count();

            $attendanceWeekly[] = [
                'day' => $days[$i],
                'hadir' => $hadir,
                'izin' => $izin,
                'sakit' => $sakit,
                'alpa' => $alpa,
            ];
        }

        // 3. Pending Surat Table
        $pendingSurat = SuratAbsensi::where('status_verifikasi', 'pending')
            ->with('siswa.kelas')
            ->orderBy('created_at', 'desc')
            ->limit(8)
            ->get()
            ->map(function ($surat) {
                return [
                    'id' => $surat->id,
                    'siswaNama' => $surat->siswa->nama_lengkap,
                    'kelas' => $surat->siswa->kelas->nama_kelas ?? '-',
                    'tgl' => $surat->tanggal_mulai->format('Y-m-d'),
                    'status' => $surat->jenis,
                ];
            });

        return response()->json([
            'stats' => $stats,
            'attendanceWeekly' => $attendanceWeekly,
            'pendingSurat' => $pendingSurat,
        ]);
    }
}

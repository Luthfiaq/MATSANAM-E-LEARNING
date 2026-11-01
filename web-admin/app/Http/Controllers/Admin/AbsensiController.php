<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Siswa;
use App\Models\SuratAbsensi;
use App\Models\AbsensiHarian;
use App\Models\JadwalPelajaran;
use Illuminate\Http\Request;
use Carbon\Carbon;

class AbsensiController extends Controller
{
public function verifikasiSurat(Request $request)
    {
        // Memuat relasi lengkap ke siswa, kelas, wali kelas, dan verifikator tanpa batasan ketat
        $query = SuratAbsensi::with(['siswa.kelas.waliKelas', 'verifikator'])
            ->orderBy('created_at', 'desc');

        // Jika user klik filter status tertentu (selain 'semua')
        if ($request->filled('status') && $request->status !== 'semua') {
            $query->whereRaw('LOWER(status_verifikasi) = ?', [strtolower($request->status)]);
        }

        if ($request->filled('siswa')) {
            $query->whereHas('siswa', function($q) use ($request) {
                $q->where('nama_lengkap', 'like', '%' . $request->siswa . '%')
                  ->orWhere('nisn', 'like', '%' . $request->siswa . '%');
            });
        }

        $suratAbsensi = $query->get();

        $totalPending = SuratAbsensi::whereRaw('LOWER(status_verifikasi) = ?', ['pending'])->count();
        $totalDisetujui = SuratAbsensi::whereRaw('LOWER(status_verifikasi) = ?', ['disetujui'])->count();
        $totalDitolak = SuratAbsensi::whereRaw('LOWER(status_verifikasi) = ?', ['ditolak'])->count();

        return view('admin.absensi.verifikasi', compact(
            'suratAbsensi', 
            'totalPending', 
            'totalDisetujui', 
            'totalDitolak'
        ));
    }

    public function approveSurat($id)
    {
        $surat = SuratAbsensi::findOrFail($id);
        $surat->update([
            'status_verifikasi' => 'disetujui',
            'verifikator_id' => auth()->id(),
            'tanggal_verifikasi' => now(),
        ]);

        return redirect()->back()->with('success', 'Surat berhasil disetujui');
    }

    public function rejectSurat(Request $request, $id)
    {
        $request->validate([
            'catatan' => 'required|string|max:500',
        ]);

        $surat = SuratAbsensi::findOrFail($id);
        $surat->update([
            'status_verifikasi' => 'ditolak',
            'verifikator_id' => auth()->id(),
            'tanggal_verifikasi' => now(),
            'catatan_verifikasi' => $request->catatan,
        ]);

        return redirect()->back()->with('error', 'Surat ditolak. Notifikasi dikirim ke siswa.');
    }

    public function rekapPresensi(Request $request)
    {
        $query = AbsensiHarian::with(['siswa', 'jadwal.guru', 'jadwal.mataPelajaran', 'jadwal.kelas']);

        if ($request->filled('periode')) {
            $query->whereDate('tanggal', '>=', Carbon::parse($request->periode)->startOfMonth())
                  ->whereDate('tanggal', '<=', Carbon::parse($request->periode)->endOfMonth());
        }

        if ($request->filled('kelas')) {
            $query->whereHas('jadwal', function($q) use ($request) {
                $q->where('kelas_id', $request->kelas);
            });
        }

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        $absensis = $query->orderBy('tanggal', 'desc')->paginate(20);

        $summary = AbsensiHarian::select('status', \DB::raw('count(*) as total'))
            ->groupBy('status')
            ->pluck('total', 'status')
            ->toArray();

        $totalHadir = $summary['hadir'] ?? 0;
        $totalIzin = $summary['izin'] ?? 0;
        $totalSakit = $summary['sakit'] ?? 0;
        $totalAlpa = $summary['alpa'] ?? 0;
        $total = $totalHadir + $totalIzin + $totalSakit + $totalAlpa;
        $persentaseHadir = $total > 0 ? round(($totalHadir / $total) * 100, 2) : 0;

        $kelasList = \App\Models\Kelas::all();

        return view('admin.absensi.rekap', compact(
            'absensis',
            'summary',
            'totalHadir',
            'totalIzin',
            'totalSakit',
            'totalAlpa',
            'total',
            'persentaseHadir',
            'kelasList',
            'request'
        ));
    }

    public function historiSurat(Request $request)
    {
        $query = SuratAbsensi::with(['siswa.kelas', 'verifikator'])
            ->orderBy('created_at', 'desc');

        if ($request->filled('status')) {
            $query->where('status_verifikasi', $request->status);
        }

        $surats = $query->paginate(15);

        $totalPending = SuratAbsensi::whereRaw('LOWER(status_verifikasi) = ?', ['pending'])->count();
        $totalDisetujui = SuratAbsensi::whereRaw('LOWER(status_verifikasi) = ?', ['disetujui'])->count();
        $totalDitolak = SuratAbsensi::whereRaw('LOWER(status_verifikasi) = ?', ['ditolak'])->count();

        return view('admin.absensi.histori', compact(
            'surats', 
            'totalPending', 
            'totalDisetujui', 
            'totalDitolak'
        ));
    }

    public function exportPresensi(Request $request)
    {
        $request->validate([
            'format' => 'required|in:pdf,excel',
            'periode' => 'required',
        ]);

        $query = AbsensiHarian::with(['siswa', 'jadwal.guru', 'jadwal.mataPelajaran', 'jadwal.kelas'])
            ->whereDate('tanggal', '>=', Carbon::parse($request->periode)->startOfMonth())
            ->whereDate('tanggal', '<=', Carbon::parse($request->periode)->endOfMonth());

        if ($request->filled('kelas')) {
            $query->whereHas('jadwal', function($q) use ($request) {
                $q->where('kelas_id', $request->kelas);
            });
        }

        $absensis = $query->get();

        if ($request->format === 'excel') {
            return \Maatwebsite\Excel\Facades\Excel::download(
                new \App\Exports\AbsensiExport($absensis),
                'rekap_absensi_' . $request->periode . '.xlsx'
            );
        }

        $pdf = \Barryvdh\DomPDF\Facade\Pdf::loadView('admin.absensi.export', compact('absensis', 'request'));
        return $pdf->download('rekap_absensi_' . $request->periode . '.pdf');
    }
}
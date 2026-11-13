<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\SuratAbsensi;
use App\Services\MatsanamNotificationService;
use App\Services\SuratAbsensiFileService;
use Illuminate\Http\Request;

class SiswaAbsensiController extends Controller
{
    public function store(Request $request)
    {
        $user = $request->user();
        if ($user?->role !== 'siswa') {
            return response()->json([
                'success' => false,
                'message' => 'Fitur pengajuan izin hanya untuk akun siswa.',
            ], 403);
        }

        $siswa = $user->siswa;
        if (!$siswa) {
            return response()->json([
                'success' => false,
                'message' => 'Profil siswa tidak ditemukan.',
            ], 404);
        }

        $validated = $request->validate([
            'jenis_izin' => ['required', 'in:sakit,izin'],
            'tanggal_mulai' => ['required', 'date'],
            'tanggal_selesai' => ['required', 'date', 'after_or_equal:tanggal_mulai'],
            'keterangan' => ['required', 'string', 'max:2000'],
            'dokumen' => ['nullable', 'file', 'mimes:pdf,jpg,jpeg,png', 'max:5120'],
        ]);

        $filePath = null;
        if ($request->hasFile('dokumen')) {
            $filePath = app(SuratAbsensiFileService::class)->store($request->file('dokumen'));
        }

        try {
            $surat = SuratAbsensi::create([
                'siswa_id' => $siswa->id,
                'tanggal_mulai' => $validated['tanggal_mulai'],
                'tanggal_selesai' => $validated['tanggal_selesai'],
                'jenis' => $validated['jenis_izin'],
                'alasan' => $validated['keterangan'],
                'file_surat' => $filePath,
                'status_verifikasi' => 'pending',
            ]);
        } catch (\Throwable $e) {
            if ($filePath) app(SuratAbsensiFileService::class)->delete($filePath);
            throw $e;
        }

        app(MatsanamNotificationService::class)->notifyClassTeachers(
            (int) $siswa->kelas_id,
            'pengajuan_izin',
            'Pengajuan izin siswa baru',
            $siswa->nama_lengkap . ' mengirim pengajuan ' . $surat->jenis . ' yang menunggu verifikasi.',
            ['surat_id' => $surat->id, 'siswa_id' => $siswa->id, 'class_id' => $siswa->kelas_id],
        );
        app(MatsanamNotificationService::class)->notifyAdmins(
            'pengajuan_izin',
            'Pengajuan izin menunggu verifikasi',
            $siswa->nama_lengkap . ' mengirim pengajuan ' . $surat->jenis . ' yang memerlukan pemeriksaan Admin.',
            ['surat_id' => $surat->id, 'siswa_id' => $siswa->id, 'class_id' => $siswa->kelas_id],
        );

        return response()->json([
            'success' => true,
            'message' => 'Pengajuan izin berhasil dikirim dan menunggu verifikasi.',
            'data' => $surat,
        ], 201);
    }
}

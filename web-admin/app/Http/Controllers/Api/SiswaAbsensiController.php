<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\SuratAbsensi;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

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
            $filePath = $request->file('dokumen')->store('surat-absensi', 'public');
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
            if ($filePath) Storage::disk('public')->delete($filePath);
            throw $e;
        }

        return response()->json([
            'success' => true,
            'message' => 'Pengajuan izin berhasil dikirim dan menunggu verifikasi.',
            'data' => $surat,
        ], 201);
    }
}

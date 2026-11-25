<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AbsensiHarian;
use App\Models\JadwalPelajaran;
use App\Models\SuratAbsensi;
use App\Services\MatsanamNotificationService;
use App\Services\SuratAbsensiFileService;
use Carbon\Carbon;
use Illuminate\Validation\ValidationException;
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
            'cakupan' => ['nullable', 'in:sehari_penuh,pulang_lebih_awal'],
            'jadwal_acuan_id' => ['nullable', 'required_if:cakupan,pulang_lebih_awal', 'integer', 'exists:jadwal_pelajaran,id'],
            'tanggal_mulai' => ['required', 'date'],
            'tanggal_selesai' => ['required', 'date', 'after_or_equal:tanggal_mulai'],
            'keterangan' => ['required', 'string', 'max:2000'],
            'dokumen' => ['nullable', 'file', 'mimes:pdf,jpg,jpeg,png', 'max:5120'],
        ]);

        $cakupan = $validated['cakupan'] ?? 'sehari_penuh';
        $jadwalAcuan = null;
        if ($cakupan === 'pulang_lebih_awal') {
            if (! $siswa->kelas_id) {
                throw ValidationException::withMessages([
                    'jadwal_acuan_id' => 'Kelas siswa belum terhubung dengan jadwal pelajaran.',
                ]);
            }

            $tanggal = Carbon::parse($validated['tanggal_mulai'])->startOfDay();
            $hariIndonesia = [1 => 'Senin', 2 => 'Selasa', 3 => 'Rabu', 4 => 'Kamis', 5 => 'Jumat', 6 => 'Sabtu'];
            $hari = $hariIndonesia[$tanggal->dayOfWeekIso] ?? null;
            if ($hari === null) {
                throw ValidationException::withMessages([
                    'tanggal_mulai' => 'Jadwal parsial hanya dapat diajukan pada hari sekolah.',
                ]);
            }

            $jadwalAcuan = JadwalPelajaran::query()
                ->with('periode')
                ->whereKey($validated['jadwal_acuan_id'])
                ->where('kelas_id', $siswa->kelas_id)
                ->where('hari', $hari)
                ->whereHas('periode', function ($query) use ($tanggal) {
                    $query->whereDate('tanggal_mulai', '<=', $tanggal->toDateString())
                        ->whereDate('tanggal_selesai', '>=', $tanggal->toDateString());
                })
                ->first();

            if (! $jadwalAcuan) {
                throw ValidationException::withMessages([
                    'jadwal_acuan_id' => 'Mata pelajaran tidak ditemukan pada tanggal dan kelas yang dipilih.',
                ]);
            }

            $sudahHadir = AbsensiHarian::query()
                ->where('siswa_id', $siswa->id)
                ->where('jadwal_id', $jadwalAcuan->id)
                ->whereDate('tanggal', $tanggal->toDateString())
                ->where('status', 'hadir')
                ->exists();

            if ($sudahHadir) {
                throw ValidationException::withMessages([
                    'jadwal_acuan_id' => 'Pilih mata pelajaran pertama yang tidak dapat diikuti. Mata pelajaran yang sudah tercatat Hadir tidak dapat menjadi awal izin.',
                ]);
            }
        }

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
                'cakupan' => $cakupan,
                'jadwal_acuan_id' => $jadwalAcuan?->id,
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
            'Pengajuan ' . ucfirst($surat->jenis) . ' siswa baru',
            $siswa->nama_lengkap . ' mengirim pengajuan ' . $surat->jenis . ' yang menunggu verifikasi.',
            ['surat_id' => $surat->id, 'siswa_id' => $siswa->id, 'class_id' => $siswa->kelas_id],
        );
        app(MatsanamNotificationService::class)->notifyAdmins(
            'pengajuan_izin',
            'Pengajuan ' . ucfirst($surat->jenis) . ' menunggu verifikasi',
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

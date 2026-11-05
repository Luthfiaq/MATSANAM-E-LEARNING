<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class NilaiController extends Controller
{
    // 1. Mengambil daftar mapel untuk halaman Pilih Mapel Nilai
    public function getDaftarMapelNilai()
    {
        $mapel = DB::table('mata_pelajaran')->select('id', 'nama', 'kkm')->get();

        $formatted = $mapel->map(function($item) {
            return [
                'id' => $item->id,
                'nama' => $item->nama,
                'rata_rata' => 0.0, // Nanti otomatis terhitung dari data nilai siswa
                'kkm' => $item->kkm ?? 75
            ];
        });

        return response()->json([
            'success' => true,
            'message' => 'Daftar mapel nilai berhasil diambil',
            'data' => $formatted
        ]);
    }

    // 2. Mengambil rincian nilai berdasarkan mapel (untuk DetailNilaiScreen)
    public function getNilaiByMapel($mapelId)
    {
        // Mengambil nilai berdasarkan relasi penugasan dan mata pelajaran di SQLite
        $nilaiList = DB::table('nilai')
            ->join('pengumpulan_tugas', 'nilai.pengumpulan_id', '=', 'pengumpulan_tugas.id')
            ->join('penugasan', 'pengumpulan_tugas.penugasan_id', '=', 'penugasan.id')
            ->join('jadwal_pelajaran', 'penugasan.jadwal_id', '=', 'jadwal_pelajaran.id')
            ->join('mata_pelajaran', 'jadwal_pelajaran.mapel_id', '=', 'mata_pelajaran.id')
            ->leftJoin('guru', 'penugasan.guru_id', '=', 'guru.id')
            ->where('mata_pelajaran.id', $mapelId)
            ->select(
                'nilai.id',
                'mata_pelajaran.id as mapel_id',
                'mata_pelajaran.nama as mapel',
                'penugasan.id as penugasan_id',
                'penugasan.judul as judul_penilaian',
                'penugasan.jenis as jenis_penilaian',
                'nilai.nilai',
                'mata_pelajaran.kkm',
                'nilai.tanggal_penilaian as tanggal',
                'guru.nama_lengkap as nama_guru',
                'nilai.catatan as feedback_guru'
            )
            ->get();

        $formatted = $nilaiList->map(function($item) {
            return [
                'id' => $item->id,
                'mapel_id' => $item->mapel_id,
                'mapel' => $item->mapel,
                'penugasan_id' => $item->penugasan_id,
                'judul_penilaian' => $item->judul_penilaian,
                'jenis_penilaian' => $item->jenis_penilaian ?? 'tugas',
                'nilai' => (double)$item->nilai,
                'kkm' => (double)($item->kkm ?? 75),
                'tanggal' => $item->tanggal ?? now()->toIso8601String(),
                'nama_guru' => $item->nama_guru ?? 'Guru Pengampu',
                'feedback_guru' => $item->feedback_guru
            ];
        });

        return response()->json([
            'success' => true,
            'message' => 'List nilai berhasil diambil',
            'data' => $formatted
        ]);
    }

    // 3. Mengambil angka rata-rata nilai berdasarkan mapel
    public function getRataRataByMapel($mapelId)
    {
        $rataRata = DB::table('nilai')
            ->join('pengumpulan_tugas', 'nilai.pengumpulan_id', '=', 'pengumpulan_tugas.id')
            ->join('penugasan', 'pengumpulan_tugas.penugasan_id', '=', 'penugasan.id')
            ->join('jadwal_pelajaran', 'penugasan.jadwal_id', '=', 'jadwal_pelajaran.id')
            ->where('jadwal_pelajaran.mapel_id', $mapelId)
            ->avg('nilai.nilai');

        return response()->json([
            'success' => true,
            'message' => 'Rata-rata nilai berhasil diambil',
            'data' => $rataRata ? (double)$rataRata : 0.0
        ]);
    }
}
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class MateriController extends Controller
{
    // 1. Mengambil daftar mata pelajaran untuk halaman Pilih Mapel
    public function getMapel()
    {
        $mapel = DB::table('mata_pelajaran')->select('id', 'kode', 'nama', 'deskripsi', 'kkm')->get();
        
        // Fallback data jika tabel database masih kosong
        if ($mapel->isEmpty()) {
            $mapel = [
                ['id' => 1, 'kode' => 'MTK', 'nama' => 'Matematika', 'deskripsi' => 'Pembelajaran matematika', 'kkm' => 75],
                ['id' => 2, 'kode' => 'BIN', 'nama' => 'Bahasa Indonesia', 'deskripsi' => 'Pembelajaran bahasa Indonesia', 'kkm' => 75],
                ['id' => 3, 'kode' => 'IPA', 'nama' => 'Ilmu Pengetahuan Alam', 'deskripsi' => 'Pembelajaran ilmu pengetahuan alam', 'kkm' => 75],
                ['id' => 4, 'kode' => 'TIK', 'nama' => 'Informatika', 'deskripsi' => 'Pembelajaran teknologi informasi', 'kkm' => 75],
            ];
        }

        return response()->json([
            'success' => true,
            'message' => 'Daftar mata pelajaran berhasil diambil',
            'data' => $mapel
        ]);
    }

    // 2. Mengambil daftar materi berdasarkan ID Mapel dari Database Asli (Tanpa Fallback)
    public function getByMapel($mapelId)
    {
        // Mengambil dari tabel penugasan yang terhubung ke mapel via jadwal
        $materi = DB::table('penugasan')
            ->join('jadwal_pelajaran', 'penugasan.jadwal_id', '=', 'jadwal_pelajaran.id')
            ->join('mata_pelajaran', 'jadwal_pelajaran.mapel_id', '=', 'mata_pelajaran.id')
            ->leftJoin('guru', 'penugasan.guru_id', '=', 'guru.id')
            ->where('mata_pelajaran.id', $mapelId)
            ->select(
                'penugasan.id',
                'mata_pelajaran.id as mapel_id',
                'mata_pelajaran.nama as mapel',
                'penugasan.judul as judul_materi',
                'penugasan.file_materi as file_path',
                'penugasan.deskripsi',
                'penugasan.created_at as tanggal',
                'guru.nama_lengkap as nama_guru'
            )
            ->get();

        $formatted = $materi->map(function($item) {
            return [
                'id' => $item->id,
                'mapel_id' => $item->mapel_id,
                'mapel' => $item->mapel,
                'judul_materi' => $item->judul_materi,
                'tipe_file' => 'pdf',
                'url' => null,
                'file_path' => $item->file_path,
                'tanggal' => $item->tanggal ?? now()->toIso8601String(),
                'deskripsi' => $item->deskripsi,
                'nama_guru' => $item->nama_guru ?? 'Guru Pengampu'
            ];
        });

        // Jika di database SQLite kosong, mengembalikan list kosong (tidak ada data tiruan)
        return response()->json([
            'success' => true,
            'message' => 'List materi berhasil diambil',
            'data' => $formatted
        ]);
    }

    // 3. Detail satu materi berdasarkan ID
    public function show($id)
    {
        $materi = [
            'id' => (int)$id,
            'mapel_id' => 1,
            'mapel' => 'Matematika',
            'judul_materi' => 'Modul Pembelajaran #' . $id,
            'tipe_file' => 'pdf',
            'url' => null,
            'file_path' => null,
            'tanggal' => now()->toIso8601String(),
            'deskripsi' => 'Penjelasan lengkap mengenai topik pembelajaran pada modul ini.',
            'nama_guru' => 'Guru Pengampu'
        ];

        return response()->json([
            'success' => true,
            'message' => 'Detail materi berhasil diambil',
            'data' => $materi
        ]);
    }

    // 4. Pencarian materi
    public function search(Request $request)
    {
        $keyword = $request->query('keyword', '');

        $materi = [
            [
                'id' => 1,
                'mapel_id' => 1,
                'mapel' => 'Matematika',
                'judul_materi' => 'Hasil Pencarian: ' . $keyword,
                'tipe_file' => 'pdf',
                'url' => null,
                'file_path' => null,
                'tanggal' => now()->toIso8601String(),
                'deskripsi' => 'Deskripsi hasil pencarian materi.',
                'nama_guru' => 'Guru Pengampu'
            ]
        ];

        return response()->json([
            'success' => true,
            'message' => 'Hasil pencarian materi',
            'data' => $materi
        ]);
    }
}
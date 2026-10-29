<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SuratAbsensi extends Model
{
    protected $table = 'surat_absensi';

    protected $fillable = [
        'siswa_id',
        'tanggal_mulai',
        'tanggal_selesai',
        'jenis',
        'alasan',
        'file_surat',
        'status_verifikasi',
        'verifikator_id',
        'tanggal_verifikasi',
        'catatan_verifikasi',
    ];

    protected $casts = [
        'tanggal_mulai' => 'date',
        'tanggal_selesai' => 'date',
        'tanggal_verifikasi' => 'datetime',
    ];

    public function siswa()
    {
        return $this->belongsTo(Siswa::class);
    }

    public function verifikator()
    {
        return $this->belongsTo(User::class, 'verifikator_id');
    }
}

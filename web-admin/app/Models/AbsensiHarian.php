<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AbsensiHarian extends Model
{
    protected $table = 'absensi_harian';

    protected $fillable = [
        'siswa_id',
        'jadwal_id',
        'tanggal',
        'status',
        'waktu_absen',
        'metode',
        'keterangan',
    ];

    protected $casts = [
        'tanggal' => 'date',
    ];

    public function siswa()
    {
        return $this->belongsTo(Siswa::class);
    }

    public function jadwal()
    {
        return $this->belongsTo(JadwalPelajaran::class, 'jadwal_id');
    }
}

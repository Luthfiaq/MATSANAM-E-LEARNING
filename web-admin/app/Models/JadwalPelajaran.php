<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class JadwalPelajaran extends Model
{
    protected $table = 'jadwal_pelajaran';

    protected $fillable = [
        'periode_id',
        'kelas_id',
        'mapel_id',
        'guru_id',
        'hari',
        'jam_mulai',
        'jam_selesai',
        'ruangan',
    ];

    public function periode()
    {
        return $this->belongsTo(PeriodeAkademik::class, 'periode_id');
    }

    public function kelas()
    {
        return $this->belongsTo(Kelas::class);
    }

    public function mataPelajaran()
    {
        return $this->belongsTo(MataPelajaran::class, 'mapel_id');
    }

    public function guru()
    {
        return $this->belongsTo(Guru::class);
    }
}

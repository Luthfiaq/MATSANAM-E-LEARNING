<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PengumpulanTugas extends Model
{
    protected $table = 'pengumpulan_tugas';

    protected $fillable = [
        'penugasan_id',
        'siswa_id',
        'jawaban',
        'file_jawaban',
        'waktu_pengumpulan',
        'status',
    ];

    protected $casts = [
        'waktu_pengumpulan' => 'datetime',
    ];

    public function penugasan()
    {
        return $this->belongsTo(Penugasan::class, 'penugasan_id');
    }

    public function siswa()
    {
        return $this->belongsTo(Siswa::class);
    }

    public function nilai()
    {
        return $this->hasOne(Nilai::class, 'pengumpulan_id');
    }
}

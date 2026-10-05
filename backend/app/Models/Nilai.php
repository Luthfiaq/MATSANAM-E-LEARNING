<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Nilai extends Model
{
    protected $table = 'nilai';

    protected $fillable = [
        'pengumpulan_id',
        'guru_id',
        'nilai',
        'catatan',
        'tanggal_penilaian',
    ];

    protected $casts = [
        'tanggal_penilaian' => 'datetime',
    ];

    public function pengumpulan()
    {
        return $this->belongsTo(PengumpulanTugas::class, 'pengumpulan_id');
    }

    public function guru()
    {
        return $this->belongsTo(Guru::class);
    }
}

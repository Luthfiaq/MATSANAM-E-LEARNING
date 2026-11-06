<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Materi extends Model
{
    use HasFactory;

    protected $table = 'materi';

    protected $fillable = [
        'jadwal_id',
        'guru_id',
        'judul',
        'deskripsi',
        'tipe',
        'file_path',
        'link',
    ];

    protected $casts = [
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    public function jadwal()
    {
        return $this->belongsTo(JadwalPelajaran::class);
    }

    public function guru()
    {
        return $this->belongsTo(Guru::class);
    }
}
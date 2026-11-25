<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Penugasan extends Model
{
    protected $table = 'penugasan';

    protected $fillable = [
        'jadwal_id',
        'guru_id',
        'judul',
        'deskripsi',
        'jenis',
        'deadline',
        'file_materi',
        'bobot',
        'client_request_id',
        'last_attachment_batch_id',
    ];

    protected $casts = [
        'deadline' => 'datetime',
    ];

    public function jadwal()
    {
        return $this->belongsTo(JadwalPelajaran::class, 'jadwal_id');
    }

    public function guru()
    {
        return $this->belongsTo(Guru::class);
    }

    public function pengumpulan()
    {
        return $this->hasMany(PengumpulanTugas::class, 'penugasan_id');
    }

    public function files()
    {
        return $this->hasMany(PenugasanFile::class, 'penugasan_id')->orderBy('id');
    }
}

<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Guru extends Model
{
    use HasFactory;

    protected $table = 'guru';

    protected $fillable = [
        'user_id',
        'nip',
        'nama_lengkap',
        'jenis_kelamin',
        'telepon',
        'alamat',
        'foto_profil',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function kelasWali()
    {
        return $this->hasMany(Kelas::class, 'wali_kelas_id');
    }

    public function jadwalPelajaran()
    {
        return $this->hasMany(JadwalPelajaran::class);
    }

    public function penugasan()
    {
        return $this->hasMany(Penugasan::class);
    }
}

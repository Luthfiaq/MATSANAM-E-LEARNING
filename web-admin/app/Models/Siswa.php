<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Siswa extends Model
{
    use HasFactory;

    protected $table = 'siswa';

    protected $fillable = [
        'user_id',
        'nis',
        'nisn',
        'nama_lengkap',
        'jenis_kelamin',
        'tanggal_lahir',
        'tempat_lahir',
        'kelas_id',
        'nama_wali',
        'telepon_wali',
        'alamat',
        'foto_profil',
    ];

    protected $casts = [
        'tanggal_lahir' => 'date',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function kelas()
    {
        return $this->belongsTo(Kelas::class);
    }

    public function absensiHarian()
    {
        return $this->hasMany(AbsensiHarian::class);
    }

    public function suratAbsensi()
    {
        return $this->hasMany(SuratAbsensi::class);
    }

    public function pengumpulanTugas()
    {
        return $this->hasMany(PengumpulanTugas::class);
    }
}

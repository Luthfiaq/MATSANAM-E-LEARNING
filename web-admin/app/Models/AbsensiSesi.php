<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class AbsensiSesi extends Model
{
    use HasFactory;

    protected $table = 'absensi_sesi';

    protected $fillable = [
        'jadwal_id',
        'guru_id',
        'kelas_id',
        'lokasi_latitude',
        'lokasi_longitude',
        'radius_meter',
        'toleransi_keterlambatan',
        'status',
        'qr_code',
        'qr_data',
        'expired_at',
        'selesai_at',
    ];

    protected $casts = [
        'toleransi_keterlambatan' => 'boolean',
        'expired_at' => 'datetime',
        'selesai_at' => 'datetime',
    ];

    public function jadwal()
    {
        return $this->belongsTo(JadwalPelajaran::class);
    }

    public function guru()
    {
        return $this->belongsTo(Guru::class);
    }

    public function kelas()
    {
        return $this->belongsTo(Kelas::class);
    }

    public function absensiHarian()
    {
        return $this->hasMany(AbsensiHarian::class);
    }
}

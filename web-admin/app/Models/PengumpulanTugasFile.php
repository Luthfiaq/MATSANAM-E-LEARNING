<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PengumpulanTugasFile extends Model
{
    protected $table = 'pengumpulan_tugas_files';

    protected $fillable = [
        'pengumpulan_id',
        'disk',
        'file_path',
        'original_name',
        'mime_type',
        'size_bytes',
    ];

    protected $casts = [
        'size_bytes' => 'integer',
    ];

    public function pengumpulan()
    {
        return $this->belongsTo(PengumpulanTugas::class, 'pengumpulan_id');
    }
}

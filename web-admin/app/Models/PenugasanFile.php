<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PenugasanFile extends Model
{
    protected $table = 'penugasan_files';

    protected $fillable = [
        'penugasan_id',
        'disk',
        'file_path',
        'original_name',
        'mime_type',
        'size_bytes',
    ];

    protected $casts = [
        'size_bytes' => 'integer',
    ];

    protected $hidden = [
        'disk',
        'file_path',
    ];

    public function penugasan()
    {
        return $this->belongsTo(Penugasan::class, 'penugasan_id');
    }
}

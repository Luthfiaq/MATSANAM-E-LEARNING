<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('absensi_harian', function (Blueprint $table) {
            $table->foreignId('surat_absensi_id')
                ->nullable()
                ->after('keterangan')
                ->constrained('surat_absensi')
                ->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::table('absensi_harian', function (Blueprint $table) {
            $table->dropConstrainedForeignId('surat_absensi_id');
        });
    }
};

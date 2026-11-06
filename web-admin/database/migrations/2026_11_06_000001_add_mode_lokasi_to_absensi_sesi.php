<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('absensi_sesi', function (Blueprint $table) {
            $table->string('mode_lokasi')
                ->default('mts')
                ->after('kelas_id');
        });
    }

    public function down(): void
    {
        Schema::table('absensi_sesi', function (Blueprint $table) {
            $table->dropColumn('mode_lokasi');
        });
    }
};
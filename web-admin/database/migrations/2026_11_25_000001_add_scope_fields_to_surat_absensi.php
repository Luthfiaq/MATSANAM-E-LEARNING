<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('surat_absensi', function (Blueprint $table) {
            $table->string('cakupan', 32)->default('sehari_penuh')->after('jenis');
            $table->foreignId('jadwal_acuan_id')
                ->nullable()
                ->after('cakupan')
                ->constrained('jadwal_pelajaran')
                ->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::table('surat_absensi', function (Blueprint $table) {
            $table->dropConstrainedForeignId('jadwal_acuan_id');
            $table->dropColumn('cakupan');
        });
    }
};

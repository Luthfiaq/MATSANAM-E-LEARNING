<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('absensi_sesi', function (Blueprint $table) {
            $table->id();
            $table->foreignId('jadwal_id')->constrained('jadwal_pelajaran')->onDelete('cascade');
            $table->foreignId('guru_id')->constrained('guru')->onDelete('cascade');
            $table->foreignId('kelas_id')->constrained('kelas')->onDelete('cascade');
            $table->decimal('lokasi_latitude', 10, 8);
            $table->decimal('lokasi_longitude', 11, 8);
            $table->integer('radius_meter')->default(150);
            $table->boolean('toleransi_keterlambatan')->default(false);
            $table->enum('status', ['aktif', 'selesai'])->default('aktif');
            $table->text('qr_code');
            $table->text('qr_data');
            $table->timestamp('expired_at');
            $table->timestamp('selesai_at')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('absensi_sesi');
    }
};

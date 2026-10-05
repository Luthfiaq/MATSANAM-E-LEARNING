<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Tabel Guru
        Schema::create('guru', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->string('nip', 20)->unique();
            $table->string('nama_lengkap');
            $table->enum('jenis_kelamin', ['L', 'P']);
            $table->string('telepon', 15)->nullable();
            $table->text('alamat')->nullable();
            $table->string('foto_profil')->nullable();
            $table->timestamps();
        });

        // Tabel Kelas
        Schema::create('kelas', function (Blueprint $table) {
            $table->id();
            $table->string('nama_kelas', 50); // VII A, VIII B, dst
            $table->integer('tingkat'); // 7, 8, 9
            $table->foreignId('wali_kelas_id')->nullable()->constrained('guru')->onDelete('set null');
            $table->integer('kapasitas')->default(30);
            $table->timestamps();
        });

        // Tabel Siswa
        Schema::create('siswa', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->string('nis', 20)->unique();
            $table->string('nisn', 20)->unique();
            $table->string('nama_lengkap');
            $table->enum('jenis_kelamin', ['L', 'P']);
            $table->date('tanggal_lahir');
            $table->string('tempat_lahir');
            $table->foreignId('kelas_id')->nullable()->constrained('kelas')->onDelete('set null');
            $table->string('nama_wali')->nullable();
            $table->string('telepon_wali', 15)->nullable();
            $table->text('alamat')->nullable();
            $table->string('foto_profil')->nullable();
            $table->timestamps();
        });

        // Tabel Periode Akademik
        Schema::create('periode_akademik', function (Blueprint $table) {
            $table->id();
            $table->string('nama'); // Ganjil 2026/2027
            $table->string('tahun_ajaran', 10); // 2026/2027
            $table->enum('semester', ['ganjil', 'genap']);
            $table->date('tanggal_mulai');
            $table->date('tanggal_selesai');
            $table->boolean('is_active')->default(false);
            $table->timestamps();
        });

        // Tabel Mata Pelajaran
        Schema::create('mata_pelajaran', function (Blueprint $table) {
            $table->id();
            $table->string('kode', 10)->unique();
            $table->string('nama');
            $table->text('deskripsi')->nullable();
            $table->integer('kkm')->default(75); // Kriteria Ketuntasan Minimal
            $table->timestamps();
        });

        // Tabel Jadwal Pelajaran
        Schema::create('jadwal_pelajaran', function (Blueprint $table) {
            $table->id();
            $table->foreignId('periode_id')->constrained('periode_akademik')->onDelete('cascade');
            $table->foreignId('kelas_id')->constrained('kelas')->onDelete('cascade');
            $table->foreignId('mapel_id')->constrained('mata_pelajaran')->onDelete('cascade');
            $table->foreignId('guru_id')->constrained('guru')->onDelete('cascade');
            $table->enum('hari', ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu']);
            $table->time('jam_mulai');
            $table->time('jam_selesai');
            $table->string('ruangan', 20)->nullable();
            $table->timestamps();
        });

        // Tabel Absensi Harian
        Schema::create('absensi_harian', function (Blueprint $table) {
            $table->id();
            $table->foreignId('siswa_id')->constrained('siswa')->onDelete('cascade');
            $table->foreignId('jadwal_id')->constrained('jadwal_pelajaran')->onDelete('cascade');
            $table->date('tanggal');
            $table->enum('status', ['hadir', 'izin', 'sakit', 'alpa'])->default('hadir');
            $table->time('waktu_absen')->nullable();
            $table->string('metode', 20)->default('manual'); // manual, qr
            $table->text('keterangan')->nullable();
            $table->timestamps();
            
            $table->unique(['siswa_id', 'jadwal_id', 'tanggal']);
        });

        // Tabel Surat Absensi (untuk izin/sakit)
        Schema::create('surat_absensi', function (Blueprint $table) {
            $table->id();
            $table->foreignId('siswa_id')->constrained('siswa')->onDelete('cascade');
            $table->date('tanggal_mulai');
            $table->date('tanggal_selesai');
            $table->enum('jenis', ['sakit', 'izin']);
            $table->text('alasan');
            $table->string('file_surat')->nullable();
            $table->enum('status_verifikasi', ['pending', 'disetujui', 'ditolak'])->default('pending');
            $table->foreignId('verifikator_id')->nullable()->constrained('users')->onDelete('set null');
            $table->timestamp('tanggal_verifikasi')->nullable();
            $table->text('catatan_verifikasi')->nullable();
            $table->timestamps();
        });

        // Tabel Penugasan
        Schema::create('penugasan', function (Blueprint $table) {
            $table->id();
            $table->foreignId('jadwal_id')->constrained('jadwal_pelajaran')->onDelete('cascade');
            $table->foreignId('guru_id')->constrained('guru')->onDelete('cascade');
            $table->string('judul');
            $table->text('deskripsi');
            $table->enum('jenis', ['tugas', 'quiz', 'uts', 'uas']);
            $table->timestamp('deadline');
            $table->string('file_materi')->nullable();
            $table->integer('bobot')->default(100); // Nilai maksimal
            $table->timestamps();
        });

        // Tabel Pengumpulan Tugas
        Schema::create('pengumpulan_tugas', function (Blueprint $table) {
            $table->id();
            $table->foreignId('penugasan_id')->constrained('penugasan')->onDelete('cascade');
            $table->foreignId('siswa_id')->constrained('siswa')->onDelete('cascade');
            $table->text('jawaban')->nullable();
            $table->string('file_jawaban')->nullable();
            $table->timestamp('waktu_pengumpulan');
            $table->enum('status', ['tepat_waktu', 'terlambat'])->default('tepat_waktu');
            $table->timestamps();
            
            $table->unique(['penugasan_id', 'siswa_id']);
        });

        // Tabel Nilai
        Schema::create('nilai', function (Blueprint $table) {
            $table->id();
            $table->foreignId('pengumpulan_id')->constrained('pengumpulan_tugas')->onDelete('cascade');
            $table->foreignId('guru_id')->constrained('guru')->onDelete('cascade');
            $table->decimal('nilai', 5, 2);
            $table->text('catatan')->nullable();
            $table->timestamp('tanggal_penilaian');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('nilai');
        Schema::dropIfExists('pengumpulan_tugas');
        Schema::dropIfExists('penugasan');
        Schema::dropIfExists('surat_absensi');
        Schema::dropIfExists('absensi_harian');
        Schema::dropIfExists('jadwal_pelajaran');
        Schema::dropIfExists('mata_pelajaran');
        Schema::dropIfExists('periode_akademik');
        Schema::dropIfExists('siswa');
        Schema::dropIfExists('kelas');
        Schema::dropIfExists('guru');
    }
};

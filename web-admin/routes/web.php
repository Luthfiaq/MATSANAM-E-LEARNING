<?php

use App\Http\Controllers\Auth\LoginController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\PenugasanController;
use App\Http\Controllers\Admin\AbsensiController;
use App\Http\Controllers\Admin\MateriController;
use App\Http\Controllers\Admin\TugasController;
use App\Http\Controllers\Admin\NilaiController;
use App\Http\Controllers\Admin\AccountManagementController;
use App\Http\Controllers\Admin\GuruController as MasterGuruController;
use App\Http\Controllers\Admin\SiswaController as MasterSiswaController;
use App\Http\Controllers\Admin\KelasController;
use App\Http\Controllers\Admin\MataPelajaranController;
use App\Http\Controllers\Admin\PeriodeAkademikController;
use App\Http\Controllers\Admin\JadwalPelajaranController;
use App\Http\Controllers\Admin\PengaturanController;
use Illuminate\Support\Facades\Route;

// Redirect root to login
Route::get('/', function () {
    return redirect()->route('login');
});

// Auth routes
Route::get('/login', [LoginController::class, 'showLoginForm'])->name('login');
Route::post('/login', [LoginController::class, 'login']);
Route::post('/logout', [LoginController::class, 'logout'])->name('logout');

// Admin routes (protected)
Route::middleware(['auth', App\Http\Middleware\EnsureUserIsAdmin::class])->prefix('admin')->name('admin.')->group(function () {
    Route::get('/dashboard', [DashboardController::class, 'index'])->name('dashboard');

    // Master data — routes ini melengkapi controller dan Blade yang sudah tersedia.
    Route::prefix('master-data')->name('master-data.')->group(function () {
        Route::get('/guru', [MasterGuruController::class, 'index'])->name('guru.index');
        Route::get('/guru/create', [MasterGuruController::class, 'create'])->name('guru.create');
        Route::post('/guru', [MasterGuruController::class, 'store'])->name('guru.store');
        Route::get('/guru/{id}/edit', [MasterGuruController::class, 'edit'])->name('guru.edit');
        Route::put('/guru/{id}', [MasterGuruController::class, 'update'])->name('guru.update');
        Route::delete('/guru/{id}', [MasterGuruController::class, 'destroy'])->name('guru.destroy');

        Route::get('/siswa', [MasterSiswaController::class, 'index'])->name('siswa.index');
        Route::get('/siswa/create', [MasterSiswaController::class, 'create'])->name('siswa.create');
        Route::post('/siswa', [MasterSiswaController::class, 'store'])->name('siswa.store');
        Route::get('/siswa/{id}/edit', [MasterSiswaController::class, 'edit'])->name('siswa.edit');
        Route::put('/siswa/{id}', [MasterSiswaController::class, 'update'])->name('siswa.update');
        Route::delete('/siswa/{id}', [MasterSiswaController::class, 'destroy'])->name('siswa.destroy');

        Route::get('/kelas', [KelasController::class, 'index'])->name('kelas.index');
        Route::get('/kelas/create', [KelasController::class, 'create'])->name('kelas.create');
        Route::post('/kelas', [KelasController::class, 'store'])->name('kelas.store');
        Route::get('/kelas/{id}/edit', [KelasController::class, 'edit'])->name('kelas.edit');
        Route::put('/kelas/{id}', [KelasController::class, 'update'])->name('kelas.update');
        Route::delete('/kelas/{id}', [KelasController::class, 'destroy'])->name('kelas.destroy');

        Route::get('/mata-pelajaran', [MataPelajaranController::class, 'index'])->name('mata-pelajaran.index');
        Route::get('/mata-pelajaran/create', [MataPelajaranController::class, 'create'])->name('mata-pelajaran.create');
        Route::post('/mata-pelajaran', [MataPelajaranController::class, 'store'])->name('mata-pelajaran.store');
        Route::get('/mata-pelajaran/{id}/edit', [MataPelajaranController::class, 'edit'])->name('mata-pelajaran.edit');
        Route::put('/mata-pelajaran/{id}', [MataPelajaranController::class, 'update'])->name('mata-pelajaran.update');
        Route::delete('/mata-pelajaran/{id}', [MataPelajaranController::class, 'destroy'])->name('mata-pelajaran.destroy');

        Route::get('/periode-akademik', [PeriodeAkademikController::class, 'index'])->name('periode-akademik.index');
        Route::get('/periode-akademik/create', [PeriodeAkademikController::class, 'create'])->name('periode-akademik.create');
        Route::post('/periode-akademik', [PeriodeAkademikController::class, 'store'])->name('periode-akademik.store');
        Route::get('/periode-akademik/{id}/edit', [PeriodeAkademikController::class, 'edit'])->name('periode-akademik.edit');
        Route::put('/periode-akademik/{id}', [PeriodeAkademikController::class, 'update'])->name('periode-akademik.update');
        Route::delete('/periode-akademik/{id}', [PeriodeAkademikController::class, 'destroy'])->name('periode-akademik.destroy');

        Route::get('/jadwal-pelajaran', [JadwalPelajaranController::class, 'index'])->name('jadwal-pelajaran.index');
        Route::get('/jadwal-pelajaran/create', [JadwalPelajaranController::class, 'create'])->name('jadwal-pelajaran.create');
        Route::post('/jadwal-pelajaran', [JadwalPelajaranController::class, 'store'])->name('jadwal-pelajaran.store');
        Route::get('/jadwal-pelajaran/{id}/edit', [JadwalPelajaranController::class, 'edit'])->name('jadwal-pelajaran.edit');
        Route::put('/jadwal-pelajaran/{id}', [JadwalPelajaranController::class, 'update'])->name('jadwal-pelajaran.update');
        Route::delete('/jadwal-pelajaran/{id}', [JadwalPelajaranController::class, 'destroy'])->name('jadwal-pelajaran.destroy');
    });

    // Pengaturan Admin
    Route::get('/pengaturan', [PengaturanController::class, 'index'])->name('pengaturan');
    Route::put('/pengaturan/profil', [PengaturanController::class, 'updateProfile'])->name('pengaturan.profile');
    Route::put('/pengaturan/password', [PengaturanController::class, 'updatePassword'])->name('pengaturan.password');

    // Manajemen Akun Guru dan Siswa
    Route::prefix('accounts')->name('accounts.')->group(function () {
        Route::get('/', [AccountManagementController::class, 'index'])->name('index');
        Route::get('/create/{role}', [AccountManagementController::class, 'create'])->name('create');
        Route::post('/create/{role}', [AccountManagementController::class, 'store'])->name('store');
        Route::get('/{user}', [AccountManagementController::class, 'show'])->name('show');
        Route::get('/{user}/edit', [AccountManagementController::class, 'edit'])->name('edit');
        Route::put('/{user}', [AccountManagementController::class, 'update'])->name('update');
        Route::post('/{user}/reset-password', [AccountManagementController::class, 'resetPassword'])->name('reset-password');
        Route::post('/{user}/status', [AccountManagementController::class, 'toggleStatus'])->name('status');
        Route::delete('/{user}', [AccountManagementController::class, 'destroy'])->name('destroy');
        Route::post('/{userId}/restore', [AccountManagementController::class, 'restore'])->name('restore');
    });
    
    // Penugasan routes
    Route::get('/penugasan', [PenugasanController::class, 'index'])->name('penugasan.index');
    Route::get('/penugasan/create', [PenugasanController::class, 'create'])->name('penugasan.create');
    Route::post('/penugasan', [PenugasanController::class, 'store'])->name('penugasan.store');
    Route::get('/penugasan/{id}/edit', [PenugasanController::class, 'edit'])->name('penugasan.edit');
    Route::put('/penugasan/{id}', [PenugasanController::class, 'update'])->name('penugasan.update');
    Route::delete('/penugasan/{id}', [PenugasanController::class, 'destroy'])->name('penugasan.destroy');

    // Materi routes
    Route::get('/materi', [MateriController::class, 'index'])->name('materi.index');
    Route::get('/materi/create', [MateriController::class, 'create'])->name('materi.create');
    Route::post('/materi', [MateriController::class, 'store'])->name('materi.store');
    Route::get('/materi/{id}/edit', [MateriController::class, 'edit'])->name('materi.edit');
    Route::put('/materi/{id}', [MateriController::class, 'update'])->name('materi.update');
    Route::delete('/materi/{id}', [MateriController::class, 'destroy'])->name('materi.destroy');

    // Tugas routes
    Route::get('/tugas', [TugasController::class, 'index'])->name('tugas.index');
    Route::get('/tugas/create', [TugasController::class, 'create'])->name('tugas.create');
    Route::post('/tugas', [TugasController::class, 'store'])->name('tugas.store');
    Route::get('/tugas/{id}', [TugasController::class, 'show'])->name('tugas.show');
    Route::get('/tugas/{id}/edit', [TugasController::class, 'edit'])->name('tugas.edit');
    Route::put('/tugas/{id}', [TugasController::class, 'update'])->name('tugas.update');
    Route::delete('/tugas/{id}', [TugasController::class, 'destroy'])->name('tugas.destroy');

    // Nilai routes
    Route::get('/nilai', [NilaiController::class, 'index'])->name('nilai.index');
    Route::get('/nilai/{tugas_id}', [NilaiController::class, 'detail'])->name('nilai.detail');
    Route::post('/nilai', [NilaiController::class, 'store'])->name('nilai.store');

    // Absensi routes
    Route::get('/absensi/verifikasi', [AbsensiController::class, 'verifikasiSurat'])->name('absensi.verifikasi');
    Route::get('/absensi/histori', [AbsensiController::class, 'historiSurat'])->name('absensi.histori');
    Route::get('/absensi/surat/{id}/file', [AbsensiController::class, 'fileSurat'])->name('absensi.surat.file');
    Route::post('/absensi/surat/{id}/approve', [AbsensiController::class, 'approveSurat'])->name('absensi.surat.approve');
    Route::post('/absensi/surat/{id}/reject', [AbsensiController::class, 'rejectSurat'])->name('absensi.surat.reject');
    Route::get('/absensi/rekap', [AbsensiController::class, 'rekapPresensi'])->name('absensi.rekap');
    Route::get('/absensi/export', [AbsensiController::class, 'exportPresensi'])->name('absensi.export');
});

<?php

use App\Http\Controllers\Auth\LoginController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\PenugasanController;
use App\Http\Controllers\Admin\AbsensiController;
use App\Http\Controllers\Admin\MateriController;
use App\Http\Controllers\Admin\TugasController;
use App\Http\Controllers\Admin\NilaiController;
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
    Route::post('/absensi/surat/{id}/approve', [AbsensiController::class, 'approveSurat'])->name('absensi.surat.approve');
    Route::post('/absensi/surat/{id}/reject', [AbsensiController::class, 'rejectSurat'])->name('absensi.surat.reject');
    Route::get('/absensi/rekap', [AbsensiController::class, 'rekapPresensi'])->name('absensi.rekap');
    Route::get('/absensi/export', [AbsensiController::class, 'exportPresensi'])->name('absensi.export');
});

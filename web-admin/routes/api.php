<?php

use App\Http\Controllers\Api\SiswaDashboardController;
use App\Http\Controllers\Api\SiswaAbsensiController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\GuruController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

// Autentikasi multi-role: admin, guru, dan siswa.
Route::post('/login', [AuthController::class, 'login']);
Route::post('/auth/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', fn (Request $request) => $request->user());
    Route::get('/auth/me', [AuthController::class, 'me']);
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::post('/auth/change-password', [AuthController::class, 'changePassword']);

    // Mobile Siswa
    Route::get('/siswa/dashboard', [SiswaDashboardController::class, 'index']);
    Route::post('/siswa/pengajuan-izin', [SiswaAbsensiController::class, 'store']);

    // Mobile Guru
    Route::prefix('guru')->group(function () {
        Route::get('/dashboard', [GuruController::class, 'dashboard']);
        Route::get('/mapel-kelas', [GuruController::class, 'mapelKelas']);
        Route::get('/mapel/{jadwalId}/tugas', [GuruController::class, 'tugasByJadwal']);

        // Materi
        Route::get('/materi', [GuruController::class, 'materiIndex']);
        Route::post('/materi', [GuruController::class, 'materiStore']);
        Route::put('/materi/{id}', [GuruController::class, 'materiUpdate']);
        Route::delete('/materi/{id}', [GuruController::class, 'materiDestroy']);

        // Tugas dan pengumpulan
        Route::get('/tugas', [GuruController::class, 'tugasIndex']);
        Route::post('/tugas', [GuruController::class, 'tugasStore']);
        Route::put('/tugas/{id}', [GuruController::class, 'tugasUpdate']);
        Route::delete('/tugas/{id}', [GuruController::class, 'tugasDestroy']);
        Route::get('/tugas/{id}/submission', [GuruController::class, 'getSubmissions']);

        // Nilai
        Route::get('/nilai', [GuruController::class, 'nilaiIndex']);
        Route::get('/nilai/{tugas_id}', [GuruController::class, 'nilaiDetail']);
        Route::post('/nilai', [GuruController::class, 'nilaiStore']);

        // Absensi Guru
        Route::post('/generate-qr', [GuruController::class, 'generateQr']);
        Route::post('/start-session', [GuruController::class, 'startSession']);
        Route::post('/stop-session', [GuruController::class, 'stopSession']);
        Route::prefix('absensi')->group(function () {
            Route::post('/start-session', [GuruController::class, 'startSession']);
            Route::post('/close-session/{id}', [GuruController::class, 'closeSession']);
            Route::get('/session/{id}', [GuruController::class, 'sessionDetails']);
            Route::post('/session/{id}/regenerate-qr', [GuruController::class, 'regenerateSessionQr']);
            Route::get('/session/{id}/attendance', [GuruController::class, 'sessionAttendance']);
        });
        Route::get('/sesi-report', [GuruController::class, 'sesiReport']);
        Route::get('/rekap-presensi', [GuruController::class, 'rekapPresensi']);

        // Verifikasi surat
        Route::get('/surat-verifikasi', [GuruController::class, 'suratVerifikasi']);
        Route::post('/surat-verifikasi/{id}/approve', [GuruController::class, 'approveSurat']);
        Route::post('/surat-verifikasi/{id}/reject', [GuruController::class, 'rejectSurat']);
    });
});

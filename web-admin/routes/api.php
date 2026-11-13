<?php

use App\Http\Controllers\Api\SiswaDashboardController;
use App\Http\Controllers\Api\SiswaAbsensiController;
use App\Http\Controllers\Api\SiswaLearningController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\GuruController;
use App\Http\Middleware\EnsurePasswordChanged;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

// Login mobile: Guru dan Siswa. Admin memakai autentikasi sesi web tersendiri.
Route::post('/login', [AuthController::class, 'login'])->middleware('throttle:login');
Route::post('/auth/login', [AuthController::class, 'login'])->middleware('throttle:login');

// API tokens are limited to active Guru/Siswa accounts. Admin uses web sessions.
Route::middleware(['auth:sanctum', 'active.account', 'role:guru,siswa'])->group(function () {
    Route::get('/user', fn (Request $request) => $request->user());
    Route::get('/auth/me', [AuthController::class, 'me']);
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::post('/auth/change-password', [AuthController::class, 'changePassword']);

    // Semua endpoint operasional Guru/Siswa dikunci sampai password sementara diganti.
    Route::middleware(EnsurePasswordChanged::class)->group(function () {
    // Notification Center — feed, badge, read state, dan preferensi akun.
    Route::prefix('notifications')->group(function () {
        Route::get('/', [NotificationController::class, 'index']);
        Route::get('/unread-count', [NotificationController::class, 'unreadCount']);
        Route::get('/preferences', [NotificationController::class, 'preferences']);
        Route::put('/preferences', [NotificationController::class, 'updatePreferences']);
        Route::post('/read-all', [NotificationController::class, 'markAllAsRead']);
        Route::post('/{id}/read', [NotificationController::class, 'markAsRead'])->whereUuid('id');
    });

    // Mobile Siswa — seluruh resource dibatasi pada siswa dari token Sanctum.
    Route::prefix('siswa')->middleware('role:siswa')->group(function () {
        Route::get('/dashboard', [SiswaDashboardController::class, 'index']);
        Route::get('/mapel', [SiswaLearningController::class, 'mapel']);

        Route::get('/materi', [SiswaLearningController::class, 'materiIndex']);
        Route::get('/materi/{id}', [SiswaLearningController::class, 'materiShow']);
        Route::get('/materi/{id}/file', [SiswaLearningController::class, 'materiFile']);

        Route::get('/tugas', [SiswaLearningController::class, 'tugasIndex']);
        Route::get('/tugas/{id}', [SiswaLearningController::class, 'tugasShow']);
        Route::get('/tugas/{id}/file', [SiswaLearningController::class, 'tugasFile']);
        Route::post('/tugas/{id}/kumpulkan', [SiswaLearningController::class, 'tugasKumpulkan']);
        Route::get('/pengumpulan/{id}/file', [SiswaLearningController::class, 'pengumpulanFile']);

        Route::get('/nilai', [SiswaLearningController::class, 'nilaiIndex']);
        Route::get('/nilai/mapel/{mapelId}', [SiswaLearningController::class, 'nilaiByMapel']);
        Route::get('/jadwal', [SiswaLearningController::class, 'jadwal']);
        Route::get('/absensi/riwayat', [SiswaLearningController::class, 'riwayatAbsensi']);
        Route::post('/absensi/scan', [SiswaLearningController::class, 'scanQr'])->middleware('throttle:10,1');
        Route::get('/surat-izin', [SiswaLearningController::class, 'suratIndex']);
        Route::get('/surat/{id}/file', [SiswaLearningController::class, 'suratFile']);
        Route::post('/pengajuan-izin', [SiswaAbsensiController::class, 'store']);
    });

    // Mobile Guru
    Route::prefix('guru')->middleware('role:guru')->group(function () {
        Route::get('/dashboard', [GuruController::class, 'dashboard']);
        Route::get('/mapel-kelas', [GuruController::class, 'mapelKelas']);
        Route::get('/mapel/{jadwalId}/tugas', [GuruController::class, 'tugasByJadwal']);

        // Materi
        Route::get('/materi', [GuruController::class, 'materiIndex']);
        Route::get('/materi/{id}/file', [GuruController::class, 'materiFile']);
        Route::post('/materi', [GuruController::class, 'materiStore']);
        Route::put('/materi/{id}', [GuruController::class, 'materiUpdate']);
        Route::delete('/materi/{id}', [GuruController::class, 'materiDestroy']);

        // Tugas dan pengumpulan
        Route::get('/tugas', [GuruController::class, 'tugasIndex']);
        Route::post('/tugas', [GuruController::class, 'tugasStore']);
        Route::put('/tugas/{id}', [GuruController::class, 'tugasUpdate']);
        Route::delete('/tugas/{id}', [GuruController::class, 'tugasDestroy']);
        Route::get('/tugas/{id}/file', [GuruController::class, 'tugasFile']);
        Route::get('/tugas/{id}/submission', [GuruController::class, 'getSubmissions']);
        Route::get('/pengumpulan/{submissionId}/file', [GuruController::class, 'submissionFile']);

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
        Route::get('/surat-verifikasi/{id}/file', [GuruController::class, 'suratFile']);
        Route::post('/surat-verifikasi/{id}/approve', [GuruController::class, 'approveSurat']);
        Route::post('/surat-verifikasi/{id}/reject', [GuruController::class, 'rejectSurat']);
    });
    });
});

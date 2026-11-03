<?php

use Illuminate\Support\Facades\Route;

use App\Http\Controllers\Auth\LoginController;

use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\PenugasanController;
use App\Http\Controllers\Admin\AbsensiController;

use App\Http\Controllers\Admin\GuruController;
use App\Http\Controllers\Admin\SiswaController;
use App\Http\Controllers\Admin\KelasController;
use App\Http\Controllers\Admin\MataPelajaranController;
use App\Http\Controllers\Admin\PeriodeAkademikController;
use App\Http\Controllers\Admin\JadwalPelajaranController;
use App\Http\Controllers\Admin\PengaturanController;


/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
*/


// ======================================================
// ROOT
// ======================================================

Route::get('/', function () {
    return redirect()->route('login');
});


// ======================================================
// AUTHENTICATION
// ======================================================

Route::get('/login', [LoginController::class, 'showLoginForm'])
    ->name('login');

Route::post('/login', [LoginController::class, 'login']);

Route::post('/logout', [LoginController::class, 'logout'])
    ->name('logout');


// ======================================================
// ADMIN
// ======================================================

Route::middleware([
    'auth',
    App\Http\Middleware\EnsureUserIsAdmin::class
])
->prefix('admin')
->name('admin.')
->group(function () {


    // ==================================================
    // DASHBOARD
    // ==================================================

    Route::get('/dashboard', [DashboardController::class, 'index'])
        ->name('dashboard');


    // ==================================================
    // MASTER DATA - GURU
    // ==================================================

    Route::get('/master-data/guru', [GuruController::class, 'index'])
        ->name('master-data.guru.index');

    Route::get('/master-data/guru/create', [GuruController::class, 'create'])
        ->name('master-data.guru.create');

    Route::post('/master-data/guru', [GuruController::class, 'store'])
        ->name('master-data.guru.store');

    Route::get('/master-data/guru/{id}/edit', [GuruController::class, 'edit'])
        ->name('master-data.guru.edit');

    Route::put('/master-data/guru/{id}', [GuruController::class, 'update'])
        ->name('master-data.guru.update');

    Route::delete('/master-data/guru/{id}', [GuruController::class, 'destroy'])
        ->name('master-data.guru.destroy');


    // ==================================================
    // MASTER DATA - SISWA
    // ==================================================

    Route::get('/master-data/siswa', [SiswaController::class, 'index'])
        ->name('master-data.siswa.index');

    Route::get('/master-data/siswa/create', [SiswaController::class, 'create'])
        ->name('master-data.siswa.create');

    Route::post('/master-data/siswa', [SiswaController::class, 'store'])
        ->name('master-data.siswa.store');

    Route::get('/master-data/siswa/{id}/edit', [SiswaController::class, 'edit'])
        ->name('master-data.siswa.edit');

    Route::put('/master-data/siswa/{id}', [SiswaController::class, 'update'])
        ->name('master-data.siswa.update');

    Route::delete('/master-data/siswa/{id}', [SiswaController::class, 'destroy'])
        ->name('master-data.siswa.destroy');


    // ==================================================
    // MASTER DATA - KELAS
    // ==================================================

    Route::get('/master-data/kelas', [KelasController::class, 'index'])
        ->name('master-data.kelas.index');

    Route::get('/master-data/kelas/create', [KelasController::class, 'create'])
        ->name('master-data.kelas.create');

    Route::post('/master-data/kelas', [KelasController::class, 'store'])
        ->name('master-data.kelas.store');

    Route::get('/master-data/kelas/{id}/edit', [KelasController::class, 'edit'])
        ->name('master-data.kelas.edit');

    Route::put('/master-data/kelas/{id}', [KelasController::class, 'update'])
        ->name('master-data.kelas.update');

    Route::delete('/master-data/kelas/{id}', [KelasController::class, 'destroy'])
        ->name('master-data.kelas.destroy');


    // ==================================================
    // MASTER DATA - MATA PELAJARAN
    // ==================================================

    Route::get('/master-data/mata-pelajaran', [MataPelajaranController::class, 'index'])
        ->name('master-data.mata-pelajaran.index');

    Route::get('/master-data/mata-pelajaran/create', [MataPelajaranController::class, 'create'])
        ->name('master-data.mata-pelajaran.create');

    Route::post('/master-data/mata-pelajaran', [MataPelajaranController::class, 'store'])
        ->name('master-data.mata-pelajaran.store');

    Route::get('/master-data/mata-pelajaran/{id}/edit', [MataPelajaranController::class, 'edit'])
        ->name('master-data.mata-pelajaran.edit');

    Route::put('/master-data/mata-pelajaran/{id}', [MataPelajaranController::class, 'update'])
        ->name('master-data.mata-pelajaran.update');

    Route::delete('/master-data/mata-pelajaran/{id}', [MataPelajaranController::class, 'destroy'])
        ->name('master-data.mata-pelajaran.destroy');


    // ==================================================
    // MASTER DATA - PERIODE AKADEMIK
    // ==================================================

    Route::get('/master-data/periode-akademik', [PeriodeAkademikController::class, 'index'])
        ->name('master-data.periode-akademik.index');

    Route::get('/master-data/periode-akademik/create', [PeriodeAkademikController::class, 'create'])
        ->name('master-data.periode-akademik.create');

    Route::post('/master-data/periode-akademik', [PeriodeAkademikController::class, 'store'])
        ->name('master-data.periode-akademik.store');

    Route::get('/master-data/periode-akademik/{id}/edit', [PeriodeAkademikController::class, 'edit'])
        ->name('master-data.periode-akademik.edit');

    Route::put('/master-data/periode-akademik/{id}', [PeriodeAkademikController::class, 'update'])
        ->name('master-data.periode-akademik.update');

    Route::delete('/master-data/periode-akademik/{id}', [PeriodeAkademikController::class, 'destroy'])
        ->name('master-data.periode-akademik.destroy');


    // ==================================================
    // MASTER DATA - JADWAL PELAJARAN
    // ==================================================

    Route::get('/master-data/jadwal-pelajaran', [JadwalPelajaranController::class, 'index'])
        ->name('master-data.jadwal-pelajaran.index');

    Route::get('/master-data/jadwal-pelajaran/create', [JadwalPelajaranController::class, 'create'])
        ->name('master-data.jadwal-pelajaran.create');

    Route::post('/master-data/jadwal-pelajaran', [JadwalPelajaranController::class, 'store'])
        ->name('master-data.jadwal-pelajaran.store');

    Route::get('/master-data/jadwal-pelajaran/{id}/edit', [JadwalPelajaranController::class, 'edit'])
        ->name('master-data.jadwal-pelajaran.edit');

    Route::put('/master-data/jadwal-pelajaran/{id}', [JadwalPelajaranController::class, 'update'])
        ->name('master-data.jadwal-pelajaran.update');

    Route::delete('/master-data/jadwal-pelajaran/{id}', [JadwalPelajaranController::class, 'destroy'])
        ->name('master-data.jadwal-pelajaran.destroy');


    // ==================================================
    // PENUGASAN GURU
    // ==================================================

    Route::get('/penugasan', [PenugasanController::class, 'index'])
        ->name('penugasan.index');

    Route::get('/penugasan/create', [PenugasanController::class, 'create'])
        ->name('penugasan.create');

    Route::post('/penugasan', [PenugasanController::class, 'store'])
        ->name('penugasan.store');

    Route::get('/penugasan/{id}/edit', [PenugasanController::class, 'edit'])
        ->name('penugasan.edit');

    Route::put('/penugasan/{id}', [PenugasanController::class, 'update'])
        ->name('penugasan.update');

    Route::delete('/penugasan/{id}', [PenugasanController::class, 'destroy'])
        ->name('penugasan.destroy');


    // ==================================================
    // ABSENSI
    // ==================================================

    Route::get('/absensi/verifikasi', [AbsensiController::class, 'verifikasiSurat'])
        ->name('absensi.verifikasi');

    Route::get('/absensi/histori', [AbsensiController::class, 'historiSurat'])
        ->name('absensi.histori');

    Route::post('/absensi/surat/{id}/approve', [AbsensiController::class, 'approveSurat'])
        ->name('absensi.surat.approve');

    Route::post('/absensi/surat/{id}/reject', [AbsensiController::class, 'rejectSurat'])
        ->name('absensi.surat.reject');

    Route::get('/absensi/rekap', [AbsensiController::class, 'rekapPresensi'])
        ->name('absensi.rekap');

    Route::get('/absensi/export', [AbsensiController::class, 'exportPresensi'])
        ->name('absensi.export');


    // ==================================================
    // PENGATURAN
    // ==================================================

    Route::get('/pengaturan', [PengaturanController::class, 'index'])
       ->name('pengaturan');

});
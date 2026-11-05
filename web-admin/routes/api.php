<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\MateriController;
use App\Http\Controllers\Api\NilaiController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

// Endpoint API untuk Modul Materi Siswa (Flutter)
Route::get('/materi/mapel', [MateriController::class, 'getMapel']);
Route::get('/materi/mapel/{mapelId}', [MateriController::class, 'getByMapel']);
Route::get('/materi/{id}', [MateriController::class, 'show']);
Route::get('/materi/search', [MateriController::class, 'search']);

//Endpoint API untuk Modul Nilai Siswa (Flutter)
Route::get('/nilai/mapel', [NilaiController::class, 'getDaftarMapelNilai']);
Route::get('/nilai/mapel/{mapelId}', [NilaiController::class, 'getNilaiByMapel']);
Route::get('/nilai/mapel/{mapelId}/rata-rata', [NilaiController::class, 'getRataRataByMapel']);
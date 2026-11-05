<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\SiswaDashboardController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes (dipakai aplikasi mobile Flutter)
|--------------------------------------------------------------------------
*/

Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', fn (Request $request) => $request->user());
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/siswa/dashboard', [SiswaDashboardController::class, 'index']);
});

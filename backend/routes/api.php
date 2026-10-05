<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\DashboardController;

// Auth routes
Route::post('/auth/login', [AuthController::class, 'login']);
Route::post('/auth/logout', [AuthController::class, 'logout']);
Route::get('/auth/me', [AuthController::class, 'me']);

// Dashboard (public for testing, nanti tambah auth)
Route::get('/admin/dashboard', [DashboardController::class, 'index']);

// Protected routes (nanti tambah middleware auth)
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', function (Request $request) {
        return $request->user();
    });
});

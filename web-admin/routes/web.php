<?php

use App\Http\Controllers\Auth\LoginController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\PenugasanController;
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
});

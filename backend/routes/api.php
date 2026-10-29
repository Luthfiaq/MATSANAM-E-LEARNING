<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\SuratAbsensiController;

Route::post('/pengajuan-izin', [
    SuratAbsensiController::class,
    'store',
]);
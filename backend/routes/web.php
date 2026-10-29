
<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\HistoriController;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/histori', [HistoriController::class, 'index']);

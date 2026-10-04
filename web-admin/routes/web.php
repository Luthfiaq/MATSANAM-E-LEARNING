<?php

use Illuminate\Support\Facades\Route;

// Redirect halaman utama langsung ke login
Route::get('/', function () {
    return view('login');
});

// Route untuk halaman Login
Route::get('/login', function () {
    return view('login');
});

// Route untuk halaman Dashboard
Route::get('/dashboard', function () {
    return view('dashboard');
});
@extends('layouts.admin')

@section('title', 'Pengaturan')

@section('content')

<div class="max-w-5xl mx-auto">

    <!-- Header -->
    <div class="mb-6">
        <h1 class="text-2xl font-bold text-slate-800">
            ⚙️ Pengaturan
        </h1>

        <p class="text-sm text-slate-500 mt-1">
            Atur tampilan dan preferensi MATSANAM E-LEARNING sesuai kenyamanan Anda.
        </p>
    </div>


    <!-- TAMPILAN -->
    <div class="bg-white rounded-xl shadow-sm border border-slate-200 p-6 mb-6 theme-card">

        <div class="flex items-center gap-3 mb-5">

            <div class="w-10 h-10 rounded-lg bg-blue-100 flex items-center justify-center text-xl">
                🎨
            </div>

            <div>
                <h2 class="text-lg font-semibold text-slate-800 theme-text">
                    Tampilan Aplikasi
                </h2>

                <p class="text-sm text-slate-500">
                    Pilih tampilan yang nyaman digunakan.
                </p>
            </div>

        </div>


        <!-- MODE TERANG -->
        <div class="flex items-center justify-between border border-slate-200 rounded-xl p-4 mb-3 theme-card">

            <div class="flex items-center gap-4">

                <div class="w-11 h-11 rounded-full bg-yellow-100 flex items-center justify-center text-2xl">
                    ☀️
                </div>

                <div>
                    <h3 class="font-semibold text-slate-800 theme-text">
                        Mode Terang
                    </h3>

                    <p class="text-sm text-slate-500">
                        Gunakan tampilan terang untuk penggunaan sehari-hari.
                    </p>
                </div>

            </div>

            <button
                type="button"
                onclick="setTheme('light')"
                id="lightButton"
                class="px-5 py-2 rounded-lg bg-blue-600 text-white text-sm font-medium hover:bg-blue-700 transition">

                Gunakan

            </button>

        </div>


        <!-- MODE GELAP -->
        <div class="flex items-center justify-between border border-slate-200 rounded-xl p-4 theme-card">

            <div class="flex items-center gap-4">

                <div class="w-11 h-11 rounded-full bg-slate-700 flex items-center justify-center text-2xl">
                    🌙
                </div>

                <div>
                    <h3 class="font-semibold text-slate-800 theme-text">
                        Mode Gelap
                    </h3>

                    <p class="text-sm text-slate-500">
                        Gunakan tampilan gelap agar lebih nyaman saat digunakan.
                    </p>
                </div>

            </div>

            <button
                type="button"
                onclick="setTheme('dark')"
                id="darkButton"
                class="px-5 py-2 rounded-lg bg-slate-700 text-white text-sm font-medium hover:bg-slate-800 transition">

                Gunakan

            </button>

        </div>

    </div>


    <!-- PREFERENSI -->
    <div class="bg-white rounded-xl shadow-sm border border-slate-200 p-6 mb-6 theme-card">

        <div class="flex items-center gap-3 mb-5">

            <div class="w-10 h-10 rounded-lg bg-green-100 flex items-center justify-center text-xl">
                🔔
            </div>

            <div>
                <h2 class="text-lg font-semibold text-slate-800 theme-text">
                    Preferensi
                </h2>

                <p class="text-sm text-slate-500">
                    Atur preferensi penggunaan aplikasi.
                </p>
            </div>

        </div>


        <!-- NOTIFIKASI -->
        <div class="flex items-center justify-between py-4 border-b border-slate-200">

            <div>
                <h3 class="font-medium text-slate-800 theme-text">
                    Notifikasi
                </h3>

                <p class="text-sm text-slate-500">
                    Aktifkan notifikasi untuk mendapatkan informasi terbaru.
                </p>
            </div>

            <label class="relative inline-flex items-center cursor-pointer">

                <input
                    type="checkbox"
                    class="sr-only peer"
                    checked>

                <div class="w-11 h-6 bg-slate-300 rounded-full peer
                            peer-checked:bg-blue-600
                            after:content-['']
                            after:absolute
                            after:top-[2px]
                            after:left-[2px]
                            after:bg-white
                            after:border
                            after:border-gray-300
                            after:rounded-full
                            after:h-5
                            after:w-5
                            after:transition-all
                            peer-checked:after:translate-x-full">
                </div>

            </label>

        </div>


        <!-- UKURAN TEKS -->
        <div class="flex items-center justify-between py-4">

            <div>
                <h3 class="font-medium text-slate-800 theme-text">
                    Ukuran Teks
                </h3>

                <p class="text-sm text-slate-500">
                    Pilih ukuran teks yang nyaman digunakan.
                </p>
            </div>

            <select
                class="border border-slate-300 rounded-lg px-3 py-2 text-sm bg-white">

                <option>Kecil</option>
                <option selected>Sedang</option>
                <option>Besar</option>

            </select>

        </div>

    </div>


    <!-- INFORMASI -->
    <div class="bg-white rounded-xl shadow-sm border border-slate-200 p-6 theme-card">

        <div class="flex items-center gap-3 mb-4">

            <div class="w-10 h-10 rounded-lg bg-purple-100 flex items-center justify-center text-xl">
                ℹ️
            </div>

            <div>
                <h2 class="text-lg font-semibold text-slate-800 theme-text">
                    Informasi Aplikasi
                </h2>

                <p class="text-sm text-slate-500">
                    Informasi mengenai aplikasi.
                </p>
            </div>

        </div>

        <div class="space-y-3 text-sm">

            <div class="flex justify-between">
                <span class="text-slate-500">
                    Nama Aplikasi
                </span>

                <span class="font-medium text-slate-800 theme-text">
                    MATSANAM E-LEARNING
                </span>
            </div>

            <div class="flex justify-between">
                <span class="text-slate-500">
                    Versi
                </span>

                <span class="font-medium text-slate-800 theme-text">
                    1.0.0
                </span>
            </div>

            <div class="flex justify-between">
                <span class="text-slate-500">
                    Platform
                </span>

                <span class="font-medium text-slate-800 theme-text">
                    Web Application
                </span>
            </div>

        </div>

    </div>

</div>


<script>

    function setTheme(theme) {

        if (theme === 'dark') {

            document.documentElement.classList.add('dark');

            localStorage.setItem('theme', 'dark');

        } else {

            document.documentElement.classList.remove('dark');

            localStorage.setItem('theme', 'light');

        }

        updateThemeButton();

    }


    function updateThemeButton() {

        const theme = localStorage.getItem('theme') || 'light';

        const lightButton = document.getElementById('lightButton');
        const darkButton = document.getElementById('darkButton');

        if (!lightButton || !darkButton) {
            return;
        }

        if (theme === 'dark') {

            darkButton.innerHTML = '✓ Aktif';

            darkButton.classList.remove('bg-slate-700');
            darkButton.classList.add('bg-green-600');

            lightButton.innerHTML = 'Gunakan';

            lightButton.classList.remove('bg-green-600');
            lightButton.classList.add('bg-blue-600');

        } else {

            lightButton.innerHTML = '✓ Aktif';

            lightButton.classList.remove('bg-blue-600');
            lightButton.classList.add('bg-green-600');

            darkButton.innerHTML = 'Gunakan';

            darkButton.classList.remove('bg-green-600');
            darkButton.classList.add('bg-slate-700');

        }

    }


    document.addEventListener('DOMContentLoaded', function () {

        if (!localStorage.getItem('theme')) {
            localStorage.setItem('theme', 'light');
        }

        updateThemeButton();

    });

</script>

@endsection
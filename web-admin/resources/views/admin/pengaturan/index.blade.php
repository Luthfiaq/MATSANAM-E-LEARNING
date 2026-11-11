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
                    id="notificationPreference"
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

            <select id="textSizePreference" class="border border-slate-300 rounded-lg px-3 py-2 text-sm bg-white">
                <option value="small">Kecil</option>
                <option value="medium">Sedang</option>
                <option value="large">Besar</option>
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
        const selectedTheme = theme === 'dark' ? 'dark' : 'light';
        document.documentElement.classList.toggle('dark', selectedTheme === 'dark');
        document.documentElement.dataset.theme = selectedTheme;
        try { localStorage.setItem('theme', selectedTheme); } catch (error) {}
        updateThemeButton();
    }

    function updateThemeButton() {
        let theme = 'light';
        try { theme = localStorage.getItem('theme') || 'light'; } catch (error) {}
        const lightButton = document.getElementById('lightButton');
        const darkButton = document.getElementById('darkButton');
        if (!lightButton || !darkButton) return;

        const activeClasses = ['bg-green-600', 'hover:bg-green-700'];
        const lightInactive = ['bg-blue-600', 'hover:bg-blue-700'];
        const darkInactive = ['bg-slate-700', 'hover:bg-slate-800'];
        if (theme === 'dark') {
            darkButton.textContent = '✓ Aktif';
            darkButton.classList.remove(...darkInactive);
            darkButton.classList.add(...activeClasses);
            lightButton.textContent = 'Gunakan';
            lightButton.classList.remove(...activeClasses);
            lightButton.classList.add(...lightInactive);
        } else {
            lightButton.textContent = '✓ Aktif';
            lightButton.classList.remove(...lightInactive);
            lightButton.classList.add(...activeClasses);
            darkButton.textContent = 'Gunakan';
            darkButton.classList.remove(...activeClasses);
            darkButton.classList.add(...darkInactive);
        }
    }

    document.addEventListener('DOMContentLoaded', function () {
        const notification = document.getElementById('notificationPreference');
        const textSize = document.getElementById('textSizePreference');
        let notificationsEnabled = true;
        let savedTextSize = 'medium';
        try {
            notificationsEnabled = localStorage.getItem('notificationsEnabled') !== 'false';
            savedTextSize = localStorage.getItem('textSize') || 'medium';
        } catch (error) {}

        if (notification) {
            notification.checked = notificationsEnabled;
            notification.addEventListener('change', function () {
                try { localStorage.setItem('notificationsEnabled', this.checked ? 'true' : 'false'); } catch (error) {}
            });
        }

        if (textSize) {
            textSize.value = ['small', 'medium', 'large'].includes(savedTextSize) ? savedTextSize : 'medium';
            document.documentElement.dataset.textSize = textSize.value;
            textSize.addEventListener('change', function () {
                document.documentElement.dataset.textSize = this.value;
                try { localStorage.setItem('textSize', this.value); } catch (error) {}
            });
        }
        updateThemeButton();
    });
</script>

@endsection
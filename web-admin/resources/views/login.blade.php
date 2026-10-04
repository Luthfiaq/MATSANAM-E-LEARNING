<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login Web Admin - MTsN 6 Nganjuk</title>
    <!-- Tailwind CSS via CDN -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Google Font Inter & FontAwesome Icons -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body { font-family: 'Inter', sans-serif; }
    </style>
</head>
<body class="bg-[#F8FAFC] min-h-screen flex flex-col items-center justify-center p-4">

    <!-- Container Utama -->
    <div class="w-full max-w-[420px] flex flex-col items-center">
        
        <!-- Logo Kemenag / MTsN 6 Nganjuk -->
        <div class="mb-4">
            <div class="w-20 h-20 bg-white rounded-full shadow-md flex items-center justify-center p-2 border border-slate-100">
                <!-- Icon/Logo Pengganti (Bisa diganti tag <img src="path_logo">) -->
                <i class="fa-solid fa-graduation-cap text-3xl text-emerald-600"></i>
            </div>
        </div>

        <!-- Badge Atas -->
        <div class="inline-flex items-center space-x-2 bg-blue-50 border border-blue-100 text-blue-600 px-3.5 py-1 rounded-full text-xs font-semibold tracking-wide mb-3">
            <span class="w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></span>
            <span>PORTAL ADMINISTRATOR WEB</span>
        </div>

        <!-- Judul Header -->
        <h1 class="text-2xl font-bold text-slate-900 tracking-tight text-center">MTsN 6 Nganjuk</h1>
        <p class="text-slate-500 text-xs text-center max-w-[280px] mt-1 mb-6 leading-relaxed">
            Gerbang Layanan Terpadu e-Learning &amp; Presensi Admin
        </p>

        <!-- Card Form Login -->
        <div class="w-full bg-white rounded-3xl p-8 shadow-sm border border-slate-200/80">
            <div class="mb-6">
                <h2 class="text-lg font-bold text-slate-900">Selamat Datang Admin</h2>
                <p class="text-xs text-slate-500 mt-0.5">Masukkan email dan kata sandi Anda</p>
            </div>

            <form action="#" method="POST" class="space-y-4" onsubmit="event.preventDefault(); window.location.href='dashboard.blade.php';">
                <!-- Field Email -->
                <div>
                    <label class="block text-xs font-medium text-slate-700 mb-1.5">Email / NIP Admin</label>
                    <div class="relative">
                        <span class="absolute inset-y-0 left-0 pl-3.5 flex items-center text-slate-400">
                            <i class="fa-regular fa-envelope text-sm"></i>
                        </span>
                        <input type="email" required placeholder="nama@matsanam.sch.id" 
                            class="w-full pl-10 pr-4 py-2.5 bg-[#F8FAFC] border border-slate-200 rounded-xl text-sm text-slate-800 placeholder-slate-400 focus:outline-none focus:border-blue-500 focus:bg-white transition duration-150">
                    </div>
                </div>

                <!-- Field Password -->
                <div>
                    <label class="block text-xs font-medium text-slate-700 mb-1.5">Kata Sandi</label>
                    <div class="relative">
                        <span class="absolute inset-y-0 left-0 pl-3.5 flex items-center text-slate-400">
                            <i class="fa-solid fa-lock text-sm"></i>
                        </span>
                        <input type="password" required placeholder="Masukkan kata sandi" 
                            class="w-full pl-10 pr-10 py-2.5 bg-[#F8FAFC] border border-slate-200 rounded-xl text-sm text-slate-800 placeholder-slate-400 focus:outline-none focus:border-blue-500 focus:bg-white transition duration-150">
                        <button type="button" class="absolute inset-y-0 right-0 pr-3.5 flex items-center text-slate-400 hover:text-slate-600">
                            <i class="fa-regular fa-eye-slash text-sm"></i>
                        </button>
                    </div>
                </div>

                <!-- Checkbox & Lupa Sandi -->
                <div class="flex items-center justify-between pt-1">
                    <label class="flex items-center cursor-pointer">
                        <input type="checkbox" class="w-4 h-4 rounded border-slate-300 text-blue-600 focus:ring-blue-500">
                        <span class="ml-2 text-xs font-medium text-slate-600">Ingat Saya</span>
                    </label>
                    <a href="#" class="text-xs font-semibold text-blue-600 hover:text-blue-700">Lupa Kata Sandi?</a>
                </div>

                <!-- Tombol Masuk -->
                <button type="submit" 
                    class="w-full mt-2 bg-blue-600 hover:bg-blue-700 text-white font-semibold py-3 px-4 rounded-xl shadow-md shadow-blue-500/20 flex items-center justify-center space-x-2 transition duration-200 active:scale-[0.99]">
                    <span>Masuk Sekarang</span>
                    <i class="fa-solid fa-arrow-right text-xs"></i>
                </button>
            </form>
        </div>

        <!-- Footer Bawah -->
        <div class="mt-8 text-center space-y-2">
            <p class="text-xs text-slate-500">
                Kendala masuk akun? <a href="#" class="font-semibold text-blue-600 hover:underline">Hubungi Admin TU Madrasah</a>
            </p>
            <div class="flex items-center justify-center space-x-2 text-[11px] text-slate-400">
                <span class="flex items-center text-emerald-600 font-medium">
                    <i class="fa-regular fa-circle-check mr-1"></i> Kemenag RI
                </span>
                <span>•</span>
                <span>Matsanam Web v2.4</span>
            </div>
        </div>

    </div>

</body>
</html>
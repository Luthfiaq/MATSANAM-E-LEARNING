<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <script>
        (function () {
            try {
                const theme = localStorage.getItem('theme') || 'light';
                document.documentElement.dataset.theme = theme;
                document.documentElement.classList.toggle('dark', theme === 'dark');
            } catch (error) { document.documentElement.dataset.theme = 'light'; }
        })();
        window.tailwind = window.tailwind || {};
        window.tailwind.config = { darkMode: 'class' };
    </script>
    <title>Login - MATSANAM E-Learning</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="{{ asset('css/matsanam-admin-ui-final.css') }}">
    <style>
        body { font-family: system-ui, -apple-system, sans-serif; }
    </style>
</head>
<body class="admin-auth-page bg-gradient-to-br from-blue-50 to-blue-100">
    <div class="flex min-h-screen items-center justify-center p-4">
        <div class="w-full max-w-md">
            <!-- Logo & Title -->
            <div class="mb-8 text-center">
                <div class="mx-auto mb-4 flex h-20 w-20 items-center justify-center rounded-2xl bg-blue-600 shadow-lg">
                    <span class="text-3xl font-bold text-white">M</span>
                </div>
                <h1 class="mb-2 text-3xl font-bold text-gray-900">MATSANAM</h1>
                <p class="text-sm text-gray-600">Portal Administrasi Akademik</p>
                <p class="text-xs text-gray-500">MTs Negeri 6 Nganjuk</p>
            </div>

            <!-- Login Form -->
            <div class="rounded-2xl bg-white p-8 shadow-xl">
                <div class="mb-6">
                    <h2 class="text-xl font-bold text-gray-900">Masuk ke Sistem</h2>
                    <p class="text-sm text-gray-500">Silakan masuk dengan akun administrator</p>
                </div>

                @if ($errors->any())
                <div class="mb-4 rounded-lg bg-red-50 border border-red-200 p-3">
                    <p class="text-sm text-red-700">⚠️ {{ $errors->first() }}</p>
                </div>
                @endif

                <form method="POST" action="{{ route('login') }}" class="space-y-4">
                    @csrf
                    
                    <div>
                        <label for="email" class="mb-1 block text-sm font-medium text-gray-700">
                            Email
                        </label>
                        <input
                            type="email"
                            id="email"
                            name="email"
                            value="{{ old('email') }}"
                            required
                            autofocus
                            placeholder="admin@matsanam.sch.id"
                            class="w-full rounded-lg border border-gray-300 px-4 py-2.5 text-sm focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20"
                        />
                    </div>

                    <div>
                        <label for="password" class="mb-1 block text-sm font-medium text-gray-700">
                            Password
                        </label>
                        <input
                            type="password"
                            id="password"
                            name="password"
                            required
                            placeholder="••••••••"
                            class="w-full rounded-lg border border-gray-300 px-4 py-2.5 text-sm focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20"
                        />
                    </div>

                    <div class="flex items-center justify-between text-sm">
                        <label class="flex items-center gap-2">
                            <input type="checkbox" name="remember" class="rounded border-gray-300 text-blue-600 focus:ring-blue-500" />
                            <span class="text-gray-600">Ingat saya</span>
                        </label>
                    </div>

                    <button
                        type="submit"
                        class="w-full rounded-lg bg-blue-600 px-4 py-3 text-sm font-semibold text-white hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition"
                    >
                        Masuk
                    </button>
                </form>
            </div>

            <!-- Info Section -->
            <div class="admin-login-help mt-6 rounded-xl bg-blue-50 border border-blue-100 p-4">
                <div class="text-sm text-gray-700">
                    <p class="mb-2 font-semibold flex items-center gap-2">
                        <span aria-hidden="true">ℹ️</span>
                        <span>Informasi Login Admin</span>
                    </p>
                    <p class="text-xs leading-relaxed">Gunakan akun administrator aktif yang diberikan oleh Tata Usaha. Jaga kerahasiaan email dan kata sandi Anda.</p>
                </div>
            </div>

            <!-- Footer -->
            <p class="mt-6 text-center text-xs text-gray-500">
                © 2026 MTs Negeri 6 Nganjuk. All rights reserved.
            </p>
        </div>
    </div>
</body>
</html>

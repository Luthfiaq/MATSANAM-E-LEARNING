<header class="bg-white border-b border-gray-200 py-3 px-6 flex items-center justify-between">
    <!-- Left: Period & Search -->
    <div class="flex flex-1 items-center gap-4 mr-8">
        <button class="flex items-center bg-blue-50 text-left py-1 px-2 gap-1 rounded-lg border border-[#004AC633]">
            <span class="text-blue-600">📅</span>
            <span class="text-[#004AC6] text-xs">T.A. 2026/2027 Ganjil</span>
        </button>
        
        <div class="flex flex-1 items-center bg-slate-50 py-1.5 px-3 gap-2 rounded-lg border border-slate-200">
            <span class="text-gray-400">🔍</span>
            <input type="text" 
                   placeholder="Cari NIP, nama guru, kelas, atau siswa..."
                   class="flex-1 text-xs bg-transparent border-none focus:outline-none text-slate-400" />
        </div>
    </div>

    <!-- Right: Notifications & User -->
    <div class="flex items-center gap-8">
        <!-- Notification -->
        <div class="relative">
            <button class="text-2xl hover:opacity-80 transition">🔔</button>
        </div>

        <!-- User Menu -->
        <div class="flex items-center gap-2 relative">
            <div>
                <div class="text-slate-900 text-base font-bold text-right">
                    {{ Auth::user()->name }}
                </div>
                <div class="text-[#004AC6] text-[11px] font-bold text-right">
                    {{ ucfirst(Auth::user()->role) }} / Tata Usaha
                </div>
            </div>
            <div class="relative">
                <button class="w-8 h-8 rounded-xl bg-blue-600 text-white flex items-center justify-center font-bold text-sm hover:bg-blue-700 transition"
                     onclick="toggleUserMenu()">
                    {{ substr(Auth::user()->name, 0, 1) }}
                </button>
                
                <!-- Dropdown Menu -->
                <div id="userMenu" class="hidden absolute right-0 mt-2 w-48 bg-white rounded-lg shadow-lg border border-gray-200 py-2 z-50">
                    <a href="#" class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-50">👤 Profil</a>
                    <a href="#" class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-50">⚙️ Pengaturan</a>
                    <hr class="my-1" />
                    <form action="{{ route('logout') }}" method="POST">
                        @csrf
                        <button type="submit" class="w-full text-left block px-4 py-2 text-sm text-red-600 hover:bg-red-50">
                            🚪 Keluar
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</header>

@push('scripts')
<script>
function toggleUserMenu() {
    const menu = document.getElementById('userMenu');
    menu.classList.toggle('hidden');
}

// Close menu when clicking outside
document.addEventListener('click', function(event) {
    const menu = document.getElementById('userMenu');
    const isClickInside = event.target.closest('[onclick="toggleUserMenu()"]') || event.target.closest('#userMenu');
    
    if (!isClickInside && !menu.classList.contains('hidden')) {
        menu.classList.add('hidden');
    }
});
</script>
@endpush

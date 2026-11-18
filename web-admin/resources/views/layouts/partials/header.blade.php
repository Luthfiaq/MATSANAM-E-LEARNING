<header id="adminTopbar" class="bg-white dark:bg-slate-800 border-b border-slate-200 dark:border-slate-700 py-3 px-4 md:px-6 flex items-center justify-between gap-4 shrink-0">
    <div class="flex items-center gap-3 min-w-0">
        <div class="hidden lg:flex items-center bg-blue-50 dark:bg-slate-700 py-1.5 px-3 gap-2 rounded-lg border border-blue-100 dark:border-slate-600 text-xs text-blue-700 dark:text-blue-300 whitespace-nowrap">
            <span>▣</span>
            @php($activePeriod = \App\Models\PeriodeAkademik::where('is_active', true)->first())
            <span>{{ $activePeriod?->nama ?? 'Periode akademik belum diatur' }}</span>
        </div>
        <div class="hidden md:flex items-center bg-slate-50 dark:bg-slate-700 py-2 px-3 gap-2 rounded-lg border border-slate-200 dark:border-slate-600 min-w-[260px]">
            <span class="text-slate-400">⌕</span>
            <span class="text-xs text-slate-400">MATSANAM Admin Portal</span>
        </div>
    </div>

    <div class="flex items-center gap-3 md:gap-6">
        @php($adminUnreadNotifications = \Illuminate\Support\Facades\Schema::hasTable('notifications') ? Auth::user()->unreadNotifications()->count() : 0)
        <a href="{{ route('admin.notifications.index') }}" class="relative inline-flex h-9 w-9 items-center justify-center rounded-xl text-slate-500 hover:bg-blue-50 hover:text-blue-700 dark:text-slate-300 dark:hover:bg-slate-700" title="Notifikasi Admin" aria-label="Notifikasi Admin">
            <span class="text-lg">🔔</span>
            @if($adminUnreadNotifications > 0)
                <span class="absolute -right-1 -top-1 min-w-[17px] rounded-full border-2 border-white bg-red-600 px-1 py-0.5 text-center text-[9px] font-extrabold leading-none text-white dark:border-slate-800">{{ $adminUnreadNotifications > 9 ? '9+' : $adminUnreadNotifications }}</span>
            @endif
        </a>
        <a href="{{ route('admin.pengaturan') }}" class="text-slate-500 dark:text-slate-300 hover:text-blue-600 text-sm" title="Pengaturan">⚙</a>
        <div class="flex items-center gap-2 relative">
            <div class="hidden sm:block text-right leading-tight">
                <div class="text-slate-900 dark:text-white text-sm font-bold">{{ Auth::user()->name }}</div>
                <div class="text-blue-600 dark:text-blue-400 text-[10px] font-semibold">{{ ucfirst(Auth::user()->role) }} / Tata Usaha</div>
            </div>
            <button type="button" class="w-9 h-9 rounded-xl bg-blue-600 text-white flex items-center justify-center font-bold text-sm hover:bg-blue-700 transition" onclick="toggleUserMenu()">
                {{ strtoupper(substr(Auth::user()->name, 0, 1)) }}
            </button>
            <div id="userMenu" class="hidden absolute right-0 top-full mt-2 w-48 bg-white dark:bg-slate-800 rounded-lg shadow-lg border border-slate-200 dark:border-slate-600 py-2 z-50">
                <a href="{{ route('admin.pengaturan') }}" class="block px-4 py-2 text-sm text-slate-700 dark:text-slate-200 hover:bg-slate-50 dark:hover:bg-slate-700">⚙ Pengaturan</a>
                <hr class="my-1 border-slate-200 dark:border-slate-600">
                <form action="{{ route('logout') }}" method="POST">
                    @csrf
                    <button type="submit" class="w-full text-left block px-4 py-2 text-sm text-red-600 hover:bg-red-50 dark:hover:bg-red-900/30">↪ Keluar</button>
                </form>
            </div>
        </div>
    </div>
</header>

@push('scripts')
<script>
function toggleUserMenu() {
    const menu = document.getElementById('userMenu');
    if (menu) menu.classList.toggle('hidden');
}
document.addEventListener('click', function (event) {
    const menu = document.getElementById('userMenu');
    if (!menu) return;
    const button = event.target.closest('[onclick="toggleUserMenu()"]');
    if (!button && !event.target.closest('#userMenu')) menu.classList.add('hidden');
});
</script>
@endpush

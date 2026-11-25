<header id="adminTopbar" class="bg-white dark:bg-slate-800 border-b border-slate-200 dark:border-slate-700 py-3 px-4 md:px-6 flex items-center justify-between gap-3 md:gap-4 shrink-0">
    <div class="flex items-center gap-3 min-w-0 flex-1">
        <div class="hidden lg:flex items-center bg-blue-50 dark:bg-slate-700 py-1.5 px-3 gap-2 rounded-lg border border-blue-100 dark:border-slate-600 text-xs text-blue-700 dark:text-blue-300 whitespace-nowrap shrink-0">
            <span>▣</span>
            @php($activePeriod = \App\Models\PeriodeAkademik::where('is_active', true)->first())
            <span>{{ $activePeriod?->nama ?? 'Periode akademik belum diatur' }}</span>
        </div>

        <div id="adminGlobalSearch" class="relative min-w-0 flex-1 max-w-2xl">
            <label for="adminGlobalSearchInput" class="sr-only">Pencarian global portal admin</label>
            <div class="flex items-center gap-2 rounded-lg border border-slate-200 bg-slate-50 px-3 py-2 dark:border-slate-600 dark:bg-slate-700 focus-within:border-blue-500 focus-within:ring-2 focus-within:ring-blue-500/20 transition">
                <span class="text-lg leading-none text-slate-400" aria-hidden="true">⌕</span>
                <input
                    id="adminGlobalSearchInput"
                    type="search"
                    autocomplete="off"
                    spellcheck="false"
                    placeholder="Cari siswa, guru, kelas, mapel, penugasan, atau menu..."
                    class="min-w-0 w-full border-0 bg-transparent p-0 text-xs text-slate-800 placeholder:text-slate-400 focus:outline-none focus:ring-0 dark:text-slate-100 dark:placeholder:text-slate-400"
                    aria-label="Cari siswa, guru, kelas, mata pelajaran, penugasan, atau menu"
                    aria-controls="adminGlobalSearchResults"
                    aria-expanded="false"
                    role="combobox"
                    aria-autocomplete="list"
                    data-search-url="{{ route('admin.global-search') }}"
                >
                <kbd class="hidden sm:inline-flex shrink-0 items-center rounded border border-slate-200 bg-white px-1.5 py-0.5 text-[10px] font-semibold text-slate-400 dark:border-slate-500 dark:bg-slate-800 dark:text-slate-300">Ctrl K</kbd>
            </div>

            <div id="adminGlobalSearchResults" class="hidden absolute left-0 top-full z-[80] mt-2 max-h-[70vh] w-[min(620px,calc(100vw-2rem))] overflow-y-auto rounded-xl border border-slate-200 bg-white p-2 shadow-2xl dark:border-slate-600 dark:bg-slate-800" role="listbox" aria-label="Hasil pencarian global">
                <p class="px-3 py-3 text-xs text-slate-500 dark:text-slate-400">Ketik minimal 2 karakter untuk mencari data atau membuka menu.</p>
            </div>
        </div>
    </div>

    <div class="flex items-center gap-2 md:gap-6 shrink-0">
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
            <button type="button" class="w-9 h-9 rounded-xl bg-blue-600 text-white flex items-center justify-center font-bold text-sm hover:bg-blue-700 transition" onclick="toggleUserMenu()" aria-label="Buka menu pengguna">
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

(function () {
    const wrapper = document.getElementById('adminGlobalSearch');
    const input = document.getElementById('adminGlobalSearchInput');
    const panel = document.getElementById('adminGlobalSearchResults');
    if (!wrapper || !input || !panel) return;

    let debounceTimer = null;
    let requestNumber = 0;
    let activeIndex = -1;

    function openPanel() {
        panel.classList.remove('hidden');
        input.setAttribute('aria-expanded', 'true');
    }

    function closePanel() {
        panel.classList.add('hidden');
        input.setAttribute('aria-expanded', 'false');
        activeIndex = -1;
    }

    function showMessage(message) {
        panel.replaceChildren();
        const paragraph = document.createElement('p');
        paragraph.className = 'px-3 py-3 text-xs text-slate-500 dark:text-slate-400';
        paragraph.textContent = message;
        panel.appendChild(paragraph);
        openPanel();
    }

    function updateActiveResult(links) {
        links.forEach((link, index) => {
            const isActive = index === activeIndex;
            link.classList.toggle('bg-blue-50', isActive);
            link.classList.toggle('dark:bg-slate-700', isActive);
            link.setAttribute('aria-selected', isActive ? 'true' : 'false');
            if (isActive) link.scrollIntoView({ block: 'nearest' });
        });
    }

    function renderResults(payload) {
        panel.replaceChildren();
        activeIndex = -1;

        if (!payload.groups || payload.groups.length === 0) {
            showMessage('Tidak ada hasil yang cocok. Coba kata kunci lain.');
            return;
        }

        payload.groups.forEach((group) => {
            const heading = document.createElement('div');
            heading.className = 'px-3 pb-1 pt-2 text-[10px] font-bold uppercase tracking-wider text-slate-400 dark:text-slate-500';
            heading.textContent = group.label || 'Hasil';
            panel.appendChild(heading);

            (group.items || []).forEach((item) => {
                const link = document.createElement('a');
                link.href = item.url;
                link.dataset.searchResult = 'true';
                link.setAttribute('role', 'option');
                link.setAttribute('aria-selected', 'false');
                link.className = 'flex items-start gap-3 rounded-lg px-3 py-2.5 text-left transition hover:bg-slate-50 focus:bg-blue-50 focus:outline-none dark:hover:bg-slate-700 dark:focus:bg-slate-700';

                const icon = document.createElement('span');
                icon.className = 'mt-0.5 flex h-8 w-8 shrink-0 items-center justify-center rounded-lg bg-slate-100 text-sm text-slate-600 dark:bg-slate-700 dark:text-slate-200';
                icon.textContent = item.icon || '⌕';

                const textContainer = document.createElement('span');
                textContainer.className = 'min-w-0 flex-1';

                const title = document.createElement('span');
                title.className = 'block truncate text-xs font-semibold text-slate-800 dark:text-slate-100';
                title.textContent = item.title || '';

                const subtitle = document.createElement('span');
                subtitle.className = 'mt-0.5 block truncate text-[11px] text-slate-500 dark:text-slate-400';
                subtitle.textContent = item.subtitle || '';

                textContainer.append(title, subtitle);
                link.append(icon, textContainer);
                panel.appendChild(link);
            });
        });

        const footer = document.createElement('div');
        footer.className = 'mt-1 border-t border-slate-100 px-3 pt-2 text-[10px] text-slate-400 dark:border-slate-700 dark:text-slate-500';
        footer.textContent = `${payload.total || 0} hasil · Gunakan tombol panah untuk memilih dan Enter untuk membuka.`;
        panel.appendChild(footer);
        openPanel();
    }

    async function performSearch(query) {
        const currentRequest = ++requestNumber;
        try {
            const url = new URL(input.dataset.searchUrl, window.location.origin);
            url.searchParams.set('q', query);
            const response = await fetch(url.toString(), {
                method: 'GET',
                credentials: 'same-origin',
                headers: { 'Accept': 'application/json', 'X-Requested-With': 'XMLHttpRequest' },
            });
            if (!response.ok) throw new Error(`HTTP ${response.status}`);
            const payload = await response.json();
            if (currentRequest !== requestNumber || input.value.trim() !== query) return;
            renderResults(payload);
        } catch (error) {
            if (currentRequest !== requestNumber) return;
            showMessage('Pencarian tidak dapat dimuat. Periksa koneksi atau sesi login Admin.');
        }
    }

    input.addEventListener('input', function () {
        const query = input.value.trim();
        window.clearTimeout(debounceTimer);
        if (query.length < 2) {
            requestNumber++;
            showMessage('Ketik minimal 2 karakter untuk mencari data atau membuka menu.');
            return;
        }
        showMessage('Mencari data...');
        debounceTimer = window.setTimeout(() => performSearch(query), 220);
    });

    input.addEventListener('focus', function () {
        if (input.value.trim().length >= 2) openPanel();
    });

    input.addEventListener('keydown', function (event) {
        if (event.key === 'Escape') {
            closePanel();
            input.blur();
            return;
        }

        if (panel.classList.contains('hidden')) return;
        const links = Array.from(panel.querySelectorAll('a[data-search-result]'));
        if (links.length === 0) return;

        if (event.key === 'ArrowDown') {
            event.preventDefault();
            activeIndex = (activeIndex + 1) % links.length;
            updateActiveResult(links);
        } else if (event.key === 'ArrowUp') {
            event.preventDefault();
            activeIndex = activeIndex <= 0 ? links.length - 1 : activeIndex - 1;
            updateActiveResult(links);
        } else if (event.key === 'Enter') {
            if (activeIndex >= 0 && links[activeIndex]) {
                event.preventDefault();
                window.location.href = links[activeIndex].href;
            } else if (links[0]) {
                event.preventDefault();
                window.location.href = links[0].href;
            }
        }
    });

    document.addEventListener('keydown', function (event) {
        if ((event.ctrlKey || event.metaKey) && event.key.toLowerCase() === 'k') {
            event.preventDefault();
            input.focus();
            input.select();
            if (input.value.trim().length < 2) showMessage('Ketik minimal 2 karakter untuk mencari data atau membuka menu.');
        }
    });

    document.addEventListener('click', function (event) {
        if (!wrapper.contains(event.target)) closePanel();
    });
})();
</script>
@endpush

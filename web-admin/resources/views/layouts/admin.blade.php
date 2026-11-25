<!DOCTYPE html>
<html lang="id" class="h-full">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>@yield('title', 'Dashboard') - MATSANAM E-Learning</title>
    <script>
        // Set Tailwind class mode before the CDN initializes and restore preferences on every page.
        window.tailwind = window.tailwind || {};
        window.tailwind.config = { darkMode: 'class' };
        (function () {
            try {
                const savedTheme = localStorage.getItem('theme') || 'light';
                const savedTextSize = localStorage.getItem('textSize') || 'medium';
                document.documentElement.classList.toggle('dark', savedTheme === 'dark');
                document.documentElement.dataset.theme = savedTheme;
                document.documentElement.dataset.textSize = savedTextSize;
            } catch (error) {
                document.documentElement.classList.remove('dark');
                document.documentElement.dataset.textSize = 'medium';
            }
        })();
    </script>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        html, body { min-height: 100%; font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; }
        html { font-size: 16px; }
        html[data-text-size="small"] { font-size: 14px; }
        html[data-text-size="medium"] { font-size: 16px; }
        html[data-text-size="large"] { font-size: 18px; }
        body { transition: background-color .2s ease, color .2s ease; }
        .theme-bg { background: #f8fafc; }
        .theme-card { background: #fff; border-color: #e2e8f0; }
        .theme-text { color: #1e293b; }
        .dark body { background:#0f172a!important; color:#e2e8f0; }
        .dark main.theme-bg, .dark .theme-bg { background:#0f172a!important; color:#e2e8f0; }
        .dark .bg-white, .dark .theme-card { background:#1e293b!important; color:#e2e8f0!important; border-color:#334155!important; }
        .dark .bg-slate-50, .dark .bg-gray-50 { background:#0f172a!important; }
        .dark .bg-slate-100, .dark .bg-gray-100 { background:#1e293b!important; }
        .dark .theme-text, .dark .text-slate-900, .dark .text-slate-800, .dark .text-gray-900, .dark .text-gray-800 { color:#f1f5f9!important; }
        .dark .text-slate-700, .dark .text-gray-700 { color:#e2e8f0!important; }
        .dark .text-slate-600, .dark .text-gray-600 { color:#cbd5e1!important; }
        .dark .text-slate-500, .dark .text-gray-500 { color:#94a3b8!important; }
        .dark input:not([type=checkbox]):not([type=radio]), .dark select, .dark textarea { background:#0f172a; color:#e2e8f0; border-color:#475569; }
        .dark table thead { background:#0f172a!important; }
        .dark table tbody tr { border-color:#334155!important; }
        .dark .border-gray-100, .dark .border-slate-100, .dark .border-slate-200 { border-color:#334155!important; }
        .dark .shadow-sm, .dark .shadow-md { box-shadow: 0 1px 3px rgba(0,0,0,.24), 0 1px 2px rgba(0,0,0,.18); }

        /* Sidebar theme is driven by the persisted application preference, not browser defaults. */
        html[data-theme="light"] #adminSidebar {
            background-color: #ffffff !important;
            color: #334155 !important;
            border-right-color: #e2e8f0 !important;
        }
        html[data-theme="light"] #adminSidebar .border-b,
        html[data-theme="light"] #adminSidebar .border-t {
            border-color: #e2e8f0 !important;
        }
        html[data-theme="light"] #adminSidebar .text-slate-900,
        html[data-theme="light"] #adminSidebar .text-slate-700 { color: #0f172a !important; }
        html[data-theme="light"] #adminSidebar .text-slate-500 { color: #64748b !important; }
        html[data-theme="light"] #adminSidebar .nav-link:not(.nav-active) { color: #334155 !important; }
        html[data-theme="light"] #adminSidebar .nav-link:not(.nav-active):hover {
            background-color: #eff6ff !important;
            color: #1d4ed8 !important;
        }
        html[data-theme="light"] #adminSidebar .nav-link.nav-active,
        html[data-theme="light"] #adminSidebar .nav-link.nav-active:hover {
            background-color: #2563eb !important;
            color: #ffffff !important;
        }
        html[data-theme="light"] #adminSidebar .bg-slate-50 {
            background-color: #f8fafc !important;
        }

        html[data-theme="dark"] #adminSidebar {
            background-color: #1e293b !important;
            color: #e2e8f0 !important;
            border-right-color: #334155 !important;
        }
        html[data-theme="dark"] #adminSidebar .border-b,
        html[data-theme="dark"] #adminSidebar .border-t { border-color: #334155 !important; }
        html[data-theme="dark"] #adminSidebar .text-slate-900,
        html[data-theme="dark"] #adminSidebar .text-slate-700 { color: #f1f5f9 !important; }
        html[data-theme="dark"] #adminSidebar .text-slate-500 { color: #94a3b8 !important; }
        html[data-theme="dark"] #adminSidebar .nav-link:not(.nav-active) { color: #cbd5e1 !important; }
        html[data-theme="dark"] #adminSidebar .nav-link:not(.nav-active):hover {
            background-color: #334155 !important;
            color: #bfdbfe !important;
        }
        html[data-theme="dark"] #adminSidebar .nav-link.nav-active,
        html[data-theme="dark"] #adminSidebar .nav-link.nav-active:hover {
            background-color: #2563eb !important;
            color: #ffffff !important;
        }
        html[data-theme="dark"] #adminSidebar .bg-slate-50 { background-color: #334155 !important; }

        /* Header/topbar follows the same persisted theme as the page and sidebar. */
        html[data-theme="light"] #adminTopbar {
            background-color: #ffffff !important;
            color: #1e293b !important;
            border-bottom-color: #e2e8f0 !important;
        }
        html[data-theme="light"] #adminTopbar .text-slate-900 { color: #0f172a !important; }
        html[data-theme="light"] #adminTopbar .text-slate-500,
        html[data-theme="light"] #adminTopbar .text-slate-400 { color: #64748b !important; }
        html[data-theme="light"] #adminTopbar .bg-blue-50 {
            background-color: #eff6ff !important;
            border-color: #dbeafe !important;
            color: #1d4ed8 !important;
        }
        html[data-theme="light"] #adminTopbar .bg-slate-50 {
            background-color: #f8fafc !important;
            border-color: #e2e8f0 !important;
        }

        html[data-theme="dark"] #adminTopbar {
            background-color: #1e293b !important;
            color: #e2e8f0 !important;
            border-bottom-color: #334155 !important;
        }
        html[data-theme="dark"] #adminTopbar .text-slate-900,
        html[data-theme="dark"] #adminTopbar .text-slate-700 { color: #f1f5f9 !important; }
        html[data-theme="dark"] #adminTopbar .text-slate-500,
        html[data-theme="dark"] #adminTopbar .text-slate-400 { color: #cbd5e1 !important; }
        html[data-theme="dark"] #adminTopbar .bg-blue-50,
        html[data-theme="dark"] #adminTopbar .bg-slate-50 {
            background-color: #334155 !important;
            border-color: #475569 !important;
            color: #bfdbfe !important;
        }


        /* Shared theme tokens and contrast corrections for all Admin pages. */
        html[data-theme="light"] { color-scheme: light; }
        html[data-theme="dark"] { color-scheme: dark; }

        html[data-theme="light"] body {
            background-color: #f8fafc;
            color: #1e293b;
        }
        html[data-theme="dark"] body {
            background-color: #0f172a;
            color: #e2e8f0;
        }
        html[data-theme="dark"] main {
            color: #e2e8f0;
        }
        html[data-theme="dark"] .text-slate-200,
        html[data-theme="dark"] .text-gray-200 { color: #e2e8f0 !important; }
        html[data-theme="dark"] .text-slate-300,
        html[data-theme="dark"] .text-gray-300 { color: #cbd5e1 !important; }
        html[data-theme="dark"] .text-slate-400,
        html[data-theme="dark"] .text-gray-400 { color: #94a3b8 !important; }
        html[data-theme="dark"] .text-slate-500,
        html[data-theme="dark"] .text-gray-500 { color: #94a3b8 !important; }
        html[data-theme="dark"] .text-slate-600,
        html[data-theme="dark"] .text-gray-600 { color: #cbd5e1 !important; }
        html[data-theme="dark"] .text-slate-700,
        html[data-theme="dark"] .text-gray-700 { color: #e2e8f0 !important; }
        html[data-theme="dark"] .text-slate-800,
        html[data-theme="dark"] .text-gray-800,
        html[data-theme="dark"] .text-slate-900,
        html[data-theme="dark"] .text-gray-900 { color: #f1f5f9 !important; }
        html[data-theme="dark"] input::placeholder,
        html[data-theme="dark"] textarea::placeholder { color: #94a3b8 !important; opacity: 1; }
        html[data-theme="dark"] select option {
            background-color: #0f172a;
            color: #e2e8f0;
        }
        html[data-theme="dark"] .divide-slate-100 > :not([hidden]) ~ :not([hidden]),
        html[data-theme="dark"] .divide-gray-100 > :not([hidden]) ~ :not([hidden]) {
            border-color: #334155 !important;
        }
        html[data-theme="dark"] .border-gray-100,
        html[data-theme="dark"] .border-gray-200,
        html[data-theme="dark"] .border-gray-300,
        html[data-theme="dark"] .border-slate-100,
        html[data-theme="dark"] .border-slate-200 {
            border-color: #334155 !important;
        }
        html[data-theme="dark"] .hover\:bg-gray-50:hover,
        html[data-theme="dark"] .hover\:bg-slate-50:hover,
        html[data-theme="dark"] .hover\:bg-gray-100:hover,
        html[data-theme="dark"] .hover\:bg-slate-100:hover,
        html[data-theme="dark"] table tbody tr:hover {
            background-color: #334155 !important;
            color: #f1f5f9;
        }
        html[data-theme="dark"] input::placeholder,
        html[data-theme="dark"] textarea::placeholder,
        html[data-theme="dark"] input::-webkit-input-placeholder,
        html[data-theme="dark"] textarea::-webkit-input-placeholder {
            color: #94a3b8 !important;
            opacity: 1;
        }

        /* Global Search input surface and text are explicit so they do not
           inherit a stale Tailwind dark variant during theme restoration. */
        html[data-theme="light"] #adminTopbar #adminGlobalSearch > div {
            background-color: #f8fafc !important;
            border-color: #cbd5e1 !important;
        }
        html[data-theme="light"] #adminGlobalSearchInput {
            color: #1e293b !important;
            background-color: transparent !important;
        }
        html[data-theme="light"] #adminGlobalSearchInput::placeholder {
            color: #64748b !important;
            opacity: 1;
        }
        html[data-theme="light"] #adminGlobalSearch kbd {
            background-color: #ffffff !important;
            color: #64748b !important;
            border-color: #cbd5e1 !important;
        }
        html[data-theme="dark"] #adminTopbar #adminGlobalSearch > div {
            background-color: #334155 !important;
            border-color: #475569 !important;
        }
        html[data-theme="dark"] #adminGlobalSearchInput {
            color: #f1f5f9 !important;
            background-color: transparent !important;
        }
        html[data-theme="dark"] #adminGlobalSearchInput::placeholder {
            color: #94a3b8 !important;
            opacity: 1;
        }

        /* Global Search results must follow the selected theme even when other
           page widgets use a locally styled surface. */
        html[data-theme="light"] #adminGlobalSearchResults {
            background: #ffffff !important;
            color: #1e293b !important;
            border-color: #cbd5e1 !important;
        }
        html[data-theme="light"] #adminGlobalSearchResults [data-search-result] {
            color: #1e293b !important;
        }
        html[data-theme="light"] #adminGlobalSearchResults [data-search-result]:hover,
        html[data-theme="light"] #adminGlobalSearchResults [data-search-result]:focus,
        html[data-theme="light"] #adminGlobalSearchResults [data-search-result].bg-blue-50 {
            background: #eff6ff !important;
        }
        html[data-theme="light"] #adminGlobalSearchResults .text-slate-800,
        html[data-theme="light"] #adminGlobalSearchResults .text-slate-700 { color: #1e293b !important; }
        html[data-theme="light"] #adminGlobalSearchResults .text-slate-600 { color: #475569 !important; }
        html[data-theme="light"] #adminGlobalSearchResults .text-slate-500 { color: #64748b !important; }
        html[data-theme="light"] #adminGlobalSearchResults .text-slate-400 { color: #64748b !important; }
        html[data-theme="light"] #adminGlobalSearchResults .bg-slate-100 { background: #f1f5f9 !important; }
        html[data-theme="light"] #adminGlobalSearchResults .border-slate-100 { border-color: #e2e8f0 !important; }
        html[data-theme="light"] #adminGlobalSearchResults .text-slate-100,
        html[data-theme="light"] #adminGlobalSearchResults .text-slate-200,
        html[data-theme="light"] #adminGlobalSearchResults [class~="dark:text-slate-100"],
        html[data-theme="light"] #adminGlobalSearchResults [class~="dark:text-slate-200"] {
            color: #334155 !important;
        }
        html[data-theme="light"] #adminGlobalSearchResults .bg-slate-700,
        html[data-theme="light"] #adminGlobalSearchResults .bg-slate-800,
        html[data-theme="light"] #adminGlobalSearchResults [class~="dark:bg-slate-700"] {
            background-color: #f1f5f9 !important;
        }
        html[data-theme="light"] #adminGlobalSearchResults .border-slate-700,
        html[data-theme="light"] #adminGlobalSearchResults [class~="dark:border-slate-700"] {
            border-color: #e2e8f0 !important;
        }
        html[data-theme="light"] #adminGlobalSearchResults {
            box-shadow: 0 18px 36px rgba(15, 23, 42, .16) !important;
        }

        html[data-theme="dark"] #adminGlobalSearchResults {
            background: #1e293b !important;
            color: #e2e8f0 !important;
            border-color: #475569 !important;
        }
        html[data-theme="dark"] #adminGlobalSearchResults [data-search-result] {
            color: #f1f5f9 !important;
        }
        html[data-theme="dark"] #adminGlobalSearchResults [data-search-result]:hover,
        html[data-theme="dark"] #adminGlobalSearchResults [data-search-result]:focus,
        html[data-theme="dark"] #adminGlobalSearchResults [data-search-result].bg-blue-50 {
            background: #334155 !important;
        }
        html[data-theme="dark"] #adminGlobalSearchResults .text-slate-800,
        html[data-theme="dark"] #adminGlobalSearchResults .text-slate-700,
        html[data-theme="dark"] #adminGlobalSearchResults .text-slate-600 { color: #f1f5f9 !important; }
        html[data-theme="dark"] #adminGlobalSearchResults .text-slate-500,
        html[data-theme="dark"] #adminGlobalSearchResults .text-slate-400 { color: #cbd5e1 !important; }
        html[data-theme="dark"] #adminGlobalSearchResults .bg-slate-100 { background: #334155 !important; }
        html[data-theme="dark"] #adminGlobalSearchResults .border-slate-100 { border-color: #475569 !important; }

        /* Ensure form controls and native date/select widgets use the same palette. */
        html[data-theme="light"] input:not([type=checkbox]):not([type=radio]),
        html[data-theme="light"] select,
        html[data-theme="light"] textarea {
            color-scheme: light;
        }
        html[data-theme="dark"] input:not([type=checkbox]):not([type=radio]),
        html[data-theme="dark"] select,
        html[data-theme="dark"] textarea {
            color-scheme: dark;
        }
    </style>
    @stack('styles')
</head>
<body class="h-full bg-slate-50 dark:bg-slate-900">
    <div class="flex h-screen overflow-hidden">
        @include('layouts.partials.sidebar')
        <div class="flex-1 flex min-w-0 flex-col overflow-hidden">
            @include('layouts.partials.header')
            <main class="flex-1 overflow-y-auto p-4 md:p-6 theme-bg">
                @yield('content')
            </main>
        </div>
    </div>
    <script>
        // Keep the sidebar's own scroll position while navigating between server-rendered pages.
        (function () {
            const storageKey = 'matsanam.admin.sidebar.scrollTop';
            function restoreSidebarPosition() {
                const sidebar = document.getElementById('adminSidebar');
                if (!sidebar) return;
                try {
                    const saved = sessionStorage.getItem(storageKey);
                    if (saved !== null) {
                        const position = Number(saved) || 0;
                        sidebar.scrollTop = position;
                        requestAnimationFrame(() => { sidebar.scrollTop = position; });
                        setTimeout(() => { sidebar.scrollTop = position; }, 80);
                    }
                } catch (error) { /* Storage can be disabled in private browser contexts. */ }
            }
            function saveSidebarPosition() {
                const sidebar = document.getElementById('adminSidebar');
                if (!sidebar) return;
                try { sessionStorage.setItem(storageKey, String(sidebar.scrollTop)); } catch (error) {}
            }
            document.addEventListener('DOMContentLoaded', restoreSidebarPosition);
            if (document.readyState !== 'loading') restoreSidebarPosition();
            window.addEventListener('pagehide', saveSidebarPosition);
            document.addEventListener('click', function (event) {
                if (event.target.closest('#adminSidebar a')) saveSidebarPosition();
            }, true);
            const sidebar = document.getElementById('adminSidebar');
            if (sidebar) sidebar.addEventListener('scroll', saveSidebarPosition, { passive: true });
        })();
    </script>
    @stack('scripts')
</body>
</html>

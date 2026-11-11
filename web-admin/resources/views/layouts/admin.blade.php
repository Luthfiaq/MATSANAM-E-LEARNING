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
        html[data-theme="light"] #adminTopbar .text-slate-900,
        html[data-theme="light"] #adminTopbar .text-white { color: #0f172a !important; }
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

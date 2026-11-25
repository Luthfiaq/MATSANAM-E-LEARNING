<!DOCTYPE html>
<html lang="id" class="h-full">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <title>@yield('title', 'Dashboard') - MATSANAM E-Learning</title>
    <script>
        // Set Tailwind class mode before the CDN initializes and restore preferences on every page.
        window.tailwind = window.tailwind || {};
        window.tailwind.config = { darkMode: 'class' };
        (function () {
            try {
                const savedTheme = localStorage.getItem('theme') || 'light';
                const savedTextSize = localStorage.getItem('textSize') || 'medium';
                const savedSidebarCollapsed = localStorage.getItem('matsanam.admin.sidebar.collapsed') === 'true';
                document.documentElement.classList.toggle('dark', savedTheme === 'dark');
                document.documentElement.classList.toggle('admin-sidebar-collapsed', savedSidebarCollapsed);
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
        html, body { min-height: 100%; font-family: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; }
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


        /* MATSANAM Admin UI Foundation — shared visual tokens */
        :root {
            --admin-canvas: #f8fafc;
            --admin-surface: #ffffff;
            --admin-surface-soft: #f1f5f9;
            --admin-surface-raised: #ffffff;
            --admin-text: #0f172a;
            --admin-text-secondary: #475569;
            --admin-text-muted: #64748b;
            --admin-border: #e2e8f0;
            --admin-primary: #2563eb;
            --admin-primary-hover: #1d4ed8;
            --admin-focus: rgba(37, 99, 235, .18);
            --admin-shadow: 0 1px 2px rgba(15, 23, 42, .04), 0 8px 20px rgba(15, 23, 42, .035);
        }
        html[data-theme="dark"] {
            --admin-canvas: #0f172a;
            --admin-surface: #1e293b;
            --admin-surface-soft: #263449;
            --admin-surface-raised: #243247;
            --admin-text: #f1f5f9;
            --admin-text-secondary: #cbd5e1;
            --admin-text-muted: #94a3b8;
            --admin-border: #334155;
            --admin-primary: #60a5fa;
            --admin-primary-hover: #93c5fd;
            --admin-focus: rgba(96, 165, 250, .2);
            --admin-shadow: 0 1px 2px rgba(0, 0, 0, .18), 0 10px 24px rgba(0, 0, 0, .14);
        }

        html, body { font-family: Inter, ui-sans-serif, system-ui, sans-serif; }
        body { background: var(--admin-canvas); color: var(--admin-text); }
        /* Hide scrollbar chrome without disabling wheel, touch, keyboard, or programmatic scrolling. */
        html, body, *, *::before, *::after {
            scrollbar-width: none !important;
            -ms-overflow-style: none !important;
        }
        *::-webkit-scrollbar, *::-webkit-scrollbar-thumb, *::-webkit-scrollbar-track {
            display: none !important;
            width: 0 !important;
            height: 0 !important;
            background: transparent !important;
        }
        main { scrollbar-gutter: auto; }

        /* Common page surfaces: cards, panels, and content sections. */
        main .bg-white.rounded-lg,
        main .bg-white.rounded-xl,
        main .bg-white.rounded-2xl,
        main .theme-card {
            border-color: var(--admin-border);
            box-shadow: var(--admin-shadow);
        }
        html[data-theme="dark"] main .bg-white,
        html[data-theme="dark"] main .theme-card {
            background-color: var(--admin-surface) !important;
            color: var(--admin-text);
            border-color: var(--admin-border) !important;
        }
        html[data-theme="dark"] main .bg-slate-50,
        html[data-theme="dark"] main .bg-gray-50 { background-color: var(--admin-canvas) !important; }
        html[data-theme="dark"] main .bg-slate-100,
        html[data-theme="dark"] main .bg-gray-100 { background-color: var(--admin-surface-soft) !important; }
        html[data-theme="dark"] main .bg-slate-200,
        html[data-theme="dark"] main .bg-gray-200 { background-color: #334155 !important; }

        /* Forms have consistent height, radius, focus and readable disabled states. */
        main input:not([type="checkbox"]):not([type="radio"]):not([type="hidden"]),
        main select, main textarea {
            border-radius: .65rem;
            transition: border-color .15s ease, box-shadow .15s ease, background-color .15s ease;
        }
        main input:focus, main select:focus, main textarea:focus {
            outline: none;
            border-color: #60a5fa !important;
            box-shadow: 0 0 0 3px var(--admin-focus) !important;
        }
        html[data-theme="light"] main input:not([type="checkbox"]):not([type="radio"]):not([type="hidden"]),
        html[data-theme="light"] main select, html[data-theme="light"] main textarea {
            color: #1e293b;
        }
        html[data-theme="dark"] main input:not([type="checkbox"]):not([type="radio"]):not([type="hidden"]),
        html[data-theme="dark"] main select, html[data-theme="dark"] main textarea {
            color: #f1f5f9 !important;
            background-color: #0f172a !important;
            border-color: #475569 !important;
        }
        html[data-theme="dark"] main input:disabled,
        html[data-theme="dark"] main select:disabled,
        html[data-theme="dark"] main textarea:disabled {
            color: #94a3b8 !important; background-color: #1e293b !important; opacity: .8;
        }

        /* Tables share a crisp header, readable rows and subtle hover feedback. */
        main .overflow-x-auto { max-width: 100%; }
        main table { border-color: var(--admin-border); }
        main table thead th { font-weight: 700; letter-spacing: .045em; }
        main table tbody tr { transition: background-color .12s ease; }
        html[data-theme="light"] main table thead { background-color: #f8fafc; }
        html[data-theme="dark"] main table thead,
        html[data-theme="dark"] main table thead tr { background-color: #172438 !important; }
        html[data-theme="dark"] main table tbody { background-color: var(--admin-surface) !important; }
        html[data-theme="dark"] main table tbody td { color: #cbd5e1; }
        html[data-theme="dark"] main table tbody tr:hover { background-color: #263449 !important; }

        /* Focus-visible affordance is consistent for keyboard navigation. */
        a:focus-visible, button:focus-visible, [role="button"]:focus-visible {
            outline: 2px solid #60a5fa; outline-offset: 2px;
        }

        /* Sidebar can collapse to an icon rail on desktop and remains an off-canvas drawer on smaller screens. */
        #adminSidebarBackdrop { display: none; }
        #adminSidebar { flex: 0 0 16rem; width: 16rem; transition: width .22s ease, flex-basis .22s ease, transform .22s ease; }
        html.admin-sidebar-collapsed #adminSidebar { flex-basis: 4.75rem; width: 4.75rem !important; }
        html.admin-sidebar-collapsed #adminSidebar > div:first-child {
            justify-content: center; padding-left: .5rem; padding-right: .5rem;
        }
        html.admin-sidebar-collapsed #adminSidebar > div:first-child > div:last-child { display: none !important; }
        html.admin-sidebar-collapsed #adminSidebar nav { padding-left: .5rem; padding-right: .5rem; }
        html.admin-sidebar-collapsed #adminSidebar nav section > p,
        html.admin-sidebar-collapsed #adminSidebar nav section > div:first-child { display: none !important; }
        html.admin-sidebar-collapsed #adminSidebar .nav-link {
            justify-content: center; gap: 0; padding-left: .5rem; padding-right: .5rem;
            min-height: 42px; margin-left: 0; margin-right: 0;
        }
        html.admin-sidebar-collapsed #adminSidebar .nav-link > span:not(.nav-icon) { display: none !important; }
        html.admin-sidebar-collapsed #adminSidebar .nav-icon { width: auto; font-size: 18px; }
        html.admin-sidebar-collapsed #adminSidebar > div:last-child { padding: .5rem; }
        html.admin-sidebar-collapsed #adminSidebar > div:last-child > div {
            justify-content: center; padding: .65rem; background: transparent; border-color: transparent;
        }
        html.admin-sidebar-collapsed #adminSidebar > div:last-child > div > div { display: none !important; }
        #adminMobileMenuToggle { display: inline-flex !important; }
        @media (min-width: 1024px) {
            #adminSidebar { position: relative; transform: none !important; }
            #adminSidebarBackdrop { display: none !important; }
        }
        @media (max-width: 1023px) {
            html.admin-sidebar-collapsed #adminSidebar { flex-basis: auto; width: min(17rem, calc(100vw - 3rem)) !important; }
            html.admin-sidebar-collapsed #adminSidebar > div:first-child { justify-content: flex-start; padding-left: 1.25rem; padding-right: 1.25rem; }
            html.admin-sidebar-collapsed #adminSidebar > div:first-child > div:last-child { display: block !important; }
            html.admin-sidebar-collapsed #adminSidebar nav { padding-left: .75rem; padding-right: .75rem; }
            html.admin-sidebar-collapsed #adminSidebar nav section > p,
            html.admin-sidebar-collapsed #adminSidebar nav section > div:first-child { display: block !important; }
            html.admin-sidebar-collapsed #adminSidebar .nav-link { justify-content: flex-start; gap: .7rem; padding-left: .82rem; padding-right: .82rem; }
            html.admin-sidebar-collapsed #adminSidebar .nav-link > span:not(.nav-icon) { display: inline !important; }
            html.admin-sidebar-collapsed #adminSidebar .nav-icon { width: 20px; }
            html.admin-sidebar-collapsed #adminSidebar > div:last-child { padding: .75rem; }
            html.admin-sidebar-collapsed #adminSidebar > div:last-child > div { justify-content: flex-start; padding: .75rem; background: #f8fafc; border-color: #e2e8f0; }
            html.admin-sidebar-collapsed #adminSidebar > div:last-child > div > div { display: block !important; }
            #adminSidebar {
                position: fixed !important; inset: 0 auto 0 0; z-index: 70;
                width: min(17rem, calc(100vw - 3rem)); height: 100dvh !important;
                transform: translateX(-105%); transition: transform .22s ease;
                box-shadow: 18px 0 40px rgba(15, 23, 42, .16);
            }
            html.admin-sidebar-open #adminSidebar { transform: translateX(0); }
            html.admin-sidebar-open #adminSidebarBackdrop {
                display: block; position: fixed; inset: 0; z-index: 60;
                width: 100%; height: 100%; background: rgba(2, 6, 23, .52);
            }
            html.admin-sidebar-open, html.admin-sidebar-open body { overflow: hidden; }
            #adminTopbar { min-height: 64px; padding-left: .75rem; padding-right: .75rem; }
        }
        @media (min-width: 1024px) {
            #adminSidebar { position: relative; transform: none !important; }
        }

    </style>
    @stack('styles')
    <link rel="stylesheet" href="{{ asset('css/matsanam-admin-ui-final.css') }}">
</head>
<body class="h-full bg-slate-50 dark:bg-slate-900">
    <button id="adminSidebarBackdrop" type="button" class="hidden" aria-label="Tutup menu navigasi" onclick="closeAdminSidebar()"></button>
    <div id="adminShell" class="flex h-screen overflow-hidden">
        @include('layouts.partials.sidebar')
        <div class="flex-1 flex min-w-0 flex-col overflow-hidden">
            @include('layouts.partials.header')
            <main id="adminMain" class="flex-1 min-w-0 overflow-y-auto p-4 md:p-6 theme-bg">
                @yield('content')
            </main>
        </div>
    </div>
    <script>
        function isAdminSidebarMobile() {
            return window.matchMedia('(max-width: 1023px)').matches;
        }
        function syncAdminSidebarToggle() {
            const toggle = document.getElementById('adminMobileMenuToggle');
            if (!toggle) return;
            const mobile = isAdminSidebarMobile();
            const expanded = mobile
                ? document.documentElement.classList.contains('admin-sidebar-open')
                : !document.documentElement.classList.contains('admin-sidebar-collapsed');
            toggle.setAttribute('aria-expanded', expanded ? 'true' : 'false');
            const label = mobile
                ? (expanded ? 'Tutup menu navigasi' : 'Buka menu navigasi')
                : (expanded ? 'Ciutkan sidebar' : 'Perluas sidebar');
            toggle.setAttribute('aria-label', label);
            toggle.setAttribute('title', label);
        }
        function toggleAdminSidebar() {
            if (isAdminSidebarMobile()) {
                document.documentElement.classList.toggle('admin-sidebar-open');
            } else {
                const collapsed = document.documentElement.classList.toggle('admin-sidebar-collapsed');
                try { localStorage.setItem('matsanam.admin.sidebar.collapsed', collapsed ? 'true' : 'false'); } catch (error) {}
            }
            syncAdminSidebarToggle();
        }
        function closeAdminSidebar() {
            document.documentElement.classList.remove('admin-sidebar-open');
            syncAdminSidebarToggle();
        }
        document.addEventListener('DOMContentLoaded', function () {
            document.querySelectorAll('#adminSidebar .nav-link').forEach(function (link) {
                const text = Array.from(link.querySelectorAll('span:not(.nav-icon)'))
                    .map(function (node) { return node.textContent.trim(); })
                    .filter(Boolean).join(' ');
                if (text) {
                    link.setAttribute('title', text);
                    link.setAttribute('aria-label', text);
                }
            });
            syncAdminSidebarToggle();
        });
        window.addEventListener('resize', function () {
            if (!isAdminSidebarMobile()) {
                document.documentElement.classList.remove('admin-sidebar-open');
            }
            syncAdminSidebarToggle();
        });
        document.addEventListener('keydown', function (event) {
            if (event.key === 'Escape') closeAdminSidebar();
        });
        document.addEventListener('click', function (event) {
            if (isAdminSidebarMobile() && event.target.closest('#adminSidebar a')) closeAdminSidebar();
        });
    </script>
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

    <script>
        // Every server-rendered Admin page starts at the top of its own scroll area.
        // This prevents the next view (notably Dashboard) from opening partially clipped.
        (function () {
            const main = document.getElementById('adminMain');
            if (!main) return;
            if ('scrollRestoration' in history) history.scrollRestoration = 'manual';
            const resetMainScroll = () => { main.scrollTop = 0; };
            resetMainScroll();
            requestAnimationFrame(() => requestAnimationFrame(resetMainScroll));
            window.addEventListener('pageshow', resetMainScroll);
        })();
    </script>
        @stack('scripts')
</body>
</html>

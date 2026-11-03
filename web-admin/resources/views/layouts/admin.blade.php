<!DOCTYPE html>
<html lang="id">

<head>

    <meta charset="UTF-8">

    <meta
        name="viewport"
        content="width=device-width, initial-scale=1.0"
    >

    <meta
        name="csrf-token"
        content="{{ csrf_token() }}"
    >

    <title>
        @yield('title', 'Dashboard') - MATSANAM E-Learning
    </title>


    <!-- ===================================================== -->
    <!-- TAILWIND CONFIGURATION -->
    <!-- ===================================================== -->

    <script>
        tailwind.config = {
            darkMode: 'class'
        };
    </script>


    <!-- Tailwind CSS -->

    <script src="https://cdn.tailwindcss.com"></script>


    <!-- ===================================================== -->
    <!-- CEK TEMA SEBELUM HALAMAN DITAMPILKAN -->
    <!-- ===================================================== -->

    <script>

        if (localStorage.getItem('theme') === 'dark') {

            document.documentElement.classList.add('dark');

        }

    </script>


    <!-- ===================================================== -->
    <!-- CUSTOM STYLE -->
    <!-- ===================================================== -->

    <style>

        /* ================================================= */
        /* DASAR */
        /* ================================================= */

        html,
        body {

            margin: 0;
            padding: 0;

            font-family:
                system-ui,
                -apple-system,
                BlinkMacSystemFont,
                "Segoe UI",
                sans-serif;

        }


        body {

            transition:
                background-color 0.25s ease,
                color 0.25s ease;

        }


        /* ================================================= */
        /* MODE GELAP - BODY */
        /* ================================================= */

        .dark body {

            background-color: #0f172a !important;
            color: #e2e8f0;

        }


        /* ================================================= */
        /* BACKGROUND UTAMA */
        /* ================================================= */

        .dark .theme-bg {

            background-color: #0f172a !important;
            color: #e2e8f0;

        }


        /* ================================================= */
        /* CARD PUTIH MENJADI GELAP */
        /* ================================================= */

        .dark .bg-white {

            background-color: #1e293b !important;
            color: #e2e8f0;

        }


        /* ================================================= */
        /* CARD / THEME CARD */
        /* ================================================= */

        .dark .theme-card {

            background-color: #1e293b !important;
            color: #e2e8f0 !important;
            border-color: #334155 !important;

        }


        /* ================================================= */
        /* TEXT GELAP → TERANG */
        /* ================================================= */

        .dark .text-slate-900 {

            color: #f8fafc !important;

        }


        .dark .text-slate-800 {

            color: #f1f5f9 !important;

        }


        .dark .text-slate-700 {

            color: #e2e8f0 !important;

        }


        .dark .text-slate-600 {

            color: #cbd5e1 !important;

        }


        .dark .text-slate-500 {

            color: #94a3b8 !important;

        }


        .dark .text-gray-900 {

            color: #f8fafc !important;

        }


        .dark .text-gray-800 {

            color: #f1f5f9 !important;

        }


        .dark .text-gray-700 {

            color: #e2e8f0 !important;

        }


        .dark .text-gray-600 {

            color: #cbd5e1 !important;

        }


        .dark .text-gray-500 {

            color: #94a3b8 !important;

        }


        /* ================================================= */
        /* TEXT CUSTOM THEME */
        /* ================================================= */

        .dark .theme-text {

            color: #e2e8f0 !important;

        }


        /* ================================================= */
        /* BORDER */
        /* ================================================= */

        .dark .border-gray-100 {

            border-color: #334155 !important;

        }


        .dark .border-gray-200 {

            border-color: #334155 !important;

        }


        .dark .border-slate-200 {

            border-color: #334155 !important;

        }


        .dark .border-slate-300 {

            border-color: #475569 !important;

        }


        /* ================================================= */
        /* BACKGROUND SLATE */
        /* ================================================= */

        .dark .bg-slate-50 {

            background-color: #0f172a !important;

        }


        .dark .bg-slate-100 {

            background-color: #1e293b !important;

        }


        .dark .bg-slate-200 {

            background-color: #334155 !important;

        }


        /* ================================================= */
        /* INPUT / SELECT / TEXTAREA */
        /* ================================================= */

        .dark input,
        .dark select,
        .dark textarea {

            background-color: #1e293b !important;

            color: #f8fafc !important;

            border-color: #475569 !important;

        }


        .dark input::placeholder,
        .dark textarea::placeholder {

            color: #94a3b8 !important;

        }


        .dark select option {

            background-color: #1e293b;

            color: #f8fafc;

        }


        /* ================================================= */
        /* TABLE */
        /* ================================================= */

        .dark table {

            color: #e2e8f0;

        }


        .dark th {

            background-color: #334155 !important;

            color: #f8fafc !important;

            border-color: #475569 !important;

        }


        .dark td {

            color: #e2e8f0;

            border-color: #475569 !important;

        }


        .dark tr:hover td {

            background-color: #263449 !important;

        }


        /* ================================================= */
        /* HOVER BACKGROUND */
        /* ================================================= */

        .dark .hover\:bg-gray-50:hover {

            background-color: #334155 !important;

        }


        .dark .hover\:bg-slate-50:hover {

            background-color: #334155 !important;

        }


        /* ================================================= */
        /* ALERT SUCCESS */
        /* ================================================= */

        .dark .bg-green-100 {

            background-color: #14532d !important;

        }


        .dark .border-green-300 {

            border-color: #166534 !important;

        }


        .dark .text-green-700 {

            color: #bbf7d0 !important;

        }


        /* ================================================= */
        /* ALERT ERROR */
        /* ================================================= */

        .dark .bg-red-50 {

            background-color: #450a0a !important;

        }


        .dark .bg-red-100 {

            background-color: #450a0a !important;

        }


        .dark .text-red-600 {

            color: #fca5a5 !important;

        }


        .dark .text-red-700 {

            color: #fecaca !important;

        }


        /* ================================================= */
        /* TRANSISI */
        /* ================================================= */

        body,
        header,
        aside,
        main,
        nav,
        div,
        input,
        select,
        textarea,
        table,
        th,
        td {

            transition:
                background-color 0.2s ease,
                color 0.2s ease,
                border-color 0.2s ease;

        }


        /* ================================================= */
        /* SCROLLBAR MODE GELAP */
        /* ================================================= */

        .dark ::-webkit-scrollbar {

            width: 8px;
            height: 8px;

        }


        .dark ::-webkit-scrollbar-track {

            background: #0f172a;

        }


        .dark ::-webkit-scrollbar-thumb {

            background: #475569;

            border-radius: 10px;

        }


        .dark ::-webkit-scrollbar-thumb:hover {

            background: #64748b;

        }

    </style>

</head>


<body class="bg-slate-50 dark:bg-slate-900">


    <!-- ===================================================== -->
    <!-- MAIN APPLICATION -->
    <!-- ===================================================== -->

    <div class="flex h-screen overflow-hidden">


        <!-- ================================================= -->
        <!-- SIDEBAR -->
        <!-- ================================================= -->

        @include('layouts.partials.sidebar')


        <!-- ================================================= -->
        <!-- MAIN AREA -->
        <!-- ================================================= -->

        <div class="flex-1 flex flex-col overflow-hidden">


            <!-- ================================================= -->
            <!-- HEADER / NAVBAR -->
            <!-- ================================================= -->

            @include('layouts.partials.header')


            <!-- ================================================= -->
            <!-- PAGE CONTENT -->
            <!-- ================================================= -->

            <main
                class="flex-1 overflow-y-auto p-6
                       bg-slate-50 dark:bg-slate-900
                       theme-bg"
            >


                <!-- ================================================= -->
                <!-- SUCCESS MESSAGE -->
                <!-- ================================================= -->

                @if(session('success'))

                    <div
                        class="mb-4
                               rounded-lg
                               bg-green-100
                               border border-green-300
                               text-green-700
                               px-4 py-3"
                    >

                        {{ session('success') }}

                    </div>

                @endif


                <!-- ================================================= -->
                <!-- ERROR MESSAGE -->
                <!-- ================================================= -->

                @if(session('error'))

                    <div
                        class="mb-4
                               rounded-lg
                               bg-red-100
                               border border-red-300
                               text-red-700
                               px-4 py-3"
                    >

                        {{ session('error') }}

                    </div>

                @endif


                <!-- ================================================= -->
                <!-- VALIDATION ERRORS -->
                <!-- ================================================= -->

                @if($errors->any())

                    <div
                        class="mb-4
                               rounded-lg
                               bg-red-100
                               border border-red-300
                               text-red-700
                               px-4 py-3"
                    >

                        <ul class="list-disc ml-5">

                            @foreach($errors->all() as $error)

                                <li>
                                    {{ $error }}
                                </li>

                            @endforeach

                        </ul>

                    </div>

                @endif


                <!-- ================================================= -->
                <!-- CONTENT HALAMAN -->
                <!-- ================================================= -->

                @yield('content')


            </main>

        </div>

    </div>


    <!-- ===================================================== -->
    <!-- SCRIPTS DARI HALAMAN -->
    <!-- ===================================================== -->

    @stack('scripts')


</body>

</html>
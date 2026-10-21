@extends('layouts.admin')

@section('title', 'Export Rekap Presensi')

@section('content')
<div class="min-h-screen bg-gray-100 py-8">
    <div class="max-w-4xl mx-auto px-4">
        <div class="bg-white rounded-lg shadow-sm p-8">
            <div class="text-center mb-8">
                <h1 class="text-2xl font-bold text-gray-900 mb-2">Export Rekap Presensi</h1>
                <p class="text-gray-500">Format file laporan</p>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <a href="{{ route('admin.absensi.export', ['format' => 'excel', 'periode' => $request->periode, 'kelas' => $request->kelas]) }}" 
                   class="flex flex-col items-center p-6 bg-green-50 rounded-lg border border-green-200 hover:bg-green-100 transition">
                    <div class="w-16 h-16 bg-green-600 rounded-full flex items-center justify-center mb-4">
                        <span class="text-white text-3xl font-bold">XLS</span>
                    </div>
                    <h3 class="text-lg font-semibold text-gray-900 mb-2">Microsoft Excel</h3>
                    <p class="text-sm text-gray-600 text-center">
                        Export data dalam format .xlsx untuk diolah di Microsoft Excel atau Google Sheets
                    </p>
                </a>

                <a href="{{ route('admin.absensi.export', ['format' => 'pdf', 'periode' => $request->periode, 'kelas' => $request->kelas]) }}" 
                   class="flex flex-col items-center p-6 bg-red-50 rounded-lg border border-red-200 hover:bg-red-100 transition">
                    <div class="w-16 h-16 bg-red-600 rounded-full flex items-center justify-center mb-4">
                        <span class="text-white text-3xl font-bold">PDF</span>
                    </div>
                    <h3 class="text-lg font-semibold text-gray-900 mb-2">Portable Document Format</h3>
                    <p class="text-sm text-gray-600 text-center">
                        Export data dalam format .pdf untuk dokumen resmi dan printing
                    </p>
                </a>
            </div>

            <div class="mt-8 text-center">
                <a href="{{ route('admin.absensi.rekap') }}" 
                   class="inline-flex items-center gap-2 px-6 py-3 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50">
                    ← Kembali ke Rekap Presensi
                </a>
            </div>
        </div>
    </div>
</div>
@endsection

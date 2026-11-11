@extends('layouts.admin')
@section('title', 'Tambah Akun ' . ucfirst($role))
@section('content')
<div class="max-w-[1200px] mx-auto space-y-5">
    <div class="text-xs text-slate-400"><a href="{{ route('admin.dashboard') }}" class="hover:text-blue-600">Dashboard</a> <span class="mx-1">›</span><a href="{{ route('admin.accounts.index', ['role' => $role]) }}" class="hover:text-blue-600">Akun {{ ucfirst($role) }}</a> <span class="mx-1">›</span> Tambah</div>
    <div class="flex items-start justify-between gap-3"><div><h1 class="text-2xl font-bold text-slate-900">Tambah Akun {{ $role === 'guru' ? 'Guru' : 'Siswa' }}</h1><p class="text-sm text-slate-500 mt-1">Buat kredensial dan profil {{ $role === 'guru' ? 'tenaga pendidik' : 'peserta didik' }} baru.</p></div><a href="{{ route('admin.accounts.index', ['role' => $role]) }}" class="btn-light">← Kembali</a></div>
    @if($errors->any())<div class="rounded-xl border border-red-200 bg-red-50 text-red-800 px-4 py-3 text-sm"><strong>Periksa kembali data yang diisi.</strong><ul class="list-disc ml-5 mt-1 text-xs">@foreach($errors->all() as $error)<li>{{ $error }}</li>@endforeach</ul></div>@endif
    <form method="POST" action="{{ route('admin.accounts.store', $role) }}" class="space-y-5">@csrf
        @include('admin.accounts._fields')
        <div class="flex justify-end gap-2"><a href="{{ route('admin.accounts.index', ['role' => $role]) }}" class="btn-light">Batal</a><button type="submit" class="btn-primary">▣ Simpan & Buat Akun {{ ucfirst($role) }}</button></div>
    </form>
</div>
<style>.btn-primary,.btn-light{display:inline-flex;align-items:center;justify-content:center;gap:7px;padding:10px 15px;border-radius:9px;font-size:12px;font-weight:650}.btn-primary{background:#2563eb;color:#fff}.btn-primary:hover{background:#1d4ed8}.btn-light{background:#f1f5f9;color:#475569}</style>
@endsection

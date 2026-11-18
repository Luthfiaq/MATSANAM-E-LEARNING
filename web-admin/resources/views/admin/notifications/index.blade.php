@extends('layouts.admin')

@section('title', 'Notification Center')

@section('content')
<div class="max-w-5xl mx-auto space-y-5">
    <div class="flex flex-col sm:flex-row sm:items-end sm:justify-between gap-4">
        <div>
            <p class="text-xs font-bold uppercase tracking-[.16em] text-blue-600">Pusat Pemberitahuan</p>
            <h1 class="mt-1 text-2xl font-extrabold text-slate-900 dark:text-white">Notifikasi Admin</h1>
            <p class="mt-1 text-sm text-slate-500 dark:text-slate-400">Aktivitas penting yang membutuhkan perhatian Tata Usaha.</p>
        </div>
        @if($unreadCount > 0)
            <form method="POST" action="{{ route('admin.notifications.read-all') }}">
                @csrf
                <button type="submit" class="inline-flex items-center gap-2 rounded-xl bg-blue-600 px-4 py-2.5 text-sm font-bold text-white hover:bg-blue-700">
                    <span>✓</span> Tandai semua dibaca
                </button>
            </form>
        @endif
    </div>

    <div class="flex flex-wrap items-center gap-2">
        <a href="{{ route('admin.notifications.index', ['filter' => 'all']) }}"
           class="rounded-full px-4 py-2 text-xs font-bold {{ $filter === 'all' ? 'bg-blue-600 text-white' : 'bg-white text-slate-600 border border-slate-200 dark:bg-slate-800 dark:text-slate-300 dark:border-slate-700' }}">
            Semua
        </a>
        <a href="{{ route('admin.notifications.index', ['filter' => 'unread']) }}"
           class="rounded-full px-4 py-2 text-xs font-bold {{ $filter === 'unread' ? 'bg-blue-600 text-white' : 'bg-white text-slate-600 border border-slate-200 dark:bg-slate-800 dark:text-slate-300 dark:border-slate-700' }}">
            Belum dibaca <span class="ml-1">{{ $unreadCount }}</span>
        </a>
    </div>

    @if(session('success'))
        <div class="rounded-xl border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm text-emerald-800 dark:border-emerald-900 dark:bg-emerald-950/40 dark:text-emerald-300">{{ session('success') }}</div>
    @endif

    <div class="space-y-3">
        @forelse($notifications as $notification)
            @php
                $data = is_array($notification->data) ? $notification->data : [];
                $event = $data['event_type'] ?? 'informasi';
                $icon = $event === 'pengajuan_izin' ? '✉' : '◉';
            @endphp
            <article class="flex gap-4 rounded-2xl border p-4 shadow-sm {{ $notification->read_at ? 'border-slate-200 bg-white dark:border-slate-700 dark:bg-slate-800' : 'border-blue-200 bg-blue-50/70 dark:border-blue-900 dark:bg-blue-950/20' }}">
                <div class="grid h-11 w-11 shrink-0 place-items-center rounded-xl bg-blue-100 text-xl text-blue-700 dark:bg-blue-900/50 dark:text-blue-300">{{ $icon }}</div>
                <div class="min-w-0 flex-1">
                    <div class="flex flex-wrap items-start justify-between gap-2">
                        <h2 class="text-sm font-extrabold text-slate-900 dark:text-white">{{ $data['title'] ?? 'Pemberitahuan' }}</h2>
                        @unless($notification->read_at)
                            <span class="rounded-full bg-blue-600 px-2.5 py-1 text-[10px] font-bold text-white">BARU</span>
                        @endunless
                    </div>
                    <p class="mt-1 text-sm leading-6 text-slate-600 dark:text-slate-300">{{ $data['body'] ?? '' }}</p>
                    <div class="mt-3 flex flex-wrap items-center justify-between gap-3">
                        <time class="text-[11px] text-slate-400" datetime="{{ $notification->created_at?->toIso8601String() }}">{{ $notification->created_at?->format('d/m/Y H:i') }}</time>
                        @unless($notification->read_at)
                            <form method="POST" action="{{ route('admin.notifications.read', $notification->id) }}">
                                @csrf
                                <button type="submit" class="text-xs font-bold text-blue-700 hover:text-blue-900 dark:text-blue-300">{{ $event === 'pengajuan_izin' ? 'Buka verifikasi' : 'Tandai dibaca' }} →</button>
                            </form>
                        @endunless
                    </div>
                </div>
            </article>
        @empty
            <div class="rounded-2xl border border-dashed border-slate-300 bg-white px-6 py-14 text-center dark:border-slate-700 dark:bg-slate-800">
                <div class="text-4xl text-slate-300">♧</div>
                <h2 class="mt-3 text-sm font-extrabold text-slate-800 dark:text-white">{{ $filter === 'unread' ? 'Tidak ada notifikasi belum dibaca' : 'Belum ada notifikasi' }}</h2>
                <p class="mt-1 text-xs text-slate-500 dark:text-slate-400">Pengajuan izin dan aktivitas penting akan ditampilkan di sini.</p>
            </div>
        @endforelse
    </div>

    @if($notifications->hasPages())
        <div class="pt-2">{{ $notifications->links() }}</div>
    @endif
</div>
@endsection

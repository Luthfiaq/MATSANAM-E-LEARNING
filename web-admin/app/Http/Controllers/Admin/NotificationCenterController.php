<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Notifications\DatabaseNotification;
use Illuminate\View\View;

class NotificationCenterController extends Controller
{
    public function index(Request $request): View
    {
        $validated = $request->validate([
            'filter' => ['nullable', 'in:all,unread'],
        ]);

        $user = $request->user();
        $query = $user->notifications()->latest();

        if (($validated['filter'] ?? 'all') === 'unread') {
            $query->whereNull('read_at');
        }

        $notifications = $query->paginate(20)->withQueryString();
        $unreadCount = $user->unreadNotifications()->count();
        $filter = $validated['filter'] ?? 'all';

        return view('admin.notifications.index', compact(
            'notifications',
            'unreadCount',
            'filter',
        ));
    }

    public function markRead(Request $request, string $id): RedirectResponse
    {
        /** @var DatabaseNotification $notification */
        $notification = $request->user()->notifications()->whereKey($id)->firstOrFail();
        $eventType = $notification->data['event_type'] ?? null;
        $notification->markAsRead();

        if ($eventType === 'pengajuan_izin') {
            return redirect()->route('admin.absensi.verifikasi')
                ->with('success', 'Notifikasi ditandai sudah dibaca.');
        }

        return back()->with('success', 'Notifikasi ditandai sudah dibaca.');
    }

    public function markAllAsRead(Request $request): RedirectResponse
    {
        $updated = $request->user()->unreadNotifications()->update(['read_at' => now()]);

        return back()->with('success', $updated . ' notifikasi ditandai sudah dibaca.');
    }
}

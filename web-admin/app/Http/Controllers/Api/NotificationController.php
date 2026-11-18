<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\MatsanamNotificationService;
use Illuminate\Http\Request;
use Illuminate\Notifications\DatabaseNotification;
use Illuminate\Validation\ValidationException;

class NotificationController extends Controller
{
    public function index(Request $request)
    {
        $validated = $request->validate([
            'filter' => ['nullable', 'in:all,unread'],
            'per_page' => ['nullable', 'integer', 'min:1', 'max:50'],
        ]);

        $user = $request->user();
        $query = $user->notifications()->latest();
        if (($validated['filter'] ?? 'all') === 'unread') {
            $query->whereNull('read_at');
        }

        $page = $query->paginate($validated['per_page'] ?? 20);
        $items = $page->getCollection()->map(fn (DatabaseNotification $notification) => [
            'id' => $notification->id,
            'type' => $notification->data['event_type'] ?? 'informasi',
            'title' => $notification->data['title'] ?? 'Pemberitahuan',
            'body' => $notification->data['body'] ?? '',
            'metadata' => is_array($notification->data['metadata'] ?? null) ? $notification->data['metadata'] : [],
            'read_at' => $notification->read_at?->toIso8601String(),
            'created_at' => $notification->created_at?->toIso8601String(),
        ])->values();

        return response()->json([
            'success' => true,
            'data' => [
                'items' => $items,
                'unread_count' => $user->unreadNotifications()->count(),
                'pagination' => [
                    'current_page' => $page->currentPage(),
                    'last_page' => $page->lastPage(),
                    'has_more' => $page->hasMorePages(),
                ],
            ],
        ]);
    }

    public function unreadCount(Request $request)
    {
        return response()->json([
            'success' => true,
            'data' => ['unread_count' => $request->user()->unreadNotifications()->count()],
        ]);
    }

    public function markAsRead(Request $request, string $id)
    {
        $notification = $request->user()->notifications()->whereKey($id)->firstOrFail();
        $notification->markAsRead();

        return response()->json([
            'success' => true,
            'data' => ['id' => $notification->id, 'read_at' => $notification->fresh()->read_at?->toIso8601String()],
        ]);
    }

    public function markAllAsRead(Request $request)
    {
        $updated = $request->user()->unreadNotifications()->update(['read_at' => now()]);

        return response()->json([
            'success' => true,
            'data' => ['updated' => $updated],
        ]);
    }

    public function preferences(Request $request, MatsanamNotificationService $service)
    {
        return response()->json([
            'success' => true,
            'data' => ['preferences' => $service->preferencesFor($request->user())],
        ]);
    }

    public function updatePreferences(Request $request, MatsanamNotificationService $service)
    {
        $allowed = array_keys($service->preferencesFor($request->user()));
        $rules = ['preferences' => ['required', 'array', 'min:1']];
        foreach ($allowed as $key) {
            $rules['preferences.' . $key] = ['sometimes', 'boolean'];
        }

        $validated = $request->validate($rules);
        $submitted = $validated['preferences'] ?? [];
        $unknown = array_diff(array_keys($submitted), $allowed);
        if ($unknown !== []) {
            throw ValidationException::withMessages([
                'preferences' => ['Terdapat preferensi notifikasi yang tidak dikenal.'],
            ]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Preferensi notifikasi berhasil disimpan.',
            'data' => ['preferences' => $service->savePreferences($request->user(), $submitted)],
        ]);
    }
}

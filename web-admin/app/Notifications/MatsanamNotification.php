<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;

class MatsanamNotification extends Notification
{
    use Queueable;

    public function __construct(
        private readonly string $eventType,
        private readonly string $title,
        private readonly string $body,
        private readonly array $metadata = [],
    ) {
    }

    public function via(object $notifiable): array
    {
        // In-app notifications are persisted synchronously; no queue worker is required.
        return ['database'];
    }

    public function toDatabase(object $notifiable): array
    {
        return [
            'event_type' => $this->eventType,
            'title' => $this->title,
            'body' => $this->body,
            'metadata' => $this->metadata,
        ];
    }
}

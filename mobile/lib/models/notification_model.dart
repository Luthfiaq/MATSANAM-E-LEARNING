class NotificationItem {
  final String id;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic> metadata;
  final DateTime? readAt;
  final DateTime? createdAt;

  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.metadata,
    required this.readAt,
    required this.createdAt,
  });

  bool get isRead => readAt != null;

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    final rawMetadata = json['metadata'];
    return NotificationItem(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'informasi',
      title: json['title']?.toString() ?? 'Pemberitahuan',
      body: json['body']?.toString() ?? '',
      metadata: rawMetadata is Map
          ? Map<String, dynamic>.from(rawMetadata)
          : <String, dynamic>{},
      readAt: DateTime.tryParse(json['read_at']?.toString() ?? ''),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }

  NotificationItem markRead() => NotificationItem(
    id: id,
    type: type,
    title: title,
    body: body,
    metadata: metadata,
    readAt: readAt ?? DateTime.now(),
    createdAt: createdAt,
  );
}

class NotificationFeedPage {
  final List<NotificationItem> items;
  final int unreadCount;
  final int currentPage;
  final int lastPage;
  final bool hasMore;

  const NotificationFeedPage({
    required this.items,
    required this.unreadCount,
    required this.currentPage,
    required this.lastPage,
    required this.hasMore,
  });

  factory NotificationFeedPage.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final rawPagination = json['pagination'];
    final pagination = rawPagination is Map
        ? Map<String, dynamic>.from(rawPagination)
        : <String, dynamic>{};
    return NotificationFeedPage(
      items: rawItems is List
          ? rawItems
                .whereType<Map>()
                .map(
                  (item) => NotificationItem.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : const <NotificationItem>[],
      unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
      currentPage: (pagination['current_page'] as num?)?.toInt() ?? 1,
      lastPage: (pagination['last_page'] as num?)?.toInt() ?? 1,
      hasMore: pagination['has_more'] == true,
    );
  }
}

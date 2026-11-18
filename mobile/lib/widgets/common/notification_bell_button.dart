import 'package:flutter/material.dart';

import '../../services/notification_service.dart';

class NotificationBellButton extends StatefulWidget {
  final Future<void> Function() onPressed;
  final String tooltip;

  const NotificationBellButton({
    super.key,
    required this.onPressed,
    this.tooltip = 'Notifikasi',
  });

  @override
  State<NotificationBellButton> createState() => _NotificationBellButtonState();
}

class _NotificationBellButtonState extends State<NotificationBellButton> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCount();
  }

  Future<void> _loadCount() async {
    try {
      final count = await NotificationService().unreadCount();
      if (mounted) setState(() => _unreadCount = count);
    } catch (_) {
      // Keep the bell usable even when the badge endpoint is unavailable.
    }
  }

  Future<void> _open() async {
    await widget.onPressed();
    if (mounted) _loadCount();
  }

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: widget.tooltip,
    onPressed: _open,
    icon: Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.notifications_none_rounded),
        if (_unreadCount > 0)
          Positioned(
            top: -5,
            right: -7,
            child: Container(
              constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 1.5,
                ),
              ),
              child: Text(
                _unreadCount > 9 ? '9+' : '$_unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

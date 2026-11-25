import 'package:flutter/material.dart';

import 'status_badge.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final bool showNotification;
  final bool showProfile;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onBackPressed;
  final String? statusBadgeText;
  final BadgeType? statusBadgeType;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = true,
    this.showNotification = false,
    this.showProfile = false,
    this.onNotificationTap,
    this.onProfileTap,
    this.onBackPressed,
    this.statusBadgeText,
    this.statusBadgeType,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AppBar(
      backgroundColor: colors.surface,
      foregroundColor: colors.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      leading: showBackButton
          ? IconButton(
              onPressed: onBackPressed ?? () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
            )
          : null,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
          if (statusBadgeText != null) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _getBadgeColor(context),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  statusBadgeText!,
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      actions: [
        if (showNotification)
          IconButton(
            tooltip: 'Notifikasi',
            onPressed: onNotificationTap ?? () {},
            icon: const Icon(Icons.notifications_outlined),
          ),
        if (showProfile)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: onProfileTap ?? () {},
              child: CircleAvatar(
                radius: 18,
                backgroundColor: colors.primary,
                child: Icon(
                  Icons.person_outline,
                  color: colors.onPrimary,
                  size: 20,
                ),
              ),
            ),
          ),
        if (actions != null) ...actions!,
      ],
    );
  }

  Color _getBadgeColor(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    switch (statusBadgeType ?? BadgeType.success) {
      case BadgeType.success:
        return _successColor(context);
      case BadgeType.warning:
        return _warningColor(context);
      case BadgeType.danger:
        return colors.error;
      case BadgeType.info:
      case BadgeType.primary:
        return colors.primary;
      case BadgeType.neutral:
        return colors.onSurfaceVariant;
    }
  }

  Color _successColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF34D399)
      : const Color(0xFF059669);

  Color _warningColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFFFBBF24)
      : const Color(0xFFD97706);
}

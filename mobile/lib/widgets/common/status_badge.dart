import 'package:flutter/material.dart';

import '../../utils/constants.dart';

enum BadgeType { success, warning, danger, info, primary, neutral }

enum BadgeSize { small, medium, large }

class StatusBadge extends StatelessWidget {
  final String text;
  final BadgeType type;
  final BadgeSize size;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.text,
    this.type = BadgeType.neutral,
    this.size = BadgeSize.medium,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final palette = _getColors(context);
    final dimensions = _getDimensions();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dimensions['paddingH']!,
        vertical: dimensions['paddingV']!,
      ),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(dimensions['radius']!),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: palette.foreground, size: dimensions['iconSize']),
            const SizedBox(width: AppDimens.spacingXSmall),
          ],
          Text(
            text,
            style: TextStyle(
              color: palette.foreground,
              fontSize: dimensions['fontSize'],
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  _BadgePalette _getColors(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    switch (type) {
      case BadgeType.success:
        return _BadgePalette(
          background: dark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5),
          foreground: dark ? const Color(0xFF6EE7B7) : const Color(0xFF047857),
          border: dark ? const Color(0xFF065F46) : const Color(0xFFA7F3D0),
        );
      case BadgeType.warning:
        return _BadgePalette(
          background: dark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7),
          foreground: dark ? const Color(0xFFFCD34D) : const Color(0xFFB45309),
          border: dark ? const Color(0xFF92400E) : const Color(0xFFFDE68A),
        );
      case BadgeType.danger:
        return _BadgePalette(
          background: dark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2),
          foreground: dark ? const Color(0xFFFCA5A5) : const Color(0xFFB91C1C),
          border: dark ? const Color(0xFF991B1B) : const Color(0xFFFECACA),
        );
      case BadgeType.info:
      case BadgeType.primary:
        return _BadgePalette(
          background: scheme.primaryContainer,
          foreground: scheme.onPrimaryContainer,
          border: scheme.primary.withValues(alpha: dark ? .38 : .18),
        );
      case BadgeType.neutral:
        return _BadgePalette(
          background: scheme.surfaceContainerHighest,
          foreground: scheme.onSurfaceVariant,
          border: scheme.outlineVariant,
        );
    }
  }

  Map<String, double> _getDimensions() {
    switch (size) {
      case BadgeSize.small:
        return {
          'paddingH': 6,
          'paddingV': 2,
          'fontSize': 10,
          'radius': 4,
          'iconSize': 12,
        };
      case BadgeSize.large:
        return {
          'paddingH': 12,
          'paddingV': 6,
          'fontSize': 14,
          'radius': 8,
          'iconSize': 18,
        };
      case BadgeSize.medium:
        return {
          'paddingH': 8,
          'paddingV': 4,
          'fontSize': 11,
          'radius': 6,
          'iconSize': 14,
        };
    }
  }
}

class _BadgePalette {
  final Color background;
  final Color foreground;
  final Color border;

  const _BadgePalette({
    required this.background,
    required this.foreground,
    required this.border,
  });
}

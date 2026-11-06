import 'package:flutter/material.dart';
import '../../utils/constants.dart';

enum BadgeType {
  success,
  warning,
  danger,
  info,
  primary,
  neutral,
}

enum BadgeSize {
  small,
  medium,
  large,
}

class StatusBadge extends StatelessWidget {
  final String text;
  final BadgeType type;
  final BadgeSize size;
  final IconData? icon;

  const StatusBadge({
    Key? key,
    required this.text,
    this.type = BadgeType.neutral,
    this.size = BadgeSize.medium,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    final dimensions = _getDimensions();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dimensions['paddingH']!,
        vertical: dimensions['paddingV']!,
      ),
      decoration: BoxDecoration(
        color: colors['background'],
        borderRadius: BorderRadius.circular(dimensions['radius']!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: colors['text'],
              size: dimensions['iconSize'],
            ),
            SizedBox(width: AppDimens.spacingXSmall),
          ],
          Text(
            text,
            style: TextStyle(
              color: colors['text'],
              fontSize: dimensions['fontSize'],
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, Color> _getColors() {
    switch (type) {
      case BadgeType.success:
        return {
          'background': AppColors.successLight,
          'text': AppColors.success,
        };
      case BadgeType.warning:
        return {
          'background': AppColors.warningLight,
          'text': AppColors.warning,
        };
      case BadgeType.danger:
        return {
          'background': AppColors.dangerLight,
          'text': AppColors.danger,
        };
      case BadgeType.info:
        return {
          'background': AppColors.infoLight,
          'text': AppColors.info,
        };
      case BadgeType.primary:
        return {
          'background': AppColors.primaryLight,
          'text': AppColors.primary,
        };
      case BadgeType.neutral:
      default:
        return {
          'background': AppColors.background,
          'text': AppColors.textSecondary,
        };
    }
  }

  Map<String, double> _getDimensions() {
    switch (size) {
      case BadgeSize.small:
        return {
          'paddingH': 6.0,
          'paddingV': 2.0,
          'fontSize': 10.0,
          'radius': 4.0,
          'iconSize': 12.0,
        };
      case BadgeSize.large:
        return {
          'paddingH': 12.0,
          'paddingV': 6.0,
          'fontSize': 14.0,
          'radius': 8.0,
          'iconSize': 18.0,
        };
      case BadgeSize.medium:
      default:
        return {
          'paddingH': 8.0,
          'paddingV': 4.0,
          'fontSize': 11.0,
          'radius': 6.0,
          'iconSize': 14.0,
        };
    }
  }
}

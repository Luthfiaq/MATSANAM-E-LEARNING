import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../common/status_badge.dart';

class InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? badgeText;
  final BadgeType? badgeType;
  final VoidCallback? onTap;
  final Widget? trailing;

  const InfoCard({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.badgeText,
    this.badgeType,
    this.onTap,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
          child: Padding(
            padding: AppDimens.paddingLarge,
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: AppDimens.iconLarge,
                  ),
                ),
                const SizedBox(width: AppDimens.spacingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: AppTypography.labelLarge,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (badgeText != null) ...[
                            const SizedBox(width: AppDimens.spacingSmall),
                            StatusBadge(
                              text: badgeText!,
                              type: badgeType ?? BadgeType.neutral,
                              size: BadgeSize.small,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppDimens.spacingXSmall),
                      Text(
                        subtitle,
                        style: AppTypography.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: AppDimens.spacingSmall),
                  trailing!,
                ] else if (onTap != null) ...[
                  const SizedBox(width: AppDimens.spacingSmall),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
                    size: 22,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

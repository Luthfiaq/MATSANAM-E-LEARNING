import 'package:flutter/material.dart';

import '../../utils/constants.dart';
import 'status_badge.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final String? badgeText;
  final BadgeType? badgeType;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.badgeText,
    this.badgeType,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
        border: Border.all(color: colors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? .12 : .025),
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
            padding: padding ?? AppDimens.paddingLarge,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
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
                const SizedBox(height: AppDimens.spacingMedium),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
    Key? key,
    required this.title,
    required this.child,
    this.badgeText,
    this.badgeType,
    this.padding,
    this.onTap,
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
            padding: padding ?? AppDimens.paddingLarge,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: AppTypography.labelLarge),
                    if (badgeText != null)
                      StatusBadge(
                        text: badgeText!,
                        type: badgeType ?? BadgeType.neutral,
                        size: BadgeSize.small,
                      ),
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

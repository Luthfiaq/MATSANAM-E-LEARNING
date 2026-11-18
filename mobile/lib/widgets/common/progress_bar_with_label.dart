import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class ProgressBarWithLabel extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final String? label;
  final String? subLabel;
  final Color? color;
  final double height;

  const ProgressBarWithLabel({
    Key? key,
    required this.value,
    this.label,
    this.subLabel,
    this.color,
    this.height = 6.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progressColor = color ?? AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null || subLabel != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (label != null)
                  Text(
                    label!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                if (subLabel != null)
                  Text(
                    subLabel!,
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            backgroundColor: AppColors.background,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            minHeight: height,
          ),
        ),
      ],
    );
  }
}

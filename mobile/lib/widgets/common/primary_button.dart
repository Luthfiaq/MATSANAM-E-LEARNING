import 'package:flutter/material.dart';
import '../../utils/constants.dart';

enum ButtonVariant { primary, secondary, danger, outline }

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final ButtonVariant variant;
  final double? height;

  const PrimaryButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.variant = ButtonVariant.primary,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    final isDisabled = onPressed == null || isLoading;

    Widget buttonChild = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(colors['foreground']!),
            ),
          )
        else if (icon != null)
          Icon(icon, size: 18, color: colors['foreground']),
        if ((isLoading || icon != null) && text.isNotEmpty)
          const SizedBox(width: 8),
        if (text.isNotEmpty)
          Text(
            text,
            style: TextStyle(
              color: colors['foreground'],
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
      ],
    );

    if (variant == ButtonVariant.outline) {
      return SizedBox(
        width: isFullWidth ? double.infinity : null,
        height: height ?? 48,
        child: OutlinedButton(
          onPressed: isDisabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: colors['foreground'],
            side: BorderSide(
              color: isDisabled ? AppColors.border : colors['background']!,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: buttonChild,
        ),
      );
    }

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height ?? 48,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors['background'],
          foregroundColor: colors['foreground'],
          disabledBackgroundColor: AppColors.border,
          disabledForegroundColor: AppColors.textMuted,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        child: buttonChild,
      ),
    );
  }

  Map<String, Color> _getColors() {
    switch (variant) {
      case ButtonVariant.secondary:
        return {'background': AppColors.success, 'foreground': Colors.white};
      case ButtonVariant.danger:
        return {'background': AppColors.danger, 'foreground': Colors.white};
      case ButtonVariant.outline:
        return {
          'background': AppColors.primary,
          'foreground': AppColors.primary,
        };
      case ButtonVariant.primary:
      default:
        return {'background': AppColors.primary, 'foreground': Colors.white};
    }
  }
}

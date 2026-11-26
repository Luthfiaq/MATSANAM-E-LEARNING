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
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.variant = ButtonVariant.primary,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final palette = _getColors(context);
    final isDisabled = onPressed == null || isLoading;

    final buttonChild = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(palette.foreground),
            ),
          )
        else if (icon != null)
          Icon(icon, size: 18, color: palette.foreground),
        if ((isLoading || icon != null) && text.isNotEmpty)
          const SizedBox(width: 8),
        if (text.isNotEmpty)
          Text(
            text,
            style: TextStyle(
              color: palette.foreground,
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
            foregroundColor: palette.foreground,
            side: BorderSide(
              color: isDisabled
                  ? Theme.of(context).colorScheme.outlineVariant
                  : palette.background,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ).copyWith(animationDuration: const Duration(milliseconds: 180)),
          child: buttonChild,
        ),
      );
    }

    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height ?? 48,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.background,
          foregroundColor: palette.foreground,
          disabledBackgroundColor: colors.surfaceContainerHighest,
          disabledForegroundColor: colors.onSurface.withValues(alpha: .38),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ).copyWith(animationDuration: const Duration(milliseconds: 180)),
        child: buttonChild,
      ),
    );
  }

  _ButtonPalette _getColors(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    switch (variant) {
      case ButtonVariant.secondary:
        return _ButtonPalette(
          background: dark ? const Color(0xFF065F46) : const Color(0xFF059669),
          foreground: Colors.white,
        );
      case ButtonVariant.danger:
        return _ButtonPalette(
          background: colors.error,
          foreground: colors.onError,
        );
      case ButtonVariant.outline:
        return _ButtonPalette(
          background: colors.primary,
          foreground: colors.primary,
        );
      case ButtonVariant.primary:
        return _ButtonPalette(
          background: colors.primary,
          foreground: colors.onPrimary,
        );
    }
  }
}

class _ButtonPalette {
  final Color background;
  final Color foreground;

  const _ButtonPalette({required this.background, required this.foreground});
}

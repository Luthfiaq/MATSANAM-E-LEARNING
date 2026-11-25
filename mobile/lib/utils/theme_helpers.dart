import 'package:flutter/material.dart';

import 'constants.dart';

/// Semantic colors shared by Mobile Guru screens and reusable widgets.
/// Keeps the existing brand palette while adapting neutral surfaces to the
/// active Material 3 light/dark theme.
extension MatsanamThemeColors on BuildContext {
  ThemeData get matsanamTheme => Theme.of(this);

  bool get matsanamIsDark => matsanamTheme.brightness == Brightness.dark;

  /// Shared heading style used by active Mobile Guru screens.
  /// Kept in the shared helper so Student and Guru UI patches can coexist.
  TextStyle get matsanamHeading3 =>
      (matsanamTheme.textTheme.titleMedium ?? const TextStyle()).copyWith(
        fontWeight: FontWeight.w700,
        color: matsanamText,
      );

  Color get matsanamPage => matsanamTheme.scaffoldBackgroundColor;
  Color get matsanamSurface => matsanamTheme.colorScheme.surface;
  Color get matsanamText => matsanamTheme.colorScheme.onSurface;
  Color get matsanamTextSecondary => matsanamTheme.colorScheme.onSurfaceVariant;
  Color get matsanamTextMuted =>
      matsanamIsDark ? const Color(0xFF94A3B8) : AppColors.textMuted;
  Color get matsanamBorder => matsanamTheme.colorScheme.outlineVariant;

  Color get matsanamSoftSurface =>
      matsanamIsDark ? const Color(0xFF263449) : const Color(0xFFF1F5F9);
  Color get matsanamSoftPrimary =>
      matsanamIsDark ? const Color(0xFF1E3A8A) : AppColors.primaryLight;
  Color get matsanamSoftSuccess =>
      matsanamIsDark ? const Color(0xFF123D31) : AppColors.successLight;
  Color get matsanamSoftWarning =>
      matsanamIsDark ? const Color(0xFF4B3718) : AppColors.warningLight;
  Color get matsanamSoftError =>
      matsanamIsDark ? const Color(0xFF4B2025) : AppColors.errorLight;

  Color get matsanamPrimary => matsanamTheme.colorScheme.primary;
  Color get matsanamSuccess =>
      matsanamIsDark ? const Color(0xFF34D399) : AppColors.success;
  Color get matsanamWarning =>
      matsanamIsDark ? const Color(0xFFFBBF24) : AppColors.warning;
  Color get matsanamError =>
      matsanamIsDark ? const Color(0xFFF87171) : AppColors.error;
}

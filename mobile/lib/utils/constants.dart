// ✅ Design System - Matsanam E-Learning
// Based on: guru_mobile_arsitektur_kode_flutter_dart.md
import 'package:flutter/material.dart';

class AppColors {
  // 1. Brand Primary & Accents (From Design Spec)
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFFEFF6FF);

  // 2. Secondary / Accent Color
  static const Color secondary = Color(0xFF10B981);
  static const Color secondaryLight = Color(0xFFD1FAE5);
  static const Color accentOrange = Color(0xFFC2410C);

  // 3. Background Color
  static const Color background = Color(0xFFF8FAFC);

  // 4. Surface / Card Color
  static const Color surface = Color(0xFFFFFFFF);

  // 5. Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // 6. Border / Divider Color
  static const Color border = Color(0xFFE2E8F0);

  // 7. Status Colors
  static const Color success = Color(0xFF059669);
  static const Color successLight = Color(0xFFD1FAE5);

  static const Color warning = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFEF3C7);

  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);

  static const Color info = Color(0xFF2563EB);
  static const Color infoLight = Color(0xFFDBEAFE);

  // Aliases (for backward compatibility)
  static const Color danger = error;
  static const Color dangerLight = errorLight;
}

// Typography Constants
class AppTypography {
  static const TextStyle heading1 = TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.5);
  static const TextStyle heading2 = TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static const TextStyle heading3 = TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static const TextStyle bodyLarge = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textPrimary);
  static const TextStyle bodyMedium = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary);
  static const TextStyle bodySmall = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary);
  static const TextStyle labelLarge = TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static const TextStyle labelMedium = TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary);
  static const TextStyle labelSmall = TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.5);
  static const TextStyle caption = TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.textMuted);
}

// Dimension Constants
class AppDimens {
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 12.0;
  static const double spacingLarge = 16.0;
  static const double spacingXLarge = 24.0;
  static const double spacingXXLarge = 32.0;
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double iconSmall = 16.0;
  static const double iconMedium = 20.0;
  static const double iconLarge = 24.0;
  static const double iconXLarge = 32.0;
  static const EdgeInsets paddingSmall = EdgeInsets.all(8.0);
  static const EdgeInsets paddingMedium = EdgeInsets.all(12.0);
  static const EdgeInsets paddingLarge = EdgeInsets.all(16.0);
  static const EdgeInsets paddingCard = EdgeInsets.all(16.0);
  static const EdgeInsets paddingScreen = EdgeInsets.all(16.0);
}
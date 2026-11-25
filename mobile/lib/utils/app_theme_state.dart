import 'package:flutter/foundation.dart';

/// Holds the active mobile role so the app can apply the matching typography.
class AppThemeState {
  AppThemeState._();

  static final ValueNotifier<String> activeRole = ValueNotifier<String>('guru');

  static void setActiveRole(String role) {
    final normalized = role.trim().toLowerCase();
    if (normalized == 'guru' || normalized == 'siswa') {
      activeRole.value = normalized;
    }
  }
}

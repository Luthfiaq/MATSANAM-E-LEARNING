import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../utils/app_theme_state.dart';
import '../utils/session.dart';
import '../widgets/common/school_logo.dart';
import 'auth/login_screen.dart';
import 'auth/change_password_screen.dart';
import 'guru/guru_tab_shell.dart';
import 'onboarding/onboarding_screen.dart';
import 'siswa/siswa_tab_shell.dart';

class SplashGate extends StatefulWidget {
  const SplashGate({super.key});

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  @override
  void initState() {
    super.initState();
    _tentukan();
  }

  Future<void> _tentukan() async {
    final onboardingDone = await Session.isOnboardingDone();
    if (!mounted) return;

    if (!onboardingDone) {
      _buka(const OnboardingScreen());
      return;
    }

    final rememberedToken = await Session.getRememberedToken();
    if (rememberedToken == null || rememberedToken.isEmpty) {
      // Token dari sesi yang tidak dipilih untuk diingat tidak dipakai setelah app ditutup.
      if (await Session.getToken() != null) await Session.clearLogin();
      if (mounted) _buka(const LoginScreen());
      return;
    }

    final current = await AuthService().getCurrentUser();
    if (!mounted) return;
    final user = current?['user'];
    final role = user is Map ? user['role']?.toString() : null;
    final mustChangePassword =
        user is Map && user['must_change_password'] == true;
    if (role == 'guru' || role == 'siswa') {
      AppThemeState.setActiveRole(role!);
    }
    if (mustChangePassword) {
      _buka(const ChangePasswordScreen(wajib: true));
    } else if (role == 'guru') {
      _buka(const GuruTabShell());
    } else if (role == 'siswa') {
      _buka(const SiswaTabShell());
    } else {
      await Session.clearLogin();
      if (mounted) _buka(const LoginScreen());
    }
  }

  void _buka(Widget tujuan) {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => tujuan));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SchoolLogoCard(size: 96),
            const SizedBox(height: 18),
            Text(
              'MTsN 6 Nganjuk',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Gerbang Layanan Terpadu e-Learning & Presensi',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

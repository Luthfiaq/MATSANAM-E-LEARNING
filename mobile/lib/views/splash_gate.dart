import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../utils/constants.dart';
import '../utils/session.dart';
import '../widgets/common/school_logo.dart';
import 'auth/login_screen.dart';
import 'guru/dashboard_guru_screen.dart';
import 'onboarding/onboarding_screen.dart';
import 'siswa/dashboard/dashboard_siswa_page.dart';

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
    if (role == 'guru') {
      _buka(const DashboardGuruScreen());
    } else if (role == 'siswa') {
      _buka(const DashboardSiswaPage());
    } else {
      await Session.clearLogin();
      if (mounted) _buka(const LoginScreen());
    }
  }

  void _buka(Widget tujuan) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => tujuan),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(child: SchoolLogoCard(size: 96)),
    );
  }
}

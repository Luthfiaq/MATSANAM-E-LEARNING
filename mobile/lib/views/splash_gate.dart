import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../utils/session.dart';
import '../widgets/common/school_logo.dart';
import 'auth/login_screen.dart';
import 'onboarding/onboarding_screen.dart';
import 'siswa/dashboard/dashboard_siswa_page.dart';

/// Menentukan layar pertama:
/// belum onboarding -> Onboarding, sudah login ("Ingat Saya") -> Dashboard, selain itu -> Login.
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
    final token = await Session.getRememberedToken();
    if (token == null) {
      // sesi tanpa "Ingat Saya" tidak dipakai lagi setelah aplikasi ditutup
      await Session.clearLogin();
    }
    if (!mounted) return;

    final Widget tujuan = !onboardingDone
        ? const OnboardingScreen()
        : (token != null ? const DashboardSiswaPage() : const LoginScreen());

    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => tujuan));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(child: SchoolLogoCard(size: 96)),
    );
  }
}

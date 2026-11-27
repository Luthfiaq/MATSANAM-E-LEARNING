import 'package:flutter/material.dart';

import '../../widgets/common/persistent_tab_shell.dart';
import 'dashboard/dashboard_siswa_page.dart';
import 'materi/siswa_materi_screen.dart';
import 'nilai/siswa_nilai_screen.dart';
import 'pengaturan/profil_siswa_screen.dart';
import 'tugas/siswa_tugas_screen.dart';

/// Persistent top-level navigation for the Siswa role.
class SiswaTabShell extends StatelessWidget {
  const SiswaTabShell({super.key});

  @override
  Widget build(BuildContext context) {
    return PersistentTabShell(
      tabs: [
        (_) => const DashboardSiswaPage(),
        (_) => const SiswaMateriScreen(),
        (_) => const SiswaTugasScreen(),
        (_) => const SiswaNilaiScreen(),
        (_) => const ProfilSiswaScreen(),
      ],
    );
  }
}

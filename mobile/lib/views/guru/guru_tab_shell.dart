import 'package:flutter/material.dart';

import '../../widgets/common/persistent_tab_shell.dart';
import 'absensi/pilih_mapel_kelas_screen.dart';
import 'dashboard_guru_screen.dart';
import 'materi/pilih_mapel_kelas_guru_screen.dart';
import 'pengaturan/pengaturan_guru_screen.dart';
import 'tugas/pilih_mapel_kelas_tugas_screen.dart';

/// Persistent top-level navigation for the Guru role.
class GuruTabShell extends StatelessWidget {
  const GuruTabShell({super.key});

  @override
  Widget build(BuildContext context) {
    return PersistentTabShell(
      tabs: [
        (_) => const DashboardGuruScreen(),
        (_) => const PilihMapelKelasGuruScreen(),
        (_) => const PilihMapelKelasTugasScreen(),
        (_) => const PilihMapelKelasScreen(),
        (_) => const PengaturanGuruScreen(),
      ],
    );
  }
}

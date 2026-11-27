import 'package:flutter/material.dart';

import 'persistent_tab_shell.dart';

/// Navigasi utama area Guru. Hanya dipakai pada halaman menu tingkat pertama;
/// halaman detail (misalnya Buka Sesi, Daftar Tugas, Koreksi Nilai) tidak
/// memasang widget ini sehingga ruang layar tetap lega.
class GuruBottomNavigation extends StatelessWidget {
  const GuruBottomNavigation({super.key, required this.currentIndex});

  final int currentIndex;

  static const List<String> _routes = [
    '/guru/dashboard',
    '/materi',
    '/guru/tugas/pilih-mapel',
    '/guru/absensi/pilih-mapel',
    '/pengaturan',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final persistentTabs = PersistentTabScope.maybeOf(context);
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: theme.colorScheme.surface,
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: theme.colorScheme.onSurfaceVariant,
      selectedFontSize: 11,
      unselectedFontSize: 11,
      elevation: 8,
      onTap: (index) {
        if (index == currentIndex) return;
        if (persistentTabs != null) {
          persistentTabs.onSelect(index);
          return;
        }
        Navigator.pushReplacementNamed(context, _routes[index]);
      },
      items: [
        BottomNavigationBarItem(
          icon: AnimatedScale(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            scale: currentIndex == 0 ? 1.06 : 1,
            child: const Icon(Icons.grid_view_rounded),
          ),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: AnimatedScale(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            scale: currentIndex == 1 ? 1.06 : 1,
            child: const Icon(Icons.menu_book_rounded),
          ),
          label: 'Materi',
        ),
        BottomNavigationBarItem(
          icon: AnimatedScale(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            scale: currentIndex == 2 ? 1.06 : 1,
            child: const Icon(Icons.assignment_outlined),
          ),
          label: 'Tugas',
        ),
        BottomNavigationBarItem(
          icon: AnimatedScale(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            scale: currentIndex == 3 ? 1.06 : 1,
            child: const Icon(Icons.fact_check_outlined),
          ),
          label: 'Absensi',
        ),
        BottomNavigationBarItem(
          icon: AnimatedScale(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            scale: currentIndex == 4 ? 1.06 : 1,
            child: const Icon(Icons.person_outline_rounded),
          ),
          label: 'Profil',
        ),
      ],
    );
  }
}

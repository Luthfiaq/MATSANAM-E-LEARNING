import 'package:flutter/material.dart';

/// Navigasi utama area Guru. Hanya dipakai pada halaman menu tingkat pertama;
/// halaman detail (misalnya Buka Sesi, Daftar Tugas, Koreksi Nilai) tidak
/// memasang widget ini sehingga ruang layar tetap lega.
class GuruBottomNavigation extends StatelessWidget {
  const GuruBottomNavigation({super.key, required this.currentIndex});

  final int currentIndex;

  static const List<String> _routes = [
    '/guru/dashboard',
    '/materi',
    '/guru/absensi/pilih-mapel',
    '/guru/nilai',
    '/pengaturan',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
        Navigator.pushReplacementNamed(context, _routes[index]);
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.grid_view_rounded),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book_rounded),
          label: 'Materi',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.fact_check_outlined),
          label: 'Presensi',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics_outlined),
          label: 'Nilai',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          label: 'Profil',
        ),
      ],
    );
  }
}

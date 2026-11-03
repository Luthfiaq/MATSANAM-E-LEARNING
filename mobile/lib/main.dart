import 'package:flutter/material.dart';

import 'views/guru/dashboard/dashboard_guru_screen.dart';
import 'views/guru/materi/pilih_mapel_kelas_guru_screen.dart';
import 'views/guru/pengaturan/pengaturan_guru_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MatsanamApp());
}

class MatsanamApp extends StatefulWidget {
  const MatsanamApp({super.key});

  static ThemeMode currentThemeMode = ThemeMode.light;

  static void ubahTema(BuildContext context, ThemeMode mode) {
    final state = context.findAncestorStateOfType<_MatsanamAppState>();
    state?.ubahTema(mode);
  }

  @override
  State<MatsanamApp> createState() => _MatsanamAppState();
}

class _MatsanamAppState extends State<MatsanamApp> {
  ThemeMode _themeMode = MatsanamApp.currentThemeMode;

  void ubahTema(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
      MatsanamApp.currentThemeMode = mode;
    });
  }

  static const Color _primary = Color(0xFF2563EB);

  ThemeData _lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primary,
        brightness: Brightness.light,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF0F172A),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: _primary,
        unselectedItemColor: Color(0xFF94A3B8),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF0F172A)),
        bodyMedium: TextStyle(color: Color(0xFF334155)),
        titleLarge: TextStyle(
          color: Color(0xFF0F172A),
          fontWeight: FontWeight.bold,
        ),
      ),
      dividerColor: const Color(0xFFE2E8F0),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFFF1F5F9),
      ),
    );
  }

  ThemeData _darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF60A5FA),
        brightness: Brightness.dark,
        surface: const Color(0xFF1E293B),
      ),
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E293B),
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E293B),
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E293B),
        selectedItemColor: Color(0xFF60A5FA),
        unselectedItemColor: Color(0xFF94A3B8),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFFF8FAFC)),
        bodyMedium: TextStyle(color: Color(0xFFCBD5E1)),
        titleLarge: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      dividerColor: const Color(0xFF334155),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF334155),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MATSANAM E-Learning',
      themeMode: _themeMode,
      theme: _lightTheme(),
      darkTheme: _darkTheme(),
      home: const DashboardGuruScreen(),
      routes: {
        '/materi': (context) => const PilihMapelKelasGuruScreen(),
        '/pengaturan': (context) => const PengaturanGuruScreen(),
      },
    );
  }
}
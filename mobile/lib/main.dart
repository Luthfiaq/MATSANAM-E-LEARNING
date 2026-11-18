import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'utils/constants.dart';
import 'views/splash_gate.dart';
import 'views/auth/login_screen.dart';
import 'views/guru/dashboard_guru_screen.dart';
import 'views/guru/absensi/buka_sesi_screen.dart';
import 'views/guru/absensi/histori_sesi_screen.dart';
import 'views/guru/absensi/pilih_mapel_kelas_screen.dart';
import 'views/guru/absensi/rekap_presensi_screen.dart';
import 'views/guru/absensi/verifikasi_surat_screen.dart';
import 'views/guru/materi/daftar_materi_screen.dart';
import 'views/guru/materi/edit_materi_screen.dart';
import 'views/guru/materi/pilih_mapel_kelas_guru_screen.dart';
import 'views/guru/materi/tambah_materi_screen.dart';
import 'views/guru/nilai/daftar_siswa_screen.dart';
import 'views/guru/nilai/koreksi_tugas_screen.dart';
import 'views/guru/nilai/nilai_daftar_tugas_mapel_screen.dart';
import 'views/guru/nilai/nilai_pilih_mapel_kelas_screen.dart';
import 'views/guru/pengaturan/pengaturan_guru_screen.dart';
import 'views/guru/tugas/edit_tugas_screen.dart';
import 'views/guru/tugas/pilih_mapel_kelas_tugas_screen.dart';
import 'views/guru/tugas/tambah_tugas_screen.dart';
import 'views/guru/tugas/tugas_per_mapel_screen.dart';
import 'views/siswa/dashboard/dashboard_siswa_page.dart';
import 'views/siswa/pengaturan/profil_siswa_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Several task, material, and grade screens format dates using id_ID.
  // Load locale symbols before the first widget build to avoid LocaleDataException.
  await initializeDateFormatting('id_ID');
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

  @override
  void initState() {
    super.initState();
    _restoreThemePreference();
  }

  Future<void> _restoreThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('siswa_theme') ?? 'Terang';
      final restored = switch (saved) {
        'Gelap' => ThemeMode.dark,
        'Sistem' => ThemeMode.system,
        _ => ThemeMode.light,
      };
      if (!mounted) return;
      setState(() {
        _themeMode = restored;
        MatsanamApp.currentThemeMode = restored;
      });
    } catch (_) {
      // Keep the safe light-theme default if local preferences are unavailable.
    }
  }

  void ubahTema(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
      MatsanamApp.currentThemeMode = mode;
    });
    final preference = switch (mode) {
      ThemeMode.dark => 'Gelap',
      ThemeMode.system => 'Sistem',
      _ => 'Terang',
    };
    SharedPreferences.getInstance().then(
      (prefs) => prefs.setString('siswa_theme', preference),
    );
  }

  ThemeData _theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    const primary = Color(0xFF2563EB);
    final background = dark ? const Color(0xFF0F172A) : AppColors.background;
    final surface = dark ? const Color(0xFF1E293B) : AppColors.surface;
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: primary,
          brightness: brightness,
          surface: surface,
        ).copyWith(
          primary: dark ? const Color(0xFF60A5FA) : primary,
          onPrimary: dark ? const Color(0xFF0F172A) : Colors.white,
          primaryContainer: dark
              ? const Color(0xFF1E3A8A)
              : const Color(0xFFEFF6FF),
          onPrimaryContainer: dark
              ? const Color(0xFFDBEAFE)
              : const Color(0xFF1E40AF),
          surface: surface,
          onSurface: dark ? const Color(0xFFF8FAFC) : AppColors.textPrimary,
          onSurfaceVariant: dark
              ? const Color(0xFFCBD5E1)
              : AppColors.textSecondary,
          outline: dark ? const Color(0xFF475569) : AppColors.border,
          outlineVariant: dark ? const Color(0xFF334155) : AppColors.border,
          error: AppColors.error,
        );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: dark ? Colors.white : AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: dark ? const Color(0xFF60A5FA) : primary,
        unselectedItemColor: const Color(0xFF94A3B8),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerColor: dark ? const Color(0xFF334155) : AppColors.border,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
      ),
    );
  }

  Map<String, dynamic> _args(RouteSettings settings) {
    final value = settings.arguments;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Matsanam E-Learning',
      themeMode: _themeMode,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      home: const SplashGate(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/guru/dashboard': (_) => const DashboardGuruScreen(),
        '/siswa/dashboard': (_) => const DashboardSiswaPage(),
        '/siswa/profil': (_) => const ProfilSiswaScreen(),

        // Materi Guru
        '/materi': (_) => const PilihMapelKelasGuruScreen(),
        '/guru/materi': (_) => const DaftarMateriScreen(),
        '/guru/materi/pilih-mapel': (_) => const PilihMapelKelasGuruScreen(),

        // Tugas Guru
        '/guru/tugas': (_) => const PilihMapelKelasTugasScreen(),
        '/guru/tugas/pilih-mapel': (_) => const PilihMapelKelasTugasScreen(),

        // Absensi Guru
        '/guru/absensi/pilih-mapel': (_) => const PilihMapelKelasScreen(),
        '/guru/absensi/histori': (_) => const HistoriSesiScreen(),
        '/guru/absensi/histori-sesi': (_) => const HistoriSesiScreen(),
        '/guru/absensi/rekap': (_) => const RekapPresensiGuruScreen(),
        '/guru/absensi/rekap-presensi': (_) => const RekapPresensiGuruScreen(),
        '/guru/absensi/verifikasi': (_) => const VerifikasiSuratGuruScreen(),
        '/guru/absensi/verifikasi-surat': (_) =>
            const VerifikasiSuratGuruScreen(),

        // Nilai Guru
        '/guru/nilai': (_) => const NilaiPilihMapelKelasScreen(),

        // Profil dan dashboard
        '/pengaturan': (_) => const PengaturanGuruScreen(),
        '/guru/pengaturan': (_) => const PengaturanGuruScreen(),
      },
      onGenerateRoute: (settings) {
        final args = _args(settings);
        final name = settings.name ?? '';

        if (name == '/guru/tambah-tugas' || name == '/guru/tugas/tambah') {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => TambahTugasScreen(initialSchedule: args),
          );
        }

        if (name == '/guru/tambah-materi' || name == '/guru/materi/tambah') {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => TambahMateriScreen(initialSchedule: args),
          );
        }

        if (name == '/guru/nilai/daftar-tugas-mapel') {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => NilaiDaftarTugasMapelScreen(mapelKelas: args),
          );
        }
        if (name == '/guru/nilai/detail-siswa') {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => DaftarSiswaMengumpulkanScreen(tugas: args),
          );
        }
        if (name == '/guru/nilai/koreksi') {
          final rows = (args['siswaList'] as List? ?? [])
              .whereType<Map>()
              .map((row) => Map<String, dynamic>.from(row))
              .toList();
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => KoreksiTugasScreen(
              tugas: args['tugas'] is Map
                  ? Map<String, dynamic>.from(args['tugas'] as Map)
                  : <String, dynamic>{},
              siswaList: rows,
              initialIndex: (args['index'] as num?)?.toInt() ?? 0,
            ),
          );
        }
        if (name == '/guru/absensi/buka-sesi') {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => BukaSesiScreen(jadwal: args),
          );
        }
        if (name == '/guru/tugas/per-mapel') {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => TugasPerMapelScreen(mapel: args),
          );
        }
        if (name == '/guru/materi/per-mapel') {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => DaftarMateriScreen(
              mapelFilter: args['mapel']?.toString(),
              kelasFilter: args['kelas']?.toString(),
              jadwalIdFilter: int.tryParse(args['jadwal_id']?.toString() ?? ''),
            ),
          );
        }

        final materiEdit = RegExp(
          r'^/guru/materi/(\d+)/edit$',
        ).firstMatch(name);
        if (materiEdit != null) {
          final materi = <String, dynamic>{
            'id': int.parse(materiEdit.group(1)!),
          }..addAll(args);
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => EditMateriScreen(materi: materi),
          );
        }

        final tugasEdit = RegExp(r'^/guru/tugas/(\d+)/edit$').firstMatch(name);
        if (tugasEdit != null) {
          final tugas = <String, dynamic>{'id': int.parse(tugasEdit.group(1)!)}
            ..addAll(args);
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => EditTugasScreen(tugas: tugas),
          );
        }

        final tugasSiswa = RegExp(
          r'^/guru/tugas/(\d+)/siswa$',
        ).firstMatch(name);
        if (tugasSiswa != null) {
          final tugas = <String, dynamic>{'id': int.parse(tugasSiswa.group(1)!)}
            ..addAll(args);
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => DaftarSiswaMengumpulkanScreen(tugas: tugas),
          );
        }
        return null;
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Halaman tidak ditemukan')),
          body: Center(
            child: Text('Route ${settings.name ?? '-'} belum terdaftar.'),
          ),
        ),
      ),
    );
  }
}

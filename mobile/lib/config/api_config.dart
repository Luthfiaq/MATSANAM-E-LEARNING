import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

/// Central API configuration.
///
/// Default URL targets the local Laravel server when running Flutter Web.
/// For Android Emulator run with:
///   --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
/// For a physical phone use the computer's LAN IP in API_BASE_URL.
class ApiConfig {
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _configuredBaseUrl.replaceFirst(RegExp(r'/$'), '');
    }
    if (kIsWeb ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux) {
      return 'http://127.0.0.1:8000/api';
    }
    // Android Emulator reaches the host machine through 10.0.2.2.
    return 'http://10.0.2.2:8000/api';
  }

  static String get guruDashboard => '$baseUrl/guru/dashboard';
  static String get guruMateri => '$baseUrl/guru/materi';
  static String get guruTugas => '$baseUrl/guru/tugas';
  static String get guruMapelKelas => '$baseUrl/guru/mapel-kelas';
  static String get guruStartSession => '$baseUrl/guru/start-session';
  static String get guruSessions => '$baseUrl/guru/sesi-report';
  static String get guruRekapPresensi => '$baseUrl/guru/rekap-presensi';
  static String get guruVerifikasiSurat => '$baseUrl/guru/surat-verifikasi';
  static String get guruNilai => '$baseUrl/guru/nilai';
  static String get login => '$baseUrl/auth/login';
  static String get logout => '$baseUrl/auth/logout';
  static String get me => '$baseUrl/auth/me';

  static const Duration timeout = Duration(seconds: 30);

  static Map<String, String> headers([String? token]) => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

  static String get siswaDashboard => '$baseUrl/siswa/dashboard';
  static String get siswaPengajuanIzin => '$baseUrl/siswa/pengajuan-izin';
}

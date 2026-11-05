import 'package:shared_preferences/shared_preferences.dart';

/// Penyimpanan lokal: status onboarding & sesi login.
class Session {
  static const _kOnboarding = 'onboarding_done';
  static const _kToken = 'auth_token';
  static const _kRemember = 'remember_me';
  static const _kNama = 'siswa_nama';
  static const _kKelas = 'siswa_kelas';
  static const _kNis = 'siswa_nis';

  static Future<bool> isOnboardingDone() async =>
      (await SharedPreferences.getInstance()).getBool(_kOnboarding) ?? false;

  static Future<void> setOnboardingDone() async =>
      (await SharedPreferences.getInstance()).setBool(_kOnboarding, true);

  static Future<String?> getToken() async =>
      (await SharedPreferences.getInstance()).getString(_kToken);

  /// Token dipakai lagi saat aplikasi dibuka ulang hanya jika "Ingat Saya" dicentang.
  static Future<String?> getRememberedToken() async {
    final p = await SharedPreferences.getInstance();
    return (p.getBool(_kRemember) ?? false) ? p.getString(_kToken) : null;
  }

  static Future<void> saveLogin({
    required String token,
    required bool remember,
    required String nama,
    required String? kelas,
    required String? nis,
  }) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kToken, token);
    await p.setBool(_kRemember, remember);
    await p.setString(_kNama, nama);
    await p.setString(_kKelas, kelas ?? '');
    await p.setString(_kNis, nis ?? '');
  }

  static Future<void> clearLogin() async {
    final p = await SharedPreferences.getInstance();
    for (final k in [_kToken, _kRemember, _kNama, _kKelas, _kNis]) {
      await p.remove(k);
    }
  }
}

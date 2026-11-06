import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Satu penyimpanan sesi untuk semua role (guru dan siswa).
class Session {
  static const _kOnboarding = 'onboarding_done';
  static const _kToken = 'auth_token';
  static const _kRemember = 'remember_me';
  static const _kNama = 'siswa_nama';
  static const _kKelas = 'siswa_kelas';
  static const _kNis = 'siswa_nis';
  static const _kRole = 'auth_role';
  static const _kProfile = 'auth_profile';
  static const _kProfileId = 'auth_profile_id';
  static const _kUser = 'auth_user';

  static Future<bool> isOnboardingDone() async =>
      (await SharedPreferences.getInstance()).getBool(_kOnboarding) ?? false;

  static Future<void> setOnboardingDone() async =>
      (await SharedPreferences.getInstance()).setBool(_kOnboarding, true);

  static Future<String?> getToken() async =>
      (await SharedPreferences.getInstance()).getString(_kToken);

  static Future<String?> getRememberedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getBool(_kRemember) ?? false) ? prefs.getString(_kToken) : null;
  }

  static Future<String?> getRole() async =>
      (await SharedPreferences.getInstance()).getString(_kRole);

  static Future<String?> getNama() async =>
      (await SharedPreferences.getInstance()).getString(_kNama);

  static Future<Map<String, dynamic>?> getProfile() async {
    final raw = (await SharedPreferences.getInstance()).getString(_kProfile);
    if (raw == null) return null;
    try {
      final value = jsonDecode(raw);
      return value is Map ? Map<String, dynamic>.from(value) : null;
    } catch (_) {
      return null;
    }
  }

  static Future<int?> getProfileId() async {
    final raw = (await SharedPreferences.getInstance()).getString(_kProfileId);
    return int.tryParse(raw ?? '');
  }

  static Future<void> saveAuthData({
    required String token,
    required bool remember,
    required Map<String, dynamic> user,
    Map<String, dynamic>? profile,
    dynamic profileId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kToken, token);
    await prefs.setBool(_kRemember, remember);
    await prefs.setString(_kUser, jsonEncode(user));

    final role = user['role']?.toString() ?? '';
    await prefs.setString(_kRole, role);
    if (profile == null) {
      await prefs.remove(_kProfile);
    } else {
      await prefs.setString(_kProfile, jsonEncode(profile));
    }
    if (profileId == null) {
      await prefs.remove(_kProfileId);
    } else {
      await prefs.setString(_kProfileId, profileId.toString());
    }

    final nama = (profile?['nama_lengkap'] ?? user['name'] ?? '').toString();
    await prefs.setString(_kNama, nama);
    await prefs.setString(_kKelas, (profile?['kelas'] ?? '').toString());
    await prefs.setString(_kNis, (profile?['nis'] ?? '').toString());
  }

  /// Dipertahankan untuk kompatibilitas dengan pemanggil dari versi kelompok.
  static Future<void> saveLogin({
    required String token,
    required bool remember,
    required String nama,
    required String? kelas,
    required String? nis,
    String role = 'siswa',
  }) async {
    await saveAuthData(
      token: token,
      remember: remember,
      user: {'role': role, 'name': nama},
      profile: {'nama_lengkap': nama, 'kelas': kelas, 'nis': nis},
    );
  }

  static Future<void> clearLogin() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in [
      _kToken, _kRemember, _kNama, _kKelas, _kNis,
      _kRole, _kProfile, _kProfileId, _kUser,
    ]) {
      await prefs.remove(key);
    }
  }
}

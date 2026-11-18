import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../utils/session.dart';

class AuthService {
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    bool remember = false,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.login),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: {
              'email': email.trim(),
              'password': password,
              'device_name': 'matsanam-mobile',
              'remember': remember ? '1' : '0',
            },
          )
          .timeout(ApiConfig.timeout);

      final payload = _decode(response.body);
      if (response.statusCode == 200 && payload['success'] == true) {
        final rawData = payload['data'];
        if (rawData is! Map) {
          return {'success': false, 'message': 'Respons login tidak lengkap.'};
        }
        final data = Map<String, dynamic>.from(rawData);
        final rawUser = data['user'];
        if (data['token'] == null || rawUser is! Map) {
          return {
            'success': false,
            'message': 'Token atau data akun tidak ditemukan.',
          };
        }
        final user = Map<String, dynamic>.from(rawUser);
        final rawProfile = data['profile'];
        final profile = rawProfile is Map
            ? Map<String, dynamic>.from(rawProfile)
            : null;
        await Session.saveAuthData(
          token: data['token'].toString(),
          remember: remember,
          user: user,
          profile: profile,
          profileId: data['profile_id'] ?? profile?['id'],
        );
        return {'success': true, 'data': data};
      }

      final errors = payload['errors'];
      final validationMessage = errors is Map && errors.isNotEmpty
          ? ((errors.values.first is List)
                ? (errors.values.first as List).first.toString()
                : errors.values.first.toString())
          : null;
      return {
        'success': false,
        'message':
            validationMessage ??
            payload['message']?.toString() ??
            'Login gagal (HTTP ${response.statusCode}).',
      };
    } on SocketException {
      return {
        'success': false,
        'message':
            'Tidak dapat terhubung ke server. Periksa koneksi dan alamat API.',
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Server terlalu lama merespons. Coba lagi.',
      };
    } on http.ClientException catch (e) {
      return {
        'success': false,
        'message': 'Koneksi ke backend gagal: ${e.message}',
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final token = await Session.getToken();
    if (token == null || token.isEmpty) return null;

    Future<Map<String, dynamic>?> cachedAuthData() async {
      final user = await Session.getUser();
      if (user == null || user.isEmpty) return null;
      final profile = await Session.getProfile();
      return {'user': user, if (profile != null) 'profile': profile};
    }

    try {
      final response = await http
          .get(
            Uri.parse(ApiConfig.me),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 401 || response.statusCode == 403) {
        // 401: token tidak valid/kedaluwarsa. 403 pada /auth/me berarti akun
        // dinonaktifkan atau tidak lagi diizinkan memakai aplikasi mobile.
        await Session.clearLogin();
        return null;
      }

      if (response.statusCode != 200) {
        // Gangguan server/rute tidak boleh dianggap sebagai token kedaluwarsa.
        return cachedAuthData();
      }

      final payload = _decode(response.body);
      if (payload['success'] != true || payload['data'] is! Map) {
        return cachedAuthData();
      }

      final data = Map<String, dynamic>.from(payload['data'] as Map);
      if (data['user'] is! Map) return cachedAuthData();
      return data;
    } on SocketException {
      return cachedAuthData();
    } on TimeoutException {
      return cachedAuthData();
    } on http.ClientException {
      return cachedAuthData();
    } catch (_) {
      // Cache tetap hanya dipakai sebagai fallback tampilan/routing lokal;
      // seluruh request data tetap divalidasi oleh backend dengan token.
      return cachedAuthData();
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = await Session.getToken();
    if (token == null || token.isEmpty) {
      throw StateError('Sesi login tidak ditemukan. Silakan masuk kembali.');
    }

    final response = await http
        .post(
          Uri.parse(ApiConfig.changePassword),
          headers: ApiConfig.headers(token),
          body: jsonEncode({
            'current_password': currentPassword,
            'password': newPassword,
            'password_confirmation': newPassword,
          }),
        )
        .timeout(ApiConfig.timeout);

    final payload = _decode(response.body);
    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        payload['success'] == true) {
      return payload;
    }

    final errors = payload['errors'];
    final firstError = errors is Map && errors.isNotEmpty
        ? ((errors.values.first is List)
              ? (errors.values.first as List).first.toString()
              : errors.values.first.toString())
        : null;
    throw StateError(
      firstError ??
          payload['message']?.toString() ??
          'Gagal memperbarui kata sandi.',
    );
  }

  Future<void> logout() async {
    final token = await Session.getToken();
    try {
      if (token != null && token.isNotEmpty) {
        await http
            .post(
              Uri.parse(ApiConfig.logout),
              headers: {
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
              },
            )
            .timeout(ApiConfig.timeout);
      }
    } catch (_) {
      // Hapus sesi lokal meskipun backend sedang tidak dapat diakses.
    } finally {
      await Session.clearLogin();
    }
  }

  Map<String, dynamic> _decode(String raw) {
    try {
      final value = jsonDecode(raw);
      return value is Map ? Map<String, dynamic>.from(value) : {};
    } catch (_) {
      return {};
    }
  }
}

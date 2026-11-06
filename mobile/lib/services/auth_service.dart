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
      final response = await http.post(
        Uri.parse(ApiConfig.login),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'email': email.trim(),
          'password': password,
          'device_name': 'matsanam-mobile',
        },
      ).timeout(ApiConfig.timeout);

      final payload = _decode(response.body);
      if (response.statusCode == 200 && payload['success'] == true) {
        final rawData = payload['data'];
        if (rawData is! Map) {
          return {'success': false, 'message': 'Respons login tidak lengkap.'};
        }
        final data = Map<String, dynamic>.from(rawData);
        final rawUser = data['user'];
        if (data['token'] == null || rawUser is! Map) {
          return {'success': false, 'message': 'Token atau data akun tidak ditemukan.'};
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
        'message': validationMessage ??
            payload['message']?.toString() ??
            'Login gagal (HTTP ${response.statusCode}).',
      };
    } on SocketException {
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server. Periksa koneksi dan alamat API.',
      };
    } on TimeoutException {
      return {'success': false, 'message': 'Server terlalu lama merespons. Coba lagi.'};
    } on http.ClientException catch (e) {
      return {'success': false, 'message': 'Koneksi ke backend gagal: ${e.message}'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final token = await Session.getToken();
    if (token == null || token.isEmpty) return null;
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.me),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.timeout);
      if (response.statusCode != 200) {
        if (response.statusCode == 401 || response.statusCode == 403) {
          await Session.clearLogin();
        }
        return null;
      }
      final payload = _decode(response.body);
      if (payload['success'] != true || payload['data'] is! Map) return null;
      return Map<String, dynamic>.from(payload['data'] as Map);
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    final token = await Session.getToken();
    try {
      if (token != null && token.isNotEmpty) {
        await http.post(
          Uri.parse(ApiConfig.logout),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(ApiConfig.timeout);
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

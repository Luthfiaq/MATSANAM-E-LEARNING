import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../utils/api_config.dart';
import '../utils/session.dart';
import 'api_exception.dart';

class AuthService {
  Future<void> login({
    required String email,
    required String password,
    required bool remember,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/login'),
            headers: ApiConfig.headers(),
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(ApiConfig.timeout);

      final body = _decode(res.body);

      if (res.statusCode == 200 && body['success'] == true) {
        final data = body['data'] as Map<String, dynamic>;
        final siswa = data['siswa'] as Map<String, dynamic>?;
        await Session.saveLogin(
          token: data['token'].toString(),
          remember: remember,
          nama: (siswa?['nama_lengkap'] ?? data['user']['name']).toString(),
          kelas: siswa?['kelas']?.toString(),
          nis: siswa?['nis']?.toString(),
        );
        return;
      }

      // 422 = validasi Laravel, 401/403 = ditolak
      String message = (body['message'] ?? 'Gagal masuk. Coba lagi.').toString();
      if (res.statusCode == 422 && body['errors'] is Map) {
        final errors = body['errors'] as Map;
        if (errors.isNotEmpty) {
          message = (errors.values.first as List).first.toString();
        }
      }
      throw ApiException(message, statusCode: res.statusCode);
    } on SocketException {
      throw const ApiException(
          'Tidak dapat terhubung ke server. Periksa koneksi internet / alamat API.');
    } on TimeoutException {
      throw const ApiException('Server terlalu lama merespons. Coba lagi.');
    } on http.ClientException {
      throw const ApiException(
          'Tidak dapat terhubung ke server. Periksa koneksi internet / alamat API.');
    }
  }

  Future<void> logout() async {
    final token = await Session.getToken();
    try {
      if (token != null) {
        await http
            .post(Uri.parse('${ApiConfig.baseUrl}/logout'),
                headers: ApiConfig.headers(token))
            .timeout(ApiConfig.timeout);
      }
    } catch (_) {
      // tetap hapus sesi lokal walau server tidak terjangkau
    } finally {
      await Session.clearLogin();
    }
  }

  Map<String, dynamic> _decode(String raw) {
    try {
      final d = jsonDecode(raw);
      return d is Map<String, dynamic> ? d : {};
    } catch (_) {
      return {};
    }
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/dashboard_model.dart';
import '../utils/api_config.dart';
import '../utils/session.dart';
import 'api_exception.dart';

class DashboardService {
  Future<DashboardSiswa> fetch() async {
    final token = await Session.getToken();
    if (token == null) {
      throw const ApiException('Sesi berakhir. Silakan masuk kembali.',
          statusCode: 401);
    }
    try {
      final res = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/siswa/dashboard'),
              headers: ApiConfig.headers(token))
          .timeout(ApiConfig.timeout);

      if (res.statusCode == 401) {
        throw const ApiException('Sesi berakhir. Silakan masuk kembali.',
            statusCode: 401);
      }
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode != 200 || body['success'] != true) {
        throw ApiException(
            (body['message'] ?? 'Gagal memuat dashboard.').toString(),
            statusCode: res.statusCode);
      }
      return DashboardSiswa.fromJson(body['data'] as Map<String, dynamic>);
    } on SocketException {
      throw const ApiException(
          'Tidak dapat terhubung ke server. Periksa koneksi internet.');
    } on TimeoutException {
      throw const ApiException('Server terlalu lama merespons. Coba lagi.');
    } on http.ClientException {
      throw const ApiException(
          'Tidak dapat terhubung ke server. Periksa koneksi internet.');
    } on FormatException {
      throw const ApiException('Respons server tidak valid.');
    }
  }
}

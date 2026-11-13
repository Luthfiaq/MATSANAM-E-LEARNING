import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/notification_model.dart';
import '../utils/session.dart';
import 'api_exception.dart';

class NotificationService {
  Future<String> _token() async {
    final token = await Session.getToken();
    if (token == null || token.isEmpty) {
      throw const ApiException(
        'Sesi login berakhir. Silakan masuk kembali.',
        statusCode: 401,
      );
    }
    return token;
  }

  Future<Map<String, dynamic>> _request(
    Future<http.Response> Function(String token) send,
  ) async {
    try {
      final response = await send(await _token()).timeout(ApiConfig.timeout);
      final decoded = jsonDecode(response.body);
      final payload = decoded is Map
          ? Map<String, dynamic>.from(decoded)
          : <String, dynamic>{};
      if (response.statusCode == 401) {
        throw const ApiException(
          'Sesi login berakhir. Silakan masuk kembali.',
          statusCode: 401,
        );
      }
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          payload['success'] != true) {
        throw ApiException(
          payload['message']?.toString() ??
              'Permintaan notifikasi gagal (HTTP ${response.statusCode}).',
          statusCode: response.statusCode,
        );
      }
      return payload;
    } on SocketException {
      throw const ApiException(
        'Tidak dapat terhubung ke server. Periksa koneksi internet.',
      );
    } on TimeoutException {
      throw const ApiException('Server terlalu lama merespons. Coba lagi.');
    } on http.ClientException {
      throw const ApiException('Koneksi ke server gagal.');
    } on FormatException {
      throw const ApiException('Respons server tidak valid.');
    }
  }

  Future<NotificationFeedPage> fetch({
    int page = 1,
    String filter = 'all',
    int perPage = 20,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/notifications').replace(
      queryParameters: {
        'page': '$page',
        'filter': filter,
        'per_page': '$perPage',
      },
    );
    final payload = await _request(
      (token) => http.get(uri, headers: ApiConfig.headers(token)),
    );
    final data = payload['data'];
    if (data is! Map) {
      throw const ApiException('Format data notifikasi tidak sesuai.');
    }
    return NotificationFeedPage.fromJson(Map<String, dynamic>.from(data));
  }

  Future<int> unreadCount() async {
    final payload = await _request(
      (token) => http.get(
        Uri.parse('${ApiConfig.baseUrl}/notifications/unread-count'),
        headers: ApiConfig.headers(token),
      ),
    );
    final data = payload['data'];
    return data is Map ? (data['unread_count'] as num?)?.toInt() ?? 0 : 0;
  }

  Future<void> markAsRead(String id) async {
    await _request(
      (token) => http.post(
        Uri.parse('${ApiConfig.baseUrl}/notifications/$id/read'),
        headers: ApiConfig.headers(token),
      ),
    );
  }

  Future<void> markAllAsRead() async {
    await _request(
      (token) => http.post(
        Uri.parse('${ApiConfig.baseUrl}/notifications/read-all'),
        headers: ApiConfig.headers(token),
      ),
    );
  }

  Future<Map<String, dynamic>> fetchPreferences() async {
    final payload = await _request(
      (token) => http.get(
        Uri.parse('${ApiConfig.baseUrl}/notifications/preferences'),
        headers: ApiConfig.headers(token),
      ),
    );
    final data = payload['data'];
    final preferences = data is Map ? data['preferences'] : null;
    return preferences is Map
        ? Map<String, dynamic>.from(preferences)
        : <String, dynamic>{};
  }

  Future<Map<String, dynamic>> updatePreferences(
    Map<String, bool> changes,
  ) async {
    final payload = await _request(
      (token) => http.put(
        Uri.parse('${ApiConfig.baseUrl}/notifications/preferences'),
        headers: ApiConfig.headers(token),
        body: jsonEncode({'preferences': changes}),
      ),
    );
    final data = payload['data'];
    final preferences = data is Map ? data['preferences'] : null;
    return preferences is Map
        ? Map<String, dynamic>.from(preferences)
        : <String, dynamic>{};
  }
}

import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';

/// API client for teacher assignment CRUD operations.
class GuruTugasService {
  // Date pickers select the school's wall-clock time (WIB). Store UTC timestamps
  // using a fixed UTC+7 conversion instead of relying on the device timezone.
  DateTime _schoolTimeToUtc(DateTime schoolWallClock) => DateTime.utc(
    schoolWallClock.year,
    schoolWallClock.month,
    schoolWallClock.day,
    schoolWallClock.hour - 7,
    schoolWallClock.minute,
    schoolWallClock.second,
    schoolWallClock.millisecond,
    schoolWallClock.microsecond,
  );

  Future<String> _requireToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null || token.isEmpty) {
      throw Exception('Sesi login tidak ditemukan. Silakan login kembali.');
    }
    return token;
  }

  Future<List<Map<String, dynamic>>> loadSchedules() async {
    final token = await _requireToken();
    final response = await http
        .get(
          Uri.parse(ApiConfig.guruMapelKelas),
          headers: ApiConfig.headers(token),
        )
        .timeout(ApiConfig.timeout);

    final decoded = _decode(response);
    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        decoded['success'] != true) {
      throw Exception(_message(decoded, 'Jadwal mengajar gagal dimuat.'));
    }

    final rows = decoded['data'];
    if (rows is! List) return <Map<String, dynamic>>[];
    return rows
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
  }

  Future<String> createTask({
    required int jadwalId,
    required String judul,
    required String deskripsi,
    required String jenis,
    required DateTime deadline,
    required int bobot,
    PlatformFile? file,
  }) async {
    final decoded = await _send(
      method: 'POST',
      fields: {
        'jadwal_id': jadwalId.toString(),
        'judul': judul,
        'deskripsi': deskripsi,
        'jenis': jenis,
        'deadline': _schoolTimeToUtc(deadline).toIso8601String(),
        'bobot': bobot.toString(),
      },
      file: file,
    );
    return _message(decoded, 'Tugas berhasil dibuat.');
  }

  Future<String> updateTask({
    required int taskId,
    required String judul,
    required String deskripsi,
    required String jenis,
    required DateTime deadline,
    required int bobot,
    PlatformFile? file,
  }) async {
    final decoded = await _send(
      method: 'PUT',
      taskId: taskId,
      fields: {
        'judul': judul,
        'deskripsi': deskripsi,
        'jenis': jenis,
        'deadline': _schoolTimeToUtc(deadline).toIso8601String(),
        'bobot': bobot.toString(),
      },
      file: file,
    );
    return _message(decoded, 'Tugas berhasil diperbarui.');
  }

  Future<String> deleteTask(int taskId) async {
    final token = await _requireToken();
    final response = await http
        .delete(
          Uri.parse('${ApiConfig.guruTugas}/$taskId'),
          headers: ApiConfig.headers(token),
        )
        .timeout(ApiConfig.timeout);

    final decoded = _decode(response);
    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        decoded['success'] != true) {
      throw Exception(
        _message(decoded, 'Tugas gagal dihapus (HTTP ${response.statusCode}).'),
      );
    }
    return _message(decoded, 'Tugas berhasil dihapus.');
  }

  Future<Map<String, dynamic>> _send({
    required String method,
    int? taskId,
    required Map<String, String> fields,
    PlatformFile? file,
  }) async {
    final token = await _requireToken();
    final baseUri = Uri.parse(ApiConfig.guruTugas);
    final uri = taskId == null
        ? baseUri
        : baseUri.replace(path: '${baseUri.path}/$taskId');
    late http.Response response;

    if (file != null) {
      if (file.bytes == null) {
        throw Exception('File tidak dapat dibaca. Silakan pilih ulang.');
      }
      final request = http.MultipartRequest('POST', uri)
        ..headers['Accept'] = 'application/json'
        ..headers['Authorization'] = 'Bearer $token'
        ..fields.addAll(fields);
      if (method == 'PUT') request.fields['_method'] = 'PUT';
      request.files.add(
        http.MultipartFile.fromBytes('file', file.bytes!, filename: file.name),
      );
      final streamed = await request.send().timeout(ApiConfig.timeout);
      response = await http.Response.fromStream(streamed);
    } else {
      final headers = ApiConfig.headers(token);
      final body = jsonEncode(fields);
      final request = method == 'PUT'
          ? http.put(uri, headers: headers, body: body)
          : http.post(uri, headers: headers, body: body);
      response = await request.timeout(ApiConfig.timeout);
    }

    final decoded = _decode(response);
    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        decoded['success'] != true) {
      throw Exception(
        _message(
          decoded,
          'Tugas gagal disimpan (HTTP ${response.statusCode}).',
        ),
      );
    }
    return decoded;
  }

  Map<String, dynamic> _decode(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } on FormatException {
      // Return a useful fallback below for non-JSON responses (for example 500 HTML).
    }
    return <String, dynamic>{};
  }

  String _message(Map<String, dynamic> decoded, String fallback) {
    final errors = decoded['errors'];
    if (errors is Map && errors.isNotEmpty) {
      for (final value in errors.values) {
        if (value is List && value.isNotEmpty) return value.first.toString();
        if (value != null) return value.toString();
      }
    }
    final message = decoded['message']?.toString();
    return message == null || message.isEmpty ? fallback : message;
  }
}

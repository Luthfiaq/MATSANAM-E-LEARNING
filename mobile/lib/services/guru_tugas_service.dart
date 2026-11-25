import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import 'multipart_upload.dart';

/// API client for Teacher assignment CRUD and its individual attachments.
class GuruTugasService {
  static const int maxFileBytes = 20 * 1024 * 1024;
  static const int maxFilesPerUpload = 20;
  static const Duration uploadTimeout = Duration(minutes: 5);

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
    List<PlatformFile> files = const [],
    PlatformFile? file,
    String? clientRequestId,
    UploadProgressCallback? onProgress,
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
        if (clientRequestId != null) 'client_request_id': clientRequestId,
      },
      files: files,
      legacyFile: file,
      onProgress: onProgress,
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
    List<PlatformFile> files = const [],
    PlatformFile? file,
    String? attachmentBatchId,
    UploadProgressCallback? onProgress,
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
        if (attachmentBatchId != null) 'attachment_batch_id': attachmentBatchId,
      },
      files: files,
      legacyFile: file,
      onProgress: onProgress,
    );
    return _message(decoded, 'Tugas berhasil diperbarui.');
  }

  Future<Uint8List> downloadTaskAttachment({
    required int taskId,
    required String fileId,
  }) async {
    final token = await _requireToken();
    final uri = Uri.parse('${ApiConfig.guruTugas}/$taskId/files/$fileId');
    final response = await http
        .get(uri, headers: {'Accept': '*/*', 'Authorization': 'Bearer $token'})
        .timeout(ApiConfig.timeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final decoded = _decode(response);
      throw Exception(
        _message(
          decoded,
          'Lampiran gagal diunduh (HTTP ${response.statusCode}).',
        ),
      );
    }
    return response.bodyBytes;
  }

  Future<String> deleteTaskAttachment({
    required int taskId,
    required String fileId,
  }) async {
    final decoded = await _delete(
      Uri.parse('${ApiConfig.guruTugas}/$taskId/files/$fileId'),
      'Lampiran gagal dihapus.',
    );
    return _message(decoded, 'Lampiran berhasil dihapus.');
  }

  Future<String> deleteAllTaskAttachments(int taskId) async {
    final decoded = await _delete(
      Uri.parse('${ApiConfig.guruTugas}/$taskId/files/all'),
      'Semua lampiran gagal dihapus.',
    );
    return _message(decoded, 'Semua lampiran berhasil dihapus.');
  }

  Future<Map<String, dynamic>> _delete(Uri uri, String fallback) async {
    final token = await _requireToken();
    final response = await http
        .delete(uri, headers: ApiConfig.headers(token))
        .timeout(ApiConfig.timeout);
    final decoded = _decode(response);
    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        decoded['success'] != true) {
      throw Exception(
        _message(decoded, '$fallback (HTTP ${response.statusCode}).'),
      );
    }
    return decoded;
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
    List<PlatformFile> files = const [],
    PlatformFile? legacyFile,
    UploadProgressCallback? onProgress,
  }) async {
    if (files.length > maxFilesPerUpload) {
      throw Exception('Maksimal 20 file dapat diunggah dalam satu proses.');
    }
    for (final file in files) {
      _validateFile(file);
    }
    if (legacyFile != null) _validateFile(legacyFile);

    final token = await _requireToken();
    final baseUri = Uri.parse(ApiConfig.guruTugas);
    final uri = taskId == null
        ? baseUri
        : baseUri.replace(path: '${baseUri.path}/$taskId');
    late http.Response response;

    if (files.isNotEmpty || legacyFile != null) {
      final request = http.MultipartRequest('POST', uri)
        ..headers['Accept'] = 'application/json'
        ..headers['Authorization'] = 'Bearer $token'
        ..fields.addAll(fields);
      if (method == 'PUT') request.fields['_method'] = 'PUT';

      for (final file in files) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'files[]',
            file.bytes!,
            filename: file.name,
          ),
        );
      }
      // Backward compatibility with previous app builds using `file`.
      if (legacyFile != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            legacyFile.bytes!,
            filename: legacyFile.name,
          ),
        );
      }

      response = await sendMultipartWithProgress(
        request,
        timeout: uploadTimeout,
        onProgress: onProgress,
      );
    } else {
      final headers = ApiConfig.headers(token);
      final body = jsonEncode(fields);
      final request = method == 'PUT'
          ? http.put(uri, headers: headers, body: body)
          : http.post(uri, headers: headers, body: body);
      response = await request.timeout(ApiConfig.timeout);
      onProgress?.call(1.0);
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

  void _validateFile(PlatformFile file) {
    if (file.size > maxFileBytes) {
      throw Exception('File "${file.name}" melebihi batas maksimal 20 MB.');
    }
    if (file.bytes == null) {
      throw Exception(
        'File "${file.name}" tidak dapat dibaca. Silakan pilih ulang.',
      );
    }
  }

  Map<String, dynamic> _decode(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } on FormatException {
      // A non-JSON response (for example an HTML 500 page) uses the fallback below.
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

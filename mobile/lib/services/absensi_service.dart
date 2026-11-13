import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/absensi_model.dart';
import '../utils/session.dart';

class AbsensiService {
  Future<Map<String, dynamic>> daftarSuratVerifikasi({
    String? status,
    int page = 1,
  }) async {
    final token = await Session.getToken();
    if (token == null || token.isEmpty) {
      throw StateError('Sesi login tidak ditemukan. Silakan masuk kembali.');
    }

    final uri = Uri.parse(ApiConfig.guruVerifikasiSurat).replace(
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
        'page': page.toString(),
      },
    );
    final response = await http
        .get(
          uri,
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(ApiConfig.timeout);

    final payload = _decodeJson(response.body);
    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        payload['success'] != true) {
      throw StateError(_responseMessage(payload, response.statusCode));
    }

    final data = payload['data'];
    if (data is! Map || data['surats'] is! Map) {
      throw StateError('Format daftar surat dari server tidak sesuai.');
    }

    return Map<String, dynamic>.from(data);
  }

  Future<Map<String, dynamic>> setujuiSurat(int suratId) async {
    return _suratAction(suratId, 'approve', const {});
  }

  Future<Map<String, dynamic>> tolakSurat(int suratId, String catatan) async {
    final trimmed = catatan.trim();
    if (trimmed.isEmpty) {
      throw StateError('Alasan penolakan wajib diisi.');
    }
    if (trimmed.length > 500) {
      throw StateError('Alasan penolakan maksimal 500 karakter.');
    }
    return _suratAction(suratId, 'reject', {'catatan': trimmed});
  }

  Future<Map<String, dynamic>> _suratAction(
    int suratId,
    String action,
    Map<String, dynamic> body,
  ) async {
    final token = await Session.getToken();
    if (token == null || token.isEmpty) {
      throw StateError('Sesi login tidak ditemukan. Silakan masuk kembali.');
    }

    final response = await http
        .post(
          Uri.parse('${ApiConfig.guruVerifikasiSurat}/$suratId/$action'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body),
        )
        .timeout(ApiConfig.timeout);

    final payload = _decodeJson(response.body);
    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        payload['success'] != true) {
      throw StateError(_responseMessage(payload, response.statusCode));
    }
    return payload;
  }

  Future<Uint8List> unduhSuratVerifikasi(int suratId) async {
    final token = await Session.getToken();
    if (token == null || token.isEmpty) {
      throw StateError('Sesi login tidak ditemukan. Silakan masuk kembali.');
    }

    final response = await http
        .get(
          Uri.parse('${ApiConfig.guruVerifikasiSurat}/$suratId/file'),
          headers: {'Accept': '*/*', 'Authorization': 'Bearer $token'},
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final payload = _decodeJson(response.body);
      throw StateError(_responseMessage(payload, response.statusCode));
    }
    if (response.bodyBytes.isEmpty) {
      throw StateError('Dokumen surat kosong atau tidak dapat dibaca.');
    }
    return response.bodyBytes;
  }

  Map<String, dynamic> _decodeJson(String body) {
    try {
      final decoded = jsonDecode(body);
      return decoded is Map<String, dynamic>
          ? decoded
          : decoded is Map
          ? Map<String, dynamic>.from(decoded)
          : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  String _responseMessage(Map<String, dynamic> payload, int statusCode) {
    final errors = payload['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final firstValue = errors.values.first;
      if (firstValue is List && firstValue.isNotEmpty) {
        return firstValue.first.toString();
      }
      if (firstValue != null) return firstValue.toString();
    }
    if (statusCode == 401) return 'Sesi login berakhir. Silakan masuk kembali.';
    if (statusCode == 403)
      return payload['message']?.toString() ??
          'Anda tidak memiliki akses ke surat ini.';
    if (statusCode == 404) return 'Surat atau dokumen tidak ditemukan.';
    if (statusCode == 409)
      return payload['message']?.toString() ??
          'Surat sudah diproses sebelumnya. Muat ulang daftar.';
    return payload['message']?.toString() ??
        'Permintaan gagal (HTTP $statusCode).';
  }

  Future<Map<String, dynamic>> kirimPengajuanIzin(
    PengajuanIzinModel data,
  ) async {
    final token = await Session.getToken();
    if (token == null || token.isEmpty) {
      throw StateError('Sesi login tidak ditemukan. Silakan masuk kembali.');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiConfig.siswaPengajuanIzin),
    );
    request.fields.addAll(data.toFields());
    if (data.fileBytes != null && data.fileName != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'dokumen',
          data.fileBytes!,
          filename: data.fileName!,
        ),
      );
    }
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    try {
      final streamed = await request.send().timeout(ApiConfig.timeout);
      final response = await http.Response.fromStream(streamed);
      Map<String, dynamic> payload;
      try {
        final decoded = jsonDecode(response.body);
        payload = decoded is Map
            ? Map<String, dynamic>.from(decoded)
            : <String, dynamic>{};
      } catch (_) {
        payload = <String, dynamic>{};
      }

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          payload['success'] == true) {
        return payload;
      }

      final errors = payload['errors'];
      final validationMessage = errors is Map && errors.isNotEmpty
          ? ((errors.values.first is List)
                ? (errors.values.first as List).first.toString()
                : errors.values.first.toString())
          : null;
      throw StateError(
        validationMessage ??
            payload['message']?.toString() ??
            'Pengajuan gagal dikirim (HTTP ${response.statusCode}).',
      );
    } on SocketException {
      throw StateError(
        'Tidak dapat terhubung ke server. Periksa koneksi dan alamat API.',
      );
    } on TimeoutException {
      throw StateError('Server terlalu lama merespons. Coba kirim kembali.');
    } on http.ClientException {
      throw StateError('Koneksi ke server gagal.');
    }
  }
}

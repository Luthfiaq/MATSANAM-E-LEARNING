import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../utils/session.dart';
import 'api_exception.dart';

class SiswaLearningService {
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

  Future<Map<String, dynamic>> _get(String url) async {
    try {
      final response = await http
          .get(Uri.parse(url), headers: ApiConfig.headers(await _token()))
          .timeout(ApiConfig.timeout);
      return _decodeResponse(response);
    } on SocketException {
      throw const ApiException(
        'Tidak dapat terhubung ke server. Periksa koneksi.',
      );
    } on TimeoutException {
      throw const ApiException('Server terlalu lama merespons. Coba lagi.');
    } on http.ClientException {
      throw const ApiException('Koneksi ke server gagal.');
    } on FormatException {
      throw const ApiException('Respons server tidak valid.');
    }
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
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
            'Permintaan gagal (HTTP ${response.statusCode}).',
        statusCode: response.statusCode,
      );
    }
    return payload;
  }

  Uri _authorizedFileUri(String rawUrl) {
    final raw = Uri.parse(rawUrl);
    final apiBase = Uri.parse(ApiConfig.baseUrl);

    // Laravel url() may emit APP_URL (often 127.0.0.1). On Android emulator
    // or a phone that host is wrong; always use the API host selected by
    // API_BASE_URL while preserving the protected endpoint path.
    return apiBase.replace(
      path: raw.path,
      query: raw.hasQuery ? raw.query : null,
    );
  }

  Future<Uint8List> downloadAuthorizedFile(String url) async {
    try {
      final response = await http
          .get(
            _authorizedFileUri(url),
            headers: {
              'Accept': '*/*',
              'Authorization': 'Bearer ${await _token()}',
            },
          )
          .timeout(ApiConfig.timeout);
      if (response.statusCode == 401) {
        throw const ApiException(
          'Sesi login berakhir. Silakan masuk kembali.',
          statusCode: 401,
        );
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          'Gagal mengambil berkas (HTTP ${response.statusCode}).',
          statusCode: response.statusCode,
        );
      }
      return response.bodyBytes;
    } on SocketException {
      throw const ApiException(
        'Tidak dapat terhubung ke server untuk mengunduh berkas.',
      );
    } on TimeoutException {
      throw const ApiException(
        'Unduhan terlalu lama. Periksa koneksi lalu coba lagi.',
      );
    } on http.ClientException {
      throw const ApiException('Koneksi unduhan gagal.');
    }
  }

  Future<List<Map<String, dynamic>>> mapel() async {
    final payload = await _get(ApiConfig.siswaMapel);
    return _mapList(payload['data']);
  }

  Future<List<Map<String, dynamic>>> materi({
    int? mapelId,
    String? tipe,
    String? query,
  }) async {
    final uri = Uri.parse(ApiConfig.siswaMateri).replace(
      queryParameters: {
        if (mapelId != null) 'mapel_id': '$mapelId',
        if (tipe != null && tipe != 'semua') 'tipe': tipe,
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
      },
    );
    final payload = await _get(uri.toString());
    return _mapList(payload['data']);
  }

  Future<Map<String, dynamic>> detailMateri(int id) async {
    final payload = await _get('${ApiConfig.siswaMateri}/$id');
    return _map(payload['data']);
  }

  Future<List<Map<String, dynamic>>> tugas({
    String status = 'semua',
    int? mapelId,
    String? query,
  }) async {
    final uri = Uri.parse(ApiConfig.siswaTugas).replace(
      queryParameters: {
        'status': status,
        if (mapelId != null) 'mapel_id': '$mapelId',
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
      },
    );
    final payload = await _get(uri.toString());
    return _mapList(payload['data']);
  }

  Future<Map<String, dynamic>> detailTugas(int id) async {
    final payload = await _get('${ApiConfig.siswaTugas}/$id');
    return _map(payload['data']);
  }

  Future<Map<String, dynamic>> kumpulkanTugas({
    required int tugasId,
    required String jawaban,
    Uint8List? fileBytes,
    String? fileName,
    bool hapusFile = false,
  }) async {
    final token = await _token();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.siswaTugas}/$tugasId/kumpulkan'),
    );
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    request.fields['jawaban'] = jawaban;
    if (hapusFile) request.fields['hapus_file'] = '1';
    if (fileBytes != null && fileName != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'file_jawaban',
          fileBytes,
          filename: fileName,
        ),
      );
    }

    try {
      final streamed = await request.send().timeout(ApiConfig.timeout);
      final response = await http.Response.fromStream(streamed);
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
        final errors = payload['errors'];
        final firstError = errors is Map && errors.isNotEmpty
            ? ((errors.values.first is List)
                  ? (errors.values.first as List).first.toString()
                  : errors.values.first.toString())
            : null;
        throw ApiException(
          firstError ?? payload['message']?.toString() ?? 'Pengumpulan gagal.',
          statusCode: response.statusCode,
        );
      }
      return payload;
    } on SocketException {
      throw const ApiException('Tidak dapat terhubung ke server.');
    } on TimeoutException {
      throw const ApiException('Server terlalu lama merespons.');
    } on http.ClientException {
      throw const ApiException('Koneksi pengumpulan gagal.');
    } on FormatException {
      throw const ApiException('Respons pengumpulan tidak valid.');
    }
  }

  Future<List<Map<String, dynamic>>> nilai() async {
    final payload = await _get(ApiConfig.siswaNilai);
    return _mapList(payload['data']);
  }

  Future<Map<String, dynamic>> nilaiMapel(int mapelId) async {
    final payload = await _get('${ApiConfig.siswaNilai}/mapel/$mapelId');
    return _map(payload['data']);
  }

  Future<List<Map<String, dynamic>>> jadwal({String? hari}) async {
    final uri = Uri.parse(ApiConfig.siswaJadwal).replace(
      queryParameters: {if (hari != null && hari.isNotEmpty) 'hari': hari},
    );
    final payload = await _get(uri.toString());
    return _mapList(payload['data']);
  }

  Future<Map<String, dynamic>> riwayatAbsensi({
    String? dari,
    String? sampai,
    String? status,
    int page = 1,
  }) async {
    final uri = Uri.parse(ApiConfig.siswaRiwayatAbsensi).replace(
      queryParameters: {
        if (dari != null) 'dari': dari,
        if (sampai != null) 'sampai': sampai,
        if (status != null && status != 'semua') 'status': status,
        'page': '$page',
      },
    );
    return _get(uri.toString());
  }

  Future<Map<String, dynamic>> scanQr({
    required String qrData,
    required double latitude,
    required double longitude,
    double? accuracy,
  }) async {
    final response = await http
        .post(
          Uri.parse(ApiConfig.siswaScanQr),
          headers: ApiConfig.headers(await _token()),
          body: jsonEncode({
            'qr_data': qrData,
            'latitude': latitude,
            'longitude': longitude,
            if (accuracy != null) 'accuracy': accuracy,
          }),
        )
        .timeout(ApiConfig.timeout);
    return _decodeResponse(response);
  }

  Future<List<Map<String, dynamic>>> suratIzin() async {
    final payload = await _get(ApiConfig.siswaSuratIzin);
    return _mapList(payload['data']);
  }

  static Map<String, dynamic> _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
  static List<Map<String, dynamic>> _mapList(dynamic value) => value is List
      ? value
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList()
      : <Map<String, dynamic>>[];
}

import 'package:http/http.dart' as http;

import '../models/absensi_model.dart';

class AbsensiService {
  // GANTI dengan URL API Laravel milik kalian.
  static const String baseUrl = 'https://domain-kalian.com/api';

  // Endpoint pengajuan izin/sakit
  static const String endpoint = '$baseUrl/pengajuan-izin';

  Future<http.StreamedResponse> kirimPengajuanIzin(
    PengajuanIzinModel data,
  ) async {
    final uri = Uri.parse(endpoint);

    final request = http.MultipartRequest(
      'POST',
      uri,
    );

    // Field data form
    request.fields.addAll(data.toFields());

    // Upload file
    if (data.fileBytes != null && data.fileName != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'dokumen',
          data.fileBytes!,
          filename: data.fileName!,
        ),
      );
    }

    // Kalau API Laravel kalian membutuhkan token,
    // bisa ditambahkan seperti ini:
    //
    // request.headers['Authorization'] = 'Bearer TOKEN_KALIAN';

    request.headers['Accept'] = 'application/json';

    return await request.send();
  }
}
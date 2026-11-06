import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/absensi_model.dart';
import '../utils/session.dart';

class AbsensiService {
  Future<http.StreamedResponse> kirimPengajuanIzin(
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
      request.files.add(http.MultipartFile.fromBytes(
        'dokumen',
        data.fileBytes!,
        filename: data.fileName!,
      ));
    }
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    return request.send().timeout(ApiConfig.timeout);
  }
}

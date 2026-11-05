import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/materi_model.dart';

class MateriService {
  // Ganti URL ini jika menggunakan HP fisik atau Emulator
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  MateriService();

  /// Mengambil seluruh mata pelajaran dari API Laravel
  Future<List<Map<String, dynamic>>> getDaftarMapel() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/materi/mapel'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List data = jsonResponse['data'] ?? [];
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      }
    } catch (e) {
      print('Error mengambil daftar mapel: $e');
    }
    return [];
  }

  /// Mengambil daftar materi berdasarkan mata pelajaran dari API Laravel
  Future<List<MateriModel>> getMateriByMapel(int mapelId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/materi/mapel/$mapelId'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List data = jsonResponse['data'] ?? [];
        return data.map((item) => MateriModel.fromMap(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      print('Error mengambil materi by mapel: $e');
    }
    return [];
  }

  /// Mengambil detail satu materi berdasarkan ID
  Future<MateriModel?> getMateriById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/materi/$id'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final data = jsonResponse['data'];
        if (data != null) {
          return MateriModel.fromMap(data as Map<String, dynamic>);
        }
      }
    } catch (e) {
      print('Error mengambil detail materi: $e');
    }
    return null;
  }

  /// Mencari materi berdasarkan kata kunci
  Future<List<MateriModel>> searchMateri(String keyword) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/materi/search?keyword=$keyword'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List data = jsonResponse['data'] ?? [];
        return data.map((item) => MateriModel.fromMap(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      print('Error mencari materi: $e');
    }
    return [];
  }
}
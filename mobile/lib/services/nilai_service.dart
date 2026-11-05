import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/nilai_model.dart';

class NilaiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  NilaiService();

  /// Mengambil daftar mapel nilai dari API Laravel
  Future<List<Map<String, dynamic>>> getDaftarMapelNilai() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/nilai/mapel'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List data = jsonResponse['data'] ?? [];
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      }
    } catch (e) {
      print('Error mengambil daftar mapel nilai: $e');
    }
    return [];
  }

  /// Mengambil list rincian nilai berdasarkan mapel
  Future<List<NilaiModel>> getNilaiByMapel(int mapelId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/nilai/mapel/$mapelId'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List data = jsonResponse['data'] ?? [];
        return data.map((item) => NilaiModel.fromMap(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      print('Error mengambil nilai by mapel: $e');
    }
    return [];
  }

  /// Mengambil angka rata-rata nilai berdasarkan mapel
  Future<double> getRataRataByMapel(int mapelId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/nilai/mapel/$mapelId/rata-rata'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return double.tryParse(jsonResponse['data'].toString()) ?? 0.0;
      }
    } catch (e) {
      print('Error mengambil rata-rata nilai: $e');
    }
    return 0.0;
  }
}
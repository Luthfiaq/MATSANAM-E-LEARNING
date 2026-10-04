import 'dart:typed_data';

class PengajuanIzinModel {
  final String jenisIzin;
  final DateTime tanggalMulai;
  final DateTime tanggalSelesai;
  final String keterangan;
  final Uint8List? fileBytes;
  final String? fileName;

  PengajuanIzinModel({
    required this.jenisIzin,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.keterangan,
    this.fileBytes,
    this.fileName,
  });

  Map<String, String> toFields() {
    return {
      'jenis_izin': jenisIzin,
      'tanggal_mulai': _formatDate(tanggalMulai),
      'tanggal_selesai': _formatDate(tanggalSelesai),
      'keterangan': keterangan,
    };
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}
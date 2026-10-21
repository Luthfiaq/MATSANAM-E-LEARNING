
class MateriModel {
  final int id;
  final int mapelId;
  final String mapel;
  final String judulMateri;
  final String tipeFile;
  final String? url;
  final String? filePath;
  final DateTime tanggal;
  final String deskripsi;
  final String? namaGuru;

  const MateriModel({
    required this.id,
    required this.mapelId,
    required this.mapel,
    required this.judulMateri,
    required this.tipeFile,
    this.url,
    this.filePath,
    required this.tanggal,
    required this.deskripsi,
    this.namaGuru,
  });

  /// Mengubah data model menjadi Map agar kompatibel
  /// dengan pola penyimpanan SQLite.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mapel_id': mapelId,
      'mapel': mapel,
      'judul_materi': judulMateri,
      'tipe_file': tipeFile,
      'url': url,
      'file_path': filePath,
      'tanggal': tanggal.toIso8601String(),
      'deskripsi': deskripsi,
      'nama_guru': namaGuru,
    };
  }

  /// Membentuk model dari Map hasil query database
  /// atau data mock.
  factory MateriModel.fromMap(Map<String, dynamic> map) {
    return MateriModel(
      id: _toInt(map['id']),
      mapelId: _toInt(map['mapel_id'] ?? map['mapelId']),
      mapel: (map['mapel'] ?? map['nama_mapel'] ?? '').toString(),
      judulMateri:
          (map['judul_materi'] ?? map['judulMateri'] ?? '').toString(),
      tipeFile: (map['tipe_file'] ?? map['tipeFile'] ?? 'teks').toString(),
      url: _toNullableString(map['url']),
      filePath: _toNullableString(map['file_path'] ?? map['filePath']),
      tanggal: _toDateTime(map['tanggal']),
      deskripsi: (map['deskripsi'] ?? '').toString(),
      namaGuru: _toNullableString(map['nama_guru'] ?? map['namaGuru']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String? _toNullableString(dynamic value) {
    if (value == null) return null;
    final result = value.toString().trim();
    return result.isEmpty ? null : result;
  }

  static DateTime _toDateTime(dynamic value) {
    if (value is DateTime) return value;
    return DateTime.tryParse(value?.toString() ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  MateriModel copyWith({
    int? id,
    int? mapelId,
    String? mapel,
    String? judulMateri,
    String? tipeFile,
    String? url,
    String? filePath,
    DateTime? tanggal,
    String? deskripsi,
    String? namaGuru,
  }) {
    return MateriModel(
      id: id ?? this.id,
      mapelId: mapelId ?? this.mapelId,
      mapel: mapel ?? this.mapel,
      judulMateri: judulMateri ?? this.judulMateri,
      tipeFile: tipeFile ?? this.tipeFile,
      url: url ?? this.url,
      filePath: filePath ?? this.filePath,
      tanggal: tanggal ?? this.tanggal,
      deskripsi: deskripsi ?? this.deskripsi,
      namaGuru: namaGuru ?? this.namaGuru,
    );
  }
}

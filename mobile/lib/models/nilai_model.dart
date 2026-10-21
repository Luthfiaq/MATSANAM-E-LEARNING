
class NilaiModel {
  final int id;
  final int mapelId;
  final String mapel;
  final int? penugasanId;
  final String judulPenilaian;
  final String jenisPenilaian;
  final double nilai;
  final double kkm;
  final DateTime tanggal;
  final String? namaGuru;
  final String? feedbackGuru;

  const NilaiModel({
    required this.id,
    required this.mapelId,
    required this.mapel,
    this.penugasanId,
    required this.judulPenilaian,
    required this.jenisPenilaian,
    required this.nilai,
    required this.kkm,
    required this.tanggal,
    this.namaGuru,
    this.feedbackGuru,
  });

  /// Status dihitung otomatis berdasarkan nilai dan KKM.
  bool get statusLulus => nilai >= kkm;

  String get statusLulusLabel => statusLulus ? 'Lulus' : 'Belum lulus';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mapel_id': mapelId,
      'mapel': mapel,
      'penugasan_id': penugasanId,
      'judul_penilaian': judulPenilaian,
      'jenis_penilaian': jenisPenilaian,
      'nilai': nilai,
      'kkm': kkm,
      'tanggal': tanggal.toIso8601String(),
      'nama_guru': namaGuru,
      'feedback_guru': feedbackGuru,
      'status_lulus': statusLulus ? 1 : 0,
    };
  }

  factory NilaiModel.fromMap(Map<String, dynamic> map) {
    final nilai = _toDouble(map['nilai']);
    final kkm = _toDouble(map['kkm'] ?? 75);

    return NilaiModel(
      id: _toInt(map['id']),
      mapelId: _toInt(map['mapel_id'] ?? map['mapelId']),
      mapel: (map['mapel'] ?? map['nama_mapel'] ?? '').toString(),
      penugasanId: _toNullableInt(
        map['penugasan_id'] ?? map['penugasanId'],
      ),
      judulPenilaian:
          (map['judul_penilaian'] ??
                  map['judulPenilaian'] ??
                  map['judul'] ??
                  '')
              .toString(),
      jenisPenilaian:
          (map['jenis_penilaian'] ??
                  map['jenisPenilaian'] ??
                  map['jenis'] ??
                  'tugas')
              .toString(),
      nilai: nilai,
      kkm: kkm,
      tanggal: _toDateTime(
        map['tanggal'] ?? map['tanggal_penilaian'],
      ),
      namaGuru: _toNullableString(map['nama_guru'] ?? map['namaGuru']),
      feedbackGuru: _toNullableString(
        map['feedback_guru'] ??
            map['feedbackGuru'] ??
            map['catatan'],
      ),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
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

  NilaiModel copyWith({
    int? id,
    int? mapelId,
    String? mapel,
    int? penugasanId,
    String? judulPenilaian,
    String? jenisPenilaian,
    double? nilai,
    double? kkm,
    DateTime? tanggal,
    String? namaGuru,
    String? feedbackGuru,
  }) {
    return NilaiModel(
      id: id ?? this.id,
      mapelId: mapelId ?? this.mapelId,
      mapel: mapel ?? this.mapel,
      penugasanId: penugasanId ?? this.penugasanId,
      judulPenilaian: judulPenilaian ?? this.judulPenilaian,
      jenisPenilaian: jenisPenilaian ?? this.jenisPenilaian,
      nilai: nilai ?? this.nilai,
      kkm: kkm ?? this.kkm,
      tanggal: tanggal ?? this.tanggal,
      namaGuru: namaGuru ?? this.namaGuru,
      feedbackGuru: feedbackGuru ?? this.feedbackGuru,
    );
  }
}

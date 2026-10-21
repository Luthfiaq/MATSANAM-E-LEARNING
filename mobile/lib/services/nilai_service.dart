
import '../models/nilai_model.dart';

class NilaiService {
  NilaiService();

  // KKM disamakan dengan data mapel di MateriService.
  static const double _kkmDefault = 75;

  // Dummy rekap nilai lokal/mock.
  // Nilai dan feedback di bawah hanya contoh untuk UI.
  static final List<NilaiModel> _nilai = [
    NilaiModel(
      id: 1,
      mapelId: 1,
      mapel: 'Matematika',
      penugasanId: 1,
      judulPenilaian: 'Latihan Persamaan Linear',
      jenisPenilaian: 'tugas',
      nilai: 85,
      kkm: 75,
      tanggal: DateTime(2026, 10, 8),
      namaGuru: 'Guru Matematika',
      feedbackGuru: 'Pemahaman sudah baik. Pertahankan ketelitian.',
    ),
    NilaiModel(
      id: 2,
      mapelId: 1,
      mapel: 'Matematika',
      penugasanId: 2,
      judulPenilaian: 'Kuis Bangun Datar',
      jenisPenilaian: 'quiz',
      nilai: 70,
      kkm: 75,
      tanggal: DateTime(2026, 10, 12),
      namaGuru: 'Guru Matematika',
      feedbackGuru:
          'Pelajari kembali rumus luas dan keliling bangun datar.',
    ),
    NilaiModel(
      id: 3,
      mapelId: 2,
      mapel: 'Bahasa Indonesia',
      penugasanId: 3,
      judulPenilaian: 'Tugas Teks Eksplanasi',
      jenisPenilaian: 'tugas',
      nilai: 90,
      kkm: 75,
      tanggal: DateTime(2026, 10, 10),
      namaGuru: 'Guru Bahasa Indonesia',
      feedbackGuru:
          'Struktur teks sudah runtut dan penggunaan bahasa baik.',
    ),
    NilaiModel(
      id: 4,
      mapelId: 3,
      mapel: 'Ilmu Pengetahuan Alam',
      penugasanId: 4,
      judulPenilaian: 'Kuis Sistem Pencernaan',
      jenisPenilaian: 'quiz',
      nilai: 78,
      kkm: 75,
      tanggal: DateTime(2026, 10, 13),
      namaGuru: 'Guru IPA',
      feedbackGuru:
          'Hasil sudah memenuhi KKM. Tingkatkan pemahaman fungsi organ.',
    ),
    NilaiModel(
      id: 5,
      mapelId: 4,
      mapel: 'Informatika',
      penugasanId: 5,
      judulPenilaian: 'Tugas Dasar Algoritma',
      jenisPenilaian: 'tugas',
      nilai: 95,
      kkm: 75,
      tanggal: DateTime(2026, 10, 15),
      namaGuru: 'Guru Informatika',
      feedbackGuru:
          'Algoritma disusun dengan logis dan langkah-langkah jelas.',
    ),
  ];

  /// Mengambil seluruh rekap nilai.
  Future<List<NilaiModel>> getAllNilai() async {
    return List<NilaiModel>.from(_nilai);
  }

  /// Mengambil nilai berdasarkan ID.
  Future<NilaiModel?> getNilaiById(int id) async {
    for (final item in _nilai) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  /// Mengambil rekap nilai berdasarkan ID mata pelajaran.
  Future<List<NilaiModel>> getNilaiByMapel(int mapelId) async {
    return _nilai
        .where((item) => item.mapelId == mapelId)
        .toList();
  }

  /// Mengambil daftar mapel yang mempunyai data nilai.
  /// Mapel yang belum memiliki nilai tidak ditampilkan.
  Future<List<Map<String, dynamic>>> getDaftarMapelNilai() async {
    final Map<int, Map<String, dynamic>> hasil = {};

    for (final item in _nilai) {
      hasil.putIfAbsent(item.mapelId, () {
        return {
          'id': item.mapelId,
          'nama': item.mapel,
          'jumlah_penilaian': 0,
          'rata_rata': 0.0,
          'kkm': item.kkm,
        };
      });

      hasil[item.mapelId]!['jumlah_penilaian'] =
          (hasil[item.mapelId]!['jumlah_penilaian'] as int) + 1;
    }

    for (final entry in hasil.values) {
      final mapelId = entry['id'] as int;
      final dataNilai = _nilai
          .where((item) => item.mapelId == mapelId)
          .toList();

      entry['rata_rata'] = _hitungRataRata(dataNilai);
      entry['status_lulus'] =
          (entry['rata_rata'] as double) >=
          (entry['kkm'] as double)
          ? 1
          : 0;
    }

    return hasil.values.toList();
  }

  /// Menghitung rata-rata nilai untuk satu mapel.
  Future<double> getRataRataByMapel(int mapelId) async {
    final data = await getNilaiByMapel(mapelId);
    return _hitungRataRata(data);
  }

  /// Menghitung rata-rata seluruh nilai siswa.
  Future<double> getRataRataSemuaNilai() async {
    return _hitungRataRata(_nilai);
  }

  /// Mengambil nilai yang belum mencapai KKM.
  Future<List<NilaiModel>> getNilaiDiBawahKKM() async {
    return _nilai.where((item) => !item.statusLulus).toList();
  }

  /// Mengambil nilai yang sudah mencapai KKM.
  Future<List<NilaiModel>> getNilaiLulus() async {
    return _nilai.where((item) => item.statusLulus).toList();
  }

  /// Mencari penilaian berdasarkan judul atau nama mapel.
  Future<List<NilaiModel>> searchNilai(String keyword) async {
    final query = keyword.trim().toLowerCase();

    if (query.isEmpty) {
      return getAllNilai();
    }

    return _nilai.where((item) {
      return item.judulPenilaian.toLowerCase().contains(query) ||
          item.mapel.toLowerCase().contains(query) ||
          item.jenisPenilaian.toLowerCase().contains(query);
    }).toList();
  }

  /// Menambahkan data nilai baru ke data mock di memori.
  Future<void> tambahNilai(NilaiModel nilai) async {
    final index = _nilai.indexWhere(
      (item) => item.id == nilai.id,
    );

    if (index != -1) {
      throw ArgumentError('ID nilai sudah digunakan.');
    }

    _nilai.add(nilai);
  }

  /// Memperbarui nilai yang sudah ada.
  Future<bool> updateNilai(NilaiModel nilai) async {
    final index = _nilai.indexWhere(
      (item) => item.id == nilai.id,
    );

    if (index == -1) {
      return false;
    }

    _nilai[index] = nilai;
    return true;
  }

  /// Menghapus nilai dari data mock di memori.
  Future<bool> hapusNilai(int id) async {
    final index = _nilai.indexWhere(
      (item) => item.id == id,
    );

    if (index == -1) {
      return false;
    }

    _nilai.removeAt(index);
    return true;
  }

  double _hitungRataRata(List<NilaiModel> data) {
    if (data.isEmpty) {
      return 0.0;
    }

    final total = data.fold<double>(
      0.0,
      (jumlah, item) => jumlah + item.nilai,
    );

    return total / data.length;
  }

  /// KKM default untuk mapel yang belum memiliki konfigurasi.
  double get kkmDefault => _kkmDefault;
}


import '../models/materi_model.dart';

class MateriService {
  MateriService();

  // Data mata pelajaran lokal/mock.
  // ID dan KKM diselaraskan dengan contoh pada NilaiService.
  static final List<Map<String, dynamic>> _mapel = [
    {
      'id': 1,
      'kode': 'MTK',
      'nama': 'Matematika',
      'deskripsi': 'Pembelajaran matematika',
      'kkm': 75,
    },
    {
      'id': 2,
      'kode': 'BIN',
      'nama': 'Bahasa Indonesia',
      'deskripsi': 'Pembelajaran bahasa Indonesia',
      'kkm': 75,
    },
    {
      'id': 3,
      'kode': 'IPA',
      'nama': 'Ilmu Pengetahuan Alam',
      'deskripsi': 'Pembelajaran ilmu pengetahuan alam',
      'kkm': 75,
    },
    {
      'id': 4,
      'kode': 'TIK',
      'nama': 'Informatika',
      'deskripsi': 'Pembelajaran teknologi informasi',
      'kkm': 75,
    },
  ];

  // Dummy materi. URL dan filePath hanya contoh, bukan
  // tautan atau file yang dijamin benar-benar tersedia.
  static final List<MateriModel> _materi = [
    MateriModel(
      id: 1,
      mapelId: 1,
      mapel: 'Matematika',
      judulMateri: 'Persamaan Linear',
      tipeFile: 'pdf',
      url: null,
      filePath: 'assets/mock/materi/persamaan_linear.pdf',
      tanggal: DateTime(2026, 10, 1),
      deskripsi:
          'Pengenalan persamaan linear, variabel, dan cara '
          'menyelesaikan persamaan sederhana.',
      namaGuru: 'Guru Matematika',
    ),
    MateriModel(
      id: 2,
      mapelId: 1,
      mapel: 'Matematika',
      judulMateri: 'Bangun Datar',
      tipeFile: 'teks',
      url: null,
      filePath: null,
      tanggal: DateTime(2026, 10, 5),
      deskripsi:
          'Ringkasan jenis bangun datar beserta sifat dan '
          'rumus luas serta kelilingnya.',
      namaGuru: 'Guru Matematika',
    ),
    MateriModel(
      id: 3,
      mapelId: 2,
      mapel: 'Bahasa Indonesia',
      judulMateri: 'Teks Eksplanasi',
      tipeFile: 'pdf',
      url: null,
      filePath: 'assets/mock/materi/teks_eksplanasi.pdf',
      tanggal: DateTime(2026, 10, 3),
      deskripsi:
          'Materi struktur teks eksplanasi, ciri kebahasaan, '
          'dan contoh penyusunan teks.',
      namaGuru: 'Guru Bahasa Indonesia',
    ),
    MateriModel(
      id: 4,
      mapelId: 3,
      mapel: 'Ilmu Pengetahuan Alam',
      judulMateri: 'Sistem Pencernaan',
      tipeFile: 'video',
      url: 'https://example.com/mock/sistem-pencernaan',
      filePath: null,
      tanggal: DateTime(2026, 10, 7),
      deskripsi:
          'Pengenalan organ pencernaan dan proses pencernaan '
          'makanan pada manusia.',
      namaGuru: 'Guru IPA',
    ),
    MateriModel(
      id: 5,
      mapelId: 4,
      mapel: 'Informatika',
      judulMateri: 'Dasar Algoritma',
      tipeFile: 'teks',
      url: null,
      filePath: null,
      tanggal: DateTime(2026, 10, 9),
      deskripsi:
          'Pengantar algoritma, urutan instruksi, dan '
          'pseudocode untuk menyelesaikan masalah.',
      namaGuru: 'Guru Informatika',
    ),
  ];

  /// Mengambil seluruh mata pelajaran.
  Future<List<Map<String, dynamic>>> getDaftarMapel() async {
    return _mapel
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  /// Mengambil satu mata pelajaran berdasarkan ID.
  Future<Map<String, dynamic>?> getMapelById(int mapelId) async {
    for (final item in _mapel) {
      if (item['id'] == mapelId) {
        return Map<String, dynamic>.from(item);
      }
    }
    return null;
  }

  /// Mengambil semua materi.
  Future<List<MateriModel>> getAllMateri() async {
    return List<MateriModel>.from(_materi);
  }

  /// Mengambil daftar materi berdasarkan mata pelajaran.
  Future<List<MateriModel>> getMateriByMapel(int mapelId) async {
    return _materi
        .where((item) => item.mapelId == mapelId)
        .toList();
  }

  /// Mengambil detail satu materi.
  Future<MateriModel?> getMateriById(int id) async {
    for (final item in _materi) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  /// Mencari materi berdasarkan judul atau deskripsi.
  Future<List<MateriModel>> searchMateri(String keyword) async {
    final query = keyword.trim().toLowerCase();

    if (query.isEmpty) {
      return getAllMateri();
    }

    return _materi.where((item) {
      return item.judulMateri.toLowerCase().contains(query) ||
          item.mapel.toLowerCase().contains(query) ||
          item.deskripsi.toLowerCase().contains(query);
    }).toList();
  }

  /// Menambahkan materi baru ke data mock di memori.
  /// Perubahan tidak disimpan permanen ke perangkat.
  Future<void> tambahMateri(MateriModel materi) async {
    final index = _materi.indexWhere(
      (item) => item.id == materi.id,
    );

    if (index != -1) {
      throw ArgumentError('ID materi sudah digunakan.');
    }

    _materi.add(materi);
  }

  /// Memperbarui materi yang sudah ada.
  Future<bool> updateMateri(MateriModel materi) async {
    final index = _materi.indexWhere(
      (item) => item.id == materi.id,
    );

    if (index == -1) {
      return false;
    }

    _materi[index] = materi;
    return true;
  }

  /// Menghapus materi dari data mock di memori.
  Future<bool> hapusMateri(int id) async {
    final index = _materi.indexWhere(
      (item) => item.id == id,
    );

    if (index == -1) {
      return false;
    }

    _materi.removeAt(index);
    return true;
  }
}

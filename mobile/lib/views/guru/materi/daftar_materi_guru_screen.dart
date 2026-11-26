import 'package:flutter/material.dart';
import 'tambah_materi_guru_screen.dart';
import 'edit_materi_guru_screen.dart';

class DaftarMateriGuruScreen extends StatefulWidget {
  final String mapel;
  final String kelas;
  final String semester;
  final String kurikulum;
  final int totalSiswa;

  const DaftarMateriGuruScreen({
    super.key,
    this.mapel = 'Matematika',
    this.kelas = 'Kelas 9A & 9B',
    this.semester = 'Semester Ganjil\n2026/2027',
    this.kurikulum = 'Kurikulum\nMerdeka',
    this.totalSiswa = 64,
  });

  @override
  State<DaftarMateriGuruScreen> createState() =>
      _DaftarMateriGuruScreenState();
}

class _DaftarMateriGuruScreenState extends State<DaftarMateriGuruScreen> {
  final Color primary = const Color(0xFF0B4BC9);

  final TextEditingController searchController = TextEditingController();

  String searchQuery = '';

  // Key tambahan (opsional): 'bab', 'kelas', 'time', 'files', 'format'.
  // Kalau data dari Tambah/Edit belum punya key itu, otomatis pakai default.
  final List<Map<String, String>> materials = [
    {
      'bab': 'Bab 1',
      'kelas': 'Kelas 9A, 9B',
      'title': 'Trigonometri Dasar & Sudut Istimewa',
      'type': 'PDF',
      'date': '20 Sep 2026',
      'time': '08:30 WIB',
      'files': '3',
      'format': 'PDF, MP4, PPTX',
    },
    {
      'bab': 'Bab 2',
      'kelas': 'Kelas 9A, 9B',
      'title': 'Persamaan Linear Dua Variabel (SPLDV)',
      'type': 'PDF',
      'date': '12 Sep 2026',
      'time': '09:15 WIB',
      'files': '2',
      'format': 'PDF, XLSX',
    },
    {
      'bab': 'Bab 3',
      'kelas': 'Kelas 9A, 9B',
      'title': 'Teorema Pythagoras & Geometri Ruang',
      'type': 'PDF',
      'date': '01 Sep 2026',
      'time': '10:00 WIB',
      'files': '4',
      'format': 'PDF, PPTX, MP4, DOCX',
    },
    {
      'bab': 'Bab 4',
      'kelas': 'Kelas 9A, 9B',
      'title': 'Statistika & Penyajian Data Frekuensi',
      'type': 'PDF',
      'date': '24 Agu 2026',
      'time': '07:45 WIB',
      'files': '2',
      'format': 'PDF, XLSX',
    },
  ];

  // Ikon kartu (berulang sesuai urutan)
  static const List<IconData> _icons = [
    Icons.square_foot,
    Icons.calculate_outlined,
    Icons.architecture,
    Icons.bar_chart_rounded,
  ];

  // ===== Warna (mode terang = persis desain Figma) =====
  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  Color get background =>
      isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC);

  Color get cardColor => isDark ? const Color(0xFF1F2937) : Colors.white;

  Color get textColor =>
      isDark ? const Color(0xFFF1F5F9) : const Color(0xFF111827);

  Color get greyText =>
      isDark ? const Color(0xFF9CA3AF) : const Color(0xFF64748B);

  Color get hintColor =>
      isDark ? const Color(0xFF9CA3AF) : const Color(0xFF94A3B8);

  Color get infoBoxColor =>
      isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC);

  Color get blueSoft =>
      isDark ? const Color(0xFF263A60) : const Color(0xFFEFF6FF);

  Color get redSoft =>
      isDark ? const Color(0xFF4B2226) : const Color(0xFFFEE2E2);

  static const Color redIcon = Color(0xFFDC2626);

  List<Map<String, String>> get filteredMaterials {
    final q = searchQuery.toLowerCase();
    return materials.where((material) {
      return (material['title'] ?? '').toLowerCase().contains(q) ||
          (material['bab'] ?? '').toLowerCase().contains(q);
    }).toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> showMaterialForm({
    Map<String, String>? material,
    int? index,
  }) async {
    if (material == null) {
      final hasil = await Navigator.push<Map<String, String>>(
        context,
        MaterialPageRoute(
          builder: (_) => const TambahMateriGuruScreen(),
        ),
      );
      if (hasil == null || !mounted) return;
      setState(() => materials.insert(0, hasil));
      showMessage('Materi berhasil ditambahkan');
      return;
    }

    final hasilEdit = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (_) => EditMateriGuruScreen(material: material),
      ),
    );
    if (hasilEdit == null || !mounted) return;
    if (index != null) {
      setState(() => materials[index] = hasilEdit);
    }
    showMessage('Materi berhasil diperbarui');
  }

  Future<void> deleteMaterial(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        title: Text(
          'Hapus Materi?',
          style: TextStyle(color: textColor),
        ),
        content: Text(
          'Materi "${materials[index]['title']}" akan dihapus.',
          style: TextStyle(color: greyText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() {
        materials.removeAt(index);
      });
      showMessage('Materi berhasil dihapus');
    }
  }

  // ===================== BUILD =====================

  @override
  Widget build(BuildContext context) {
    final list = filteredMaterials;

    return Scaffold(
      backgroundColor: background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 16),
              _buildTambahButton(),
              const SizedBox(height: 16),
              _buildSearch(),
              const SizedBox(height: 16),
              if (list.isEmpty)
                _buildEmptyState()
              else
                ...list.map((material) {
                  final index = materials.indexOf(material);
                  return _buildMaterialCard(material, index);
                }),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      leading: IconButton(
        onPressed: () => Navigator.maybePop(context),
        icon: Icon(Icons.arrow_back, color: textColor),
      ),
      title: Text(
        'Detail Mapel',
        style: TextStyle(
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.notifications_none_rounded,
                color: textColor,
                size: 24,
              ),
            ),
            Positioned(
              top: 11,
              right: 11,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16, left: 4),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.18),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Watermark Σ
          Positioned(
            right: 14,
            top: 4,
            child: Text(
              'Σ',
              style: TextStyle(
                fontSize: 84,
                height: 1,
                fontWeight: FontWeight.w300,
                color: Colors.white.withOpacity(0.15),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _headerChip(widget.semester, withDot: true),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: _headerChip(widget.kurikulum),
                    ),
                    const SizedBox(width: 20),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  widget.mapel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.groups_2,
                      color: Colors.white70,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '${widget.kelas} • Total ${widget.totalSiswa} Siswa',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerChip(String text, {bool withDot = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          if (withDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFF4ADE80),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                height: 1.25,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTambahButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () => showMaterialForm(),
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        icon: const Icon(Icons.add_circle_outline, size: 22),
        label: const Text(
          'Tambah Materi Baru',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        onChanged: (value) {
          setState(() => searchQuery = value);
        },
        style: TextStyle(color: textColor, fontSize: 14),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
          hintText: 'Cari bab, topik, atau kata kunci materi...',
          hintStyle: TextStyle(color: hintColor, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: hintColor, size: 22),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    searchController.clear();
                    setState(() => searchQuery = '');
                  },
                  icon: Icon(Icons.close, color: hintColor, size: 20),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildMaterialCard(
    Map<String, String> material,
    int index,
  ) {
    // Nilai dengan fallback supaya data dari Tambah/Edit tetap tampil
    final bab = material['bab'] ?? 'Bab ${index + 1}';
    final kelas = material['kelas'] ?? 'Kelas 9A, 9B';
    final title = material['title'] ?? '';
    final date = material['date'] ?? '';
    final time = material['time'];
    final tanggal = time == null || time.isEmpty ? date : '$date • $time';
    final files = material['files'] ?? '1';
    final format = material['format'] ?? material['type'] ?? 'PDF';
    final icon = _icons[(index < 0 ? 0 : index) % _icons.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== Baris atas: ikon + chip/judul + badge Aktif =====
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: blueSoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _smallChip(
                          bab,
                          const Color(0xFFD1FAE5),
                          const Color(0xFF065F46),
                        ),
                        const SizedBox(width: 6),
                        _smallChip(
                          kelas,
                          const Color(0xFFE0E7FF),
                          const Color(0xFF3730A3),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        height: 1.4,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Aktif',
                  style: TextStyle(
                    color: Color(0xFF166534),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ===== Kotak info =====
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: infoBoxColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.schedule, size: 15, color: hintColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Dipublikasikan $tanggal',
                        style: TextStyle(color: greyText, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.attach_file, size: 15, color: hintColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          style: TextStyle(color: greyText, fontSize: 12),
                          children: [
                            TextSpan(text: '$files Berkas '),
                            TextSpan(
                              text: '($format)',
                              style: TextStyle(color: textColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ===== Tombol Edit & Hapus =====
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: () => showMaterialForm(
                      material: material,
                      index: index,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blueSoft,
                      foregroundColor: primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              SizedBox(
                width: 40,
                height: 40,
                child: ElevatedButton(
                  onPressed: () => deleteMaterial(index),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: redSoft,
                    foregroundColor: redIcon,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Icon(Icons.delete_outline, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _smallChip(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.menu_book_outlined, size: 42, color: hintColor),
          const SizedBox(height: 12),
          Text(
            'Materi tidak ditemukan',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Coba gunakan kata kunci lainnya.',
            style: TextStyle(color: greyText, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
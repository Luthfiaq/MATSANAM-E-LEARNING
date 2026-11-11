import 'package:flutter/material.dart';
import 'tambah_materi_guru_screen.dart';
import 'edit_materi_guru_screen.dart';

class DaftarMateriGuruScreen extends StatefulWidget {
  final String mapel;
  final String kelas;

  const DaftarMateriGuruScreen({
    super.key,
    this.mapel = 'Matematika',
    this.kelas = 'Kelas 9A',
  });

  @override
  State<DaftarMateriGuruScreen> createState() =>
      _DaftarMateriGuruScreenState();
}

class _DaftarMateriGuruScreenState
    extends State<DaftarMateriGuruScreen> {
  final Color primary = const Color(0xFF0349C9);

  final TextEditingController searchController =
      TextEditingController();

  String searchQuery = '';

  final List<Map<String, String>> materials = [
    {
      'title': 'Persamaan Kuadrat',
      'description':
          'Mengenal bentuk umum dan penyelesaian persamaan kuadrat.',
      'type': 'PDF',
      'date': '04 November 2026',
    },
    {
      'title': 'Rumus Bangun Ruang',
      'description':
          'Materi tentang volume dan luas permukaan bangun ruang.',
      'type': 'Dokumen',
      'date': '02 November 2026',
    },
    {
      'title': 'Latihan Soal Matematika',
      'description':
          'Kumpulan latihan soal untuk persiapan evaluasi.',
      'type': 'PDF',
      'date': '30 Oktober 2026',
    },
  ];

  bool get isDark =>
      Theme.of(context).brightness == Brightness.dark;

  Color get background =>
      isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC);

  Color get cardColor =>
      isDark ? const Color(0xFF1F2937) : Colors.white;

  Color get textColor =>
      isDark ? const Color(0xFFF1F5F9) : const Color(0xFF172033);

  Color get secondaryColor =>
      isDark ? const Color(0xFF9CA3AF) : const Color(0xFF94A3B8);

  Color get borderColor =>
      isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB);

  List<Map<String, String>> get filteredMaterials {
    return materials.where((material) {
      return material['title']!
          .toLowerCase()
          .contains(searchQuery.toLowerCase());
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
        if (material == null)
        
         {
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
    return;
    final titleController = TextEditingController(
      text: material?['title'] ?? '',
    );

    final descriptionController = TextEditingController(
      text: material?['description'] ?? '',
    );

    String selectedType = material?['type'] ?? 'PDF';

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: cardColor,
              title: Text(
                material == null ? 'Tambah Materi' : 'Edit Materi',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      style: TextStyle(color: textColor),
                      decoration: const InputDecoration(
                        labelText: 'Judul Materi',
                        prefixIcon: Icon(Icons.menu_book_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      style: TextStyle(color: textColor),
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi Materi',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Jenis Materi',
                        border: OutlineInputBorder(),
                      ),
                      items: ['PDF', 'Dokumen', 'Video', 'Link']
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedType = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(dialogContext),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) {
                      return;
                    }

                    Navigator.pop(dialogContext, {
                      'title': titleController.text.trim(),
                      'description':
                          descriptionController.text.trim(),
                      'type': selectedType,
                      'date': material?['date'] ??
                          '04 November 2026',
                    });
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    descriptionController.dispose();

    if (result == null || !mounted) return;

    setState(() {
      if (index == null) {
        materials.insert(0, result);
      } else {
        materials[index] = result;
      }
    });

    showMessage(
      index == null
          ? 'Materi berhasil ditambahkan'
          : 'Materi berhasil diperbarui',
    );
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
          style: TextStyle(color: secondaryColor),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: Icon(Icons.arrow_back, color: textColor),
        ),
        title: Text(
          'Daftar Materi',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showMaterialForm(),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Materi'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildClassInfo(),
                    const SizedBox(height: 20),
                    _buildSearch(),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Materi Pembelajaran',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${filteredMaterials.length} Materi',
                          style: TextStyle(
                            color: primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (filteredMaterials.isEmpty)
                      _buildEmptyState()
                    else
                      ...filteredMaterials.map((material) {
                        final index = materials.indexOf(material);
                        return _buildMaterialCard(material, index);
                      }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.school_outlined,
            color: Colors.white,
            size: 27,
          ),
          const SizedBox(height: 12),
          const Text(
            'MATA PELAJARAN',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.mapel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            widget.kelas,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: TextField(
        controller: searchController,
        onChanged: (value) {
          setState(() => searchQuery = value);
        },
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Cari materi...',
          hintStyle: TextStyle(color: secondaryColor),
          prefixIcon: Icon(Icons.search, color: secondaryColor),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    searchController.clear();
                    setState(() => searchQuery = '');
                  },
                  icon: Icon(Icons.close, color: secondaryColor),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF263A60)
                      : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  color: primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material['title']!,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${material['type']} • ${material['date']}',
                      style: TextStyle(
                        color: secondaryColor,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: secondaryColor,
                ),
                onSelected: (value) {
                  if (value == 'edit') {
                    showMaterialForm(
                      material: material,
                      index: index,
                    );
                  } else if (value == 'delete') {
                    deleteMaterial(index);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 19),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 19,
                        ),
                        SizedBox(width: 8),
                        Text('Hapus'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            material['description']!,
            style: TextStyle(
              color: secondaryColor,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Divider(color: borderColor),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: secondaryColor,
              ),
              const SizedBox(width: 6),
              Text(
                'Diterbitkan ${material['date']}',
                style: TextStyle(
                  color: secondaryColor,
                  fontSize: 10,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 15,
              ),
              const SizedBox(width: 4),
              const Text(
                'Terbit',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Icon(
            Icons.menu_book_outlined,
            size: 42,
            color: secondaryColor,
          ),
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
            style: TextStyle(
              color: secondaryColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

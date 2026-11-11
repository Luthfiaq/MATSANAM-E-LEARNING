import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import 'daftar_tugas_guru_screen.dart';

class PilihMapelKelasTugasGuruScreen extends StatefulWidget {
  const PilihMapelKelasTugasGuruScreen({super.key});

  @override
  State<PilihMapelKelasTugasGuruScreen> createState() =>
      _PilihMapelKelasTugasGuruScreenState();
}

class _PilihMapelKelasTugasGuruScreenState
    extends State<PilihMapelKelasTugasGuruScreen> {
  final TextEditingController searchController = TextEditingController();

  String selectedFilter = 'Semua';
  String searchQuery = '';

  final Color primary = AppColors.primary;

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  Color get pageBackground =>
      isDark ? const Color(0xFF111827) : AppColors.background;

  Color get cardBackground =>
      isDark ? const Color(0xFF1F2937) : AppColors.surface;

  Color get primaryText =>
      isDark ? const Color(0xFFF1F5F9) : AppColors.textPrimary;

  Color get secondaryText =>
      isDark ? const Color(0xFF9CA3AF) : AppColors.textSecondary;

  Color get borderColor =>
      isDark ? const Color(0xFF374151) : const Color(0xFFF0F2F5);

  Color get softBackground =>
      isDark ? const Color(0xFF273449) : const Color(0xFFF5F7FF);

  Color get searchBackground =>
      isDark ? const Color(0xFF273449) : const Color(0xFFF1F5F9);

  Color get chipBackground =>
      isDark ? const Color(0xFF273449) : Colors.white;

  Color get academicBackground =>
      isDark ? const Color(0xFF252F49) : Colors.white;

  Color get iconBackground =>
      isDark ? const Color(0xFF273449) : AppColors.primaryLight;

  final List<Map<String, dynamic>> subjects = [
    {
      'name': 'Matematika',
      'status': 'Wajib',
      'classes': ['Kelas 9A', 'Kelas 9B', 'Kelas 9C'],
      'students': 94,
      'tasks': 8,
      'icon': Icons.square_foot_rounded,
      'color': const Color(0xFF405CEB),
      'light': const Color(0xFFDDE4FF),
      'badge': const Color(0xFFE8F0FF),
    },
    {
      'name': 'IPA Terpadu',
      'status': 'Lab Aktif',
      'classes': ['Kelas 8A', 'Kelas 8B'],
      'students': 64,
      'tasks': 5,
      'icon': Icons.biotech_outlined,
      'color': const Color(0xFF059669),
      'light': const Color(0xFFCFF7E6),
      'badge': const Color(0xFF86EFC5),
    },
    {
      'name': 'Informatika',
      'status': 'Praktikum',
      'classes': ['Kelas 7B', 'Kelas 8C'],
      'students': 62,
      'tasks': 7,
      'icon': Icons.terminal_rounded,
      'color': const Color(0xFFB45309),
      'light': const Color(0xFFFFD8CB),
      'badge': const Color(0xFFFFD9CC),
    },
    {
      'name': 'Bahasa Indonesia',
      'status': 'Wajib',
      'classes': ['Kelas 7A', 'Kelas 7B', 'Kelas 7C'],
      'students': 96,
      'tasks': 4,
      'icon': Icons.menu_book_rounded,
      'color': const Color(0xFF2454E8),
      'light': const Color(0xFFDDE4FF),
      'badge': const Color(0xFFE8F0FF),
    },
    {
      'name': 'IPS',
      'status': 'Wajib',
      'classes': ['Kelas 8A', 'Kelas 9A'],
      'students': 60,
      'tasks': 6,
      'icon': Icons.public_rounded,
      'color': const Color(0xFF7C3AED),
      'light': const Color(0xFFE9D5FF),
      'badge': const Color(0xFFF3E8FF),
    },
  ];

  final List<String> filters = ['Semua', 'Kelas 7', 'Kelas 8', 'Kelas 9'];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredSubjects {
    return subjects.where((subject) {
      final name = subject['name'].toString().toLowerCase();
      final classes =
          (subject['classes'] as List<String>).join(' ').toLowerCase();
      final query = searchQuery.toLowerCase();

      final matchesSearch = name.contains(query) || classes.contains(query);

      final matchesClass = selectedFilter == 'Semua' ||
          (subject['classes'] as List<String>)
              .any((kelas) => kelas.contains(selectedFilter));

      return matchesSearch && matchesClass;
    }).toList();
  }

  // Contoh: ['Kelas 9A','Kelas 9B'] -> "Kelas 9A, 9B"
  // Contoh beda tingkat: ['Kelas 7B','Kelas 8C'] -> "Kelas 7B & 8C"
  String formatClasses(List<String> classes) {
    final short = classes.map((k) => k.replaceFirst('Kelas ', '')).toList();
    final grades = short.map((k) => k.substring(0, 1)).toSet();
    final separator = grades.length > 1 ? ' & ' : ', ';
    return 'Kelas ${short.join(separator)}';
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            isDark ? const Color(0xFF374151) : const Color(0xFF172033),
      ),
    );
  }

  void showClassOptions(Map<String, dynamic> subject) {
    final classes = subject['classes'] as List<String>;

    showModalBottomSheet(
      context: context,
      backgroundColor: cardBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: secondaryText,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  subject['name'],
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Pilih kelas yang ingin dibuka',
                  style: TextStyle(color: secondaryText),
                ),
                const SizedBox(height: 16),
                ...classes.map(
                  (kelas) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: iconBackground,
                      child: Icon(Icons.school_outlined, color: primary),
                    ),
                    title: Text(
                      kelas,
                      style: TextStyle(
                        color: primaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: Icon(Icons.chevron_right, color: secondaryText),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DaftarTugasGuruScreen(
                            mapel: subject['name'],
                            kelas: kelas,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: pageBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryText),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          'Pilih Mapel Tugas',
          style: TextStyle(
            color: primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => showMessage('Belum ada notifikasi baru'),
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.notifications_none_rounded, color: primaryText),
                Positioned(
                  right: 1,
                  top: 1,
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
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.pushNamed(context, '/pengaturan'),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTeacherCard(),
                  const SizedBox(height: 14),
                  _buildFilters(),
                  const SizedBox(height: 18),
                  _buildSectionHeader(),
                  const SizedBox(height: 12),
                  if (filteredSubjects.isEmpty)
                    _buildEmptyState()
                  else
                    ...filteredSubjects.map(
                      (subject) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildSubjectCard(subject),
                      ),
                    ),
                  const SizedBox(height: 6),
                  _buildAcademicInfo(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Kartu guru + kolom pencarian (satu kartu, sesuai desain)
  Widget _buildTeacherCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Thumbnail guru (placeholder; ganti Image.asset jika ada fotonya)
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.person_rounded, color: primary, size: 30),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF064E3B)
                            : const Color(0xFF86EFC5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.circle,
                            size: 7,
                            color: Color(0xFF059669),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Aktif Mengajar',
                            style: TextStyle(
                              color: isDark
                                  ? const Color(0xFFA7F3D0)
                                  : const Color(0xFF065F46),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Pak Imam Kholik, S.Pd',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: primaryText,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => showMessage('Filter lanjutan belum tersedia'),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF30365A)
                        : const Color(0xFFE8EAFE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.tune_rounded, color: primary, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSearch(),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: searchBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: secondaryText, size: 21),
          const SizedBox(width: 9),
          Expanded(
            child: TextField(
              controller: searchController,
              onChanged: (value) => setState(() => searchQuery = value),
              style: TextStyle(color: primaryText, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Cari mata pelajaran atau kelas...',
                hintStyle: TextStyle(color: secondaryText, fontSize: 13),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                searchController.clear();
                setState(() => searchQuery = '');
              },
              child: Icon(Icons.close, size: 18, color: secondaryText),
            ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final selected = selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                filter == 'Semua' ? 'Semua (${subjects.length})' : filter,
                style: TextStyle(
                  color: selected ? Colors.white : primaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              selected: selected,
              showCheckmark: false,
              onSelected: (_) => setState(() => selectedFilter = filter),
              backgroundColor: chipBackground,
              selectedColor: primary,
              side: BorderSide(color: selected ? primary : borderColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Daftar Mata Pelajaran',
            style: TextStyle(
              color: primaryText,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF273449) : const Color(0xFFE8ECF4),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '${filteredSubjects.length} Mapel',
            style: TextStyle(
              color: secondaryText,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectCard(Map<String, dynamic> subject) {
    final Color color = subject['color'];
    final Color light = subject['light'];
    final Color accent = isDark ? Color.lerp(color, Colors.white, 0.3)! : color;
    final classes = subject['classes'] as List<String>;

    return Material(
      color: cardBackground,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor),
      ),
      child: InkWell(
        onTap: () => showClassOptions(subject),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: light,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(subject['icon'], color: color, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Text(
                              subject['name'],
                              style: TextStyle(
                                color: primaryText,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? color.withOpacity(0.18)
                                    : subject['badge'],
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                subject['status'],
                                style: TextStyle(
                                  color: accent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        Row(
                          children: [
                            Icon(
                              Icons.groups_rounded,
                              color: secondaryText,
                              size: 16,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                '${formatClasses(classes)} \u2022 ${subject['students']} Siswa',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: secondaryText,
                                  fontSize: 11.5,
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
            ),
            // Footer: jumlah tugas + "Buka Tugas"
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              color: softBackground,
              child: Row(
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    color: secondaryText,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${subject['tasks']} Tugas Aktif & Terjadwal',
                      style: TextStyle(
                        color: secondaryText,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    'Buka Tugas',
                    style: TextStyle(
                      color: primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Icon(Icons.arrow_forward, color: primary, size: 15),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 38, color: secondaryText),
          const SizedBox(height: 10),
          Text(
            'Mata pelajaran tidak ditemukan',
            style: TextStyle(
              color: primaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Coba kata kunci atau filter kelas lainnya.',
            style: TextStyle(color: secondaryText, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicInfo() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: academicBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF064E3B)
                  : const Color(0xFFD1FAE5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_outlined,
              color: Color(0xFF059669),
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TAHUN AJARAN & KURIKULUM',
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.circle,
                      color: Color(0xFF047857),
                      size: 8,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'T.A 2026/2027 Ganjil \u2022 Kurikulum Merdeka',
                        style: TextStyle(
                          color: primaryText,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => showMessage('T.A 2026/2027 Ganjil \u2022 Kurikulum Merdeka'),
            child: Icon(Icons.info_outline, color: secondaryText, size: 18),
          ),
        ],
      ),
    );
  }
}
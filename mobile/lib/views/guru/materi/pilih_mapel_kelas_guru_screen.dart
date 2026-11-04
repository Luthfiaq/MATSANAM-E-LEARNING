import 'package:flutter/material.dart';
import 'daftar_materi_guru_screen.dart';

class PilihMapelKelasGuruScreen extends StatefulWidget {
  const PilihMapelKelasGuruScreen({super.key});

  @override
  State<PilihMapelKelasGuruScreen> createState() =>
      _PilihMapelKelasGuruScreenState();
}

class _PilihMapelKelasGuruScreenState
    extends State<PilihMapelKelasGuruScreen> {
  final TextEditingController searchController = TextEditingController();

  String selectedFilter = 'Semua';
  String searchQuery = '';

  final Color primary = const Color(0xFF0349C9);

  bool get isDark =>
      Theme.of(context).brightness == Brightness.dark;

  Color get pageBackground =>
      isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC);

  Color get cardBackground =>
      isDark ? const Color(0xFF1F2937) : Colors.white;

  Color get primaryText =>
      isDark ? const Color(0xFFF1F5F9) : const Color(0xFF172033);

  Color get secondaryText =>
      isDark ? const Color(0xFF9CA3AF) : const Color(0xFF94A3B8);

  Color get borderColor =>
      isDark ? const Color(0xFF374151) : const Color(0xFFF0F2F5);

  Color get softBackground =>
      isDark ? const Color(0xFF273449) : const Color(0xFFF7F8FD);

  Color get searchBackground =>
      isDark ? const Color(0xFF1F2937) : Colors.white;

  Color get chipBackground =>
      isDark ? const Color(0xFF273449) : Colors.white;

  Color get academicBackground =>
      isDark ? const Color(0xFF252F49) : const Color(0xFFF0F2FF);

  Color get iconBackground =>
      isDark ? const Color(0xFF273449) : const Color(0xFFEFF6FF);

  final List<Map<String, dynamic>> subjects = [
    {
      'name': 'Matematika',
      'status': 'Wajib',
      'classes': ['Kelas 9A', 'Kelas 9B', 'Kelas 9C'],
      'students': 94,
      'materials': 8,
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
      'materials': 6,
      'icon': Icons.biotech_outlined,
      'color': const Color(0xFF059669),
      'light': const Color(0xFF7CF2C5),
      'badge': const Color(0xFFD1FAE5),
    },
    {
      'name': 'Informatika',
      'status': 'Praktikum',
      'classes': ['Kelas 7B', 'Kelas 8C'],
      'students': 62,
      'materials': 10,
      'icon': Icons.terminal_rounded,
      'color': const Color(0xFFB45309),
      'light': const Color(0xFFFFD8CB),
      'badge': const Color(0xFFFFE0D5),
    },
    {
      'name': 'Bahasa Indonesia',
      'status': 'Wajib',
      'classes': ['Kelas 7A', 'Kelas 7B', 'Kelas 7C'],
      'students': 96,
      'materials': 5,
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
      'materials': 7,
      'icon': Icons.public_rounded,
      'color': const Color(0xFF7C3AED),
      'light': const Color(0xFFE9D5FF),
      'badge': const Color(0xFFF3E8FF),
    },
  ];

  final List<String> filters = [
    'Semua',
    'Kelas 7',
    'Kelas 8',
    'Kelas 9',
  ];

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

      final matchesSearch =
          name.contains(query) || classes.contains(query);

      final matchesClass = selectedFilter == 'Semua' ||
          (subject['classes'] as List<String>)
              .any((kelas) => kelas.contains(selectedFilter));

      return matchesSearch && matchesClass;
    }).toList();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark
            ? const Color(0xFF374151)
            : const Color(0xFF172033),
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
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
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
                      child: Icon(
                        Icons.school_outlined,
                        color: primary,
                      ),
                    ),
                    title: Text(
                      kelas,
                      style: TextStyle(
                        color: primaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: secondaryText,
                    ),
                    onTap: () {
  Navigator.pop(sheetContext);

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => DaftarMateriGuruScreen(
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
          icon: Icon(
            Icons.arrow_back,
            color: primaryText,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          'Materi',
          style: TextStyle(
            color: primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => showMessage('Belum ada notifikasi baru'),
            icon: Icon(
              Icons.notifications_none_rounded,
              color: primaryText,
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
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTeacherInfo(),
                  const SizedBox(height: 12),
                  _buildSearch(),
                  const SizedBox(height: 12),
                  _buildFilters(),
                  const SizedBox(height: 20),
                  _buildSectionHeader(),
                  const SizedBox(height: 12),
                  if (filteredSubjects.isEmpty)
                    _buildEmptyState()
                  else
                    ...filteredSubjects.map(
                      (subject) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _buildSubjectCard(subject),
                      ),
                    ),
                  const SizedBox(height: 10),
                  _buildAcademicInfo(),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildTeacherInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              Icons.school_outlined,
              color: primary,
              size: 25,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GURU PENGAMPU',
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.7,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Pak Imam Kholik, S.Pd',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF30365A)
                  : const Color(0xFFE8EAFE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.circle,
                  size: 8,
                  color: Color(0xFF059669),
                ),
                const SizedBox(width: 5),
                Text(
                  'Aktif Mengajar',
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
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
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: secondaryText,
            size: 21,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() => searchQuery = value);
              },
              style: TextStyle(
                color: primaryText,
                fontSize: 13,
              ),
              decoration: InputDecoration(
                hintText: 'Cari mata pelajaran atau kelas...',
                hintStyle: TextStyle(
                  color: secondaryText,
                  fontSize: 13,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (searchQuery.isNotEmpty)
            IconButton(
              onPressed: () {
                searchController.clear();
                setState(() => searchQuery = '');
              },
              icon: Icon(
                Icons.close,
                size: 18,
                color: secondaryText,
              ),
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
                filter == 'Semua' ? 'Semua (5)' : filter,
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : primaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              selected: selected,
              showCheckmark: false,
              onSelected: (_) {
                setState(() => selectedFilter = filter);
              },
              backgroundColor: chipBackground,
              selectedColor: primary,
              side: BorderSide(
                color: selected ? primary : borderColor,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 7,
                vertical: 2,
              ),
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
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF263A60)
                : const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${filteredSubjects.length} Mapel',
            style: TextStyle(
              color: isDark ? const Color(0xFF93B4FF) : primary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Tap untuk kelola',
          style: TextStyle(
            color: secondaryText,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectCard(Map<String, dynamic> subject) {
    final Color color = subject['color'];
    final Color light = subject['light'];

    return Material(
      color: cardBackground,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => showClassOptions(subject),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: light,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      subject['icon'],
                      color: color,
                      size: 26,
                    ),
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
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                subject['status'],
                                style: TextStyle(
                                  color: isDark
                                      ? Color.lerp(color, Colors.white, 0.3)
                                      : color,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 5,
                          children: [
                            Icon(
                              Icons.groups_rounded,
                              color: color,
                              size: 15,
                            ),
                            Text(
                              (subject['classes'] as List<String>).join(', '),
                              style: TextStyle(
                                color: primaryText,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '• ${subject['students']} Siswa',
                              style: TextStyle(
                                color: secondaryText,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF30365A)
                          : const Color(0xFFEEF0FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: secondaryText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Tombol Buka Materi tetap terlihat.
              // Fungsinya belum diaktifkan.
              InkWell(
                borderRadius: BorderRadius.circular(9),
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: softBackground,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.menu_book_outlined,
                        color: Color(0xFF047857),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${subject['materials']} Modul Materi Terbit',
                          style: TextStyle(
                            color: primaryText,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      Text(
                        'Buka Materi',
                        style: TextStyle(
                          color: isDark
                              ? Color.lerp(color, Colors.white, 0.3)
                              : color,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Icon(
                        Icons.arrow_forward,
                        color: isDark
                            ? Color.lerp(color, Colors.white, 0.3)
                            : color,
                        size: 15,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
          Icon(
            Icons.search_off_rounded,
            size: 38,
            color: secondaryText,
          ),
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
            style: TextStyle(
              color: secondaryText,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicInfo() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: academicBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: cardBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.verified_outlined,
              color: primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tahun Ajaran & Kurikulum',
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'T.A 2026/2027 Ganjil • Kurikulum Merdeka',
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.circle,
            color: Color(0xFF047857),
            size: 9,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: 1,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: primary,
      unselectedItemColor: secondaryText,
      selectedFontSize: 11,
      unselectedFontSize: 11,
      backgroundColor: cardBackground,
      elevation: 8,
      onTap: (index) {
        if (index == 0) {
          Navigator.pushReplacementNamed(context, '/');
        } else if (index == 4) {
          Navigator.pushNamed(context, '/pengaturan');
        } else if (index != 1) {
          showMessage('Halaman sedang disiapkan');
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.grid_view_rounded),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book_rounded),
          label: 'Materi',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_outlined),
          label: 'Tugas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.fact_check_outlined),
          label: 'Absensi',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          label: 'Profil',
        ),
      ],
    );
  }
}
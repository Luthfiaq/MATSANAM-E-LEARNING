import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../services/api_exception.dart';
import '../../../services/siswa_learning_service.dart';
import '../../../utils/constants.dart';
import '../../../widgets/common/siswa_bottom_navigation.dart';
import '../dashboard/dashboard_siswa_page.dart';
import '../materi/siswa_materi_screen.dart';
import '../nilai/siswa_nilai_screen.dart';
import '../pengaturan/profil_siswa_screen.dart';


class SiswaTugasScreen extends StatefulWidget {
  const SiswaTugasScreen({super.key});

  @override
  State<SiswaTugasScreen> createState() => _SiswaTugasScreenState();
}

class _SiswaTugasScreenState extends State<SiswaTugasScreen> {
  final _service = SiswaLearningService();
  final _search = TextEditingController();

  List<Map<String, dynamic>> _items = [];

  String _kelas = '-';
  String _semester = '-';
  String _tahunAjaran = '-';

  bool _loading = true;
  String? _error;

  String _tab = 'aktif';
  String _selectedMapel = 'Semua Mapel';

  static const Color primary = Color(0xFF1554D1);
  static const Color background = Color(0xFFF6F8FC);
  static const Color textDark = Color(0xFF17233D);
  static const Color textMuted = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  
Future<void> _load() async {
  setState(() {
    _loading = true;
    _error = null;
  });

  try {
    final response = await _service.tugasDenganMeta(
      status: 'semua',
      query: '',
    );

    if (!mounted) return;

    final items = List<Map<String, dynamic>>.from(
      response['data'] ?? [],
    );

    final meta = response['meta'] is Map
        ? Map<String, dynamic>.from(response['meta'])
        : <String, dynamic>{};

    setState(() {
      _items = items;

      _kelas = (meta['kelas'] ??
              (items.isNotEmpty ? items.first['kelas'] : null) ??
              '-')
          .toString();

      _semester = (meta['semester'] ?? '-').toString();
      _tahunAjaran = (meta['tahun_ajaran'] ?? '-').toString();

      _loading = false;
    });
  } on ApiException catch (e) {
    if (!mounted) return;

    setState(() {
      _error = e.message;
      _loading = false;
    });
  } catch (e) {
    if (!mounted) return;

    setState(() {
      _error = 'Terjadi kesalahan saat memuat tugas.';
      _loading = false;
    });
  }
}

  List<String> get _mapelList {
    final names = _items
        .map((e) => (e['mapel'] ?? '').toString())
        .where((e) => e.isNotEmpty && e != '-')
        .toSet()
        .toList()
      ..sort();

    return ['Semua Mapel', ...names];
  }

  List<Map<String, dynamic>> get _filteredItems {
    final keyword = _search.text.trim().toLowerCase();

    return _items.where((item) {
      final status = (item['status'] ?? '').toString();

      final matchesTab = switch (_tab) {
        'aktif' =>
          status == 'belum_dikumpulkan' ||
          status == 'melewati_deadline',
        'menunggu' =>
          status == 'sudah_dikumpulkan' ||
          status == 'terlambat',
        'selesai' => status == 'sudah_dinilai',
        _ => true,
      };

      final mapel = (item['mapel'] ?? '').toString();
      final matchesMapel =
          _selectedMapel == 'Semua Mapel' ||
          mapel == _selectedMapel;

      final judul = (item['judul'] ?? '').toString().toLowerCase();
      final matchesSearch =
          keyword.isEmpty ||
          judul.contains(keyword) ||
          mapel.toLowerCase().contains(keyword);

      return matchesTab && matchesMapel && matchesSearch;
    }).toList();
  }

  int _countTab(String tab) {
    return _items.where((item) {
      final status = (item['status'] ?? '').toString();

      return switch (tab) {
        'aktif' =>
          status == 'belum_dikumpulkan' ||
          status == 'melewati_deadline',
        'menunggu' =>
          status == 'sudah_dikumpulkan' ||
          status == 'terlambat',
        'selesai' => status == 'sudah_dinilai',
        _ => false,
      };
    }).length;
  }

  Color _mapelColor(String mapel) {
    final value = mapel.toLowerCase();

    if (value.contains('matematika')) {
      return const Color(0xFF1554D1);
    }
    if (value.contains('ipa') || value.contains('sains')) {
      return const Color(0xFF00875A);
    }
    if (value.contains('inggris')) {
      return const Color(0xFF008F83);
    }
    if (value.contains('indonesia')) {
      return const Color(0xFFB7791F);
    }
    if (value.contains('ips')) {
    return const Color(0xFF7C3AED);
    }
    if (value.contains('pkn')) {
    return const Color(0xFFDC2626);
    }
    if (value.contains('pjok')) {
    return const Color.fromARGB(146, 30, 30, 29);
    }
    if (value.contains('jawa')) {
    return const Color(0xFF0891B2);
    }
    if (value.contains('seni')) {
    return const Color(0xFFDB2777);
    }
    if (value.contains('fiqih')) {
    return const Color(0xFF64748B);
    }
    if (value.contains('quran') || value.contains('hadist')) {
    return const Color(0xFF059669);
    }
    if (value.contains('arab')) {
    return const Color(0xFF0D9488);
    }
    if (value.contains('aqidah') || value.contains('akhlak')) {
    return const Color(0xFF9333EA);
    }
    if (value.contains('ski')) {
    return const Color(0xFF92400E);
    }
    if (value.contains('informatika')) {
    return const Color(0xFF2563EB);
    }

    return const Color(0xFF7952B8);
  }

  IconData _mapelIcon(String mapel) {
    final value = mapel.toLowerCase();

    if (value.contains('matematika')) {
      return Icons.calculate_rounded;
    }
    if (value.contains('Ilmu Pengetahuan Alam')) {
      return Icons.biotech_rounded;
    }
    if (value.contains('inggris') || value.contains('bahasa') || value.contains('jawa')) {
      return Icons.translate_rounded;
    }
    if (value.contains('Ilmu Pengetahuan Sosial')) {
      return Icons.public_rounded;
    }
    if (value.contains('pkn')) {
      return Icons.account_balance_rounded;
    }
    if (value.contains('pjok')) {
      return Icons.sports_baseball;
    }
    if (value.contains('seni')) {
      return Icons.palette_rounded;
    }
    if (value.contains('fiqih')) {
      return Icons.menu_book_rounded;
    }
    if (value.contains('quran') || value.contains('arab')) {
      return Icons.auto_stories_rounded;
    }
    if (value.contains('aqidah')) {
      return Icons.volunteer_activism_rounded;
    }
    if (value.contains('ski')) {
      return Icons.history_edu_rounded;
    }
    if (value.contains('informatika')) {
      return Icons.computer_rounded;
    }

    return Icons.menu_book_rounded;
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value.toString())?.toLocal();
  }

  String _formatDate(dynamic value) {
    final date = _parseDate(value);

    if (date == null) return 'Waktu belum tersedia';

    return DateFormat(
      'dd MMM yyyy, HH:mm',
      'id_ID',
    ).format(date);
  }

  // Warna deadline:
  // Hari ini = merah
  // Besok = kuning
  // 2 hari atau lebih = biru
  Map<String, dynamic> _deadlineInfo(dynamic value) {
    final deadline = _parseDate(value);

    if (deadline == null) {
      return {
        'label': 'Deadline belum tersedia',
        'color': Colors.grey,
        'icon': Icons.circle,
      };
    }

    final today = DateUtils.dateOnly(DateTime.now());
    final deadlineDay = DateUtils.dateOnly(deadline);

    final difference = deadlineDay.difference(today).inDays;

    if (deadline.isBefore(DateTime.now())) {
      return {
        'label': 'Terlambat',
        'color': const Color(0xFFDC2626),
        'icon': Icons.circle,
      };
    }

    if (difference == 0) {
      return {
        'label': 'Sisa Hari Ini',
        'color': const Color(0xFFDC2626),
        'icon': Icons.circle,
      };
    }

    if (difference == 1) {
      return {
        'label': 'Sisa 1 Hari',
        'color': const Color(0xFFF59E0B),
        'icon': Icons.circle,
      };
    }

    return {
      'label': 'Sisa $difference Hari',
      'color': const Color(0xFF2563EB),
      'icon': Icons.circle,
    };
  }

  String _statusLabel(String status) {
    return switch (status) {
      'belum_dikumpulkan' => 'Belum Dikumpulkan',
      'melewati_deadline' => 'Melewati Deadline',
      'sudah_dikumpulkan' => 'Menunggu Penilaian',
      'terlambat' => 'Dikumpulkan Terlambat',
      'sudah_dinilai' => 'Sudah Dinilai',
      _ => 'Tugas',
    };
  }

  void _openDetail(Map<String, dynamic> item) {
    final id = item['id'];

    if (id is! num) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SiswaTugasDetailScreen(
          tugasId: id.toInt(),
        ),
      ),
    ).then((_) => _load());
  }

  void _tabNavigation(int index) {
    final Widget page = switch (index) {
      0 => const DashboardSiswaPage(),
      1 => const SiswaMateriScreen(),
      2 => const SiswaTugasScreen(),
      3 => const SiswaNilaiScreen(),
      _ => const ProfilSiswaScreen(),
    };

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => page),
    );
  }


Color _deadlineColor(DateTime? deadline) {
  if (deadline == null) return Colors.grey;

  final now = DateTime.now();
  final today = DateUtils.dateOnly(now);
  final deadlineDay = DateUtils.dateOnly(deadline);
  final difference = deadlineDay.difference(today).inDays;

  if (deadline.isBefore(now)) {
    return const Color(0xFFDC2626);
  }

  if (difference == 0) {
    return const Color(0xFFDC2626);
  }

  if (difference == 1) {
    return const Color(0xFFF59E0B);
  }

  return const Color(0xFF2563EB);
}

String _deadlineLabel(DateTime? deadline) {
  if (deadline == null) return 'Deadline belum tersedia';

  final now = DateTime.now();

  if (deadline.isBefore(now)) {
    return 'Deadline Terlewati';
  }

  final remaining = deadline.difference(now);

  if (remaining.inHours < 1) {
    return 'Sisa ${remaining.inMinutes} Menit';
  }

  if (remaining.inHours < 24) {
    return 'Sisa ${remaining.inHours} Jam';
  }

  final days = DateUtils.dateOnly(deadline)
      .difference(DateUtils.dateOnly(now))
      .inDays;

  return days == 1 ? 'Sisa 1 Hari' : 'Sisa $days Hari';
}

  @override
  Widget build(BuildContext context) {
    final tugasAktif = _items.where((e) {
      final status = e['status'];
      return status == 'belum_dikumpulkan' ||
          status == 'melewati_deadline';
    }).length;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Matsanam Siswa',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF8A9AB5),
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 3),
            Text(
              'Siswa: Daftar Tugas',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: textDark,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF475569),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: primary,
              child: const Icon(
                Icons.person_outline_rounded,
                color: Colors.white,
                size: 21,
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.cloud_off_outlined,
                                size: 45,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 12),
                              Text(_error!),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _load,
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(
                            16, 16, 16, 24,
                          ),
                          children: [
                            // Ringkasan tugas
                            Container(
                              padding: const EdgeInsets.all(17),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFE0E7F0),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: .03),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Tugas Siswa',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                            color: textDark,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Text(
                                              'Kelas $_kelas',
                                              style: const TextStyle(
                                                color: primary,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '• Semester $_semester $_tahunAjaran',
                                              style: const TextStyle(
                                                color: textMuted,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 13),
                                        Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFF7E8),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            '$tugasAktif Tugas Perlu Diselesaikan',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFFB7791F),
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEDF3FF),
                                      borderRadius: BorderRadius.circular(13),
                                    ),
                                    child: const Icon(
                                      Icons.assignment_turned_in_outlined,
                                      color: primary,
                                      size: 24,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Tab status
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF1FA),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                children: [
                                  _statusTab('aktif', 'Tugas Aktif'),
                                  _statusTab('menunggu', 'Menunggu'),
                                  _statusTab('selesai', 'Selesai'),
                                ],
                              ),
                            ),

                            const SizedBox(height: 15),

                            // Pencarian
                            TextField(
                              controller: _search,
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                hintText: 'Cari nama tugas atau materi...',
                                hintStyle: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF94A3B8),
                                ),
                                prefixIcon: const Icon(
                                  Icons.search_rounded,
                                  color: Color(0xFF8A9AB5),
                                  size: 21,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFDCE4EF),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFDCE4EF),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: primary,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Filter mata pelajaran
                            SizedBox(
                              height: 38,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: _mapelList.map((mapel) {
                                  final selected =
                                      _selectedMapel == mapel;

                                  return Padding(
                                    padding: const EdgeInsets.only(right: 7),
                                    child: ChoiceChip(
                                      label: Text(
                                        mapel,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: selected
                                              ? Colors.white
                                              : const Color(0xFF475569),
                                        ),
                                      ),
                                      selected: selected,
                                      showCheckmark: false,
                                      backgroundColor: Colors.white,
                                      selectedColor: primary,
                                      side: BorderSide(
                                        color: selected
                                            ? primary
                                            : const Color(0xFFDCE4EF),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      onSelected: (_) {
                                        setState(() {
                                          _selectedMapel = mapel;
                                        });
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),

                            const SizedBox(height: 13),

                            // Daftar card tugas
                            if (_filteredItems.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(30),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Column(
                                  children: [
                                    Icon(
                                      Icons.assignment_outlined,
                                      size: 45,
                                      color: Color(0xFF94A3B8),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'Tidak ada tugas',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: textDark,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      'Belum ada tugas yang sesuai.',
                                      style: TextStyle(
                                        color: textMuted,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              ..._filteredItems.map(_taskCard),

                            const SizedBox(height: 16),

                            // Tips belajar
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF4FF),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFD6E3FF),
                                ),
                              ),
                              child: const Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 17,
                                    backgroundColor: Color(0xFFD9E7FF),
                                    child: Icon(
                                      Icons.lightbulb_outline_rounded,
                                      color: primary,
                                      size: 19,
                                    ),
                                  ),
                                  SizedBox(width: 11),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Tips Belajar',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13,
                                            color: textDark,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          'Jangan menunda pengumpulan tugas agar terhindar dari pemotongan nilai keterlambatan otomatis oleh sistem madrasah.',
                                          style: TextStyle(
                                            fontSize: 12,
                                            height: 1.5,
                                            color: Color(0xFF475569),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
          ),
        ],
      ),

      bottomNavigationBar: SiswaBottomNavigationBar(
        currentIndex: 2,
        onTap: _tabNavigation,
      ),
    );
  }

  Widget _statusTab(String value, String label) {
    final selected = _tab == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _tab = value;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 3),
          decoration: BoxDecoration(
            color: selected ? primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : const Color(0xFF475569),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(alpha: .20)
                      : const Color(0xFFDCE4F5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_countTab(value)}',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  
Widget _taskCard(Map<String, dynamic> item) {
  final mapel = (item['mapel'] ?? '-').toString();
  final guru = (item['guru'] ?? 'Guru').toString();
  final judul = (item['judul'] ?? '-').toString();
  final status = (item['status'] ?? '').toString();

  final color = _mapelColor(mapel);
  final deadline = _deadlineInfo(item['deadline']);

  final bobot = item['bobot'] ?? 0;
  final jenis = (item['jenis'] ?? 'Tugas').toString();
  final deskripsi = (item['deskripsi'] ?? '').toString();

  final isBelum = status == 'belum_dikumpulkan' ||
      status == 'melewati_deadline';

  final isSubmitted = status == 'sudah_dikumpulkan' ||
      status == 'terlambat';

  return Container(
    margin: const EdgeInsets.only(bottom: 14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: const Color(0xFFDCE4EF)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .035),
          blurRadius: 7,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      children: [
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: deadline['color'] as Color,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(15),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(15, 13, 15, 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          _mapelIcon(mapel),
                          color: color,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            mapel,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: color,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            '•',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            guru,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: (deadline['color'] as Color)
                          .withValues(alpha: .10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          deadline['icon'] as IconData,
                          size: 11,
                          color: deadline['color'] as Color,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          deadline['label'].toString(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: deadline['color'] as Color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Text(
                judul,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),

              const SizedBox(height: 5),

              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 13,
                    color: deadline['color'] as Color,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Batas pengumpulan: ${_formatDate(item['deadline'])}',
                      style: TextStyle(
                        fontSize: 11,
                        color: deadline['color'] as Color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Wrap(
                spacing: 7,
                runSpacing: 6,
                children: [
                  _infoChip(
                    Icons.emoji_events_outlined,
                    'Bobot: $bobot Poin',
                  ),
                  _infoChip(
                    Icons.person_outline_rounded,
                    jenis,
                  ),
                ],
              ),

              if (deskripsi.isNotEmpty) ...[
                const SizedBox(height: 9),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F3FF),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    deskripsi,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.5,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 11),

              SizedBox(
                width: double.infinity,
                height: 39,
                child: OutlinedButton.icon(
                  onPressed: () => _openDetail(item),
                  icon: Icon(
                    isBelum
                        ? (deadline['label'] == 'Sisa Hari Ini' ||
                              deadline['label'] == 'Sisa 1 Hari'
                            ? Icons.rocket_launch_rounded
                            : Icons.edit_note_outlined)
                        : Icons.visibility_outlined,
                    size: 17,
                    color: isBelum ? Colors.white : primary,
                  ),
                  label: Text(
                    isBelum
                        ? (deadline['label'] == 'Terlambat'
                            ? 'Lihat Detail Tugas'
                            : 'Kumpulkan Tugas Sekarang')
                        : isSubmitted
                            ? 'Lihat Pengumpulan Tugas'
                            : 'Detail Tugas',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isBelum ? Colors.white : textDark,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor:
                        isBelum ? primary : Colors.white,
                    side: BorderSide(
                      color: isBelum
                          ? primary
                          : const Color(0xFFDCE4EF),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF1FF),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }
}


class SiswaTugasDetailScreen extends StatefulWidget {
  final int tugasId;
  const SiswaTugasDetailScreen({super.key, required this.tugasId});
  @override
  State<SiswaTugasDetailScreen> createState() => _SiswaTugasDetailScreenState();
}

class _SiswaTugasDetailScreenState extends State<SiswaTugasDetailScreen> {
  final _service = SiswaLearningService();
  final _answer = TextEditingController();
  Map<String, dynamic> _data = {};
  PlatformFile? _file;
  bool _loading = true, _sending = false, _removeExistingFile = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _answer.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final data = await _service.detailTugas(widget.tugasId);
      if (!mounted) return;
      final submission = data['pengumpulan'] is Map
          ? Map<String, dynamic>.from(data['pengumpulan'])
          : <String, dynamic>{};
      setState(() {
        _data = data;
        _answer.text = (submission['jawaban'] ?? '').toString();
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (mounted)
        setState(() {
          _error = e.toString();
          _loading = false;
        });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const [
        'pdf',
        'doc',
        'docx',
        'xls',
        'xlsx',
        'ppt',
        'pptx',
        'jpg',
        'jpeg',
        'png',
        'txt',
        'zip',
      ],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final selected = result.files.single;
    if (selected.bytes == null) {
      _snack('File tidak dapat dibaca.', error: true);
      return;
    }
    if (selected.size > 10 * 1024 * 1024) {
      _snack('Ukuran file maksimal 10 MB.', error: true);
      return;
    }
    setState(() {
      _file = selected;
      _removeExistingFile = false;
    });
  }

  Future<void> _downloadLampiran(String? url, String fileName) async {
    if (url == null || url.isEmpty) return;
    try {
      final bytes = await _service.downloadAuthorizedFile(url);
      await FilePicker.platform.saveFile(
        dialogTitle: 'Simpan lampiran tugas',
        fileName: fileName,
        bytes: bytes,
      );
      if (mounted) _snack('Lampiran siap disimpan.');
    } catch (e) {
      if (mounted) _snack('Gagal mengunduh lampiran: $e', error: true);
    }
  }

  Future<void> _submit() async {
    final submission = _data['pengumpulan'] is Map
        ? Map<String, dynamic>.from(_data['pengumpulan'])
        : <String, dynamic>{};
    final hasExistingFile =
        submission['file_url'] != null && !_removeExistingFile;
    if (_answer.text.trim().isEmpty && _file == null && !hasExistingFile) {
      _snack('Isi jawaban atau lampirkan berkas terlebih dahulu.', error: true);
      return;
    }
    setState(() => _sending = true);
    try {
      await _service.kumpulkanTugas(
        tugasId: widget.tugasId,
        jawaban: _answer.text.trim(),
        fileBytes: _file?.bytes,
        fileName: _file?.name,
        hapusFile: _removeExistingFile,
      );
      if (!mounted) return;
      _snack('Pengumpulan tugas berhasil disimpan.');
      await _load();
      setState(() {
        _file = null;
        _removeExistingFile = false;
      });
    } catch (e) {
      if (mounted) _snack(e.toString(), error: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  bool _deadlineHariIni(dynamic value) {
  if (value == null) return false;

  final deadline = DateTime.tryParse(value.toString());
  if (deadline == null) return false;

  final today = DateUtils.dateOnly(DateTime.now());
  final deadlineDay = DateUtils.dateOnly(deadline);

  return deadlineDay == today &&
      !deadline.isBefore(DateTime.now());
}

Color _deadlineColor(DateTime? deadline) {
  if (deadline == null) return Colors.grey;

  final now = DateTime.now();
  final today = DateUtils.dateOnly(now);
  final deadlineDay = DateUtils.dateOnly(deadline);
  final difference = deadlineDay.difference(today).inDays;

  if (deadline.isBefore(now)) {
    return const Color(0xFFDC2626);
  }

  if (difference == 0) {
    return const Color(0xFFDC2626);
  }

  if (difference == 1) {
    return const Color(0xFFF59E0B);
  }

  return const Color(0xFF2563EB);
}

String _deadlineLabel(DateTime? deadline) {
  if (deadline == null) return 'Deadline belum tersedia';

  final now = DateTime.now();

  if (deadline.isBefore(now)) {
    return 'Deadline Terlewati';
  }

  final remaining = deadline.difference(now);

  if (remaining.inHours < 1) {
    return 'Sisa ${remaining.inMinutes} Menit';
  }

  if (remaining.inHours < 24) {
    return 'Sisa ${remaining.inHours} Jam';
  }

  final days = DateUtils.dateOnly(deadline)
      .difference(DateUtils.dateOnly(now))
      .inDays;

  return days == 1 ? 'Sisa 1 Hari' : 'Sisa $days Hari';
}

  void _snack(String message, {bool error = false}) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: error ? AppColors.error : AppColors.success,
        ),
      );


@override
Widget build(BuildContext context) {
  final submission = _data['pengumpulan'] is Map
      ? Map<String, dynamic>.from(_data['pengumpulan'])
      : <String, dynamic>{};

  final nilai = submission['nilai'] is Map
      ? Map<String, dynamic>.from(submission['nilai'])
      : null;

  final status = (_data['status'] ?? '').toString();
  final locked = nilai != null;

  final deadline = DateTime.tryParse(
    _data['deadline']?.toString() ?? '',
  )?.toLocal();

  final deadlineColor = _deadlineColor(deadline);
  final deadlineLabel = _deadlineLabel(deadline);

  final daysLeft = deadline == null
      ? 999
      : DateUtils.dateOnly(deadline)
          .difference(DateUtils.dateOnly(DateTime.now()))
          .inDays;

  final urgent = deadline != null &&
      !deadline.isBefore(DateTime.now()) &&
      daysLeft <= 1;

  final mapel = (_data['mapel'] ?? '-').toString();
  final kelas = (_data['kelas'] ?? '-').toString();
  final guru = (_data['guru'] ?? '-').toString();
  final judul = (_data['judul'] ?? '-').toString();

  return Scaffold(
    backgroundColor: const Color(0xFFF6F8FC),
    appBar: AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_rounded),
        color: const Color(0xFF17233D),
      ),
      title: const Text(
        'Detail Tugas',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: Color(0xFF17233D),
        ),
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 16),
          child: CircleAvatar(
            radius: 17,
            backgroundColor: Color(0xFF1554D1),
            child: Icon(
              Icons.person_outline_rounded,
              color: Colors.white,
              size: 19,
            ),
          ),
        ),
      ],
    ),

    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(_error!),
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                      children: [
                        // INFORMASI TUGAS
                        _Card(
                          child: Padding(
                            padding: const EdgeInsets.all(17),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 9,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEDF3FF),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Text(
                                        (_data['jenis'] ?? 'TUGAS')
                                            .toString()
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF1554D1),
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: deadlineColor.withValues(
                                          alpha: .12,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.access_time_rounded,
                                            size: 12,
                                            color: deadlineColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            deadlineLabel,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              color: deadlineColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 13),

                                Text(
                                  judul,
                                  style: const TextStyle(
                                    fontSize: 21,
                                    height: 1.3,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF17233D),
                                  ),
                                ),

                                const SizedBox(height: 7),

                                Text(
                                  '$mapel • $kelas',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  'Guru: $guru',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                ),

                                const SizedBox(height: 14),

                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0F3FF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _detailInfo(
                                          'Batas Waktu',
                                          deadline == null
                                              ? '-'
                                              : DateFormat(
                                                  'dd MMM, HH:mm',
                                                  'id_ID',
                                                ).format(deadline),
                                          valueColor: deadlineColor,
                                        ),
                                      ),
                                      Expanded(
                                        child: _detailInfo(
                                          'Bobot Nilai',
                                          '${_data['bobot'] ?? '-'} Poin',
                                        ),
                                      ),
                                      Expanded(
                                        child: _detailInfo(
                                          'Status',
                                          _statusLabel(status),
                                          valueColor: _statusColor(status),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // INSTRUKSI TUGAS
                        _Card(
                          child: Padding(
                            padding: const EdgeInsets.all(17),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.menu_book_rounded,
                                      color: Color(0xFF1554D1),
                                      size: 19,
                                    ),
                                    SizedBox(width: 7),
                                    Text(
                                      'Instruksi Tugas',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF17233D),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  (_data['deskripsi'] ??
                                          'Tidak ada instruksi tambahan.')
                                      .toString(),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    height: 1.6,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // LAMPIRAN DARI GURU
                        if (_data['ada_lampiran'] == true) ...[
                          const SizedBox(height: 14),
                          _Card(
                            child: Padding(
                              padding: const EdgeInsets.all(17),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.attach_file_rounded,
                                        color: Color(0xFF1554D1),
                                        size: 19,
                                      ),
                                      SizedBox(width: 7),
                                      Text(
                                        'Berkas Lampiran Soal',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF17233D),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0F3FF),
                                      borderRadius: BorderRadius.circular(9),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.picture_as_pdf_rounded,
                                          size: 32,
                                          color: Color(0xFFDC2626),
                                        ),
                                        const SizedBox(width: 10),
                                        const Expanded(
                                          child: Text(
                                            'Lampiran dari Guru',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF17233D),
                                            ),
                                          ),
                                        ),
                                        TextButton.icon(
                                          onPressed: () =>
                                              _downloadLampiran(
                                            _data['lampiran_url']?.toString(),
                                            'lampiran-tugas-${widget.tugasId}',
                                          ),
                                          icon: const Icon(
                                            Icons.download_rounded,
                                            size: 15,
                                          ),
                                          label: const Text('Unduh'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 14),

                        // UNGGAH JAWABAN
                        _Card(
                          child: Padding(
                            padding: const EdgeInsets.all(17),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.upload_file_rounded,
                                      color: Color(0xFF1554D1),
                                      size: 19,
                                    ),
                                    const SizedBox(width: 7),
                                    const Expanded(
                                      child: Text(
                                        'Unggah Lembar Jawaban',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF17233D),
                                        ),
                                      ),
                                    ),
                                    if (_file != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 7,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDDF8EB),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: const Text(
                                          '1 Berkas Siap',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF00875A),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),

                                const SizedBox(height: 13),

                                if (submission['file_name'] != null &&
                                    !_removeExistingFile)
                                  Container(
                                    padding: const EdgeInsets.all(9),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0F3FF),
                                      borderRadius: BorderRadius.circular(9),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.insert_drive_file_rounded,
                                          color: Color(0xFF00875A),
                                          size: 27,
                                        ),
                                        const SizedBox(width: 9),
                                        Expanded(
                                          child: Text(
                                            submission['file_name'].toString(),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () => _downloadLampiran(
                                            submission['file_url']?.toString(),
                                            submission['file_name'].toString(),
                                          ),
                                          icon: const Icon(
                                            Icons.download_rounded,
                                            color: Color(0xFF1554D1),
                                          ),
                                        ),
                                        if (!locked)
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _removeExistingFile = true;
                                              });
                                            },
                                            icon: const Icon(
                                              Icons.close_rounded,
                                              color: Color(0xFF94A3B8),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),

                                if (_file != null) ...[
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0F3FF),
                                      borderRadius: BorderRadius.circular(9),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.check_circle_rounded,
                                          color: Color(0xFF00875A),
                                          size: 27,
                                        ),
                                        const SizedBox(width: 9),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _file!.name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              Text(
                                                '${(_file!.size / 1024 / 1024).toStringAsFixed(2)} MB',
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Color(0xFF94A3B8),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (!locked)
                                          IconButton(
                                            onPressed: () {
                                              setState(() => _file = null);
                                            },
                                            icon: const Icon(
                                              Icons.close_rounded,
                                              color: Color(0xFF94A3B8),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],

                                if (!locked)
                                  InkWell(
                                    onTap: _pickFile,
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 23,
                                        horizontal: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF0F3FF),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: const Color(0xFFE0E7FF),
                                        ),
                                      ),
                                      child: const Column(
                                        children: [
                                          Icon(
                                            Icons.add_photo_alternate_outlined,
                                            color: Color(0xFF1554D1),
                                            size: 25,
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            'Ketuk untuk Ganti atau Tambah Berkas',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF17233D),
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            'PDF, DOC, DOCX, JPG, PNG dan lainnya (Maks. 10 MB)',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Color(0xFF94A3B8),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                const SizedBox(height: 15),

                                const Text(
                                  'Catatan Tambahan Siswa (Opsional)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                                const SizedBox(height: 7),

                                TextField(
                                  controller: _answer,
                                  maxLines: 3,
                                  enabled: !locked,
                                  decoration: InputDecoration(
                                    hintText:
                                        'Tuliskan catatan untuk guru jika ada...',
                                    hintStyle: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF94A3B8),
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF0F3FF),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(9),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.all(12),
                                  ),
                                ),

                                if (nilai != null) ...[
                                  const SizedBox(height: 18),
                                  const Divider(),
                                  Text(
                                    'Nilai: ${nilai['nilai']}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF00875A),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'Feedback Guru: ${nilai['catatan'] ?? 'Belum ada feedback.'}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],

                                if (locked) ...[
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Pengumpulan dikunci karena Guru sudah memberikan nilai.',
                                    style: TextStyle(
                                      color: Color(0xFF00875A),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // TOMBOL KUMPULKAN
                  if (!locked)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                      color: const Color(0xFFF6F8FC),
                      child: SizedBox(
                        height: 52,
                        child: FilledButton.icon(
                          onPressed: _sending ? null : _submit,
                          icon: _sending
                              ? const SizedBox(
                                  width: 17,
                                  height: 17,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(
                                  urgent
                                      ? Icons.rocket_launch_rounded
                                      : Icons.send_rounded,
                                  size: 19,
                                ),
                          label: Text(
                            _sending
                                ? 'Mengirim Pengumpulan...'
                                : 'Kumpulkan Tugas Sekarang',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
  );
}

  Widget _info(String label, String value) => Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Row(
      children: [
        SizedBox(
          width: 145,
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );

Widget _detailInfo(
  String label,
  String value, {
  Color valueColor = const Color(0xFF17233D),
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          color: Color(0xFF94A3B8),
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        value,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 10,
          color: valueColor,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );
}

  String _date(dynamic value) {
    final d = DateTime.tryParse(value?.toString() ?? '');
    return d == null
        ? '-'
        : DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(d.toLocal());
  }

  String _statusLabel(String status) => switch (status) {
    'sudah_dinilai' => 'Sudah Dinilai',
    'sudah_dikumpulkan' => 'Sudah Dikumpulkan',
    'terlambat' => 'Dikumpulkan Terlambat',
    'melewati_deadline' => 'Deadline Terlewati',
    _ => 'Belum Dikumpulkan',
  };
  Color _statusColor(String status) => status == 'sudah_dinilai'
      ? AppColors.success
      : (status == 'terlambat' || status == 'melewati_deadline')
      ? AppColors.error
      : status == 'sudah_dikumpulkan'
      ? AppColors.primary
      : AppColors.warning;
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: Theme.of(context).dividerColor.withValues(alpha: .5),
      ),
    ),
    child: child,
  );
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge({required this.text, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .10),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      text,
      style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 11),
    ),
  );
}

class _Empty extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? action;
  const _Empty({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 42, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          if (action != null)
            TextButton(onPressed: action, child: const Text('Coba Lagi')),
        ],
      ),
    ),
  );
}

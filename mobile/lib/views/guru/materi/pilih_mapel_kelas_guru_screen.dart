import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/api_config.dart';
import '../../../utils/constants.dart';
import '../../../widgets/common/guru_bottom_navigation.dart';

class PilihMapelKelasGuruScreen extends StatefulWidget {
  const PilihMapelKelasGuruScreen({super.key});

  @override
  State<PilihMapelKelasGuruScreen> createState() =>
      _PilihMapelKelasGuruScreenState();
}

class _PilihMapelKelasGuruScreenState extends State<PilihMapelKelasGuruScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _schedules = [];
  List<Map<String, dynamic>> _materials = [];
  bool _isLoading = true;
  String _query = '';
  String _selectedClass = 'Semua';

  static const _filters = ['Semua', 'Kelas 7', 'Kelas 8', 'Kelas 9'];
  static const _palette = <Color>[
    Color(0xFF405CEB),
    Color(0xFF059669),
    Color(0xFFB45309),
    Color(0xFF7C3AED),
    Color(0xFF0F766E),
  ];
  static const _icons = <IconData>[
    Icons.menu_book_rounded,
    Icons.biotech_outlined,
    Icons.computer_rounded,
    Icons.public_rounded,
    Icons.calculate_outlined,
  ];

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _background => _isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC);
  Color get _surface => _isDark ? const Color(0xFF1F2937) : Colors.white;
  Color get _primaryText => _isDark ? const Color(0xFFF1F5F9) : const Color(0xFF172033);
  Color get _secondaryText => _isDark ? const Color(0xFF9CA3AF) : const Color(0xFF64748B);
  Color get _border => _isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (mounted) setState(() => _query = _searchController.text.trim());
    });
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) {
        throw Exception('Sesi login tidak ditemukan. Silakan login kembali.');
      }
      final headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      final responses = await Future.wait([
        http.get(Uri.parse(ApiConfig.guruMapelKelas), headers: headers)
            .timeout(ApiConfig.timeout),
        http.get(Uri.parse(ApiConfig.guruMateri), headers: headers)
            .timeout(ApiConfig.timeout),
      ]);
      for (final response in responses) {
        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw Exception('Gagal memuat data materi (HTTP ${response.statusCode}).');
        }
      }
      final scheduleJson = jsonDecode(responses[0].body);
      final materialJson = jsonDecode(responses[1].body);
      if (scheduleJson is! Map || scheduleJson['success'] != true ||
          materialJson is! Map || materialJson['success'] != true) {
        throw Exception('Respons API jadwal atau materi tidak sesuai format.');
      }
      final schedules = (scheduleJson['data'] as List? ?? [])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      final materials = (materialJson['data'] as List? ?? [])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      if (!mounted) return;
      setState(() {
        _schedules = schedules;
        _materials = materials;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Coba Lagi',
            textColor: Colors.white,
            onPressed: _loadData,
          ),
        ),
      );
    }
  }

  String _prettyClass(String raw) {
    final cleaned = raw.trim().replaceFirst(RegExp(r'^Kelas\s+', caseSensitive: false), '');
    final match = RegExp(r'^(VII|VIII|IX)\s*([A-Z])$', caseSensitive: false)
        .firstMatch(cleaned);
    if (match == null) return raw.startsWith('Kelas') ? raw : 'Kelas $raw';
    const levels = {'VII': '7', 'VIII': '8', 'IX': '9'};
    return 'Kelas ${levels[match.group(1)!.toUpperCase()] ?? ''}${match.group(2)!.toUpperCase()}';
  }

  int _classLevel(String raw) {
    final match = RegExp(r'Kelas\s*(7|8|9)', caseSensitive: false).firstMatch(_prettyClass(raw));
    return int.tryParse(match?.group(1) ?? '') ?? 0;
  }

  List<Map<String, dynamic>> get _filteredSchedules => _schedules.where((schedule) {
        final subject = (schedule['mata_pelajaran'] ?? 'Mata Pelajaran').toString();
        final rawClass = (schedule['kelas'] ?? '').toString();
        final displayClass = _prettyClass(rawClass);
        final matchesQuery = '$subject $displayClass'.toLowerCase().contains(_query.toLowerCase());
        final level = _selectedClass == 'Semua' ? 0 : int.tryParse(_selectedClass.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        final matchesClass = level == 0 || _classLevel(rawClass) == level;
        return matchesQuery && matchesClass;
      }).toList();

  Map<String, List<Map<String, dynamic>>> get _groupedSchedules {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final schedule in _filteredSchedules) {
      final subject = (schedule['mata_pelajaran'] ?? 'Mata Pelajaran').toString();
      grouped.putIfAbsent(subject, () => []).add(schedule);
    }
    return grouped;
  }

  int _materialCountFor(List<Map<String, dynamic>> schedules) {
    final ids = schedules.map((item) => item['id'].toString()).toSet();
    return _materials.where((material) {
      final scheduleId = material['jadwal_id']?.toString() ??
          (material['jadwal'] is Map ? material['jadwal']['id']?.toString() : null);
      return scheduleId != null && ids.contains(scheduleId);
    }).length;
  }

  int _studentCountFor(List<Map<String, dynamic>> schedules) => schedules.fold<int>(
        0,
        (total, schedule) => total + ((schedule['jumlah_siswa'] as num?)?.toInt() ?? 0),
      );

  void _openSchedule(Map<String, dynamic> schedule) {
    Navigator.pushNamed(
      context,
      '/guru/materi/per-mapel',
      arguments: {
        'mapel': schedule['mata_pelajaran']?.toString() ?? 'Mata Pelajaran',
        'kelas': _prettyClass(schedule['kelas']?.toString() ?? ''),
        'jadwal_id': schedule['id'],
      },
    ).then((result) {
      if (result == true && mounted) _loadData();
    });
  }

  void _chooseClass(String subject, List<Map<String, dynamic>> schedules) {
    if (schedules.length == 1) {
      _openSchedule(schedules.first);
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 18),
              Text(subject, style: TextStyle(color: _primaryText, fontSize: 19, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Pilih kelas untuk melihat dan mengelola materi.', style: TextStyle(color: _secondaryText, fontSize: 13)),
              const SizedBox(height: 12),
              ...schedules.map((schedule) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primaryLight,
                      child: Icon(Icons.groups_outlined, color: AppColors.primary),
                    ),
                    title: Text(_prettyClass(schedule['kelas']?.toString() ?? ''), style: TextStyle(color: _primaryText, fontWeight: FontWeight.w600)),
                    subtitle: Text('${schedule['hari'] ?? '-'} • ${schedule['jam_mulai'] ?? ''} - ${schedule['jam_selesai'] ?? ''}'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _openSchedule(schedule);
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupedSchedules;
    final totalStudents = _studentCountFor(_filteredSchedules);
    final totalMaterials = _materialCountFor(_filteredSchedules);
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(onPressed: () => Navigator.maybePop(context), icon: const Icon(Icons.arrow_back_ios_new_rounded)),
        title: Text('Materi', style: TextStyle(color: _primaryText, fontSize: 18, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(tooltip: 'Muat ulang', onPressed: _loadData, icon: Icon(Icons.refresh_rounded, color: _primaryText)),
          const SizedBox(width: 6),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 26),
                    children: [
                      _teacherIntro(totalStudents, totalMaterials),
                      const SizedBox(height: 14),
                      _searchBox(),
                      const SizedBox(height: 12),
                      _filterChips(),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(child: Text('Daftar Mata Pelajaran', style: TextStyle(color: _primaryText, fontSize: 16, fontWeight: FontWeight.w700))),
                          Text('${grouped.length} Mapel', style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (grouped.isEmpty) _emptyState() else ...grouped.entries.toList().asMap().entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _subjectCard(entry.value.key, entry.value.value, entry.key),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: const GuruBottomNavigation(currentIndex: 1),
    );
  }

  Widget _teacherIntro(int students, int materials) => Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: _surface, border: Border.all(color: _border), borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          Container(width: 46, height: 46, decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.school_outlined, color: AppColors.primary, size: 25)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('PENGELOLAAN MATERI GURU', style: TextStyle(color: _secondaryText, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: .6)),
            const SizedBox(height: 4),
            Text('${_schedules.length} Jadwal Mengajar', style: TextStyle(color: _primaryText, fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 3),
            Text('$students siswa • $materials materi terbit', style: TextStyle(color: _secondaryText, fontSize: 11)),
          ])),
          const Icon(Icons.verified_user_outlined, color: AppColors.success, size: 22),
        ]),
      );

  Widget _searchBox() => Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(13), border: Border.all(color: _border)),
        child: Row(children: [
          Icon(Icons.search_rounded, color: _secondaryText),
          const SizedBox(width: 9),
          Expanded(child: TextField(controller: _searchController, style: TextStyle(color: _primaryText, fontSize: 13), decoration: InputDecoration(hintText: 'Cari mata pelajaran atau kelas...', hintStyle: TextStyle(color: _secondaryText, fontSize: 13), border: InputBorder.none, isDense: true))),
          if (_query.isNotEmpty) IconButton(onPressed: _searchController.clear, icon: Icon(Icons.close, size: 18, color: _secondaryText)),
        ]),
      );

  Widget _filterChips() => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: _filters.map((filter) {
          final selected = _selectedClass == filter;
          final count = filter == 'Semua' ? _schedules.length : _schedules.where((schedule) => _classLevel(schedule['kelas']?.toString() ?? '') == int.tryParse(filter.replaceAll(RegExp(r'[^0-9]'), ''))).length;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter == 'Semua' ? 'Semua ($count)' : '$filter ($count)', style: TextStyle(color: selected ? Colors.white : _primaryText, fontSize: 12, fontWeight: FontWeight.w600)),
              selected: selected,
              showCheckmark: false,
              onSelected: (_) => setState(() => _selectedClass = filter),
              selectedColor: AppColors.primary,
              backgroundColor: _surface,
              side: BorderSide(color: selected ? AppColors.primary : _border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          );
        }).toList()),
      );

  Widget _subjectCard(String subject, List<Map<String, dynamic>> schedules, int index) {
    final color = _palette[index % _palette.length];
    final classLabels = schedules.map((schedule) => _prettyClass(schedule['kelas']?.toString() ?? '')).toSet().toList();
    final studentCount = _studentCountFor(schedules);
    final materialCount = _materialCountFor(schedules);
    return Material(
      color: _surface,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => _chooseClass(subject, schedules),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), border: Border.all(color: _border)),
          child: Column(children: [
            Row(children: [
              Container(width: 48, height: 48, decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(11)), child: Icon(_icons[index % _icons.length], color: color, size: 25)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(subject, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: _primaryText, fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 7),
                Wrap(spacing: 5, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
                  Icon(Icons.groups_rounded, color: color, size: 14),
                  Text(classLabels.join(', '), style: TextStyle(color: _primaryText, fontSize: 11, fontWeight: FontWeight.w600)),
                  Text('• $studentCount Siswa', style: TextStyle(color: _secondaryText, fontSize: 11)),
                ]),
              ])),
              Icon(Icons.chevron_right_rounded, color: _secondaryText),
            ]),
            const SizedBox(height: 12),
            InkWell(
              borderRadius: BorderRadius.circular(9),
              onTap: () => _chooseClass(subject, schedules),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
                decoration: BoxDecoration(color: _isDark ? const Color(0xFF273449) : const Color(0xFFF7F8FD), borderRadius: BorderRadius.circular(9)),
                child: Row(children: [
                  const Icon(Icons.menu_book_outlined, color: Color(0xFF047857), size: 16),
                  const SizedBox(width: 7),
                  Expanded(child: Text('$materialCount Modul Materi Terbit', style: TextStyle(color: _primaryText, fontSize: 11))),
                  const Text('Buka Materi', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_rounded, color: AppColors.primary, size: 15),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _emptyState() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: _border)),
        child: Column(children: [
          Icon(Icons.search_off_rounded, size: 38, color: _secondaryText),
          const SizedBox(height: 10),
          Text(_schedules.isEmpty ? 'Belum ada jadwal mengajar' : 'Mata pelajaran tidak ditemukan', style: TextStyle(color: _primaryText, fontWeight: FontWeight.w600)),
          const SizedBox(height: 5),
          Text(_schedules.isEmpty ? 'Jadwal kelas yang ditugaskan kepada akun Guru akan tampil di sini.' : 'Coba kata kunci atau filter kelas lainnya.', textAlign: TextAlign.center, style: TextStyle(color: _secondaryText, fontSize: 12)),
        ]),
      );
}

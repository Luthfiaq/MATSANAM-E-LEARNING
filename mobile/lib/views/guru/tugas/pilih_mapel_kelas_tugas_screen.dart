import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/api_config.dart';
import '../../../utils/constants.dart';
import '../../../widgets/common/guru_bottom_navigation.dart';

class PilihMapelKelasTugasScreen extends StatefulWidget {
  const PilihMapelKelasTugasScreen({super.key});

  @override
  State<PilihMapelKelasTugasScreen> createState() =>
      _PilihMapelKelasTugasScreenState();
}

class _PilihMapelKelasTugasScreenState
    extends State<PilihMapelKelasTugasScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _jadwal = [];
  bool _isLoading = true;
  String _query = '';
  String _selectedClass = 'Semua';

  static const _filters = ['Semua', 'Kelas 7', 'Kelas 8', 'Kelas 9'];

  @override
  void initState() {
    super.initState();
    _loadJadwal();
    _searchController.addListener(() {
      if (mounted) setState(() => _query = _searchController.text.trim());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadJadwal() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) {
        throw Exception('Sesi login tidak ditemukan. Silakan login kembali.');
      }

      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/guru/mapel-kelas'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode != 200) {
        throw Exception('Gagal memuat jadwal (HTTP ${response.statusCode}).');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map || decoded['success'] != true) {
        throw Exception(
          decoded is Map
              ? (decoded['message']?.toString() ?? 'Respons API tidak valid.')
              : 'Respons API tidak valid.',
        );
      }

      final rows = (decoded['data'] as List? ?? [])
          .whereType<Map>()
          .map((row) => Map<String, dynamic>.from(row))
          .toList();
      if (!mounted) return;
      setState(() {
        _jadwal = rows;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  String _prettyClass(String raw) {
    final match = RegExp(
      r'^(VII|VIII|IX)\s*([A-Z])$',
      caseSensitive: false,
    ).firstMatch(raw.trim());
    if (match == null) return raw.startsWith('Kelas') ? raw : 'Kelas $raw';
    const levels = {'VII': '7', 'VIII': '8', 'IX': '9'};
    return 'Kelas ${levels[match.group(1)!.toUpperCase()] ?? ''}${match.group(2)!.toUpperCase()}';
  }

  List<Map<String, dynamic>> get _filteredRows {
    return _jadwal.where((item) {
      final mapel = item['mata_pelajaran']?.toString() ?? '';
      final kelas = _prettyClass(item['kelas']?.toString() ?? '');
      final matchesQuery = '$mapel $kelas'.toLowerCase().contains(
        _query.toLowerCase(),
      );
      final matchesClass =
          _selectedClass == 'Semua' || kelas.startsWith(_selectedClass);
      return matchesQuery && matchesClass;
    }).toList();
  }

  Map<String, List<Map<String, dynamic>>> get _groupedRows {
    final result = <String, List<Map<String, dynamic>>>{};
    for (final row in _filteredRows) {
      final subject = row['mata_pelajaran']?.toString() ?? 'Mata Pelajaran';
      result.putIfAbsent(subject, () => []).add(row);
    }
    return result;
  }

  void _openSchedule(Map<String, dynamic> jadwal) {
    Navigator.pushNamed(context, '/guru/tugas/per-mapel', arguments: jadwal);
  }

  void _chooseClass(String subject, List<Map<String, dynamic>> schedules) {
    if (schedules.length == 1) {
      _openSchedule(schedules.first);
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
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
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(subject, style: AppTypography.heading3),
              const SizedBox(height: 4),
              const Text(
                'Pilih kelas untuk melihat dan mengelola tugas.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 12),
              ...schedules.map(
                (schedule) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(
                      Icons.school_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  title: Text(
                    _prettyClass(schedule['kelas']?.toString() ?? ''),
                  ),
                  subtitle: Text(
                    '${schedule['hari'] ?? '-'} • ${schedule['jam_mulai'] ?? ''}',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _openSchedule(schedule);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupedRows;
    final totalStudents = _filteredRows.fold<int>(
      0,
      (total, row) => total + ((row['jumlah_siswa'] as num?)?.toInt() ?? 0),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Tugas', style: AppTypography.heading3),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: _loadJadwal,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadJadwal,
              child: LayoutBuilder(
                builder: (context, constraints) => Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1180),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      children: [
                        _teacherHeader(grouped.length, totalStudents),
                        const SizedBox(height: 14),
                        _searchField(),
                        const SizedBox(height: 14),
                        _filterRow(),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Daftar Mata Pelajaran',
                                style: AppTypography.heading3,
                              ),
                            ),
                            Text(
                              '${grouped.length} Mapel',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (grouped.isEmpty)
                          _emptyState()
                        else
                          ...grouped.entries.map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _subjectCard(entry.key, entry.value),
                            ),
                          ),
                        const SizedBox(height: 8),
                        _academicInfo(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      bottomNavigationBar: const GuruBottomNavigation(currentIndex: 2),
    );
  }

  Widget _teacherHeader(int subjects, int students) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.school_outlined,
              color: AppColors.primary,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GURU PENGAMPU',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .6,
                  ),
                ),
                SizedBox(height: 4),
                Text('Daftar Tugas Mengajar', style: AppTypography.heading3),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$subjects Mapel',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              Text(
                '$students Siswa',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _searchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Cari mata pelajaran atau kelas...',
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }

  Widget _filterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((filter) {
          final selected = _selectedClass == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: selected,
              onSelected: (_) => setState(() => _selectedClass = filter),
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              labelStyle: TextStyle(
                color: selected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              side: BorderSide(
                color: selected ? AppColors.primary : AppColors.border,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _subjectCard(String subject, List<Map<String, dynamic>> schedules) {
    final classes = schedules
        .map((row) => _prettyClass(row['kelas']?.toString() ?? ''))
        .toSet()
        .toList();
    final students = schedules.fold<int>(
      0,
      (total, row) => total + ((row['jumlah_siswa'] as num?)?.toInt() ?? 0),
    );
    final hasPending = schedules.any(
      (row) => (row['tugas_menunggu'] as num?)?.toInt() != 0,
    );
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => _chooseClass(subject, schedules),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${classes.join(', ')} • $students Siswa',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textMuted,
                    size: 25,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F8FF),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(
                  children: [
                    Icon(
                      hasPending
                          ? Icons.assignment_late_outlined
                          : Icons.assignment_turned_in_outlined,
                      color: hasPending ? AppColors.warning : AppColors.success,
                      size: 17,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        hasPending
                            ? 'Ada tugas yang menunggu penilaian'
                            : 'Kelola tugas aktif dan terjadwal',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const Text(
                      'Buka Tugas',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.primary,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(Icons.search_off_rounded, size: 38, color: AppColors.textMuted),
          SizedBox(height: 10),
          Text('Jadwal tidak ditemukan', style: AppTypography.heading3),
          SizedBox(height: 5),
          Text(
            'Coba ubah kata kunci atau filter kelas.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _academicInfo() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.verified_outlined, color: AppColors.primary),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tahun Ajaran & Kurikulum',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'T.A. 2026/2027 Ganjil • Kurikulum Merdeka',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.circle, color: AppColors.success, size: 9),
        ],
      ),
    );
  }
}

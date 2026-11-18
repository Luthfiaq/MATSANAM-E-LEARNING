import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/api_config.dart';
import '../../../utils/constants.dart';
import '../../../utils/session.dart';
import '../../../widgets/common/empty_state.dart';
import '../../../widgets/common/guru_bottom_navigation.dart';
import '../../../widgets/common/guru_profile_summary_card.dart';

class NilaiPilihMapelKelasScreen extends StatefulWidget {
  const NilaiPilihMapelKelasScreen({super.key});

  @override
  State<NilaiPilihMapelKelasScreen> createState() =>
      _NilaiPilihMapelKelasScreenState();
}

class _NilaiPilihMapelKelasScreenState
    extends State<NilaiPilihMapelKelasScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final Future<Map<String, dynamic>?> _profileFuture;
  List<Map<String, dynamic>> _mapelKelasList = [];
  bool _isLoading = true;
  String _selectedClass = 'Semua';
  String? _error;

  @override
  void initState() {
    super.initState();
    _profileFuture = Session.getProfile();
    _loadMapelKelas();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _classLevel(String value) {
    final upper = value.toUpperCase().trim();
    if (upper.startsWith('VII') || upper.startsWith('7')) return 'Kelas 7';
    if (upper.startsWith('VIII') || upper.startsWith('8')) return 'Kelas 8';
    if (upper.startsWith('IX') || upper.startsWith('9')) return 'Kelas 9';
    return 'Lainnya';
  }

  Future<void> _loadMapelKelas({bool showLoader = true}) async {
    if (showLoader && mounted) setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty)
        throw Exception('Sesi login tidak ditemukan.');
      final response = await http
          .get(
            Uri.parse(ApiConfig.guruMapelKelas),
            headers: ApiConfig.headers(token),
          )
          .timeout(ApiConfig.timeout);
      final body = jsonDecode(response.body);
      if (response.statusCode != 200 ||
          body is! Map ||
          body['success'] != true) {
        throw Exception(
          body is Map
              ? (body['message']?.toString() ?? 'Gagal memuat jadwal.')
              : 'Respons server tidak valid.',
        );
      }
      final rows = (body['data'] as List? ?? [])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      if (!mounted) return;
      setState(() {
        _mapelKelasList = rows;
        _isLoading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  List<MapEntry<String, List<Map<String, dynamic>>>> get _visibleGroups {
    final groups = <String, List<Map<String, dynamic>>>{};
    final query = _searchController.text.trim().toLowerCase();
    for (final row in _mapelKelasList) {
      final subject = (row['mata_pelajaran'] ?? 'Mata Pelajaran').toString();
      final className = (row['kelas'] ?? '').toString();
      if (_selectedClass != 'Semua' && _classLevel(className) != _selectedClass)
        continue;
      if (query.isNotEmpty &&
          !subject.toLowerCase().contains(query) &&
          !className.toLowerCase().contains(query))
        continue;
      groups.putIfAbsent(subject, () => []).add(row);
    }
    final result = groups.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return result;
  }

  void _openAssessment(Map<String, dynamic> schedule) {
    Navigator.pushNamed(
      context,
      '/guru/nilai/daftar-tugas-mapel',
      arguments: schedule,
    );
  }

  @override
  Widget build(BuildContext context) {
    final groups = _visibleGroups;
    final pending = _mapelKelasList.fold<int>(
      0,
      (sum, row) => sum + ((row['tugas_menunggu'] as num?)?.toInt() ?? 0),
    );
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
          ),
        ),
        title: const Text(
          'Penilaian Siswa',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Profil Guru',
            onPressed: () => Navigator.pushNamed(context, '/pengaturan'),
            icon: const CircleAvatar(
              radius: 15,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person_outline, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null && _mapelKelasList.isEmpty
          ? EmptyState(
              icon: Icons.wifi_off_rounded,
              title: 'Data Penilaian Tidak Dapat Dimuat',
              message: _error!,
              actionText: 'Coba Lagi',
              onAction: _loadMapelKelas,
            )
          : RefreshIndicator(
              onRefresh: () => _loadMapelKelas(showLoader: false),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  GuruProfileSummaryCard(profileFuture: _profileFuture),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Cari mata pelajaran atau kelas penilaian...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: Colors.white,
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
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _classChip('Semua', _mapelKelasList.length),
                        _classChip('Kelas 7'),
                        _classChip('Kelas 8'),
                        _classChip('Kelas 9'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Daftar Mata Pelajaran',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        '${groups.length} Mapel',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$pending tugas perlu ditinjau • pilih kelas untuk melihat daftar penilaian',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (groups.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 48),
                      child: Center(
                        child: Text('Tidak ada mata pelajaran yang cocok.'),
                      ),
                    )
                  else
                    ...groups.map(_buildSubjectCard),
                ],
              ),
            ),
      bottomNavigationBar: const GuruBottomNavigation(currentIndex: 3),
    );
  }

  Widget _classChip(String label, [int? count]) {
    final selected = _selectedClass == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(count == null ? label : '$label ($count)'),
        selected: selected,
        onSelected: (_) => setState(() => _selectedClass = label),
        showCheckmark: false,
        selectedColor: AppColors.primary,
        backgroundColor: Colors.white,
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border,
        ),
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSubjectCard(MapEntry<String, List<Map<String, dynamic>>> group) {
    final schedules = group.value;
    final students = schedules.fold<int>(
      0,
      (sum, row) => sum + ((row['jumlah_siswa'] as num?)?.toInt() ?? 0),
    );
    final pending = schedules.fold<int>(
      0,
      (sum, row) => sum + ((row['tugas_menunggu'] as num?)?.toInt() ?? 0),
    );
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.key,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${schedules.length} kelas • $students siswa',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: pending > 0
                      ? AppColors.warningLight
                      : AppColors.successLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  pending > 0 ? '$pending Perlu Dinilai' : 'Tuntas',
                  style: TextStyle(
                    color: pending > 0 ? AppColors.warning : AppColors.success,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 8),
          ...schedules.map((row) {
            final className = (row['kelas'] ?? 'Kelas').toString();
            final count = (row['tugas_menunggu'] as num?)?.toInt() ?? 0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  const Icon(
                    Icons.groups_2_outlined,
                    size: 17,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      '$className • ${row['jumlah_siswa'] ?? 0} siswa',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _openAssessment(row),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: Text(
                      count > 0 ? 'Buka Penilaian →' : 'Lihat Tugas →',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

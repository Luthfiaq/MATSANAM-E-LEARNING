import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/api_config.dart';
import '../../../utils/constants.dart';
import '../../../utils/session.dart';
import '../../../widgets/common/empty_state.dart';
import '../../../widgets/common/guru_bottom_navigation.dart';
import '../../../widgets/common/guru_profile_summary_card.dart';
import 'buka_sesi_screen.dart';

class PilihMapelKelasScreen extends StatefulWidget {
  const PilihMapelKelasScreen({super.key});

  @override
  State<PilihMapelKelasScreen> createState() => _PilihMapelKelasScreenState();
}

class _PilihMapelKelasScreenState extends State<PilihMapelKelasScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final Future<Map<String, dynamic>?> _profileFuture;
  List<Map<String, dynamic>> _mapelList = [];
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
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      if (!mounted) return;
      setState(() {
        _mapelList = rows;
        _error = null;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  String _classLevel(String value) {
    final upper = value.toUpperCase().trim();
    if (upper.startsWith('VII') || upper.startsWith('7')) return 'Kelas 7';
    if (upper.startsWith('VIII') || upper.startsWith('8')) return 'Kelas 8';
    if (upper.startsWith('IX') || upper.startsWith('9')) return 'Kelas 9';
    return 'Lainnya';
  }

  List<MapEntry<String, List<Map<String, dynamic>>>> get _visibleGroups {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final row in _mapelList) {
      final subject = (row['mata_pelajaran'] ?? 'Mata Pelajaran').toString();
      final className = (row['kelas'] ?? '').toString();
      final query = _searchController.text.trim().toLowerCase();
      if (_selectedClass != 'Semua' && _classLevel(className) != _selectedClass)
        continue;
      if (query.isNotEmpty &&
          !subject.toLowerCase().contains(query) &&
          !className.toLowerCase().contains(query))
        continue;
      grouped.putIfAbsent(subject, () => []).add(row);
    }
    final entries = grouped.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries;
  }

  Future<void> _openSchedule(Map<String, dynamic> schedule) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BukaSesiScreen(jadwal: schedule)),
    );
    if (mounted) await _loadMapelKelas(showLoader: false);
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = _mapelList
        .where((e) => e['status_absensi'] == 'aktif')
        .length;
    final visibleGroups = _visibleGroups;
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
          'Presensi Siswa',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Histori Sesi',
            onPressed: () =>
                Navigator.pushNamed(context, '/guru/absensi/histori-sesi'),
            icon: const Icon(
              Icons.history_rounded,
              color: AppColors.textPrimary,
            ),
          ),
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
          : _error != null && _mapelList.isEmpty
          ? EmptyState(
              icon: Icons.wifi_off_rounded,
              title: 'Jadwal Tidak Dapat Dimuat',
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
                      hintText: 'Cari mata pelajaran atau kelas presensi...',
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
                        _filterChip('Semua', _mapelList.length),
                        _filterChip('Kelas 7', null),
                        _filterChip('Kelas 8', null),
                        _filterChip('Kelas 9', null),
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
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        '${visibleGroups.length} Mapel',
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
                    '$activeCount sesi sedang aktif • pilih kelas untuk membuka presensi',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (visibleGroups.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 48),
                      child: Center(
                        child: Text('Tidak ada jadwal yang cocok.'),
                      ),
                    )
                  else
                    ...visibleGroups.map(_buildSubjectCard),
                ],
              ),
            ),
      bottomNavigationBar: const GuruBottomNavigation(currentIndex: 2),
    );
  }

  Widget _filterChip(String label, int? count) {
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
    final studentCount = schedules.fold<int>(
      0,
      (sum, row) => sum + ((row['jumlah_siswa'] as num?)?.toInt() ?? 0),
    );
    final active = schedules
        .where((row) => row['status_absensi'] == 'aktif')
        .length;
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
                      '${schedules.length} kelas • $studentCount siswa',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (active > 0)
                _statusPill(
                  '$active Aktif',
                  AppColors.success,
                  const Color(0xFFD1FAE5),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 8),
          ...schedules.map((row) {
            final className = (row['kelas'] ?? 'Kelas').toString();
            final isActive = row['status_absensi'] == 'aktif';
            final startTime = (row['jam_mulai'] ?? '').toString();
            final endTime = (row['jam_selesai'] ?? '').toString();
            final scheduleTime =
                '${startTime.length >= 5 ? startTime.substring(0, 5) : startTime} - ${endTime.length >= 5 ? endTime.substring(0, 5) : endTime}';
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$className • ${row['jumlah_siswa'] ?? 0} siswa',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${row['hari'] ?? ''} ${scheduleTime.trim()}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => _openSchedule(row),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: Text(
                      isActive ? 'Lihat Sesi →' : 'Buka Presensi →',
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

  Widget _statusPill(String label, Color color, Color background) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
    ),
  );
}

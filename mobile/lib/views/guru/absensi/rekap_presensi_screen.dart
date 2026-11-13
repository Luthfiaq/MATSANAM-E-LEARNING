import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/api_config.dart';
import '../../../utils/constants.dart';

class RekapPresensiGuruScreen extends StatefulWidget {
  const RekapPresensiGuruScreen({super.key});

  @override
  State<RekapPresensiGuruScreen> createState() =>
      _RekapPresensiGuruScreenState();
}

class _RekapPresensiGuruScreenState extends State<RekapPresensiGuruScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  DateTime _selectedMonth = DateTime.now();
  String? _selectedClassId;
  List<Map<String, dynamic>> _kelasList = [];
  List<Map<String, dynamic>> _absensiList = [];
  Map<String, dynamic> _summary = {};
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  int _page = 1;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadRekap(refresh: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients ||
        _isLoading ||
        _isLoadingMore ||
        !_hasMore)
      return;
    if (_scrollController.position.extentAfter < 260) _loadRekap();
  }

  String get _periodQuery =>
      '${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}-01';

  Future<void> _loadRekap({bool refresh = false}) async {
    if (refresh) {
      if (mounted)
        setState(() {
          _isLoading = true;
          _page = 1;
          _error = null;
        });
    } else if (_isLoading || _isLoadingMore || !_hasMore) {
      return;
    } else {
      if (mounted) setState(() => _isLoadingMore = true);
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty)
        throw Exception('Sesi login tidak ditemukan.');
      final query = <String, String>{'periode': _periodQuery, 'page': '$_page'};
      if (_selectedClassId != null) query['kelas'] = _selectedClassId!;
      final uri = Uri.parse(
        ApiConfig.guruRekapPresensi,
      ).replace(queryParameters: query);
      final response = await http
          .get(uri, headers: ApiConfig.headers(token))
          .timeout(ApiConfig.timeout);
      final body = jsonDecode(response.body);
      if (response.statusCode != 200 ||
          body is! Map ||
          body['success'] != true) {
        throw Exception(
          body is Map
              ? (body['message']?.toString() ?? 'Gagal memuat rekap presensi.')
              : 'Respons server tidak valid.',
        );
      }
      final data = body['data'] is Map
          ? Map<String, dynamic>.from(body['data'])
          : <String, dynamic>{};
      final paginator = data['absensis'] is Map
          ? Map<String, dynamic>.from(data['absensis'])
          : <String, dynamic>{};
      final rows = (paginator['data'] as List? ?? [])
          .whereType<Map>()
          .map((row) => Map<String, dynamic>.from(row))
          .toList();
      final summary = data['summary'] is Map
          ? Map<String, dynamic>.from(data['summary'])
          : <String, dynamic>{};
      final classes = (data['kelas_list'] as List? ?? [])
          .whereType<Map>()
          .map((row) => Map<String, dynamic>.from(row))
          .toList();
      final current = (paginator['current_page'] as num?)?.toInt() ?? _page;
      final last = (paginator['last_page'] as num?)?.toInt() ?? current;
      if (!mounted) return;
      setState(() {
        if (refresh) _absensiList.clear();
        _absensiList.addAll(rows);
        _summary = summary;
        if (classes.isNotEmpty) _kelasList = classes;
        _page = current + 1;
        _hasMore = current < last;
        _isLoading = false;
        _isLoadingMore = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  List<Map<String, dynamic>> get _filteredRows {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _absensiList;
    return _absensiList.where((row) {
      final siswa = row['siswa'] is Map
          ? Map<String, dynamic>.from(row['siswa'])
          : <String, dynamic>{};
      final jadwal = row['jadwal'] is Map
          ? Map<String, dynamic>.from(row['jadwal'])
          : <String, dynamic>{};
      final kelas = jadwal['kelas'] is Map
          ? Map<String, dynamic>.from(jadwal['kelas'])
          : <String, dynamic>{};
      final mapel = jadwal['mata_pelajaran'] is Map
          ? Map<String, dynamic>.from(jadwal['mata_pelajaran'])
          : <String, dynamic>{};
      final values =
          '${siswa['nama_lengkap'] ?? ''} ${siswa['nis'] ?? ''} ${kelas['nama_kelas'] ?? ''} ${mapel['nama'] ?? ''} ${row['status'] ?? ''}'
              .toLowerCase();
      return values.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final summary = _summary;
    final rows = _filteredRows;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
          ),
        ),
        title: const Text(
          'Rekap Presensi',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: () => _loadRekap(refresh: true),
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      body: _isLoading && _absensiList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _loadRekap(refresh: true),
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  _buildPeriodAndClassSelector(),
                  const SizedBox(height: 14),
                  _buildSummary(summary),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Rincian Kehadiran Siswa',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        '${rows.length} data dimuat',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search_rounded),
                      hintText: 'Cari nama siswa, NIS, kelas, atau mapel...',
                      filled: true,
                      fillColor: Colors.white,
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
                  if (_error != null && _absensiList.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Text(_error!, textAlign: TextAlign.center),
                            TextButton(
                              onPressed: () => _loadRekap(refresh: true),
                              child: const Text('Coba lagi'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (rows.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(28),
                      child: Center(
                        child: Text(
                          'Belum ada data presensi untuk filter ini.',
                        ),
                      ),
                    )
                  else
                    ...rows.map(_buildAttendanceRow),
                  if (_isLoadingMore)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildPeriodAndClassSelector() {
    final monthLabel =
        '${_monthName(_selectedMonth.month)} ${_selectedMonth.year}';
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _chooseMonth,
            icon: const Icon(Icons.calendar_month_rounded, size: 18),
            label: Text(monthLabel, overflow: TextOverflow.ellipsis),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              backgroundColor: Colors.white,
              side: const BorderSide(color: AppColors.border),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                isExpanded: true,
                value: _selectedClassId,
                hint: const Text('Semua Kelas', style: TextStyle(fontSize: 12)),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Semua Kelas', style: TextStyle(fontSize: 12)),
                  ),
                  ..._kelasList.map(
                    (row) => DropdownMenuItem<String?>(
                      value: row['id'].toString(),
                      child: Text(
                        row['nama_kelas']?.toString() ?? 'Kelas',
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _selectedClassId = value);
                  _loadRekap(refresh: true);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _chooseMonth() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      helpText: 'Pilih tanggal pada bulan yang ingin ditampilkan',
    );
    if (selected == null || !mounted) return;
    setState(() => _selectedMonth = DateTime(selected.year, selected.month));
    _loadRekap(refresh: true);
  }

  Widget _buildSummary(Map<String, dynamic> summary) {
    final hadir = (summary['hadir'] as num?)?.toInt() ?? 0;
    final izin = (summary['izin'] as num?)?.toInt() ?? 0;
    final sakit = (summary['sakit'] as num?)?.toInt() ?? 0;
    final alpa = (summary['alpa'] as num?)?.toInt() ?? 0;
    final percent = (summary['persentase_hadir'] as num?)?.toDouble() ?? 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TINGKAT KEHADIRAN',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: .5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${percent.toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: Text(
                  'persentase hadir',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (percent / 100).clamp(0.0, 1.0).toDouble(),
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _summaryItem('Hadir', hadir, AppColors.success),
              _summaryItem('Izin', izin, AppColors.info),
              _summaryItem('Sakit', sakit, AppColors.warning),
              _summaryItem('Alpa', alpa, AppColors.error),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, int value, Color color) => Expanded(
    child: Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
        ),
      ],
    ),
  );

  Widget _buildAttendanceRow(Map<String, dynamic> row) {
    final student = row['siswa'] is Map
        ? Map<String, dynamic>.from(row['siswa'])
        : <String, dynamic>{};
    final schedule = row['jadwal'] is Map
        ? Map<String, dynamic>.from(row['jadwal'])
        : <String, dynamic>{};
    final classData = schedule['kelas'] is Map
        ? Map<String, dynamic>.from(schedule['kelas'])
        : <String, dynamic>{};
    final subjectData = schedule['mata_pelajaran'] is Map
        ? Map<String, dynamic>.from(schedule['mata_pelajaran'])
        : <String, dynamic>{};
    final status = (row['status'] ?? 'belum').toString().toLowerCase();
    final color = status == 'hadir'
        ? AppColors.success
        : status == 'izin'
        ? AppColors.info
        : status == 'sakit'
        ? AppColors.warning
        : AppColors.error;
    final name = (student['nama_lengkap'] ?? student['nama'] ?? 'Siswa')
        .toString();
    final className = (classData['nama_kelas'] ?? '-').toString();
    final mapel = (subjectData['nama'] ?? '-').toString();
    final date = (row['tanggal'] ?? '-').toString();
    final time = (row['waktu_absen'] ?? '').toString();
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFEFF6FF),
            child: Text(
              name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'S',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'NIS ${student['nis'] ?? '-'} • $className',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$mapel • $date ${time.isNotEmpty ? '• ${_shortTime(time)}' : ''}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              _statusLabel(status),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'hadir':
        return 'Hadir';
      case 'izin':
        return 'Izin';
      case 'sakit':
        return 'Sakit';
      case 'alpa':
        return 'Alpa';
      default:
        return status;
    }
  }

  String _shortTime(String value) => value.length >= 16
      ? value.substring(11, 16)
      : (value.length >= 5 ? value.substring(0, 5) : value);
  String _monthName(int month) => const [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ][month - 1];
}

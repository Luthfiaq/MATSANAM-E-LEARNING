import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/api_config.dart';
import '../../../utils/constants.dart';
import 'buka_sesi_screen.dart';

class HistoriSesiScreen extends StatefulWidget {
  const HistoriSesiScreen({super.key});

  @override
  State<HistoriSesiScreen> createState() => _HistoriSesiScreenState();
}

class _HistoriSesiScreenState extends State<HistoriSesiScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _sesiList = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  String _filter = 'semua';
  int _page = 1;
  int _total = 0;
  int _activeCount = 0;
  int _completedCount = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadSesi(refresh: true);
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
    if (_scrollController.position.extentAfter < 280) _loadSesi();
  }

  Future<void> _loadSesi({bool refresh = false}) async {
    if (refresh) {
      if (mounted)
        setState(() {
          _isLoading = true;
          _error = null;
          _page = 1;
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
      final response = await http
          .get(
            Uri.parse('${ApiConfig.guruSessions}?page=$_page'),
            headers: ApiConfig.headers(token),
          )
          .timeout(ApiConfig.timeout);
      final body = jsonDecode(response.body);
      if (response.statusCode != 200 ||
          body is! Map ||
          body['success'] != true) {
        throw Exception(
          body is Map
              ? (body['message']?.toString() ?? 'Gagal memuat histori sesi.')
              : 'Respons server tidak valid.',
        );
      }
      final data = body['data'] is Map
          ? Map<String, dynamic>.from(body['data'])
          : <String, dynamic>{};
      final rows = (data['report'] as List? ?? [])
          .whereType<Map>()
          .map((row) => Map<String, dynamic>.from(row))
          .toList();
      final summary = data['summary'] is Map
          ? Map<String, dynamic>.from(data['summary'])
          : <String, dynamic>{};
      final pagination = data['pagination'] is Map
          ? Map<String, dynamic>.from(data['pagination'])
          : <String, dynamic>{};
      final current = (pagination['current_page'] as num?)?.toInt() ?? _page;
      final perPage = (pagination['per_page'] as num?)?.toInt() ?? 20;
      final total = (pagination['total'] as num?)?.toInt() ?? rows.length;
      if (!mounted) return;
      setState(() {
        if (refresh) _sesiList.clear();
        _sesiList.addAll(rows);
        _total = total;
        _activeCount = (summary['aktif'] as num?)?.toInt() ?? _activeCount;
        _completedCount =
            (summary['selesai'] as num?)?.toInt() ?? _completedCount;
        _page = current + 1;
        _hasMore = current * perPage < total;
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

  int _monthNumber(String? raw) {
    final value = (raw ?? '').toLowerCase();
    const months = {
      'jan': 1,
      'feb': 2,
      'mar': 3,
      'apr': 4,
      'may': 5,
      'mei': 5,
      'jun': 6,
      'jul': 7,
      'aug': 8,
      'agu': 8,
      'sep': 9,
      'oct': 10,
      'okt': 10,
      'nov': 11,
      'dec': 12,
      'des': 12,
    };
    for (final entry in months.entries) {
      if (value.contains(entry.key)) return entry.value;
    }
    return 0;
  }

  List<Map<String, dynamic>> get _filteredSessions {
    final query = _searchController.text.trim().toLowerCase();
    return _sesiList.where((session) {
      final jadwal = session['jadwal'] is Map
          ? Map<String, dynamic>.from(session['jadwal'])
          : <String, dynamic>{};
      final searchable =
          '${jadwal['mapel'] ?? ''} ${jadwal['kelas'] ?? ''} ${session['created_at'] ?? ''}'
              .toLowerCase();
      if (query.isNotEmpty && !searchable.contains(query)) return false;
      switch (_filter) {
        case 'bulan_ini':
          return _monthNumber(session['created_at']?.toString()) ==
              DateTime.now().month;
        case 'aktif':
          return session['status'] == 'aktif';
        case 'selesai':
          return session['status'] == 'selesai';
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final active = _activeCount;
    final completed = _completedCount;
    final filtered = _filteredSessions;
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
          'Histori Sesi Presensi',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Rekap Presensi',
            onPressed: () =>
                Navigator.pushNamed(context, '/guru/absensi/rekap'),
            icon: const Icon(
              Icons.analytics_outlined,
              color: AppColors.textPrimary,
            ),
          ),
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: () => _loadSesi(refresh: true),
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      body: _isLoading && _sesiList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _loadSesi(refresh: true),
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  _buildSummaryCard(active, completed),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        '/guru/absensi/pilih-mapel',
                      ),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Buka Sesi Presensi & QR Baru'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search_rounded),
                      hintText: 'Cari tanggal, sesi, atau mata pelajaran...',
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
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _filterChip('Semua', 'semua'),
                        _filterChip('Bulan Ini', 'bulan_ini'),
                        _filterChip('Sesi Aktif', 'aktif'),
                        _filterChip('Selesai', 'selesai'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Daftar Sesi Presensi',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_error != null && _sesiList.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Text(_error!, textAlign: TextAlign.center),
                            TextButton(
                              onPressed: () => _loadSesi(refresh: true),
                              child: const Text('Coba lagi'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (filtered.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(28),
                      child: Center(child: Text('Belum ada sesi yang sesuai.')),
                    )
                  else
                    ...filtered.map(_buildSessionCard),
                  if (_isLoadingMore)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  if (!_hasMore && _sesiList.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Center(
                        child: Text(
                          'Menampilkan ${_sesiList.length} dari $_total sesi',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard(int active, int completed) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                color: Colors.white,
                size: 17,
              ),
              const SizedBox(width: 7),
              Text(
                'Riwayat Presensi',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .9),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '$_total sesi',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Rekap Sesi Guru',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _summaryValue('$active', 'Aktif'),
              const SizedBox(width: 24),
              _summaryValue('$completed', 'Selesai'),
              const SizedBox(width: 24),
              _summaryValue('$_total', 'Total Sesi'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryValue(String value, String label) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
      Text(
        label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: .8),
          fontSize: 11,
        ),
      ),
    ],
  );

  Widget _filterChip(String label, String value) {
    final selected = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => setState(() => _filter = value),
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

  Future<void> _openActiveSession(
    Map<String, dynamic> session,
    Map<String, dynamic> schedule,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BukaSesiScreen(
          jadwal: {
            'id': session['jadwal_id'],
            'jadwal_id': session['jadwal_id'],
            'mata_pelajaran': schedule['mapel'],
            'kelas': schedule['kelas'],
            'sesi_id': session['id'],
            'status_absensi': 'aktif',
            'jumlah_siswa': session['total_siswa'],
          },
        ),
      ),
    );
    if (mounted) await _loadSesi(refresh: true);
  }

  Widget _buildSessionCard(Map<String, dynamic> session) {
    final schedule = session['jadwal'] is Map
        ? Map<String, dynamic>.from(session['jadwal'])
        : <String, dynamic>{};
    final present = (session['hadir'] as num?)?.toInt() ?? 0;
    final total = (session['total_siswa'] as num?)?.toInt() ?? 0;
    final rate = total > 0 ? (present / total).clamp(0.0, 1.0).toDouble() : 0.0;
    final active = session['status'] == 'aktif';
    final className = (schedule['kelas'] ?? '-').toString();
    final subject = (schedule['mapel'] ?? 'Mata Pelajaran').toString();
    final sessionId = session['id']?.toString() ?? '';
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.primaryLight
                      : const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  active ? Icons.qr_code_2_rounded : Icons.fact_check_outlined,
                  color: active ? AppColors.primary : AppColors.success,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      children: [
                        _tag('Kelas $className'),
                        _tag('${schedule['hari'] ?? ''}'),
                      ],
                    ),
                  ],
                ),
              ),
              _statusBadge(active ? 'Berlangsung' : 'Selesai', active),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${session['created_at'] ?? '-'} • ${_shortTime(schedule['jam_mulai'])} - ${_shortTime(schedule['jam_selesai'])}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F6FC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Hadir: $present / $total siswa',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '${(rate * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: AppColors.success,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: rate,
                    minHeight: 6,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation(AppColors.success),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showSessionDetails(session, schedule),
                  icon: const Icon(Icons.receipt_long_outlined, size: 16),
                  label: const Text(
                    'Detail Rekap',
                    style: TextStyle(fontSize: 11),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                ),
              ),
              if (active) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openActiveSession(session, schedule),
                    icon: const Icon(Icons.qr_code_rounded, size: 16),
                    label: const Text(
                      'Lihat QR',
                      style: TextStyle(fontSize: 11),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _tag(String label) => Container(
    margin: const EdgeInsets.only(top: 2),
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  Widget _statusBadge(String label, bool active) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: active ? AppColors.successLight : const Color(0xFFEFF6FF),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: active ? AppColors.success : AppColors.primary,
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  String _shortTime(dynamic value) {
    final text = (value ?? '').toString();
    return text.length >= 5 ? text.substring(0, 5) : text;
  }

  void _showSessionDetails(
    Map<String, dynamic> session,
    Map<String, dynamic> schedule,
  ) {
    final total = (session['total_siswa'] as num?)?.toInt() ?? 0;
    final percent = (session['persentase'] as num?)?.toDouble() ?? 0;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
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
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              '${schedule['mapel'] ?? 'Presensi'} • ${schedule['kelas'] ?? ''}',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '${session['created_at'] ?? '-'}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              '${percent.toStringAsFixed(1)}% Kehadiran',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              '${session['hadir'] ?? 0} dari $total siswa hadir',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 14),
            _detailRow('Hadir', session['hadir'], AppColors.success),
            _detailRow('Izin', session['izin'], AppColors.info),
            _detailRow('Sakit', session['sakit'], AppColors.warning),
            _detailRow('Alpa', session['alpa'], AppColors.error),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(sheetContext),
                child: const Text('Tutup'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, dynamic value, Color color) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 9),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const Spacer(),
        Text(
          '${value ?? 0}',
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

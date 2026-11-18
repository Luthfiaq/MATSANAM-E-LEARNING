import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/constants.dart';
import '../../../services/guru_tugas_service.dart';
import '../../../config/api_config.dart';

class TugasPerMapelScreen extends StatefulWidget {
  final Map<String, dynamic> mapel;
  const TugasPerMapelScreen({super.key, this.mapel = const {}});

  @override
  State<TugasPerMapelScreen> createState() => _TugasPerMapelScreenState();
}

class _TugasPerMapelScreenState extends State<TugasPerMapelScreen> {
  final GuruTugasService _tugasService = GuruTugasService();
  List<Map<String, dynamic>> _tugasList = [];
  bool _isLoading = true;
  String? _loadError;
  String _selectedFilter = 'Semua';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTugas();
  }

  Future<void> _loadTugas() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) {
        throw Exception('Sesi login tidak ditemukan. Silakan login kembali.');
      }
      final scheduleId = widget.mapel['jadwal_id'] ?? widget.mapel['id'];
      if (scheduleId == null) {
        throw Exception(
          'ID jadwal mengajar tidak ditemukan. Kembali pilih mapel dan kelas.',
        );
      }
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/guru/mapel/$scheduleId/tugas'),
            headers: ApiConfig.headers(token),
          )
          .timeout(ApiConfig.timeout);

      dynamic decoded;
      try {
        decoded = json.decode(response.body);
      } catch (_) {
        decoded = null;
      }
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          decoded is! Map ||
          decoded['success'] != true) {
        final message = decoded is Map ? decoded['message']?.toString() : null;
        throw Exception(
          message?.isNotEmpty == true
              ? message
              : 'Gagal memuat tugas (HTTP ${response.statusCode}).',
        );
      }

      final rows = (decoded['data'] as List? ?? [])
          .whereType<Map>()
          .map((row) => Map<String, dynamic>.from(row))
          .toList();
      if (!mounted) return;
      setState(() {
        _tugasList = rows;
        _isLoading = false;
        _loadError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = error.toString().replaceFirst('Exception: ', '');
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_loadError!),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _downloadAttachment(Map<String, dynamic> tugas) async {
    final taskId = tugas['id']?.toString();
    final storedPath = tugas['file_materi']?.toString();
    if (taskId == null || storedPath == null || storedPath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tugas ini tidak memiliki lampiran.')),
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) {
        throw Exception('Sesi login tidak ditemukan. Silakan login kembali.');
      }
      final response = await http
          .get(
            Uri.parse('${ApiConfig.guruTugas}/$taskId/file'),
            headers: {'Accept': '*/*', 'Authorization': 'Bearer $token'},
          )
          .timeout(ApiConfig.timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Lampiran gagal diunduh (HTTP ${response.statusCode}).',
        );
      }
      final fileName = storedPath.split('/').last;
      await FilePicker.platform.saveFile(
        dialogTitle: 'Simpan lampiran tugas',
        fileName: fileName,
        bytes: response.bodyBytes,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _confirmDeleteTask(
    BuildContext pageContext,
    Map<String, dynamic> tugas,
  ) async {
    final taskId = int.tryParse(tugas['id']?.toString() ?? '');
    if (taskId == null) {
      ScaffoldMessenger.of(pageContext).showSnackBar(
        const SnackBar(content: Text('ID tugas tidak ditemukan.')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: pageContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus tugas?'),
        content: Text(
          'Tugas "${tugas['judul'] ?? 'ini'}" akan dihapus. Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      final message = await _tugasService.deleteTask(taskId);
      if (!mounted) return;
      ScaffoldMessenger.of(pageContext).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      await _loadTugas();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(pageContext).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  DateTime? _parseTaskInstant(dynamic raw) =>
      DateTime.tryParse(raw?.toString() ?? '');

  String _formatSchoolTime(dynamic raw) {
    final parsed = _parseTaskInstant(raw);
    if (parsed == null) return '-';
    final wib = parsed.toUtc().add(const Duration(hours: 7));
    final day = wib.day.toString().padLeft(2, '0');
    final month = wib.month.toString().padLeft(2, '0');
    final hour = wib.hour.toString().padLeft(2, '0');
    final minute = wib.minute.toString().padLeft(2, '0');
    return '$day/$month/${wib.year} $hour:$minute WIB';
  }

  bool _isTaskActive(Map<String, dynamic> tugas) {
    final deadline = _parseTaskInstant(tugas['deadline']);
    return deadline == null || deadline.isAfter(DateTime.now().toUtc());
  }

  List<Map<String, dynamic>> get _filteredTugas {
    return _tugasList.where((tugas) {
      final title = (tugas['judul'] ?? '').toString().toLowerCase();
      final description = (tugas['deskripsi'] ?? '').toString().toLowerCase();
      final matchesSearch =
          _searchQuery.isEmpty ||
          title.contains(_searchQuery) ||
          description.contains(_searchQuery);
      final matchesFilter =
          _selectedFilter == 'Semua' ||
          (_selectedFilter == 'Aktif' && _isTaskActive(tugas)) ||
          (_selectedFilter == 'Selesai' && !_isTaskActive(tugas));
      return matchesSearch && matchesFilter;
    }).toList();
  }

  int get _reviewedCount => _tugasList.fold<int>(0, (total, tugas) {
    final submissions = tugas['pengumpulan'];
    if (submissions is! List) return total;
    return total +
        submissions
            .where((item) => item is Map && item['nilai'] != null)
            .length;
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.book_outlined,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.mapel['mata_pelajaran'] ?? 'Matematika',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        widget.mapel['kelas'] ?? '9A',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    final tugasTampil = _filteredTugas;
    return RefreshIndicator(
      onRefresh: _loadTugas,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          _buildSummaryHeader(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(
                context,
                '/guru/tambah-tugas',
                arguments: {'jadwal_id': widget.mapel['id']},
              ).then((_) => _loadTugas()),
              icon: const Icon(Icons.add_circle_outline_rounded),
              label: const Text('Tambah Tugas Baru'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0750C8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            onChanged: (value) =>
                setState(() => _searchQuery = value.trim().toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Cari tugas, topik, atau kata kunci...',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: ['Semua', 'Aktif', 'Selesai'].map((filter) {
              final selected = _selectedFilter == filter;
              final count = filter == 'Semua'
                  ? _tugasList.length
                  : _tugasList
                        .where(
                          (t) => filter == 'Aktif'
                              ? _isTaskActive(t)
                              : !_isTaskActive(t),
                        )
                        .length;
              return ChoiceChip(
                label: Text('$filter ($count)'),
                selected: selected,
                onSelected: (_) => setState(() => _selectedFilter = filter),
                selectedColor: const Color(0xFF0750C8),
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
                side: BorderSide(
                  color: selected ? const Color(0xFF0750C8) : AppColors.border,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          if (_loadError != null && _tugasList.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 44),
              child: Column(
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    size: 48,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _loadError!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _loadTugas,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Coba Lagi'),
                  ),
                ],
              ),
            )
          else if (tugasTampil.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 44),
              child: Column(
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 56,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _tugasList.isEmpty
                        ? 'Belum ada tugas untuk mapel ini.'
                        : 'Tugas tidak ditemukan.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            )
          else
            ...tugasTampil.map(_buildTugasCard),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader() {
    final mapel =
        widget.mapel['mata_pelajaran']?.toString() ?? 'Mata Pelajaran';
    final kelas = widget.mapel['kelas']?.toString() ?? '-';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0750C8), Color(0xFF3569E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0750C8).withOpacity(0.20),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'MANAJEMEN TUGAS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            mapel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Kelas $kelas  •  ${_tugasList.length} tugas',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.fact_check_outlined,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PROGRES PENILAIAN',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '$_reviewedCount pengumpulan telah dinilai',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$_reviewedCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTugasCard(Map<String, dynamic> tugas) {
    final isActive = _isTaskActive(tugas);
    final submissions = tugas['pengumpulan'] is List
        ? tugas['pengumpulan'] as List
        : const [];
    final submittedCount = submissions.length;
    final totalStudents = (widget.mapel['jumlah_siswa'] as num?)?.toInt() ?? 0;
    final progress = totalStudents > 0
        ? (submittedCount / totalStudents).clamp(0.0, 1.0).toDouble()
        : 0.0;
    final isDeadlineMepet = tugas['deadline_mepet'] == true;
    final description = (tugas['deskripsi'] ?? 'Kerjakan soal latihan.')
        .toString()
        .trim();
    final shortDescription = description.length > 60
        ? '${description.substring(0, 60)}…'
        : (description.isEmpty ? 'Kerjakan soal latihan.' : description);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (isDeadlineMepet)
            Container(
              height: 4,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFEF4444), Color(0xFFF59E0B)],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tugas['judul'] ?? 'Judul Tugas',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Dibuat: ${_formatSchoolTime(tugas['created_at'])}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.successLight
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isActive
                            ? (isDeadlineMepet ? 'Mepet' : 'Aktif')
                            : 'Selesai',
                        style: TextStyle(
                          color: isActive
                              ? (isDeadlineMepet
                                    ? AppColors.error
                                    : AppColors.success)
                              : AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (totalStudents > 0) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Pengumpulan Siswa',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '$submittedCount / $totalStudents Siswa',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 7,
                            backgroundColor: Colors.white,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF087A52),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: isDeadlineMepet
                          ? AppColors.error
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _formatSchoolTime(tugas['deadline']),
                        style: TextStyle(
                          color: isDeadlineMepet
                              ? AppColors.error
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Text(
                      '${tugas['jumlah_siswa'] ?? totalStudents} Siswa',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          shortDescription,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:
                            (tugas['file_materi']?.toString().isNotEmpty ??
                                false)
                            ? () => _downloadAttachment(tugas)
                            : null,
                        icon: const Icon(Icons.download_rounded),
                        label: Text(
                          (tugas['file_materi']?.toString().isNotEmpty ?? false)
                              ? 'Unduh'
                              : 'Tanpa File',
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showDetailTugas(tugas),
                        icon: const Icon(Icons.chevron_right_rounded),
                        label: const Text('Lihat Siswa'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
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
    );
  }

  void _showDetailTugas(Map<String, dynamic> tugas) {
    final rootContext = context;
    final int totalStudents =
        (widget.mapel['jumlah_siswa'] as num?)?.toInt() ?? 0;
    final submissions = (tugas['pengumpulan'] as List? ?? [])
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.78,
        minChildSize: 0.45,
        maxChildSize: 0.92,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                tugas['judul']?.toString() ?? 'Judul Tugas',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                tugas['deskripsi']?.toString() ?? 'Tidak ada deskripsi.',
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _detailChip('Jenis: ${tugas['jenis'] ?? 'Tugas'}'),
                  _detailChip(
                    'Deadline: ${_formatSchoolTime(tugas['deadline'])}',
                  ),
                  _detailChip('Bobot: ${tugas['bobot'] ?? 100}'),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Pengumpulan (${submissions.length} dari $totalStudents siswa)',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: submissions.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada siswa yang mengumpulkan tugas.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        itemCount: submissions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final submission = submissions[index];
                          final student = submission['siswa'];
                          final name = student is Map
                              ? student['nama_lengkap']?.toString()
                              : null;
                          final graded = submission['nilai'] != null;
                          final status = graded
                              ? 'Sudah dinilai'
                              : (submission['status']?.toString() == 'terlambat'
                                    ? 'Terlambat'
                                    : 'Menunggu nilai');
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  radius: 17,
                                  child: Icon(
                                    Icons.person_outline_rounded,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name ??
                                            'Siswa #${submission['siswa_id'] ?? '-'}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        status,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: graded
                                              ? AppColors.success
                                              : AppColors.warning,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        Navigator.pushNamed(
                          rootContext,
                          '/guru/tugas/${tugas['id']}/edit',
                          arguments: tugas,
                        ).then((result) {
                          if (result == true) _loadTugas();
                        });
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit Tugas'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        Navigator.pushNamed(
                          rootContext,
                          '/guru/tugas/${tugas['id']}/siswa',
                        ).then((_) => _loadTugas());
                      },
                      icon: const Icon(Icons.people_alt_outlined),
                      label: const Text('Lihat Semua'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (submissions.isEmpty)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _confirmDeleteTask(rootContext, tugas);
                    },
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.error,
                    ),
                    label: const Text(
                      'Hapus tugas',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                )
              else
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Tugas tidak dapat dihapus karena sudah memiliki pengumpulan siswa.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailChip(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.border),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

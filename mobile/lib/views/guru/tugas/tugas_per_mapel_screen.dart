import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/constants.dart';
import '../../../config/api_config.dart';

class TugasPerMapelScreen extends StatefulWidget {
  final Map<String, dynamic> mapel;
  const TugasPerMapelScreen({super.key, this.mapel = const {}});

  @override
  State<TugasPerMapelScreen> createState() => _TugasPerMapelScreenState();
}

class _TugasPerMapelScreenState extends State<TugasPerMapelScreen> {
  List<Map<String, dynamic>> _tugasList = [];
  bool _isLoading = true;
  String _selectedFilter = 'Semua';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTugas();
  }

  Future<void> _loadTugas() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) throw Exception('Sesi login tidak ditemukan.');
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/guru/mapel/${widget.mapel['id']}/tugas',
        ),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.timeout);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && mounted) {
          setState(() {
            _tugasList = List<Map<String, dynamic>>.from(data['data']);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  bool _isTaskActive(Map<String, dynamic> tugas) {
    final deadline = DateTime.tryParse(tugas['deadline']?.toString() ?? '');
    return deadline == null || deadline.isAfter(DateTime.now());
  }

  List<Map<String, dynamic>> get _filteredTugas {
    return _tugasList.where((tugas) {
      final title = (tugas['judul'] ?? '').toString().toLowerCase();
      final description = (tugas['deskripsi'] ?? '').toString().toLowerCase();
      final matchesSearch = _searchQuery.isEmpty ||
          title.contains(_searchQuery) || description.contains(_searchQuery);
      final matchesFilter = _selectedFilter == 'Semua' ||
          (_selectedFilter == 'Aktif' && _isTaskActive(tugas)) ||
          (_selectedFilter == 'Selesai' && !_isTaskActive(tugas));
      return matchesSearch && matchesFilter;
    }).toList();
  }

  int get _reviewedCount => _tugasList.fold<int>(0, (total, tugas) {
    final submissions = tugas['pengumpulan'];
    if (submissions is! List) return total;
    return total + submissions.where((item) =>
        item is Map && item['nilai'] != null).length;
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
        actions: [
        ],
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value.trim().toLowerCase()),
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
                  : _tugasList.where((t) => filter == 'Aktif' ? _isTaskActive(t) : !_isTaskActive(t)).length;
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
                side: BorderSide(color: selected ? const Color(0xFF0750C8) : AppColors.border),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          if (tugasTampil.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 44),
              child: Column(
                children: [
                  Icon(Icons.assignment_outlined, size: 56, color: AppColors.textSecondary),
                  const SizedBox(height: 12),
                  Text(
                    _tugasList.isEmpty ? 'Belum ada tugas untuk mapel ini.' : 'Tugas tidak ditemukan.',
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
    final mapel = widget.mapel['mata_pelajaran']?.toString() ?? 'Mata Pelajaran';
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
          BoxShadow(color: const Color(0xFF0750C8).withOpacity(0.20), blurRadius: 14, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(20)),
            child: const Text('MANAJEMEN TUGAS', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.6)),
          ),
          const SizedBox(height: 12),
          Text(mapel, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('Kelas $kelas  •  ${_tugasList.length} tugas', style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.16), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const Icon(Icons.fact_check_outlined, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('PROGRES PENILAIAN', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w700)),
                      Text('$_reviewedCount pengumpulan telah dinilai', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                Text('$_reviewedCount', style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTugasCard(Map<String, dynamic> tugas) {
    final isActive = _isTaskActive(tugas);
    final submissions = tugas['pengumpulan'] is List ? tugas['pengumpulan'] as List : const [];
    final submittedCount = submissions.length;
    final totalStudents = (widget.mapel['jumlah_siswa'] as num?)?.toInt() ?? 0;
    final progress = totalStudents > 0 ? (submittedCount / totalStudents).clamp(0.0, 1.0).toDouble() : 0.0;
    final isDeadlineMepet = tugas['deadline_mepet'] == true;
    final description = (tugas['deskripsi'] ?? 'Kerjakan soal latihan.').toString().trim();
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
                            'Dibuat: ${tugas['created_at'] ?? '-'}',
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
                        color: isActive ? AppColors.successLight : AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isActive ? (isDeadlineMepet ? 'Mepet' : 'Aktif') : 'Selesai',
                        style: TextStyle(
                          color: isActive ? (isDeadlineMepet ? AppColors.error : AppColors.success) : AppColors.textSecondary,
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
                            const Text('Pengumpulan Siswa', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                            Text('$submittedCount / $totalStudents Siswa', style: const TextStyle(fontSize: 11, color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 7,
                            backgroundColor: Colors.white,
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF087A52)),
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
                        tugas['deadline'] ?? '-',
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
                        onPressed: () {},
                        icon: const Icon(Icons.download_rounded),
                        label: const Text('Unduh'),
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
    final int totalStudents =
        (widget.mapel['jumlah_siswa'] as num?)?.toInt() ?? 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
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
              const SizedBox(height: 24),
              Text(
                tugas['judul'] ?? 'Judul Tugas',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Deadline',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tugas['deadline'] ?? '-',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Submissions (${tugas['jumlah_siswa'] ?? totalStudents})',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) => _buildSubmissionItem(index),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      '/guru/tugas/${tugas['id']}/siswa',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Lihat Semua Siswa',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmissionItem(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.person, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Siswa ${index + 1}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Kumpul: 2 jam lalu',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Sudah',
              style: TextStyle(
                color: AppColors.success,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

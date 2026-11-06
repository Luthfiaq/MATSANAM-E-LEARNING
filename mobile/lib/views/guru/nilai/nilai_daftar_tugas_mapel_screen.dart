import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/api_config.dart';
import '../../../utils/constants.dart';
import '../../../widgets/common/empty_state.dart';

class NilaiDaftarTugasMapelScreen extends StatefulWidget {
  final Map<String, dynamic> mapelKelas;

  const NilaiDaftarTugasMapelScreen({super.key, required this.mapelKelas});

  @override
  State<NilaiDaftarTugasMapelScreen> createState() => _NilaiDaftarTugasMapelScreenState();
}

class _NilaiDaftarTugasMapelScreenState extends State<NilaiDaftarTugasMapelScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _tugasList = [];
  bool _isLoading = true;
  String? _error;
  String _filter = 'semua';

  @override
  void initState() {
    super.initState();
    _loadTugas();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTugas({bool showLoader = true}) async {
    if (showLoader && mounted) setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) throw Exception('Sesi login tidak ditemukan. Silakan masuk kembali.');
      final response = await http.get(Uri.parse(ApiConfig.guruNilai), headers: ApiConfig.headers(token)).timeout(ApiConfig.timeout);
      final body = jsonDecode(response.body);
      if (response.statusCode != 200 || body is! Map || body['success'] != true) {
        throw Exception(body is Map ? (body['message']?.toString() ?? 'Gagal memuat daftar penilaian.') : 'Respons server tidak valid.');
      }
      final allTasks = (body['data'] as List? ?? [])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      final scheduleId = (widget.mapelKelas['jadwal_id'] ?? widget.mapelKelas['id'])?.toString();
      final tasks = allTasks.where((task) => task['jadwal_id']?.toString() == scheduleId).toList();
      tasks.sort((a, b) => (b['deadline'] ?? '').toString().compareTo((a['deadline'] ?? '').toString()));
      if (!mounted) return;
      setState(() { _tugasList = tasks; _isLoading = false; _error = null; });
    } catch (error) {
      if (!mounted) return;
      setState(() { _isLoading = false; _error = error.toString().replaceFirst('Exception: ', ''); });
    }
  }

  int _count(Map<String, dynamic> task, String field) => (task[field] as num?)?.toInt() ?? 0;
  int _submitted(Map<String, dynamic> task) => (task['pengumpulan'] as List? ?? []).length;
  int _graded(Map<String, dynamic> task) => _count(task, 'dinilai_count');
  int _pending(Map<String, dynamic> task) => (_submitted(task) - _graded(task)).clamp(0, 999999).toInt();

  List<Map<String, dynamic>> get _visibleTasks {
    final query = _searchController.text.trim().toLowerCase();
    return _tugasList.where((task) {
      final title = (task['judul'] ?? '').toString().toLowerCase();
      final type = (task['jenis'] ?? '').toString().toLowerCase();
      if (query.isNotEmpty && !title.contains(query) && !type.contains(query)) return false;
      switch (_filter) {
        case 'pending': return _pending(task) > 0;
        case 'selesai': return _submitted(task) > 0 && _pending(task) == 0;
        case 'belum': return _submitted(task) == 0;
        default: return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final totalStudents = (widget.mapelKelas['jumlah_siswa'] as num?)?.toInt() ?? 0;
    final totalSubmissions = _tugasList.fold<int>(0, (sum, task) => sum + _submitted(task));
    final totalGraded = _tugasList.fold<int>(0, (sum, task) => sum + _graded(task));
    final totalPending = _tugasList.fold<int>(0, (sum, task) => sum + _pending(task));
    final denominator = _tugasList.length * totalStudents;
    final progress = denominator > 0 ? (totalGraded / denominator).clamp(0.0, 1.0).toDouble() : 0.0;
    final visible = _visibleTasks;
    final subject = widget.mapelKelas['mata_pelajaran']?.toString() ?? 'Mata Pelajaran';
    final className = widget.mapelKelas['kelas']?.toString() ?? 'Kelas';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary)),
        title: const Text('Detail Penilaian', style: TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _loadTugas(showLoader: false),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  _buildHero(subject, className, totalStudents, _tugasList.length, progress, totalGraded),
                  const SizedBox(height: 12),
                  Row(children: [
                    _statCard('Tugas', '${_tugasList.length}', Icons.assignment_outlined, AppColors.primary),
                    const SizedBox(width: 8),
                    _statCard('Perlu Dinilai', '$totalPending', Icons.pending_actions_rounded, AppColors.warning),
                    const SizedBox(width: 8),
                    _statCard('Diperiksa', '$totalGraded', Icons.task_alt_rounded, AppColors.success),
                  ]),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(prefixIcon: const Icon(Icons.search_rounded), hintText: 'Cari tugas, ulangan, atau asesmen...', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: AppColors.border)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: AppColors.border))),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
                    _filterChip('Semua (${_tugasList.length})', 'semua'),
                    _filterChip('Perlu Dinilai', 'pending'),
                    _filterChip('Selesai', 'selesai'),
                    _filterChip('Belum Ada', 'belum'),
                  ])),
                  const SizedBox(height: 14),
                  if (_error != null && _tugasList.isEmpty)
                    Center(child: Column(children: [Text(_error!, textAlign: TextAlign.center), TextButton(onPressed: _loadTugas, child: const Text('Coba Lagi'))]))
                  else if (visible.isEmpty)
                    EmptyState(icon: Icons.assignment_outlined, title: 'Belum Ada Tugas', message: _searchController.text.isEmpty ? 'Belum ada tugas penilaian untuk kelas ini.' : 'Tidak ada tugas yang cocok dengan pencarian atau filter.', actionText: 'Muat Ulang', onAction: _loadTugas)
                  else
                    ...visible.map(_buildTaskCard),
                  const SizedBox(height: 14),
                  if (totalSubmissions > 0)
                    Text('Total pengumpulan pada tugas yang tampil: $totalSubmissions', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                ],
              ),
            ),
    );
  }

  Widget _buildHero(String subject, String className, int totalStudents, int taskCount, double progress, int graded) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primaryDark, AppColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _heroTag('Penilaian Guru'),
          const Spacer(),
          _heroTag('$taskCount Asesmen'),
        ]),
        const SizedBox(height: 14),
        Text(subject, style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800)),
        const SizedBox(height: 3),
        Text('Kelas $className • $totalStudents siswa', style: TextStyle(color: Colors.white.withValues(alpha: .85), fontSize: 11)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: .14), borderRadius: BorderRadius.circular(11)),
          child: Column(children: [
            Row(children: [
              const Expanded(child: Text('PROGRES PENILAIAN', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w700))),
              Text('${(progress * 100).toStringAsFixed(1)}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 19)),
            ]),
            const SizedBox(height: 7),
            ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: progress, minHeight: 7, backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation(Color(0xFF6EE7B7)))),
            const SizedBox(height: 5),
            Align(alignment: Alignment.centerLeft, child: Text('$graded penilaian tersimpan', style: const TextStyle(color: Colors.white70, fontSize: 10))),
          ]),
        ),
      ]),
    );
  }

  Widget _heroTag(String label) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .17), borderRadius: BorderRadius.circular(6)), child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)));

  Widget _statCard(String label, String value, IconData icon, Color color) => Expanded(child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(11), border: Border.all(color: AppColors.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: color, size: 19),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 19)),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
        ]),
      ));

  Widget _filterChip(String label, String value) {
    final selected = _filter == value;
    return Padding(padding: const EdgeInsets.only(right: 7), child: ChoiceChip(label: Text(label), selected: selected, showCheckmark: false, onSelected: (_) => setState(() => _filter = value), selectedColor: AppColors.primary, backgroundColor: Colors.white, side: BorderSide(color: selected ? AppColors.primary : AppColors.border), labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)));
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    final total = _count(task, 'total_siswa');
    final submitted = _submitted(task);
    final graded = _graded(task);
    final pending = _pending(task);
    final unsubmitted = (total - submitted).clamp(0, 999999).toInt();
    final progress = total > 0 ? (graded / total).clamp(0.0, 1.0).toDouble() : 0.0;
    final deadline = DateTime.tryParse(task['deadline']?.toString() ?? '');
    final dateLabel = deadline == null ? 'Deadline belum ditentukan' : '${deadline.day.toString().padLeft(2, '0')} ${_monthName(deadline.month)} ${deadline.year} • ${deadline.hour.toString().padLeft(2, '0')}:${deadline.minute.toString().padLeft(2, '0')}';
    final type = (task['jenis'] ?? 'Tugas').toString();
    final bobot = task['bobot']?.toString();
    final statusLabel = pending > 0 ? '$pending Perlu Dinilai' : submitted > 0 ? 'Selesai Dinilai' : 'Belum Mengumpulkan';
    final statusColor = pending > 0 ? AppColors.warning : submitted > 0 ? AppColors.success : AppColors.textSecondary;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Wrap(spacing: 6, runSpacing: 5, children: [
            _miniTag('$type${bobot == null ? '' : ' • Bobot $bobot%'}', AppColors.primaryLight, AppColors.primary),
            _miniTag('Kelas ${widget.mapelKelas['kelas'] ?? '-'}', const Color(0xFFF1F5F9), AppColors.textSecondary),
          ])),
          _miniTag(statusLabel, statusColor.withValues(alpha: .12), statusColor),
        ]),
        const SizedBox(height: 9),
        Text(task['judul']?.toString() ?? 'Tugas', style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800)),
        const SizedBox(height: 5),
        Row(children: [const Icon(Icons.schedule_rounded, color: AppColors.textMuted, size: 13), const SizedBox(width: 5), Expanded(child: Text(dateLabel, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)))]),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(9)),
          child: Column(children: [
            Row(children: [
              Expanded(child: Text('Pengumpulan: $submitted/$total siswa', style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w600))),
              Text('$pending Belum Dikoreksi', style: TextStyle(color: pending > 0 ? AppColors.warning : AppColors.success, fontSize: 10, fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 7),
            ClipRRect(borderRadius: BorderRadius.circular(5), child: LinearProgressIndicator(value: progress, minHeight: 6, backgroundColor: AppColors.border, valueColor: const AlwaysStoppedAnimation(AppColors.success))),
            const SizedBox(height: 6),
            Row(children: [
              Expanded(child: Text('$graded Diperiksa', style: const TextStyle(color: AppColors.success, fontSize: 10))),
              Expanded(child: Text('$pending Menunggu', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.warning, fontSize: 10))),
              Expanded(child: Text('$unsubmitted Belum Kumpul', textAlign: TextAlign.end, style: const TextStyle(color: AppColors.textMuted, fontSize: 10))),
            ]),
          ]),
        ),
        const SizedBox(height: 11),
        SizedBox(width: double.infinity, child: ElevatedButton.icon(
          onPressed: () => Navigator.pushNamed(context, '/guru/nilai/detail-siswa', arguments: task).then((_) => _loadTugas(showLoader: false)),
          icon: const Icon(Icons.rate_review_outlined, size: 17),
          label: const Text('Input Nilai / Detail Siswa'),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9))),
        )),
      ]),
    );
  }

  Widget _miniTag(String label, Color background, Color foreground) => Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4), decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(5)), child: Text(label, style: TextStyle(color: foreground, fontSize: 9, fontWeight: FontWeight.w700)));
  String _monthName(int month) => const ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'][month - 1];
}

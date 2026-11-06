import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/api_config.dart';
import '../../../utils/constants.dart';
import '../../../widgets/common/empty_state.dart';

class DaftarSiswaMengumpulkanScreen extends StatefulWidget {
  final Map<String, dynamic> tugas;
  const DaftarSiswaMengumpulkanScreen({super.key, this.tugas = const {}});

  @override
  State<DaftarSiswaMengumpulkanScreen> createState() => _DaftarSiswaMengumpulkanScreenState();
}

class _DaftarSiswaMengumpulkanScreenState extends State<DaftarSiswaMengumpulkanScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _siswaList = [];
  bool _isLoading = true;
  String? _error;
  String _filter = 'semua';
  String _sort = 'tercepat';

  @override
  void initState() {
    super.initState();
    _loadSiswa();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSiswa({bool showLoader = true}) async {
    if (showLoader && mounted) setState(() => _isLoading = true);
    try {
      final taskId = widget.tugas['id'];
      if (taskId == null) throw Exception('ID tugas tidak ditemukan.');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) throw Exception('Sesi login tidak ditemukan.');
      final response = await http.get(
        Uri.parse('${ApiConfig.guruTugas}/$taskId/submission'),
        headers: ApiConfig.headers(token),
      ).timeout(ApiConfig.timeout);
      final body = jsonDecode(response.body);
      if (response.statusCode != 200 || body is! Map || body['success'] != true) {
        throw Exception(body is Map ? (body['message']?.toString() ?? 'Gagal memuat data siswa.') : 'Respons server tidak valid.');
      }
      final students = (body['data'] as List? ?? [])
          .whereType<Map>()
          .map((row) => Map<String, dynamic>.from(row))
          .toList();
      if (!mounted) return;
      setState(() { _siswaList = students; _isLoading = false; _error = null; });
    } catch (error) {
      if (!mounted) return;
      setState(() { _isLoading = false; _error = error.toString().replaceFirst('Exception: ', ''); });
    }
  }

  List<Map<String, dynamic>> get _visibleStudents {
    final query = _searchController.text.trim().toLowerCase();
    final list = _siswaList.where((student) {
      final name = (student['nama_siswa'] ?? '').toString().toLowerCase();
      final nis = (student['nis'] ?? '').toString().toLowerCase();
      if (query.isNotEmpty && !name.contains(query) && !nis.contains(query)) return false;
      switch (_filter) {
        case 'belum_dinilai': return student['status'] == 'submitted';
        case 'sudah_dinilai': return student['status'] == 'graded';
        case 'belum_kumpul': return student['status'] == 'not_submitted';
        default: return true;
      }
    }).toList();
    list.sort((a, b) {
      switch (_sort) {
        case 'az': return (a['nama_siswa'] ?? '').toString().compareTo((b['nama_siswa'] ?? '').toString());
        case 'za': return (b['nama_siswa'] ?? '').toString().compareTo((a['nama_siswa'] ?? '').toString());
        case 'nilai': return ((b['nilai'] as num?) ?? -1).compareTo((a['nilai'] as num?) ?? -1);
        default:
          final left = DateTime.tryParse(a['waktu_pengumpulan']?.toString() ?? '') ?? DateTime(2100);
          final right = DateTime.tryParse(b['waktu_pengumpulan']?.toString() ?? '') ?? DateTime(2100);
          return left.compareTo(right);
      }
    });
    return list;
  }

  Future<void> _openCorrection(Map<String, dynamic> student, List<Map<String, dynamic>> visible) async {
    final index = visible.indexWhere((row) => row['siswa_id'].toString() == student['siswa_id'].toString());
    final result = await Navigator.pushNamed(context, '/guru/nilai/koreksi', arguments: {
      'tugas': widget.tugas,
      'siswaList': visible,
      'index': index < 0 ? 0 : index,
    });
    if (result == true && mounted) await _loadSiswa(showLoader: false);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.tugas['judul']?.toString() ?? 'Penilaian Tugas';
    final subject = widget.tugas['mata_pelajaran']?.toString() ?? 'Mata Pelajaran';
    final className = widget.tugas['kelas']?.toString() ?? 'Kelas';
    final total = _siswaList.length;
    final submitted = _siswaList.where((s) => s['status'] == 'submitted' || s['status'] == 'graded').length;
    final graded = _siswaList.where((s) => s['status'] == 'graded').length;
    final pending = submitted - graded;
    final notSubmitted = total - submitted;
    final visible = _visibleStudents;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary)),
        title: const Text('Daftar Pengumpulan', style: TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _loadSiswa(showLoader: false),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  _buildTaskHeader(title, subject, className, submitted, total, graded),
                  const SizedBox(height: 12),
                  Row(children: [
                    _statCard('Mengumpulkan', submitted, AppColors.primary, Icons.description_outlined),
                    const SizedBox(width: 8),
                    _statCard('Perlu Dinilai', pending, AppColors.warning, Icons.pending_actions_rounded),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    _statCard('Sudah Dinilai', graded, AppColors.success, Icons.verified_outlined),
                    const SizedBox(width: 8),
                    _statCard('Belum Kumpul', notSubmitted, AppColors.error, Icons.person_off_outlined),
                  ]),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(prefixIcon: const Icon(Icons.search_rounded), hintText: 'Cari nama siswa atau NISN...', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: AppColors.border)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: AppColors.border))),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
                    _filterChip('Semua ($total)', 'semua'),
                    _filterChip('Belum Dinilai ($pending)', 'belum_dinilai'),
                    _filterChip('Sudah Dinilai ($graded)', 'sudah_dinilai'),
                    _filterChip('Belum Kumpul ($notSubmitted)', 'belum_kumpul'),
                  ])),
                  const SizedBox(height: 9),
                  Row(children: [
                    const Icon(Icons.sort_rounded, size: 17, color: AppColors.textSecondary),
                    const SizedBox(width: 5),
                    const Text('Urutkan:', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    const SizedBox(width: 8),
                    Expanded(child: DropdownButtonHideUnderline(child: DropdownButton<String>(
                      value: _sort,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'tercepat', child: Text('Pengumpulan Tercepat', style: TextStyle(fontSize: 11))),
                        DropdownMenuItem(value: 'az', child: Text('Nama A - Z', style: TextStyle(fontSize: 11))),
                        DropdownMenuItem(value: 'za', child: Text('Nama Z - A', style: TextStyle(fontSize: 11))),
                        DropdownMenuItem(value: 'nilai', child: Text('Nilai Tertinggi', style: TextStyle(fontSize: 11))),
                      ],
                      onChanged: (value) => setState(() => _sort = value ?? 'tercepat'),
                    ))),
                  ]),
                  const SizedBox(height: 8),
                  if (_error != null && _siswaList.isEmpty)
                    Center(child: Column(children: [Text(_error!, textAlign: TextAlign.center), TextButton(onPressed: _loadSiswa, child: const Text('Coba Lagi'))]))
                  else if (visible.isEmpty)
                    const Padding(padding: EdgeInsets.all(26), child: Center(child: Text('Tidak ada siswa pada filter ini.')))
                  else
                    ...visible.map((student) => _buildStudentCard(student, visible)),
                ],
              ),
            ),
    );
  }

  Widget _buildTaskHeader(String title, String subject, String className, int submitted, int total, int graded) {
    final progress = submitted > 0 ? (graded / submitted).clamp(0.0, 1.0).toDouble() : 0.0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primaryDark, AppColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(15)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .17), borderRadius: BorderRadius.circular(6)), child: Text('$className • $subject', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600))),
          const Spacer(),
          Text('${DateTime.now().day} ${_monthName(DateTime.now().month)} ${DateTime.now().year}', style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ]),
        const SizedBox(height: 13),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 5),
        Text(widget.tugas['deskripsi']?.toString() ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 14),
        Row(children: [
          const Expanded(child: Text('Progres Penilaian', style: TextStyle(color: Colors.white70, fontSize: 10))),
          Text('$graded dari $submitted Dinilai (${(progress * 100).toStringAsFixed(0)}%)', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 7),
        ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: progress, minHeight: 7, backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation(Color(0xFF6EE7B7)))),
      ]),
    );
  }

  Widget _statCard(String label, int value, Color color, IconData icon) => Expanded(child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(11), border: Border.all(color: AppColors.border)),
        child: Row(children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(9)), child: Icon(icon, color: color, size: 19)),
          const SizedBox(width: 9),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('$value', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 19)), Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10))])),
        ]),
      ));

  Widget _filterChip(String label, String value) {
    final selected = _filter == value;
    return Padding(padding: const EdgeInsets.only(right: 7), child: ChoiceChip(label: Text(label), selected: selected, showCheckmark: false, onSelected: (_) => setState(() => _filter = value), selectedColor: AppColors.primary, backgroundColor: Colors.white, side: BorderSide(color: selected ? AppColors.primary : AppColors.border), labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w600)));
  }

  Widget _buildStudentCard(Map<String, dynamic> student, List<Map<String, dynamic>> visible) {
    final status = student['status']?.toString() ?? 'not_submitted';
    final submitted = status == 'submitted' || status == 'graded';
    final graded = status == 'graded';
    final late = student['status_pengumpulan']?.toString() == 'terlambat';
    final score = student['nilai'];
    final name = student['nama_siswa']?.toString() ?? 'Siswa';
    final color = graded ? AppColors.success : submitted ? AppColors.warning : AppColors.error;
    final label = graded ? '${score ?? 0} / 100' : submitted ? (late ? 'Terlambat • Belum Dinilai' : 'Belum Dinilai') : 'Belum Kumpul';
    final submittedAt = student['waktu_pengumpulan']?.toString();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(radius: 22, backgroundColor: const Color(0xFFEFF6FF), child: Text(_initials(name), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800))),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w800)),
            Text('NIS: ${student['nis'] ?? '-'} • Kelas ${widget.tugas['kelas'] ?? '-'}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
          ])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(7)), child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700))),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Icon(submitted ? Icons.attach_file_rounded : Icons.event_busy_rounded, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 5),
          Expanded(child: Text(submitted ? (submittedAt == null ? 'Sudah mengumpulkan' : 'Dikumpulkan $submittedAt') : 'Belum ada pengumpulan', style: const TextStyle(color: AppColors.textSecondary, fontSize: 10))),
        ]),
        const SizedBox(height: 9),
        SizedBox(width: double.infinity, child: submitted
            ? ElevatedButton.icon(
                onPressed: () => _openCorrection(student, visible),
                icon: Icon(graded ? Icons.edit_note_rounded : Icons.rate_review_outlined, size: 17),
                label: Text(graded ? 'Edit Nilai / Review' : 'Periksa & Nilai'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 11), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9))),
              )
            : OutlinedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.hourglass_empty_rounded, size: 16),
                label: const Text('Menunggu Pengumpulan'),
                style: OutlinedButton.styleFrom(disabledForegroundColor: AppColors.textMuted, side: const BorderSide(color: AppColors.border)),
              )),
      ]),
    );
  }

  String _initials(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toList();
    if (words.isEmpty) return 'S';
    return words.take(2).map((word) => word[0].toUpperCase()).join();
  }

  String _monthName(int month) => const ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'][month - 1];
}

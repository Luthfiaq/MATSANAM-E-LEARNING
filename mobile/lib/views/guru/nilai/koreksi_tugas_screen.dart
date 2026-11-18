import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/api_config.dart';
import '../../../utils/constants.dart';

class KoreksiTugasScreen extends StatefulWidget {
  final Map<String, dynamic> tugas;
  final List<Map<String, dynamic>> siswaList;
  final int initialIndex;

  const KoreksiTugasScreen({
    super.key,
    required this.tugas,
    required this.siswaList,
    this.initialIndex = 0,
  });

  @override
  State<KoreksiTugasScreen> createState() => _KoreksiTugasScreenState();
}

class _KoreksiTugasScreenState extends State<KoreksiTugasScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _scoreController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  late List<Map<String, dynamic>> _students;
  int _index = 0;
  bool _isSaving = false;
  bool _downloadingFile = false;
  bool _dirty = false;

  Map<String, dynamic> get _student => _students[_index];

  @override
  void initState() {
    super.initState();
    _students = widget.siswaList
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
    if (_students.isEmpty) _students = [<String, dynamic>{}];
    _index = widget.initialIndex.clamp(0, _students.length - 1).toInt();
    _loadStudentFields();
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  void _loadStudentFields() {
    _scoreController.text = _student['nilai']?.toString() ?? '';
    _feedbackController.text = _student['catatan']?.toString() ?? '';
    _dirty = false;
  }

  Future<bool> _confirmDiscard() async {
    if (!_dirty) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Perubahan belum disimpan'),
        content: const Text(
          'Nilai atau catatan yang sedang diubah akan hilang. Tetap lanjut?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Tetap di sini'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Buang Perubahan'),
          ),
        ],
      ),
    );
    return result == true;
  }

  Future<void> _moveTo(int next) async {
    if (next < 0 || next >= _students.length || next == _index) return;
    if (!await _confirmDiscard() || !mounted) return;
    setState(() {
      _index = next;
      _loadStudentFields();
    });
  }

  Future<bool> _saveScore({required bool continueNext}) async {
    if (_isSaving) return false;
    if (!_formKey.currentState!.validate()) return false;
    final submissionId = _student['pengumpulan_id'];
    if (submissionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Siswa belum mengumpulkan tugas sehingga belum dapat diberi nilai.',
          ),
        ),
      );
      return false;
    }

    final score = double.tryParse(_scoreController.text.replaceAll(',', '.'));
    if (score == null) return false;
    setState(() => _isSaving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty)
        throw Exception('Sesi login tidak ditemukan.');
      final response = await http
          .post(
            Uri.parse(ApiConfig.guruNilai),
            headers: ApiConfig.headers(token),
            body: jsonEncode({
              'pengumpulan_id': submissionId,
              'nilai': score,
              'catatan': _feedbackController.text.trim(),
            }),
          )
          .timeout(ApiConfig.timeout);
      final body = jsonDecode(response.body);
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          body is! Map ||
          body['success'] != true) {
        throw Exception(
          body is Map
              ? (body['message']?.toString() ?? 'Nilai gagal disimpan.')
              : 'Respons server tidak valid.',
        );
      }
      if (!mounted) return false;
      setState(() {
        _student['status'] = 'graded';
        _student['nilai'] = score;
        _student['catatan'] = _feedbackController.text.trim();
        _student['tanggal_penilaian'] = DateTime.now().toIso8601String();
        _dirty = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            body['message']?.toString() ?? 'Nilai berhasil disimpan.',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (continueNext) {
        if (_index + 1 < _students.length) {
          setState(() {
            _index++;
            _loadStudentFields();
          });
        } else {
          Navigator.pop(context, true);
        }
      }
      return true;
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return false;
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  List<Map<String, dynamic>> _attachments() {
    final raw = _student['file_jawaban'];
    if (raw == null || raw.toString().trim().isEmpty) return [];

    final explicitName = _student['file_name']?.toString();
    final url = _student['file_url']?.toString();
    if (raw is List) {
      return raw.map((item) {
        final path = item.toString();
        return <String, dynamic>{'name': _fileName(path), 'url': url};
      }).toList();
    }

    return [
      <String, dynamic>{
        'name': explicitName?.isNotEmpty == true
            ? explicitName
            : _fileName(raw.toString()),
        'url': url,
      },
    ];
  }

  Future<void> _downloadAttachment(Map<String, dynamic> attachment) async {
    final url = attachment['url']?.toString();
    final name = attachment['name']?.toString() ?? 'jawaban-siswa';
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tautan berkas belum tersedia. Muat ulang daftar pengumpulan.',
          ),
        ),
      );
      return;
    }
    if (_downloadingFile) return;

    setState(() => _downloadingFile = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty)
        throw Exception('Sesi login tidak ditemukan.');

      final sourceUri = Uri.parse(url);
      final apiBase = Uri.parse(ApiConfig.baseUrl);
      final downloadUri = apiBase.replace(
        path: sourceUri.path,
        query: sourceUri.hasQuery ? sourceUri.query : null,
      );
      final response = await http
          .get(
            downloadUri,
            headers: {'Accept': '*/*', 'Authorization': 'Bearer $token'},
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        var message = 'Gagal mengunduh berkas (HTTP ${response.statusCode}).';
        try {
          final body = jsonDecode(response.body);
          if (body is Map && body['message'] != null)
            message = body['message'].toString();
        } catch (_) {}
        throw Exception(message);
      }

      final saved = await FilePicker.platform.saveFile(
        dialogTitle: 'Simpan jawaban siswa',
        fileName: name,
        bytes: response.bodyBytes,
      );
      if (mounted && saved != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berkas jawaban siap disimpan.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal mengunduh berkas: ${error.toString().replaceFirst('Exception: ', '')}',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _downloadingFile = false);
    }
  }

  String _fileName(String path) => path.replaceAll('\\', '/').split('/').last;

  @override
  Widget build(BuildContext context) {
    final taskTitle = widget.tugas['judul']?.toString() ?? 'Tugas';
    final name = _student['nama_siswa']?.toString() ?? 'Siswa';
    final className = widget.tugas['kelas']?.toString() ?? '-';
    final subject = widget.tugas['mata_pelajaran']?.toString() ?? '-';
    final submittedAt =
        _student['waktu_pengumpulan']?.toString() ??
        'Waktu pengumpulan tidak tersedia';
    final attachments = _attachments();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () async {
            if (await _confirmDiscard() && mounted)
              Navigator.pop(context, true);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
          ),
        ),
        title: const Text(
          'Detail & Koreksi Tugas',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
          children: [
            _buildStudentNavigator(name, className, subject),
            const SizedBox(height: 12),
            _buildSubmissionCard(name, className, submittedAt, attachments),
            const SizedBox(height: 14),
            _buildScoringCard(taskTitle),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildStudentNavigator(String name, String className, String subject) {
    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: _index > 0 && !_isSaving
              ? () => _moveTo(_index - 1)
              : null,
          icon: const Icon(Icons.chevron_left_rounded, size: 18),
          label: const Text('Sebelumnya', style: TextStyle(fontSize: 10)),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            side: const BorderSide(color: AppColors.border),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                '${_index + 1} dari ${_students.length} Siswa',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
              Text(
                '$className • $subject',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: _index < _students.length - 1 && !_isSaving
              ? () => _moveTo(_index + 1)
              : null,
          icon: const Icon(Icons.chevron_right_rounded, size: 18),
          label: const Text('Berikutnya', style: TextStyle(fontSize: 10)),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.border),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmissionCard(
    String name,
    String className,
    String submittedAt,
    List<Map<String, dynamic>> attachments,
  ) {
    final isLate = _student['status_pengumpulan']?.toString() == 'terlambat';
    final submitted = _student['pengumpulan_id'] != null;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Kelas $className • NIS ${_student['nis'] ?? '-'}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                submitted
                    ? Icons.verified_rounded
                    : Icons.hourglass_empty_rounded,
                color: submitted ? AppColors.success : AppColors.warning,
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  submitted
                      ? 'Diserahkan $submittedAt${isLate ? ' (Terlambat)' : ' (Tepat Waktu)'}'
                      : 'Belum mengumpulkan tugas',
                  style: TextStyle(
                    color: submitted
                        ? (isLate ? AppColors.warning : AppColors.success)
                        : AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.folder_open_rounded,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 7),
              const Expanded(
                child: Text(
                  'Berkas Siswa',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${attachments.length} File',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (attachments.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Text(
                'Tidak ada berkas lampiran.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
            )
          else
            ...attachments.map((file) {
              final fileName = file['name']?.toString() ?? 'Berkas jawaban';
              final canDownload = (file['url'] ?? '').toString().isNotEmpty;
              return Container(
                margin: const EdgeInsets.only(bottom: 7),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: ListTile(
                  dense: true,
                  leading: Icon(
                    fileName.toLowerCase().endsWith('.pdf')
                        ? Icons.picture_as_pdf_outlined
                        : Icons.insert_drive_file_outlined,
                    color: AppColors.primary,
                  ),
                  title: Text(
                    fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    canDownload
                        ? 'Unduh berkas jawaban siswa'
                        : 'Berkas tersimpan; tautan unduh belum tersedia',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  trailing: canDownload
                      ? IconButton(
                          tooltip: 'Unduh berkas',
                          onPressed: _downloadingFile
                              ? null
                              : () => _downloadAttachment(file),
                          icon: _downloadingFile
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.download_rounded,
                                  color: AppColors.primary,
                                ),
                        )
                      : const Icon(
                          Icons.lock_outline_rounded,
                          size: 18,
                          color: AppColors.textMuted,
                        ),
                  onTap: canDownload && !_downloadingFile
                      ? () => _downloadAttachment(file)
                      : null,
                ),
              );
            }),
          if ((_student['jawaban'] ?? '').toString().trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text(
              'Jawaban Tertulis',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 7),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(9),
              ),
              child: SelectableText(
                _student['jawaban'].toString(),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ),
          ],
          if (!submitted) ...[
            const SizedBox(height: 12),
            const Text(
              'Input nilai dapat dilakukan setelah siswa mengumpulkan tugas.',
              style: TextStyle(color: AppColors.warning, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScoringCard(String taskTitle) {
    final submitted = _student['pengumpulan_id'] != null;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Input Skor Nilai Tugas',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            '$taskTitle • Skala 0–100',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _scoreController,
            enabled: submitted && !_isSaving,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'^\d{0,3}([.,]\d{0,2})?$'),
              ),
            ],
            onChanged: (_) => _dirty = true,
            decoration: InputDecoration(
              labelText: 'Nilai Akhir',
              suffixText: '/ 100',
              prefixIcon: const Icon(Icons.grade_outlined),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
            validator: (value) {
              if (!submitted) return null;
              final score = double.tryParse((value ?? '').replaceAll(',', '.'));
              if (score == null) return 'Masukkan nilai antara 0 sampai 100.';
              if (score < 0 || score > 100)
                return 'Nilai harus berada pada rentang 0–100.';
              return null;
            },
          ),
          const SizedBox(height: 14),
          const Text(
            'Catatan / Masukan untuk Siswa',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          TextFormField(
            controller: _feedbackController,
            enabled: submitted && !_isSaving,
            maxLines: 4,
            maxLength: 1000,
            onChanged: (_) => _dirty = true,
            decoration: InputDecoration(
              hintText: 'Tuliskan masukan yang membangun untuk siswa...',
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'Nilai dapat diperbarui kembali. Penyimpanan akan memperbarui nilai untuk pengumpulan siswa ini.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    final submitted = _student['pengumpulan_id'] != null;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: !submitted || _isSaving
                    ? null
                    : () => _saveScore(continueNext: true),
                icon: _isSaving
                    ? const SizedBox(
                        width: 17,
                        height: 17,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_rounded, size: 17),
                label: Text(
                  _index + 1 < _students.length
                      ? 'Simpan & Lanjut Siswa Berikutnya'
                      : 'Simpan Nilai & Kembali',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: !submitted || _isSaving
                        ? null
                        : () => _saveScore(continueNext: false),
                    icon: const Icon(Icons.save_outlined, size: 16),
                    label: const Text(
                      'Simpan Nilai Saja',
                      style: TextStyle(fontSize: 11),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton.icon(
                    onPressed: _isSaving
                        ? null
                        : () async {
                            if (await _confirmDiscard() && mounted)
                              Navigator.pop(context, true);
                          },
                    icon: const Icon(Icons.list_alt_rounded, size: 16),
                    label: const Text(
                      'Daftar Siswa',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

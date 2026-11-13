import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/api_config.dart';
import '../../../utils/constants.dart';

class TambahMateriScreen extends StatefulWidget {
  final Map<String, dynamic> initialSchedule;

  const TambahMateriScreen({super.key, this.initialSchedule = const {}});

  @override
  State<TambahMateriScreen> createState() => _TambahMateriScreenState();
}

class _TambahMateriScreenState extends State<TambahMateriScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _linkController = TextEditingController();

  List<Map<String, dynamic>> _schedules = [];
  int? _selectedJadwalId;
  String _selectedType = 'pdf';
  PlatformFile? _selectedFile;
  bool _isLoadingSchedules = true;
  String? _scheduleError;
  bool _isSaving = false;

  bool get _needsFile => _selectedType == 'pdf' || _selectedType == 'video';

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<String> _requireToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null || token.isEmpty) {
      throw Exception('Sesi login tidak ditemukan. Silakan login kembali.');
    }
    return token;
  }

  Future<void> _loadSchedules() async {
    if (mounted) {
      setState(() {
        _isLoadingSchedules = true;
        _scheduleError = null;
      });
    }
    try {
      final token = await _requireToken();
      final response = await http
          .get(
            Uri.parse(ApiConfig.guruMapelKelas),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(ApiConfig.timeout);
      final decoded = jsonDecode(response.body);
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          decoded is! Map ||
          decoded['success'] != true) {
        throw Exception(
          decoded is Map
              ? decoded['message']?.toString() ??
                    'Jadwal mengajar gagal dimuat.'
              : 'Jadwal mengajar gagal dimuat.',
        );
      }
      final rows = (decoded['data'] as List? ?? [])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      final requestedId = int.tryParse(
        widget.initialSchedule['jadwal_id']?.toString() ?? '',
      );
      int? selected =
          requestedId != null &&
              rows.any(
                (row) =>
                    int.tryParse(row['id']?.toString() ?? '') == requestedId,
              )
          ? requestedId
          : null;
      if (selected == null && widget.initialSchedule['mapel'] != null) {
        final expectedSubject = widget.initialSchedule['mapel']
            .toString()
            .toLowerCase();
        final expectedClass = widget.initialSchedule['kelas']
            ?.toString()
            .toLowerCase();
        for (final row in rows) {
          if ((row['mata_pelajaran'] ?? '').toString().toLowerCase() ==
                  expectedSubject &&
              (expectedClass == null ||
                  _prettyClass(row['kelas']?.toString() ?? '').toLowerCase() ==
                      expectedClass)) {
            selected = int.tryParse(row['id']?.toString() ?? '');
            break;
          }
        }
      }
      if (!mounted) return;
      setState(() {
        _schedules = rows;
        _selectedJadwalId = selected;
        _scheduleError = rows.isEmpty
            ? 'Belum ada jadwal mengajar yang terhubung dengan akun ini.'
            : null;
        _isLoadingSchedules = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoadingSchedules = false;
        _scheduleError = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  String _prettyClass(String raw) {
    final value = raw.trim().replaceFirst(
      RegExp(r'^Kelas\s+', caseSensitive: false),
      '',
    );
    final match = RegExp(
      r'^(VII|VIII|IX)\s*([A-Z])$',
      caseSensitive: false,
    ).firstMatch(value);
    if (match == null) return raw.startsWith('Kelas') ? raw : 'Kelas $raw';
    const levels = {'VII': '7', 'VIII': '8', 'IX': '9'};
    return 'Kelas ${levels[match.group(1)!.toUpperCase()]}${match.group(2)!.toUpperCase()}';
  }

  Future<void> _pickFile() async {
    final extensions = _selectedType == 'pdf'
        ? ['pdf']
        : ['mp4', 'mov', 'webm'];
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: extensions,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.single;
      if (file.bytes == null)
        throw Exception('File tidak dapat dibaca. Coba pilih file kembali.');
      if (file.size > 10 * 1024 * 1024)
        throw Exception('Ukuran file maksimal 10 MB.');
      if (!mounted) return;
      setState(() => _selectedFile = file);
    } catch (error) {
      if (!mounted) return;
      _showMessage(
        error.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    }
  }

  String _responseMessage(dynamic decoded, String fallback) {
    if (decoded is Map) {
      final errors = decoded['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
      }
      final message = decoded['message']?.toString();
      if (message != null && message.isNotEmpty) return message;
    }
    return fallback;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedJadwalId == null) {
      _showMessage(
        'Pilih mata pelajaran dan kelas terlebih dahulu.',
        isError: true,
      );
      return;
    }
    if (_needsFile && _selectedFile?.bytes == null) {
      _showMessage(
        'Pilih file ${_selectedType.toUpperCase()} terlebih dahulu.',
        isError: true,
      );
      return;
    }
    if (_selectedType == 'link') {
      final uri = Uri.tryParse(_linkController.text.trim());
      if (uri == null ||
          !uri.hasScheme ||
          !['http', 'https'].contains(uri.scheme)) {
        _showMessage(
          'Masukkan URL yang valid dan diawali http:// atau https://.',
          isError: true,
        );
        return;
      }
    }

    setState(() => _isSaving = true);
    try {
      final token = await _requireToken();
      late http.Response response;
      if (_needsFile) {
        final request =
            http.MultipartRequest('POST', Uri.parse(ApiConfig.guruMateri))
              ..headers['Accept'] = 'application/json'
              ..headers['Authorization'] = 'Bearer $token'
              ..fields['jadwal_id'] = _selectedJadwalId.toString()
              ..fields['judul'] = _judulController.text.trim()
              ..fields['deskripsi'] = _deskripsiController.text.trim()
              ..fields['tipe'] = _selectedType
              ..files.add(
                http.MultipartFile.fromBytes(
                  'file',
                  _selectedFile!.bytes!,
                  filename: _selectedFile!.name,
                ),
              );
        final streamed = await request.send().timeout(ApiConfig.timeout);
        response = await http.Response.fromStream(
          streamed,
        ).timeout(ApiConfig.timeout);
      } else {
        response = await http
            .post(
              Uri.parse(ApiConfig.guruMateri),
              headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
              body: jsonEncode({
                'jadwal_id': _selectedJadwalId,
                'judul': _judulController.text.trim(),
                'deskripsi': _deskripsiController.text.trim(),
                'tipe': 'link',
                'link': _linkController.text.trim(),
              }),
            )
            .timeout(ApiConfig.timeout);
      }

      dynamic decoded;
      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        decoded = null;
      }
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          decoded is! Map ||
          decoded['success'] != true) {
        throw Exception(
          _responseMessage(
            decoded,
            'Materi gagal disimpan (HTTP ${response.statusCode}).',
          ),
        );
      }
      if (!mounted) return;
      _showMessage(
        decoded['message']?.toString() ?? 'Materi berhasil ditambahkan.',
      );
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      _showMessage(
        error.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text('Tambah Materi', style: AppTypography.heading3),
      ),
      body: _isLoadingSchedules
          ? const Center(child: CircularProgressIndicator())
          : _scheduleError != null && _schedules.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.event_busy_outlined,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _scheduleError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _loadSchedules,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _sectionCard(
                        title: 'Informasi Materi',
                        subtitle:
                            'Tentukan jadwal mengajar dan informasi materi.',
                        children: [
                          DropdownButtonFormField<int>(
                            value: _selectedJadwalId,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Mata Pelajaran & Kelas',
                              border: OutlineInputBorder(),
                            ),
                            items: _schedules
                                .map((schedule) {
                                  final id = int.tryParse(
                                    schedule['id']?.toString() ?? '',
                                  );
                                  final mapel =
                                      schedule['mata_pelajaran']?.toString() ??
                                      'Mata Pelajaran';
                                  final kelas = _prettyClass(
                                    schedule['kelas']?.toString() ?? '',
                                  );
                                  return DropdownMenuItem<int>(
                                    value: id,
                                    child: Text(
                                      '$mapel • $kelas',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                })
                                .where((item) => item.value != null)
                                .toList(),
                            onChanged: _isSaving
                                ? null
                                : (value) =>
                                      setState(() => _selectedJadwalId = value),
                            validator: (value) =>
                                value == null ? 'Pilih jadwal mengajar.' : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _judulController,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              labelText: 'Judul Materi',
                              hintText: 'Contoh: Sistem Persamaan Linear',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.menu_book_outlined),
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? 'Judul materi wajib diisi.'
                                : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _deskripsiController,
                            maxLines: 3,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              labelText: 'Deskripsi',
                              hintText: 'Ringkasan isi materi...',
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _sectionCard(
                        title: 'Jenis Materi',
                        subtitle: 'Pilih satu jenis sumber materi.',
                        children: [
                          SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(
                                value: 'pdf',
                                label: Text('PDF'),
                                icon: Icon(Icons.picture_as_pdf_outlined),
                              ),
                              ButtonSegment(
                                value: 'video',
                                label: Text('Video'),
                                icon: Icon(Icons.play_circle_outline),
                              ),
                              ButtonSegment(
                                value: 'link',
                                label: Text('Link'),
                                icon: Icon(Icons.link_rounded),
                              ),
                            ],
                            selected: {_selectedType},
                            onSelectionChanged: _isSaving
                                ? null
                                : (selection) => setState(() {
                                    _selectedType = selection.first;
                                    _selectedFile = null;
                                  }),
                          ),
                          const SizedBox(height: 14),
                          if (_needsFile) _filePickerCard() else _linkField(),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 50,
                        child: FilledButton.icon(
                          onPressed: _isSaving ? null : _submit,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.cloud_upload_outlined),
                          label: Text(
                            _isSaving
                                ? 'Menyimpan...'
                                : 'Simpan & Terbitkan Materi',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _sectionCard({
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .025),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.heading3),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    ),
  );

  Widget _filePickerCard() => InkWell(
    borderRadius: BorderRadius.circular(13),
    onTap: _isSaving ? null : _pickFile,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.primary.withValues(alpha: .25)),
      ),
      child: Column(
        children: [
          Icon(
            _selectedType == 'pdf'
                ? Icons.picture_as_pdf_outlined
                : Icons.video_file_outlined,
            color: AppColors.primary,
            size: 32,
          ),
          const SizedBox(height: 9),
          Text(
            _selectedFile?.name ?? 'Pilih file ${_selectedType.toUpperCase()}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'PDF atau video • Maksimal 10 MB',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
          if (_selectedFile != null) ...[
            const SizedBox(height: 7),
            Text(
              '${(_selectedFile!.size / (1024 * 1024)).toStringAsFixed(2)} MB',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    ),
  );

  Widget _linkField() => TextFormField(
    controller: _linkController,
    keyboardType: TextInputType.url,
    decoration: const InputDecoration(
      labelText: 'URL Materi',
      hintText: 'https://...',
      prefixIcon: Icon(Icons.link_rounded),
      border: OutlineInputBorder(),
    ),
    validator: (value) {
      if (value == null || value.trim().isEmpty)
        return 'URL materi wajib diisi.';
      final uri = Uri.tryParse(value.trim());
      if (uri == null ||
          !uri.hasScheme ||
          !['http', 'https'].contains(uri.scheme))
        return 'Masukkan URL http/https yang valid.';
      return null;
    },
  );
}

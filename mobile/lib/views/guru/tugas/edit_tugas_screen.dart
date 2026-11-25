import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../services/guru_tugas_service.dart';
import '../../../utils/constants.dart';
import '../../../utils/theme_helpers.dart';
import '../../../utils/camera_task_attachment.dart';

class EditTugasScreen extends StatefulWidget {
  final Map<String, dynamic> tugas;

  const EditTugasScreen({super.key, this.tugas = const {}});

  @override
  State<EditTugasScreen> createState() => _EditTugasScreenState();
}

class _EditTugasScreenState extends State<EditTugasScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = GuruTugasService();
  late final TextEditingController _judulController;
  late final TextEditingController _deskripsiController;
  late final TextEditingController _bobotController;

  DateTime? _selectedDeadline;
  final List<PlatformFile> _newFiles = <PlatformFile>[];
  final List<Map<String, dynamic>> _existingFiles = <Map<String, dynamic>>[];
  String _selectedJenis = 'tugas';
  bool _isSaving = false;
  bool _isManagingFiles = false;
  bool _uploadFailed = false;
  double? _uploadProgress;
  String _attachmentBatchId = DateTime.now().microsecondsSinceEpoch
      .toRadixString(36);
  String? _lastRequestFingerprint;

  static const _jenisOptions = <String, String>{
    'tugas': 'Tugas',
    'quiz': 'Kuis',
    'uts': 'Ujian Tengah Semester',
    'uas': 'Ujian Akhir Semester',
  };

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(
      text: widget.tugas['judul']?.toString() ?? '',
    );
    _deskripsiController = TextEditingController(
      text: widget.tugas['deskripsi']?.toString() ?? '',
    );
    _bobotController = TextEditingController(
      text: widget.tugas['bobot']?.toString() ?? '100',
    );
    final jenis = widget.tugas['jenis']?.toString() ?? 'tugas';
    _selectedJenis = _jenisOptions.containsKey(jenis) ? jenis : 'tugas';
    final rawDeadline = widget.tugas['deadline']?.toString();
    if (rawDeadline != null && rawDeadline.isNotEmpty) {
      final parsed = DateTime.tryParse(rawDeadline);
      if (parsed != null) {
        final wib = parsed.toUtc().add(const Duration(hours: 7));
        // Keep the school wall-clock fields for DatePicker/TimePicker input.
        _selectedDeadline = DateTime(
          wib.year,
          wib.month,
          wib.day,
          wib.hour,
          wib.minute,
          wib.second,
        );
      }
    }

    final rawFiles = widget.tugas['lampiran_files'];
    if (rawFiles is List) {
      _existingFiles.addAll(
        rawFiles.whereType<Map>().map(
          (file) => Map<String, dynamic>.from(file),
        ),
      );
    }
    // Keep compatibility with tasks created by older app versions.
    if (_existingFiles.isEmpty) {
      final legacyPath = widget.tugas['file_materi']?.toString();
      if (legacyPath != null && legacyPath.isNotEmpty) {
        _existingFiles.add({
          'id': 'legacy',
          'file_name': legacyPath.split('/').last,
          'is_legacy': true,
          'available': true,
        });
      }
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _bobotController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: true,
        allowedExtensions: const [
          'pdf',
          'doc',
          'docx',
          'ppt',
          'pptx',
          'xls',
          'xlsx',
          'jpg',
          'jpeg',
          'png',
          'txt',
          'zip',
        ],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final validFiles = <PlatformFile>[];
      final rejected = <String>[];
      for (final file in result.files) {
        if (file.size > GuruTugasService.maxFileBytes) {
          rejected.add('${file.name} (lebih dari 20 MB)');
          continue;
        }
        if (file.bytes == null) {
          rejected.add('${file.name} (tidak dapat dibaca)');
          continue;
        }
        final duplicate =
            _newFiles.any(
              (existing) =>
                  existing.name == file.name && existing.size == file.size,
            ) ||
            validFiles.any(
              (existing) =>
                  existing.name == file.name && existing.size == file.size,
            );
        if (duplicate) continue;
        if (_newFiles.length + validFiles.length >=
            GuruTugasService.maxFilesPerUpload) {
          rejected.add('${file.name} (maksimal 20 file per unggahan)');
          continue;
        }
        validFiles.add(file);
      }
      if (!mounted) return;
      setState(() => _newFiles.addAll(validFiles));
      if (rejected.isNotEmpty) {
        _showMessage(
          'File berikut tidak ditambahkan: ${rejected.join(', ')}. Batas 20 MB per file dan 20 file per unggahan.',
          isError: true,
        );
      }
    } catch (error) {
      _showMessage(_cleanError(error), isError: true);
    }
  }

  Future<void> _capturePhoto() async {
    try {
      final photo = await captureTaskPhoto(namePrefix: 'lampiran_tugas_guru');
      if (photo == null || !mounted) return;
      if (photo.size > GuruTugasService.maxFileBytes) {
        _showMessage(
          'Foto melebihi batas 20 MB dan tidak ditambahkan.',
          isError: true,
        );
        return;
      }
      if (photo.bytes == null) {
        _showMessage(
          'Foto tidak dapat dibaca. Silakan ambil ulang.',
          isError: true,
        );
        return;
      }
      if (_newFiles.length >= GuruTugasService.maxFilesPerUpload) {
        _showMessage(
          'Maksimal 20 file baru dalam satu proses unggah.',
          isError: true,
        );
        return;
      }
      setState(() => _newFiles.add(photo));
      _showMessage('Foto berhasil ditambahkan sebagai lampiran baru.');
    } catch (error) {
      _showMessage(_cleanError(error), isError: true);
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / 1024).toStringAsFixed(0)} KB';
  }

  Future<void> _downloadExistingFile(Map<String, dynamic> file) async {
    final taskId = int.tryParse(widget.tugas['id']?.toString() ?? '');
    final fileId = file['id']?.toString();
    final fileName = file['file_name']?.toString() ?? 'lampiran';
    if (taskId == null || fileId == null || fileId.isEmpty) return;

    try {
      final bytes = await _service.downloadTaskAttachment(
        taskId: taskId,
        fileId: fileId,
      );
      final savedPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Simpan lampiran tugas',
        fileName: fileName,
        bytes: bytes,
      );
      if (!mounted) return;
      if (savedPath != null)
        _showMessage('File "$fileName" berhasil disimpan.');
    } catch (error) {
      _showMessage(_cleanError(error), isError: true);
    }
  }

  Future<void> _deleteExistingFile(Map<String, dynamic> file) async {
    final taskId = int.tryParse(widget.tugas['id']?.toString() ?? '');
    final fileId = file['id']?.toString();
    if (taskId == null || fileId == null || fileId.isEmpty) return;

    final name = file['file_name']?.toString() ?? 'lampiran ini';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Hapus lampiran?'),
        content: Text('File "$name" akan dihapus dari tugas ini.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isManagingFiles = true);
    try {
      final message = await _service.deleteTaskAttachment(
        taskId: taskId,
        fileId: fileId,
      );
      if (!mounted) return;
      setState(
        () => _existingFiles.removeWhere(
          (item) => item['id']?.toString() == fileId,
        ),
      );
      _showMessage(message);
    } catch (error) {
      _showMessage(_cleanError(error), isError: true);
    } finally {
      if (mounted) setState(() => _isManagingFiles = false);
    }
  }

  Future<void> _deleteAllExistingFiles() async {
    if (_existingFiles.isEmpty) return;
    final taskId = int.tryParse(widget.tugas['id']?.toString() ?? '');
    if (taskId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Hapus semua lampiran?'),
        content: Text(
          '${_existingFiles.length} file lampiran tugas akan dihapus. Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('Hapus semua'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isManagingFiles = true);
    try {
      final message = await _service.deleteAllTaskAttachments(taskId);
      if (!mounted) return;
      setState(_existingFiles.clear);
      _showMessage(message);
    } catch (error) {
      _showMessage(_cleanError(error), isError: true);
    } finally {
      if (mounted) setState(() => _isManagingFiles = false);
    }
  }

  DateTime _schoolNow() {
    final wib = DateTime.now().toUtc().add(const Duration(hours: 7));
    return DateTime(wib.year, wib.month, wib.day, wib.hour, wib.minute);
  }

  Future<void> _pickDeadline() async {
    final now = _schoolNow();
    final current = _selectedDeadline ?? now;
    final initial = current.isBefore(now) ? now : current;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (!mounted || picked == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedDeadline == null
          ? const TimeOfDay(hour: 23, minute: 59)
          : TimeOfDay.fromDateTime(_selectedDeadline!),
    );
    if (time == null || !mounted) return;
    setState(() {
      _selectedDeadline = DateTime(
        picked.year,
        picked.month,
        picked.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    final taskId = int.tryParse(widget.tugas['id']?.toString() ?? '');
    if (taskId == null) {
      _showMessage(
        'ID tugas tidak ditemukan. Kembali ke daftar lalu buka ulang tugas.',
        isError: true,
      );
      return;
    }
    if (_selectedDeadline == null) {
      _showMessage(
        'Deadline tugas belum tersedia. Tentukan deadline terlebih dahulu.',
        isError: true,
      );
      return;
    }
    final bobot = int.tryParse(_bobotController.text.trim());
    if (bobot == null || bobot < 1 || bobot > 100) {
      _showMessage(
        'Bobot nilai harus berupa angka 1 sampai 100.',
        isError: true,
      );
      return;
    }

    final fingerprint = [
      taskId,
      _judulController.text.trim(),
      _deskripsiController.text.trim(),
      _selectedJenis,
      _selectedDeadline?.toIso8601String(),
      bobot,
      ..._newFiles.map(
        (file) =>
            '${file.name}:${file.size}:${file.bytes == null ? 0 : Object.hashAll(file.bytes!)}',
      ),
    ].join('|');
    if (_lastRequestFingerprint != fingerprint) {
      _attachmentBatchId = DateTime.now().microsecondsSinceEpoch.toRadixString(
        36,
      );
      _lastRequestFingerprint = fingerprint;
    }

    setState(() {
      _isSaving = true;
      _uploadFailed = false;
      _uploadProgress = _newFiles.isEmpty ? null : 0;
    });
    try {
      final message = await _service.updateTask(
        taskId: taskId,
        judul: _judulController.text.trim(),
        deskripsi: _deskripsiController.text.trim(),
        jenis: _selectedJenis,
        deadline: _selectedDeadline!,
        bobot: bobot,
        files: List<PlatformFile>.from(_newFiles),
        attachmentBatchId: _attachmentBatchId,
        onProgress: (progress) {
          if (!mounted || _newFiles.isEmpty) return;
          setState(() => _uploadProgress = progress);
        },
      );
      if (!mounted) return;
      _showMessage(message);
      Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        setState(() => _uploadFailed = _newFiles.isNotEmpty);
        _showMessage(
          '${_cleanError(error)}. File baru tetap dipilih; tekan Simpan Perubahan lagi untuk mencoba ulang.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _cleanError(Object error) =>
      error.toString().replaceFirst('Exception: ', '');

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _scheduleText() {
    final schedule = widget.tugas['jadwal'];
    if (schedule is Map) {
      final subject = schedule['mata_pelajaran'];
      final classData = schedule['kelas'];
      final subjectName = subject is Map ? subject['nama'] : null;
      final className = classData is Map ? classData['nama_kelas'] : null;
      if (subjectName != null || className != null) {
        return '${subjectName ?? 'Mapel'} — ${className ?? 'Kelas'}';
      }
    }
    final subject = widget.tugas['mata_pelajaran']?.toString();
    final className = widget.tugas['kelas']?.toString();
    if (subject != null || className != null)
      return '${subject ?? 'Mapel'} — ${className ?? 'Kelas'}';
    return 'Jadwal #${widget.tugas['jadwal_id'] ?? '-'}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.matsanamPage,
      appBar: AppBar(
        backgroundColor: context.matsanamSurface,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: context.matsanamText,
          ),
        ),
        title: Text(
          'Edit Tugas',
          style: TextStyle(
            color: context.matsanamText,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionCard(
                      title: 'Informasi Tugas',
                      children: [
                        InputDecorator(
                          decoration: _inputDecoration(
                            'Mata Pelajaran dan Kelas',
                          ),
                          child: Text(
                            _scheduleText(),
                            style: TextStyle(
                              color: context.matsanamText,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedJenis,
                          decoration: _inputDecoration('Jenis Tugas'),
                          items: _jenisOptions.entries
                              .map(
                                (entry) => DropdownMenuItem(
                                  value: entry.key,
                                  child: Text(entry.value),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedJenis = value ?? 'tugas'),
                        ),
                        const SizedBox(height: 12),
                        _textField(
                          _judulController,
                          'Judul Tugas',
                          required: true,
                        ),
                        const SizedBox(height: 12),
                        _textField(
                          _deskripsiController,
                          'Deskripsi / Instruksi',
                          required: true,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 12),
                        _textField(
                          _bobotController,
                          'Bobot Nilai',
                          required: true,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _sectionCard(
                      title: 'Deadline',
                      children: [
                        InkWell(
                          onTap: _pickDeadline,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: context.matsanamSurface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: context.matsanamBorder),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  color: AppColors.warning,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _selectedDeadline == null
                                        ? 'Pilih deadline'
                                        : _formatDateTime(_selectedDeadline!),
                                    style: TextStyle(
                                      color: _selectedDeadline == null
                                          ? context.matsanamTextSecondary
                                          : context.matsanamText,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: context.matsanamTextSecondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _sectionCard(
                      title: 'Lampiran Tugas',
                      children: [
                        if (_existingFiles.isNotEmpty) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_existingFiles.length} lampiran tersimpan',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: (_isSaving || _isManagingFiles)
                                    ? null
                                    : _deleteAllExistingFiles,
                                icon: Icon(Icons.delete_sweep_outlined),
                                label: Text('Hapus semua'),
                              ),
                            ],
                          ),
                          ..._existingFiles.map((file) {
                            final name =
                                file['file_name']?.toString() ?? 'Lampiran';
                            final available = file['available'] != false;
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                Icons.insert_drive_file_outlined,
                              ),
                              title: Text(
                                name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                available
                                    ? 'Lampiran tersimpan'
                                    : 'File tidak ditemukan di storage',
                              ),
                              trailing: Wrap(
                                spacing: 0,
                                children: [
                                  IconButton(
                                    tooltip: 'Unduh file ini',
                                    onPressed:
                                        (_isSaving ||
                                            _isManagingFiles ||
                                            !available)
                                        ? null
                                        : () => _downloadExistingFile(file),
                                    icon: Icon(Icons.download_outlined),
                                  ),
                                  IconButton(
                                    tooltip: 'Hapus file ini',
                                    onPressed: (_isSaving || _isManagingFiles)
                                        ? null
                                        : () => _deleteExistingFile(file),
                                    icon: Icon(
                                      Icons.delete_outline_rounded,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          Divider(),
                        ] else
                          Text(
                            'Belum ada lampiran pada tugas ini.',
                            style: TextStyle(color: context.matsanamTextSecondary),
                          ),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: (_isSaving || _isManagingFiles)
                                    ? null
                                    : _pickFiles,
                                icon: Icon(Icons.upload_file_rounded),
                                label: Text('Pilih File'),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(48),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: (_isSaving || _isManagingFiles)
                                    ? null
                                    : _capturePhoto,
                                icon: Icon(Icons.camera_alt_outlined),
                                label: Text('Ambil Foto'),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(48),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Setiap file maksimal 20 MB. Maksimal 20 file per proses tambah; file baru ditambahkan tanpa menghapus lampiran lama.',
                          style: TextStyle(
                            color: context.matsanamTextSecondary,
                            fontSize: 11,
                          ),
                        ),
                        if (_isSaving && _uploadProgress != null) ...[
                          const SizedBox(height: 10),
                          LinearProgressIndicator(value: _uploadProgress),
                          const SizedBox(height: 4),
                          Text(
                            'Mengunggah lampiran ${(100 * (_uploadProgress ?? 0)).round()}%',
                            style: TextStyle(
                              fontSize: 11,
                              color: context.matsanamTextSecondary,
                            ),
                          ),
                        ],
                        if (_uploadFailed)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              'Percobaan ulang menggunakan ID yang sama agar lampiran tidak terduplikasi.',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                        if (_newFiles.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_newFiles.length} file baru dipilih',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: (_isSaving || _isManagingFiles)
                                    ? null
                                    : () => setState(_newFiles.clear),
                                icon: Icon(Icons.delete_sweep_outlined),
                                label: Text('Hapus semua pilihan'),
                              ),
                            ],
                          ),
                          ..._newFiles.asMap().entries.map((entry) {
                            final index = entry.key;
                            final file = entry.value;
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.attach_file_rounded),
                              title: Text(
                                file.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(_formatFileSize(file.size)),
                              trailing: IconButton(
                                tooltip: 'Hapus pilihan file ini',
                                onPressed: _isSaving
                                    ? null
                                    : () => setState(
                                        () => _newFiles.removeAt(index),
                                      ),
                                icon: Icon(Icons.close_rounded),
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _submitForm,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(Icons.check_rounded),
                        label: Text(
                          _uploadFailed
                              ? 'Coba Simpan Lagi'
                              : 'Simpan Perubahan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _sectionCard({
    required String title,
    required List<Widget> children,
  }) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: context.matsanamSurface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: context.matsanamBorder),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: context.matsanamText,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        ...children,
      ],
    ),
  );

  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: context.matsanamSurface,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: context.matsanamBorder),
    ),
  );

  Widget _textField(
    TextEditingController controller,
    String label, {
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) => TextFormField(
    controller: controller,
    maxLines: maxLines,
    keyboardType: keyboardType,
    decoration: _inputDecoration(label),
    validator: (value) {
      if (required && (value == null || value.trim().isEmpty))
        return '$label wajib diisi.';
      if (label == 'Bobot Nilai') {
        final number = int.tryParse(value?.trim() ?? '');
        if (number == null || number < 1 || number > 100)
          return 'Bobot harus 1 sampai 100.';
      }
      return null;
    },
  );

  String _formatDateTime(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')} WIB';
}

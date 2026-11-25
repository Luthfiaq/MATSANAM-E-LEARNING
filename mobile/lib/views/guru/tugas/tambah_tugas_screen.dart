import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../services/guru_tugas_service.dart';
import '../../../utils/constants.dart';
import '../../../utils/camera_task_attachment.dart';

class TambahTugasScreen extends StatefulWidget {
  final Map<String, dynamic> initialSchedule;

  const TambahTugasScreen({super.key, this.initialSchedule = const {}});

  @override
  State<TambahTugasScreen> createState() => _TambahTugasScreenState();
}

class _TambahTugasScreenState extends State<TambahTugasScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = GuruTugasService();
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _bobotController = TextEditingController(text: '100');

  List<Map<String, dynamic>> _schedules = [];
  int? _selectedJadwalId;
  DateTime? _selectedDeadline;
  final List<PlatformFile> _selectedFiles = <PlatformFile>[];
  String _selectedJenis = 'tugas';
  bool _isLoadingSchedules = true;
  bool _isSaving = false;
  bool _uploadFailed = false;
  double? _uploadProgress;
  String _clientRequestId = DateTime.now().microsecondsSinceEpoch.toRadixString(
    36,
  );
  String? _lastRequestFingerprint;
  String? _loadError;

  static const _jenisOptions = <String, String>{
    'tugas': 'Tugas',
    'quiz': 'Kuis',
    'uts': 'Ujian Tengah Semester',
    'uas': 'Ujian Akhir Semester',
  };

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _bobotController.dispose();
    super.dispose();
  }

  Future<void> _loadSchedules() async {
    setState(() {
      _isLoadingSchedules = true;
      _loadError = null;
    });
    try {
      final rows = await _service.loadSchedules();
      final requestedId = int.tryParse(
        (widget.initialSchedule['jadwal_id'] ?? widget.initialSchedule['id'])
                ?.toString() ??
            '',
      );
      final selected =
          requestedId != null &&
              rows.any((row) => _scheduleId(row) == requestedId)
          ? requestedId
          : null;
      if (!mounted) return;
      setState(() {
        _schedules = rows;
        _selectedJadwalId =
            selected ?? (rows.length == 1 ? _scheduleId(rows.first) : null);
        _isLoadingSchedules = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoadingSchedules = false;
        _loadError = _cleanError(error);
      });
    }
  }

  int? _scheduleId(Map<String, dynamic> row) =>
      int.tryParse(row['jadwal_id']?.toString() ?? row['id']?.toString() ?? '');

  String _scheduleLabel(Map<String, dynamic> row) {
    final subject = row['mata_pelajaran']?.toString() ?? 'Mapel';
    final className = row['kelas']?.toString() ?? 'Kelas';
    final day = row['hari']?.toString();
    final start = row['jam_mulai']?.toString();
    final end = row['jam_selesai']?.toString();
    final time = (start != null && end != null) ? ' • $start–$end' : '';
    final dayLabel = day == null || day.isEmpty ? '' : ' • $day';
    return '$subject — $className$dayLabel$time';
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
            _selectedFiles.any(
              (existing) =>
                  existing.name == file.name && existing.size == file.size,
            ) ||
            validFiles.any(
              (existing) =>
                  existing.name == file.name && existing.size == file.size,
            );
        if (duplicate) continue;
        if (_selectedFiles.length + validFiles.length >=
            GuruTugasService.maxFilesPerUpload) {
          rejected.add('${file.name} (maksimal 20 file per unggahan)');
          continue;
        }
        validFiles.add(file);
      }

      if (!mounted) return;
      setState(() => _selectedFiles.addAll(validFiles));
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
      if (_selectedFiles.length >= GuruTugasService.maxFilesPerUpload) {
        _showMessage('Maksimal 20 file dalam satu unggahan.', isError: true);
        return;
      }
      setState(() => _selectedFiles.add(photo));
      _showMessage('Foto berhasil ditambahkan sebagai lampiran.');
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

  DateTime _schoolNow() {
    final wib = DateTime.now().toUtc().add(const Duration(hours: 7));
    return DateTime(wib.year, wib.month, wib.day, wib.hour, wib.minute);
  }

  Future<void> _pickDeadline() async {
    final now = _schoolNow();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? now.add(const Duration(days: 1)),
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
    if (_selectedJadwalId == null) {
      _showMessage(
        'Pilih mata pelajaran dan kelas terlebih dahulu.',
        isError: true,
      );
      return;
    }
    if (_selectedDeadline == null) {
      _showMessage('Tentukan deadline tugas terlebih dahulu.', isError: true);
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
      _selectedJadwalId,
      _judulController.text.trim(),
      _deskripsiController.text.trim(),
      _selectedJenis,
      _selectedDeadline?.toIso8601String(),
      bobot,
      ..._selectedFiles.map(
        (file) =>
            '${file.name}:${file.size}:${file.bytes == null ? 0 : Object.hashAll(file.bytes!)}',
      ),
    ].join('|');
    if (_lastRequestFingerprint != fingerprint) {
      _clientRequestId = DateTime.now().microsecondsSinceEpoch.toRadixString(
        36,
      );
      _lastRequestFingerprint = fingerprint;
    }

    setState(() {
      _isSaving = true;
      _uploadFailed = false;
      _uploadProgress = _selectedFiles.isEmpty ? null : 0;
    });
    try {
      final message = await _service.createTask(
        jadwalId: _selectedJadwalId!,
        judul: _judulController.text.trim(),
        deskripsi: _deskripsiController.text.trim(),
        jenis: _selectedJenis,
        deadline: _selectedDeadline!,
        bobot: bobot,
        files: List<PlatformFile>.from(_selectedFiles),
        clientRequestId: _clientRequestId,
        onProgress: (progress) {
          if (!mounted || _selectedFiles.isEmpty) return;
          setState(() => _uploadProgress = progress);
        },
      );
      if (!mounted) return;
      _showMessage(message);
      Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        setState(() => _uploadFailed = _selectedFiles.isNotEmpty);
        _showMessage(
          '${_cleanError(error)}. File tetap tersimpan di daftar; tekan Simpan Tugas lagi untuk mencoba ulang.',
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
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
          ),
        ),
        title: const Text(
          'Buat Tugas Baru',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _isLoadingSchedules
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
          ? _buildLoadError()
          : _isSaving
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
                        _buildScheduleField(),
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
                          'Masukkan judul tugas',
                          required: true,
                        ),
                        const SizedBox(height: 12),
                        _textField(
                          _deskripsiController,
                          'Deskripsi / Instruksi',
                          'Masukkan instruksi pengerjaan',
                          required: true,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 12),
                        _textField(
                          _bobotController,
                          'Bobot Nilai',
                          '1–100',
                          keyboardType: TextInputType.number,
                          required: true,
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
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                const Icon(
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
                                          ? AppColors.textSecondary
                                          : AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _sectionCard(
                      title: 'Lampiran (Opsional)',
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _isSaving ? null : _pickFiles,
                                icon: const Icon(Icons.upload_file_rounded),
                                label: const Text('Pilih File'),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(48),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _isSaving ? null : _capturePhoto,
                                icon: const Icon(Icons.camera_alt_outlined),
                                label: const Text('Ambil Foto'),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(48),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Setiap file maksimal 20 MB. Maksimal 20 file dalam satu unggahan.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                        if (_isSaving && _uploadProgress != null) ...[
                          const SizedBox(height: 10),
                          LinearProgressIndicator(value: _uploadProgress),
                          const SizedBox(height: 4),
                          Text(
                            'Mengunggah lampiran ${(100 * (_uploadProgress ?? 0)).round()}%',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                        if (_uploadFailed)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              'Unggah belum terkonfirmasi. Percobaan ulang memakai ID yang sama agar tugas tidak dibuat dua kali.',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                        if (_selectedFiles.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_selectedFiles.length} file dipilih',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _isSaving
                                    ? null
                                    : () => setState(_selectedFiles.clear),
                                icon: const Icon(Icons.delete_sweep_outlined),
                                label: const Text('Hapus semua'),
                              ),
                            ],
                          ),
                          ..._selectedFiles.asMap().entries.map((entry) {
                            final index = entry.key;
                            final file = entry.value;
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.attach_file_rounded),
                              title: Text(
                                file.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(_formatFileSize(file.size)),
                              trailing: IconButton(
                                tooltip: 'Hapus file ini',
                                onPressed: _isSaving
                                    ? null
                                    : () => setState(
                                        () => _selectedFiles.removeAt(index),
                                      ),
                                icon: const Icon(Icons.delete_outline_rounded),
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
                            : const Icon(Icons.check_rounded),
                        label: Text(
                          _uploadFailed ? 'Coba Simpan Lagi' : 'Simpan Tugas',
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

  Widget _buildLoadError() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 42, color: AppColors.error),
          const SizedBox(height: 12),
          Text(_loadError!, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _loadSchedules,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    ),
  );

  Widget _buildScheduleField() {
    if (_schedules.isEmpty) {
      return const Text(
        'Belum ada jadwal mengajar yang dapat dipilih. Periksa penugasan Guru di web admin.',
      );
    }
    return DropdownButtonFormField<int>(
      value: _selectedJadwalId,
      isExpanded: true,
      decoration: _inputDecoration('Mata Pelajaran dan Kelas'),
      items: _schedules
          .map((row) {
            final id = _scheduleId(row);
            if (id == null) return null;
            return DropdownMenuItem<int>(
              value: id,
              child: Text(_scheduleLabel(row), overflow: TextOverflow.ellipsis),
            );
          })
          .whereType<DropdownMenuItem<int>>()
          .toList(),
      onChanged: (value) => setState(() => _selectedJadwalId = value),
      validator: (value) => value == null ? 'Pilih jadwal mengajar.' : null,
    );
  }

  Widget _sectionCard({
    required String title,
    required List<Widget> children,
  }) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
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
    fillColor: AppColors.surface,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: AppColors.border),
    ),
  );

  Widget _textField(
    TextEditingController controller,
    String label,
    String hint, {
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) => TextFormField(
    controller: controller,
    maxLines: maxLines,
    keyboardType: keyboardType,
    decoration: _inputDecoration(label).copyWith(hintText: hint),
    validator: (value) {
      if (required && (value == null || value.trim().isEmpty))
        return '$label wajib diisi.';
      if (label == 'Bobot Nilai') {
        final valueInt = int.tryParse(value?.trim() ?? '');
        if (valueInt == null || valueInt < 1 || valueInt > 100)
          return 'Bobot harus 1 sampai 100.';
      }
      return null;
    },
  );

  String _formatDateTime(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')} WIB';
}

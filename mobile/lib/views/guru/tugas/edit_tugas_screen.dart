import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../services/guru_tugas_service.dart';
import '../../../utils/constants.dart';

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
  PlatformFile? _replacementFile;
  String _selectedJenis = 'tugas';
  bool _isSaving = false;

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
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _bobotController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
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
      final file = result.files.single;
      if (file.bytes == null)
        throw Exception('File tidak dapat dibaca. Silakan pilih ulang.');
      if (file.size > 10 * 1024 * 1024)
        throw Exception('Ukuran lampiran maksimal 10 MB.');
      if (!mounted) return;
      setState(() => _replacementFile = file);
    } catch (error) {
      _showMessage(_cleanError(error), isError: true);
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

    setState(() => _isSaving = true);
    try {
      final message = await _service.updateTask(
        taskId: taskId,
        judul: _judulController.text.trim(),
        deskripsi: _deskripsiController.text.trim(),
        jenis: _selectedJenis,
        deadline: _selectedDeadline!,
        bobot: bobot,
        file: _replacementFile,
      );
      if (!mounted) return;
      _showMessage(message);
      Navigator.pop(context, true);
    } catch (error) {
      _showMessage(_cleanError(error), isError: true);
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

  String _attachmentName() {
    if (_replacementFile != null) return _replacementFile!.name;
    final path = widget.tugas['file_materi']?.toString();
    if (path == null || path.isEmpty) return 'Belum ada lampiran';
    return path.split('/').last;
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
          'Edit Tugas',
          style: TextStyle(
            color: AppColors.textPrimary,
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
                            style: const TextStyle(
                              color: AppColors.textPrimary,
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
                      title: 'Lampiran',
                      children: [
                        Text(
                          _attachmentName(),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: _pickFile,
                          icon: const Icon(Icons.upload_file_rounded),
                          label: Text(
                            _replacementFile == null
                                ? 'Ganti / Tambah Lampiran'
                                : 'Ganti File: ${_replacementFile!.name}',
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _submitForm,
                        icon: const Icon(Icons.check_rounded),
                        label: const Text(
                          'Simpan Perubahan',
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

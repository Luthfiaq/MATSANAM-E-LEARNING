import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../models/absensi_model.dart';
import '../../../services/absensi_service.dart';
import '../../../services/siswa_learning_service.dart';
import '../../../utils/theme_helpers.dart';

class UploadSuratScreen extends StatefulWidget {
  const UploadSuratScreen({super.key});

  @override
  State<UploadSuratScreen> createState() => _UploadSuratScreenState();
}

class _UploadSuratScreenState extends State<UploadSuratScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = AbsensiService();
  final _learningService = SiswaLearningService();
  final _reasonController = TextEditingController();

  String _type = 'izin';
  String _scope = 'sehari_penuh';
  List<Map<String, dynamic>> _scheduleOptions = [];
  int? _selectedScheduleId;
  bool _loadingSchedules = false;
  DateTime? _startDate;
  DateTime? _endDate;
  Uint8List? _fileBytes;
  String? _fileName;
  bool _submitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  String _isoDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Future<void> _setScope(String value) async {
    setState(() {
      _scope = value;
      _selectedScheduleId = null;
      _scheduleOptions = [];
    });
    if (value == 'pulang_lebih_awal' && _startDate != null) {
      await _loadScheduleOptions(_startDate!);
    }
  }

  Future<void> _loadScheduleOptions(DateTime date) async {
    if (_scope != 'pulang_lebih_awal') return;
    setState(() {
      _loadingSchedules = true;
      _scheduleOptions = [];
      _selectedScheduleId = null;
    });
    try {
      final schedules = await _learningService.jadwal(tanggal: _isoDate(date));
      if (!mounted) return;
      // Mata pelajaran acuan adalah pelajaran pertama yang mulai diizinkan.
      // Pelajaran yang sudah tercatat Hadir tidak ditawarkan karena catatan
      // Hadir yang valid tidak boleh diubah menjadi Izin/Sakit.
      final options = schedules
          .where((item) => (item['absensi_status'] ?? '').toString().toLowerCase() != 'hadir')
          .toList();
      setState(() {
        _scheduleOptions = options;
        _loadingSchedules = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadingSchedules = false;
        _scheduleOptions = [];
      });
      _showMessage('Gagal memuat jadwal: $error', isError: true);
    }
  }

  String _selectedScheduleLabel() {
    Map<String, dynamic>? item;
    for (final row in _scheduleOptions) {
      if ((row['id'] as num?)?.toInt() == _selectedScheduleId) {
        item = row;
        break;
      }
    }
    if (item == null) return 'mata pelajaran yang dipilih';
    return '${item['mapel']} (${item['jam_mulai']}–${item['jam_selesai']})';
  }

  Future<void> _selectDate({required bool start}) async {
    final now = DateTime.now();
    final minimum = start
        ? DateTime(2020, 1, 1)
        : (_startDate ?? DateTime(2020, 1, 1));
    final current = start
        ? (_startDate ?? now)
        : (_endDate ?? _startDate ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: current.isBefore(minimum) ? minimum : current,
      firstDate: minimum,
      lastDate: DateTime(now.year + 2, 12, 31),
      helpText: start ? 'Pilih tanggal mulai' : 'Pilih tanggal selesai',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(
            context,
          ).colorScheme.copyWith(primary: Theme.of(context).colorScheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked == null || !mounted) return;

    setState(() {
      if (start) {
        _startDate = picked;
        if (_endDate == null || _endDate!.isBefore(picked)) {
          _endDate = picked;
        }
        // Pilihan jadwal harus selalu berasal dari tanggal mulai pengajuan.
        _selectedScheduleId = null;
      } else {
        _endDate = picked;
      }
    });
    if (start && _scope == 'pulang_lebih_awal' && _startDate != null) {
      await _loadScheduleOptions(_startDate!);
    }
  }

  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
        withData: true,
      );
      if (result == null || !mounted) return;

      final file = result.files.single;
      final bytes = file.bytes;
      if (bytes == null) {
        _showMessage(
          'File tidak dapat dibaca. Coba pilih file lain.',
          isError: true,
        );
        return;
      }
      if (bytes.length > 5 * 1024 * 1024) {
        _showMessage('Ukuran dokumen maksimal 5 MB.', isError: true);
        return;
      }

      setState(() {
        _fileBytes = bytes;
        _fileName = file.name;
      });
    } catch (error) {
      if (mounted) _showMessage('Gagal memilih dokumen: $error', isError: true);
    }
  }

  void _removeDocument() {
    setState(() {
      _fileBytes = null;
      _fileName = null;
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      _showMessage('Pilih tanggal mulai dan tanggal selesai.', isError: true);
      return;
    }
    if (_scope == 'pulang_lebih_awal' && _selectedScheduleId == null) {
      _showMessage('Pilih mata pelajaran pertama yang mulai diizinkan.', isError: true);
      return;
    }
    if (_endDate!.isBefore(_startDate!)) {
      _showMessage(
        'Tanggal selesai tidak boleh sebelum tanggal mulai.',
        isError: true,
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Kirim pengajuan?'),
        content: Text(_confirmationMessage()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Periksa lagi'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Ya, kirim'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _submitting = true);
    try {
      final request = PengajuanIzinModel(
        jenisIzin: _type,
        tanggalMulai: _startDate!,
        tanggalSelesai: _endDate!,
        cakupan: _scope,
        jadwalAcuanId: _selectedScheduleId,
        keterangan: _reasonController.text.trim(),
        fileBytes: _fileBytes,
        fileName: _fileName,
      );
      final response = await _service.kirimPengajuanIzin(request);
      if (!mounted) return;
      final message =
          response['message']?.toString() ??
          'Pengajuan berhasil dikirim dan menunggu verifikasi.';
      Navigator.of(context).pop(message);
    } catch (error) {
      if (mounted) {
        _showMessage(
          error.toString().replaceFirst('Bad state: ', ''),
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _confirmationMessage() {
    final start = _formatIndonesianDate(_startDate!);
    final end = _formatIndonesianDate(_endDate!);
    final kind = _type == 'sakit' ? 'sakit' : 'izin';
    if (_scope == 'pulang_lebih_awal') {
      return 'Pengajuan $kind dari ${_selectedScheduleLabel()} pada $start sampai $end. Pada tanggal mulai, mata pelajaran yang dipilih dan pelajaran setelahnya masuk cakupan $kind. Pada tanggal berikutnya sampai tanggal selesai, seluruh jadwal masuk cakupan $kind setelah surat disetujui.';
    }
    return 'Pengajuan $kind sehari penuh untuk $start sampai $end akan dikirim untuk diverifikasi.';
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? context.matsanamError : context.matsanamSuccess,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Pengajuan Izin / Sakit')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: .16),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Isi informasi pengajuan dengan benar. Pengajuan akan diperiksa oleh Guru atau Admin. Dokumen pendukung dapat dilampirkan bila tersedia.',
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Jenis Pengajuan',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _TypeOption(
                      label: 'Izin',
                      subtitle: 'Keperluan pribadi',
                      icon: Icons.event_note_outlined,
                      selected: _type == 'izin',
                      onTap: () => setState(() => _type = 'izin'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TypeOption(
                      label: 'Sakit',
                      subtitle: 'Kondisi kesehatan',
                      icon: Icons.medical_services_outlined,
                      selected: _type == 'sakit',
                      onTap: () => setState(() => _type = 'sakit'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                'Cakupan Pengajuan',
                style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              _ScopeOption(
                title: 'Sehari penuh',
                subtitle: 'Seluruh mata pelajaran pada setiap tanggal yang dipilih.',
                selected: _scope == 'sehari_penuh',
                onTap: () => _setScope('sehari_penuh'),
              ),
              const SizedBox(height: 8),
              _ScopeOption(
                title: 'Pulang lebih awal',
                subtitle: 'Tentukan mata pelajaran pertama yang mulai diizinkan.',
                selected: _scope == 'pulang_lebih_awal',
                onTap: () => _setScope('pulang_lebih_awal'),
              ),
              const SizedBox(height: 22),
              Text(
                'Rentang Tanggal',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _DateField(
                      label: 'Tanggal mulai',
                      value: _startDate == null ? null : _formatIndonesianDate(_startDate!),
                      onTap: () => _selectDate(start: true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DateField(
                      label: 'Tanggal selesai',
                      value: _endDate == null ? null : _formatIndonesianDate(_endDate!),
                      onTap: () => _selectDate(start: false),
                    ),
                  ),
                ],
              ),
              if (_scope == 'pulang_lebih_awal') ...[
                const SizedBox(height: 16),
                Text(
                  'Mulai Izin Dari Mata Pelajaran',
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                if (_startDate == null)
                  Text(
                    'Pilih tanggal mulai terlebih dahulu untuk memuat jadwal kelas.',
                    style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                  )
                else if (_loadingSchedules)
                  const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()))
                else if (_scheduleOptions.isEmpty)
                  Text(
                    'Tidak ada mata pelajaran yang dapat dipilih pada tanggal mulai. Pastikan jadwal tersedia dan mata pelajaran tersebut belum tercatat Hadir.',
                    style: textTheme.bodySmall?.copyWith(color: scheme.error),
                  )
                else
                  DropdownButtonFormField<int>(
                    value: _selectedScheduleId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      hintText: 'Pilih mata pelajaran pertama yang diizinkan',
                    ),
                    items: _scheduleOptions.map((item) {
                      final id = (item['id'] as num).toInt();
                      final time = '${item['jam_mulai']}–${item['jam_selesai']}';
                      final subject = item['mapel']?.toString() ?? 'Mata pelajaran';
                      return DropdownMenuItem<int>(
                        value: id,
                        child: Text('$time · $subject', maxLines: 1, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedScheduleId = value),
                    validator: (value) => _scope == 'pulang_lebih_awal' && value == null
                        ? 'Pilih mata pelajaran pertama yang diizinkan.'
                        : null,
                  ),
                const SizedBox(height: 6),
                Text(
                  'Pada tanggal mulai, mata pelajaran yang dipilih dan semua pelajaran setelahnya menjadi cakupan izin/sakit. Pada tanggal berikutnya sampai tanggal selesai, seluruh jadwal menjadi cakupan izin/sakit. Catatan Hadir tetap dipertahankan.',
                  style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
              const SizedBox(height: 22),
              Text(
                _scope == 'pulang_lebih_awal' ? 'Alasan Pulang Lebih Awal' : 'Alasan / Keterangan',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _reasonController,
                minLines: 4,
                maxLines: 6,
                maxLength: 2000,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: _scope == 'pulang_lebih_awal'
                      ? 'Jelaskan alasan harus pulang lebih awal...'
                      : 'Jelaskan alasan pengajuan secara singkat dan jelas...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty)
                    return 'Alasan pengajuan wajib diisi.';
                  if (value.trim().length < 5)
                    return 'Keterangan minimal 5 karakter.';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              Text(
                'Dokumen Pendukung',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Opsional · PDF, JPG, JPEG, atau PNG · Maksimal 5 MB',
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              _DocumentPicker(
                fileName: _fileName,
                fileSize: _fileBytes?.length,
                onPick: _pickDocument,
                onRemove: _removeDocument,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: FilledButton.icon(
                  onPressed: _submitting ? null : _submit,
                  icon: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(
                    _submitting ? 'Mengirim pengajuan...' : 'Kirim Pengajuan',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: _submitting
                      ? null
                      : () => Navigator.of(context).maybePop(),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Batal'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScopeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _ScopeOption({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected ? Theme.of(context).colorScheme.primary.withValues(alpha: .07) : scheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? Theme.of(context).colorScheme.primary : scheme.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: selected ? Theme.of(context).colorScheme.primary : scheme.onSurfaceVariant),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: selected ? Theme.of(context).colorScheme.primary : scheme.onSurface)),
                    const SizedBox(height: 3),
                    Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeOption extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TypeOption({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected
          ? Theme.of(context).colorScheme.primary.withValues(alpha: .08)
          : scheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? Theme.of(context).colorScheme.primary : scheme.outlineVariant,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: selected ? Theme.of(context).colorScheme.primary : scheme.onSurfaceVariant,
              ),
              const SizedBox(height: 9),
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: selected ? Theme.of(context).colorScheme.primary : scheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(minHeight: 76),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: 17,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    value ?? 'Pilih tanggal',
                    maxLines: 2,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: value == null
                          ? scheme.onSurfaceVariant
                          : scheme.onSurface,
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

class _DocumentPicker extends StatelessWidget {
  final String? fileName;
  final int? fileSize;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _DocumentPicker({
    required this.fileName,
    required this.fileSize,
    required this.onPick,
    required this.onRemove,
  });

  String _readableSize(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasFile = fileName != null;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: hasFile
          ? Row(
              children: [
                Icon(
                  Icons.insert_drive_file_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 30,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (fileSize != null)
                        Text(
                          _readableSize(fileSize!),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onRemove,
                  tooltip: 'Hapus dokumen',
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            )
          : Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.upload_file_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Belum ada dokumen',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Lampirkan bukti jika tersedia',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(onPressed: onPick, child: const Text('Pilih')),
              ],
            ),
    );
  }
}

const _monthNames = <String>[
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

String _formatIndonesianDate(DateTime date) =>
    '${date.day} ${_monthNames[date.month - 1]} ${date.year}';

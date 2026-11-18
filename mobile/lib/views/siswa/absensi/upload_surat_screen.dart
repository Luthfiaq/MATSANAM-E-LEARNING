import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../models/absensi_model.dart';
import '../../../services/absensi_service.dart';
import '../../../utils/constants.dart';

class UploadSuratScreen extends StatefulWidget {
  const UploadSuratScreen({super.key});

  @override
  State<UploadSuratScreen> createState() => _UploadSuratScreenState();
}

class _UploadSuratScreenState extends State<UploadSuratScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = AbsensiService();
  final _reasonController = TextEditingController();

  String _type = 'izin';
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
          ).colorScheme.copyWith(primary: AppColors.primary),
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
      } else {
        _endDate = picked;
      }
    });
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
        content: Text(
          'Pengajuan ${_type == 'sakit' ? 'sakit' : 'izin'} untuk ${_formatIndonesianDate(_startDate!)} sampai ${_formatIndonesianDate(_endDate!)} akan dikirim untuk diverifikasi.',
        ),
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

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? AppColors.error : AppColors.success,
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
                  color: AppColors.primary.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: .16),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.primary,
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
                      value: _startDate == null
                          ? null
                          : _formatIndonesianDate(_startDate!),
                      onTap: () => _selectDate(start: true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DateField(
                      label: 'Tanggal selesai',
                      value: _endDate == null
                          ? null
                          : _formatIndonesianDate(_endDate!),
                      onTap: () => _selectDate(start: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                'Alasan / Keterangan',
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
                decoration: const InputDecoration(
                  hintText:
                      'Jelaskan alasan pengajuan secara singkat dan jelas...',
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
                    backgroundColor: AppColors.primary,
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
          ? AppColors.primary.withValues(alpha: .08)
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
              color: selected ? AppColors.primary : scheme.outlineVariant,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: selected ? AppColors.primary : scheme.onSurfaceVariant,
              ),
              const SizedBox(height: 9),
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: selected ? AppColors.primary : scheme.onSurface,
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
                const Icon(
                  Icons.calendar_month_outlined,
                  size: 17,
                  color: AppColors.primary,
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
                const Icon(
                  Icons.insert_drive_file_outlined,
                  color: AppColors.primary,
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
                    color: AppColors.primary.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.upload_file_rounded,
                    color: AppColors.primary,
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

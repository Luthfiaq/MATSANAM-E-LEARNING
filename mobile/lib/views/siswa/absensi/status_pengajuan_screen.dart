import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../services/siswa_learning_service.dart';
import '../../../utils/constants.dart';
import 'upload_surat_screen.dart';

class StatusPengajuanScreen extends StatefulWidget {
  final String? successMessage;
  const StatusPengajuanScreen({super.key, this.successMessage});

  @override
  State<StatusPengajuanScreen> createState() => _StatusPengajuanScreenState();
}

class _StatusPengajuanScreenState extends State<StatusPengajuanScreen> {
  final _service = SiswaLearningService();
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  String? _error;
  int? _downloadingId;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _successMessage = widget.successMessage;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _service.suratIzin();
      if (!mounted) return;
      setState(() {
        _items = data;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _buatPengajuan() async {
    final message = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(builder: (_) => const UploadSuratScreen()),
    );
    if (!mounted) return;
    if (message != null && message.isNotEmpty) {
      setState(() => _successMessage = message);
    }
    await _load();
  }

  Future<void> _downloadDocument(Map<String, dynamic> item) async {
    final id = (item['id'] as num?)?.toInt();
    final url = item['dokumen_url']?.toString();
    if (id == null || url == null || url.isEmpty) return;

    setState(() => _downloadingId = id);
    try {
      final bytes = await _service.downloadAuthorizedFile(url);
      final saved = await FilePicker.platform.saveFile(
        dialogTitle: 'Simpan dokumen pengajuan',
        fileName: item['nama_file']?.toString().trim().isNotEmpty == true
            ? item['nama_file'].toString()
            : 'surat-izin-$id',
        bytes: bytes,
      );
      if (!mounted) return;
      if (saved != null) {
        _snack('Dokumen berhasil disimpan.');
      }
    } catch (error) {
      if (mounted) _snack('Gagal mengunduh dokumen: $error', error: true);
    } finally {
      if (mounted) setState(() => _downloadingId = null);
    }
  }

  void _snack(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? AppColors.error : AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Pengajuan'),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _buatPengajuan,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Ajukan Izin / Sakit'),
      ),
      body: _loading && _items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _error != null && _items.isEmpty
          ? _ErrorState(message: _error!, onRetry: _load)
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 104),
                children: [
                  if (_successMessage != null) ...[
                    _SuccessBanner(message: _successMessage!),
                    const SizedBox(height: 12),
                  ],
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: .10),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Icon(
                            Icons.assignment_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pengajuan Izin / Sakit',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Pantau verifikasi pengajuan yang sudah kamu kirim.',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: scheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Riwayat Pengajuan',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      Text(
                        '${_items.length} pengajuan',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _InlineError(message: _error!, onRetry: _load),
                    ),
                  if (_items.isEmpty)
                    _EmptyState(onCreate: _buatPengajuan)
                  else
                    ..._items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ApplicationCard(
                          item: item,
                          downloading:
                              _downloadingId == (item['id'] as num?)?.toInt(),
                          onDownload: () => _downloadDocument(item),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool downloading;
  final VoidCallback onDownload;
  const _ApplicationCard({
    required this.item,
    required this.downloading,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = (item['status_verifikasi'] ?? 'pending').toString();
    final color = _statusColor(status);
    final submittedAt = _formatDateTime(item['tanggal_pengajuan']);
    final verifiedAt = _formatDateTime(item['tanggal_verifikasi']);
    final start = _formatDate(item['tanggal_mulai']);
    final end = _formatDate(item['tanggal_selesai']);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.description_outlined, color: color),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title(item['jenis']),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$start – $end',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(label: _title(status), color: color),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Alasan',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(
            _value(item['alasan']),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          _ApplicationTimeline(
            status: status,
            submittedAt: submittedAt,
            verifiedAt: verifiedAt,
          ),
          if ((item['catatan_verifikasi'] ?? '')
              .toString()
              .trim()
              .isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: status == 'ditolak'
                    ? AppColors.error.withValues(alpha: .07)
                    : scheme.surfaceContainerHighest.withValues(alpha: .6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Catatan Verifikator',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['catatan_verifikasi'].toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if ((item['verifikator'] ?? '')
                      .toString()
                      .trim()
                      .isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      'Diperiksa oleh ${item['verifikator']}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          if (item['ada_dokumen'] == true && item['dokumen_url'] != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: .45),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.attach_file_rounded,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _value(item['nama_file']),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: downloading ? null : onDownload,
                    icon: downloading
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.download_outlined, size: 17),
                    label: Text(downloading ? 'Mengunduh' : 'Unduh'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ApplicationTimeline extends StatelessWidget {
  final String status;
  final String submittedAt;
  final String verifiedAt;
  const _ApplicationTimeline({
    required this.status,
    required this.submittedAt,
    required this.verifiedAt,
  });

  @override
  Widget build(BuildContext context) {
    final isFinal = status == 'disetujui' || status == 'ditolak';
    final finalColor = _statusColor(status);
    return Column(
      children: [
        _TimelineStep(
          title: 'Pengajuan dikirim',
          subtitle: submittedAt,
          state: _TimelineState.complete,
          color: AppColors.success,
          isLast: false,
        ),
        _TimelineStep(
          title: isFinal ? 'Selesai diverifikasi' : 'Menunggu verifikasi',
          subtitle: isFinal
              ? verifiedAt
              : 'Pengajuan sedang menunggu pemeriksaan Guru / Admin.',
          state: isFinal ? _TimelineState.complete : _TimelineState.current,
          color: AppColors.primary,
          isLast: false,
        ),
        _TimelineStep(
          title: status == 'disetujui'
              ? 'Pengajuan disetujui'
              : status == 'ditolak'
              ? 'Pengajuan ditolak'
              : 'Keputusan verifikasi',
          subtitle: status == 'pending'
              ? 'Belum ada keputusan.'
              : _title(status),
          state: status == 'pending'
              ? _TimelineState.waiting
              : _TimelineState.complete,
          color: finalColor,
          isLast: true,
        ),
      ],
    );
  }
}

enum _TimelineState { complete, current, waiting }

class _TimelineStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final _TimelineState state;
  final Color color;
  final bool isLast;
  const _TimelineStep({
    required this.title,
    required this.subtitle,
    required this.state,
    required this.color,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dotColor = state == _TimelineState.waiting
        ? scheme.outlineVariant
        : color;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 22,
            child: Column(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: state == _TimelineState.waiting
                        ? scheme.surface
                        : dotColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: dotColor, width: 1.5),
                  ),
                  child: state == _TimelineState.complete
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 12,
                        )
                      : state == _TimelineState.current
                      ? Center(
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: scheme.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: state == _TimelineState.waiting
                          ? scheme.onSurfaceVariant
                          : scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 11),
    ),
  );
}

class _SuccessBanner extends StatelessWidget {
  final String message;
  const _SuccessBanner({required this.message});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: AppColors.success.withValues(alpha: .10),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.check_circle_outline_rounded,
          color: AppColors.success,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreate;
  const _EmptyState({required this.onCreate});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 32),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: Column(
      children: [
        const Icon(
          Icons.description_outlined,
          size: 42,
          color: AppColors.textMuted,
        ),
        const SizedBox(height: 10),
        Text(
          'Belum ada pengajuan',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 5),
        Text(
          'Pengajuan izin atau sakit yang kamu kirim akan muncul di sini.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: onCreate,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Buat Pengajuan'),
        ),
      ],
    ),
  );
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 42,
            color: AppColors.error,
          ),
          const SizedBox(height: 12),
          Text(
            'Status pengajuan belum dapat dimuat',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    ),
  );
}

class _InlineError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _InlineError({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.error.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        const Icon(Icons.error_outline_rounded, color: AppColors.error),
        const SizedBox(width: 8),
        Expanded(
          child: Text(message, style: Theme.of(context).textTheme.bodySmall),
        ),
        TextButton(onPressed: onRetry, child: const Text('Ulangi')),
      ],
    ),
  );
}

Color _statusColor(String status) => switch (status) {
  'disetujui' => AppColors.success,
  'ditolak' => AppColors.error,
  _ => AppColors.warning,
};

String _title(dynamic value) {
  final text = value?.toString().trim() ?? '';
  if (text.isEmpty) return '-';
  return '${text[0].toUpperCase()}${text.substring(1)}';
}

String _value(dynamic value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? '-' : text;
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

String _formatDate(dynamic value) {
  final date = DateTime.tryParse(value?.toString() ?? '');
  if (date == null) return '-';
  final local = date.toLocal();
  return '${local.day} ${_monthNames[local.month - 1]} ${local.year}';
}

String _formatDateTime(dynamic value) {
  final date = DateTime.tryParse(value?.toString() ?? '');
  if (date == null) return 'Belum tercatat';
  final local = date.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '${local.day} ${_monthNames[local.month - 1]} ${local.year}, $hour:$minute';
}

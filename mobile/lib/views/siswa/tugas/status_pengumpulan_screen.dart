import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../services/siswa_learning_service.dart';
import '../../../utils/constants.dart';
import '../nilai/detail_hasil_penilaian_screen.dart';

/// Displays the current submission state using the existing Siswa task detail API.
/// The screen intentionally shows only fields returned by Laravel today.
class StatusPengumpulanScreen extends StatefulWidget {
  final int tugasId;

  const StatusPengumpulanScreen({super.key, required this.tugasId});

  @override
  State<StatusPengumpulanScreen> createState() =>
      _StatusPengumpulanScreenState();
}

class _StatusPengumpulanScreenState extends State<StatusPengumpulanScreen> {
  final SiswaLearningService _service = SiswaLearningService();
  Map<String, dynamic> _data = {};
  bool _loading = true;
  String? _error;
  bool _downloading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _service.detailTugas(widget.tugasId);
      if (!mounted) return;
      setState(() {
        _data = result;
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

  Future<void> _downloadSubmission(Map<String, dynamic> file) async {
    final url = (file['file_url'] ?? file['url'])?.toString();
    final fileName = (file['file_name'] ?? file['name'])?.toString();
    if (url == null || url.isEmpty || fileName == null || fileName.isEmpty) {
      return;
    }

    setState(() => _downloading = true);
    try {
      final bytes = await _service.downloadAuthorizedFile(url);
      final saved = await FilePicker.platform.saveFile(
        dialogTitle: 'Simpan file pengumpulan',
        fileName: fileName,
        bytes: bytes,
      );
      if (mounted && saved != null) _message('File pengumpulan siap disimpan.');
    } catch (error) {
      if (mounted) _message('Gagal mengunduh file: $error', isError: true);
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  List<Map<String, dynamic>> _submissionFiles(Map<String, dynamic> submission) {
    final raw = submission['files'];
    if (raw is List && raw.isNotEmpty) {
      return raw
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    if (submission['file_name'] != null && submission['file_url'] != null) {
      return [
        {
          'file_name': submission['file_name'],
          'file_url': submission['file_url'],
        },
      ];
    }
    return [];
  }

  void _message(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Status Pengumpulan')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Status Pengumpulan')),
        body: _LoadError(message: _error!, onRetry: _load),
      );
    }

    final submission = _asMap(_data['pengumpulan']);
    final grade = _asMap(submission['nilai']);
    final hasSubmission = submission.isNotEmpty;
    final isGraded = grade.isNotEmpty;
    final status = (_data['status'] ?? 'belum_dikumpulkan').toString();
    final isLate =
        submission['status']?.toString() == 'terlambat' ||
        status == 'terlambat';
    final stage = isGraded
        ? 3
        : hasSubmission
        ? 2
        : 1;
    final submissionFiles = _submissionFiles(submission);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Pengumpulan'),
        actions: [
          IconButton(
            tooltip: 'Muat ulang status',
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            _TaskSummaryCard(data: _data, status: status),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'Proses Pengumpulan',
              trailing: _StageBadge(stage: stage),
              child: Column(
                children: [
                  _TimelineStep(
                    title: 'Tugas diberikan Guru',
                    detail: _date(_data['tanggal_dibuat']),
                    state: _TimelineState.complete,
                    icon: Icons.assignment_turned_in_outlined,
                  ),
                  _TimelineStep(
                    title: 'Siswa mengumpulkan tugas',
                    detail: hasSubmission
                        ? '${_date(submission['waktu_pengumpulan'])} • ${isLate ? 'Terlambat' : 'Tepat waktu'}'
                        : _notSubmittedDetail(status),
                    state: hasSubmission
                        ? _TimelineState.complete
                        : status == 'melewati_deadline'
                        ? _TimelineState.overdue
                        : _TimelineState.pending,
                    icon: Icons.upload_file_outlined,
                    isLast: false,
                  ),
                  _TimelineStep(
                    title: 'Penilaian Guru',
                    detail: isGraded
                        ? 'Nilai diterbitkan ${_date(grade['tanggal_penilaian'])}'
                        : hasSubmission
                        ? 'Menunggu Guru memeriksa pengumpulan.'
                        : 'Aktif setelah tugas dikumpulkan.',
                    state: isGraded
                        ? _TimelineState.complete
                        : hasSubmission
                        ? _TimelineState.current
                        : _TimelineState.pending,
                    icon: Icons.fact_check_outlined,
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'Informasi Pengumpulan',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(
                    label: 'Batas pengumpulan',
                    value: _date(_data['deadline']),
                  ),
                  _InfoRow(
                    label: 'Waktu dikumpulkan',
                    value: hasSubmission
                        ? _date(submission['waktu_pengumpulan'])
                        : 'Belum dikumpulkan',
                  ),
                  _InfoRow(
                    label: 'Status waktu',
                    value: hasSubmission
                        ? (isLate ? 'Terlambat' : 'Tepat waktu')
                        : _notSubmittedDetail(status),
                    valueColor: hasSubmission
                        ? (isLate ? AppColors.error : AppColors.success)
                        : AppColors.warning,
                  ),
                  if (submission['jawaban'] != null &&
                      submission['jawaban'].toString().trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Catatan/Jawaban',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(submission['jawaban'].toString()),
                    ),
                  ],
                  if (submissionFiles.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Lampiran yang dikumpulkan',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    ...submissionFiles.map((file) {
                      final name =
                          (file['file_name'] ?? file['name'] ?? 'Lampiran')
                              .toString();
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.insert_drive_file_outlined,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              tooltip: 'Unduh $name',
                              onPressed: _downloading
                                  ? null
                                  : () => _downloadSubmission(file),
                              icon: _downloading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.download_rounded),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                  if (!hasSubmission)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        'Belum ada catatan pengumpulan untuk tugas ini.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                ],
              ),
            ),
            if (isGraded) ...[
              const SizedBox(height: 14),
              _SectionCard(
                title: 'Hasil Penilaian',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_number(grade['nilai']).toStringAsFixed(0)} / ${_number(_data['bobot'], fallback: 100).toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Feedback Guru: ${_text(grade['catatan'], fallback: 'Belum ada catatan dari Guru.')} ',
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailHasilPenilaianScreen(
                              tugasId: widget.tugasId,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.assessment_outlined),
                        label: const Text('Lihat Detail Hasil Penilaian'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            const _PrivacyNote(),
          ],
        ),
      ),
    );
  }
}

class _TaskSummaryCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String status;

  const _TaskSummaryCard({required this.data, required this.status});

  @override
  Widget build(BuildContext context) {
    final tone = _statusColor(status);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${data['mapel'] ?? '-'} • ${data['kelas'] ?? '-'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              _StatusBadge(label: _statusLabel(status), color: tone),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _text(data['judul']),
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            'Guru pengampu: ${_text(data['guru'])}',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const Divider(height: 24),
          _InfoRow(label: 'Skor maksimal', value: '${data['bobot'] ?? 100}'),
          _InfoRow(
            label: 'KKM mata pelajaran',
            value: _number(data['kkm']) > 0 ? '${data['kkm']}' : 'Belum diatur',
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
        const SizedBox(height: 14),
        child,
      ],
    ),
  );
}

class _TimelineStep extends StatelessWidget {
  final String title;
  final String detail;
  final IconData icon;
  final _TimelineState state;
  final bool isLast;

  const _TimelineStep({
    required this.title,
    required this.detail,
    required this.icon,
    required this.state,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      _TimelineState.complete => AppColors.success,
      _TimelineState.current => AppColors.primary,
      _TimelineState.pending => AppColors.textMuted,
      _TimelineState.overdue => AppColors.error,
    };

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 30,
            child: Column(
              children: [
                Container(
                  width: 27,
                  height: 27,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .12),
                    shape: BoxShape.circle,
                    border: Border.all(color: color.withValues(alpha: .5)),
                  ),
                  child: Icon(
                    state == _TimelineState.complete
                        ? Icons.check_rounded
                        : icon,
                    size: 15,
                    color: color,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      color: state == _TimelineState.complete
                          ? AppColors.success.withValues(alpha: .45)
                          : AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 22, top: 3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    detail,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      height: 1.4,
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

enum _TimelineState { complete, current, pending, overdue }

class _StageBadge extends StatelessWidget {
  final int stage;
  const _StageBadge({required this.stage});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: AppColors.primaryLight,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      'Tahap $stage dari 3',
      style: const TextStyle(
        color: AppColors.primaryDark,
        fontSize: 11,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800),
    ),
  );
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 142,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: valueColor,
            ),
          ),
        ),
      ],
    ),
  );
}

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.primaryLight,
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.verified_user_outlined, color: AppColors.primary, size: 18),
        SizedBox(width: 9),
        Expanded(
          child: Text(
            'Status ditampilkan berdasarkan catatan pengumpulan dan penilaian pada server e-learning.',
            style: TextStyle(fontSize: 11, height: 1.4),
          ),
        ),
      ],
    ),
  );
}

class _LoadError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _LoadError({required this.message, required this.onRetry});

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
          const Text(
            'Gagal memuat status',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
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

Map<String, dynamic> _asMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

String _text(dynamic value, {String fallback = '-'}) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

String _date(dynamic value) {
  final date = DateTime.tryParse(value?.toString() ?? '');
  return date == null
      ? 'Belum tersedia'
      : DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(date.toLocal());
}

String _notSubmittedDetail(String status) => status == 'melewati_deadline'
    ? 'Batas waktu pengumpulan telah terlewati.'
    : 'Belum ada pengumpulan yang tercatat.';

String _statusLabel(String status) => switch (status) {
  'sudah_dinilai' => 'Sudah Dinilai',
  'sudah_dikumpulkan' => 'Sudah Dikumpulkan',
  'terlambat' => 'Dikumpulkan Terlambat',
  'melewati_deadline' => 'Deadline Terlewati',
  _ => 'Belum Dikumpulkan',
};

Color _statusColor(String status) => switch (status) {
  'sudah_dinilai' => AppColors.success,
  'sudah_dikumpulkan' => AppColors.primary,
  'terlambat' || 'melewati_deadline' => AppColors.error,
  _ => AppColors.warning,
};

double _number(dynamic value, {double fallback = 0}) => value is num
    ? value.toDouble()
    : double.tryParse(value?.toString() ?? '') ?? fallback;

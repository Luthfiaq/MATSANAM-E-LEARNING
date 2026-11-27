import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../services/siswa_learning_service.dart';
import '../../../utils/constants.dart';
import '../../../utils/theme_helpers.dart';

/// Shows the real grading information returned by the existing Siswa task API.
/// Rubrics, audio feedback, discussion and generated PDF are not fabricated.
class DetailHasilPenilaianScreen extends StatefulWidget {
  final int tugasId;

  const DetailHasilPenilaianScreen({super.key, required this.tugasId});

  @override
  State<DetailHasilPenilaianScreen> createState() =>
      _DetailHasilPenilaianScreenState();
}

class _DetailHasilPenilaianScreenState
    extends State<DetailHasilPenilaianScreen> {
  final SiswaLearningService _service = SiswaLearningService();
  Map<String, dynamic> _data = {};
  bool _loading = true;
  bool _downloading = false;
  String? _error;

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

  Future<void> _downloadAnswer(Map<String, dynamic> file) async {
    final url = (file['file_url'] ?? file['url'])?.toString();
    final name = (file['file_name'] ?? file['name'])?.toString();
    if (url == null || url.isEmpty || name == null || name.isEmpty) return;

    setState(() => _downloading = true);
    try {
      final bytes = await _service.downloadAuthorizedFile(url);
      final saved = await FilePicker.platform.saveFile(
        dialogTitle: 'Simpan file jawaban',
        fileName: name,
        bytes: bytes,
      );
      if (mounted && saved != null) _message('File jawaban siap disimpan.');
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
        appBar: _resultAppBar(context, 'Detail Penilaian'),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: _resultAppBar(context, 'Detail Penilaian'),
        body: _LoadError(message: _error!, onRetry: _load),
      );
    }

    final submission = _asMap(_data['pengumpulan']);
    final grade = _asMap(submission['nilai']);
    final hasSubmission = submission.isNotEmpty;
    final isGraded = grade.isNotEmpty;
    final submissionFiles = _submissionFiles(submission);
    final score = _number(grade['nilai']);
    final kkm = _number(_data['kkm']);
    final hasKkm = kkm > 0;
    final passed = isGraded && hasKkm && score >= kkm;
    final maxScore = _number(
      _data['bobot'],
      fallback: 100,
    ).clamp(1, 100).toDouble();
    final normalizedScore = (score / maxScore).clamp(0.0, 1.0).toDouble();

    return Scaffold(
      appBar: _resultAppBar(
        context,
        'Detail Penilaian',
        onRefresh: _load,
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            _TaskHeader(data: _data),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'Hasil Capaian Belajar',
              icon: Icons.emoji_events_outlined,
              child: isGraded
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: context.matsanamSoftPrimary,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: context.matsanamPrimary.withValues(alpha: .12),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'NILAI AKHIR',
                                style: TextStyle(
                                  color: context.matsanamPrimary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: .8,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Text(
                                      score.toStringAsFixed(0),
                                      style: TextStyle(
                                        fontSize: 48,
                                        height: 1,
                                        fontWeight: FontWeight.w900,
                                        color: context.matsanamPrimary,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 5),
                                    child: Text(
                                      '/ ${maxScore.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: context.matsanamTextSecondary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _Pill(
                                    label: !hasKkm
                                        ? 'Nilai Tersedia'
                                        : passed
                                            ? 'Tuntas'
                                            : 'Belum Tuntas',
                                    color: !hasKkm
                                        ? context.matsanamPrimary
                                        : passed
                                            ? context.matsanamSuccess
                                            : context.matsanamError,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: context.matsanamBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'KKM Mata Pelajaran',
                                    style: TextStyle(
                                      color: context.matsanamTextSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    hasKkm ? kkm.toStringAsFixed(0) : 'Belum diatur',
                                    style: TextStyle(
                                      color: context.matsanamPrimary,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 9),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: LinearProgressIndicator(
                                  value: normalizedScore,
                                  minHeight: 9,
                                  backgroundColor: context.matsanamBorder,
                                  color: !hasKkm
                                      ? context.matsanamPrimary
                                      : passed
                                          ? context.matsanamSuccess
                                          : context.matsanamError,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                !hasKkm
                                    ? 'KKM belum tersedia, sehingga ketuntasan belum dapat ditentukan.'
                                    : passed
                                        ? 'Nilai memenuhi Kriteria Ketuntasan Minimal.'
                                        : 'Nilai belum mencapai Kriteria Ketuntasan Minimal.',
                                style: TextStyle(
                                  color: !hasKkm
                                      ? context.matsanamPrimary
                                      : passed
                                          ? context.matsanamSuccess
                                          : context.matsanamError,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        _InfoRow(
                          label: 'Tanggal dikumpulkan',
                          value: _date(submission['waktu_pengumpulan']),
                        ),
                        _InfoRow(
                          label: 'Tanggal dinilai',
                          value: _date(grade['tanggal_penilaian']),
                        ),
                        _InfoRow(
                          label: 'Guru pengampu',
                          value: _text(_data['guru']),
                        ),
                      ],
                    )
                  : _WaitingGrade(hasSubmission: hasSubmission),
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'Feedback dan Catatan Guru',
              icon: Icons.chat_bubble_outline_rounded,
              child:
                  isGraded && _text(grade['catatan'], fallback: '').isNotEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: context.matsanamSoftPrimary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.format_quote_rounded,
                            color: context.matsanamPrimary,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              grade['catatan'].toString(),
                              style: TextStyle(
                                color: context.matsanamText,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Text(
                      isGraded
                          ? 'Guru belum menambahkan catatan penilaian.'
                          : 'Catatan Guru akan tampil setelah penilaian diterbitkan.',
                      style: TextStyle(color: context.matsanamTextSecondary),
                    ),
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'Jawaban yang Dikumpulkan',
              icon: Icons.upload_file_rounded,
              child: hasSubmission
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_text(
                          submission['jawaban'],
                          fallback: '',
                        ).isNotEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: context.matsanamPage,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(submission['jawaban'].toString()),
                          )
                        else
                          Text(
                            'Tidak ada jawaban teks; Siswa mengumpulkan berkas.',
                            style: TextStyle(
                              color: context.matsanamTextSecondary,
                            ),
                          ),
                        if (submissionFiles.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Text(
                            'Lampiran yang dikumpulkan',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          ...submissionFiles.map((file) {
                            final name =
                                (file['file_name'] ??
                                        file['name'] ??
                                        'Lampiran')
                                    .toString();
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: context.matsanamSoftPrimary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: context.matsanamSoftPrimary,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.insert_drive_file_outlined,
                                      color: context.matsanamPrimary,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Unduh $name',
                                    onPressed: _downloading
                                        ? null
                                        : () => _downloadAnswer(file),
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
                      ],
                    )
                  : Text(
                      'Belum ada pengumpulan yang tercatat.',
                      style: TextStyle(color: context.matsanamTextSecondary),
                    ),
            ),
            const SizedBox(height: 14),
            const _DataNote(),
          ],
        ),
      ),
    );
  }
}

PreferredSizeWidget _resultAppBar(
  BuildContext context,
  String title, {
  VoidCallback? onRefresh,
}) => AppBar(
  backgroundColor: Theme.of(context).colorScheme.surface,
  surfaceTintColor: Colors.transparent,
  elevation: 0,
  foregroundColor: context.matsanamText,
  title: Text(
    title,
    style: TextStyle(
      color: context.matsanamText,
      fontSize: 17,
      fontWeight: FontWeight.w800,
    ),
  ),
  actions: [
    if (onRefresh != null)
      IconButton(
        tooltip: 'Muat ulang hasil',
        onPressed: onRefresh,
        icon: Icon(Icons.refresh_rounded, color: context.matsanamPrimary),
      ),
  ],
  bottom: PreferredSize(
    preferredSize: const Size.fromHeight(1),
    child: Container(height: 1, color: context.matsanamBorder),
  ),
);

class _TaskHeader extends StatelessWidget {
  final Map<String, dynamic> data;
  const _TaskHeader({required this.data});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: context.matsanamBorder),
      boxShadow: [
        BoxShadow(
          color: context.matsanamPrimary.withValues(alpha: .06),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: context.matsanamSoftPrimary,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.menu_book_rounded, size: 14, color: context.matsanamPrimary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '${data['mapel'] ?? '-'} • Kelas ${data['kelas'] ?? '-'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.matsanamPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          _text(data['judul']),
          style: TextStyle(
            color: context.matsanamText,
            fontSize: 21,
            height: 1.2,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (_text(data['deskripsi'], fallback: '').isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            data['deskripsi'].toString(),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: context.matsanamTextSecondary, height: 1.45, fontSize: 13),
          ),
        ],
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(Icons.person_outline_rounded, size: 16, color: context.matsanamPrimary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Guru pengampu: ${_text(data['guru'])}',
                style: TextStyle(
                  color: context.matsanamTextSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.matsanamSoftPrimary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: _HeaderMetric(
                  label: 'Jenis tugas',
                  value: _text(data['jenis']),
                  icon: Icons.assignment_outlined,
                ),
              ),
              Container(width: 1, height: 36, color: context.matsanamPrimary.withValues(alpha: .18)),
              Expanded(
                child: _HeaderMetric(
                  label: 'Batas waktu',
                  value: _date(data['deadline']),
                  icon: Icons.schedule_rounded,
                ),
              ),
              Container(width: 1, height: 36, color: context.matsanamPrimary.withValues(alpha: .18)),
              Expanded(
                child: _HeaderMetric(
                  label: 'Skor maks.',
                  value: '${data['bobot'] ?? 100}',
                  icon: Icons.stars_rounded,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _HeaderMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _HeaderMetric({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 7),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: context.matsanamPrimary),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: context.matsanamTextSecondary, fontSize: 9.5, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: context.matsanamText, fontSize: 11, fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final IconData icon;

  const _SectionCard({
    required this.title,
    required this.child,
    this.icon = Icons.info_outline_rounded,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: context.matsanamBorder),
      boxShadow: [
        BoxShadow(
          color: context.matsanamPrimary.withValues(alpha: .035),
          blurRadius: 12,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: context.matsanamSoftPrimary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: context.matsanamPrimary, size: 17),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: context.matsanamText,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        child,
      ],
    ),
  );
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800),
    ),
  );
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

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
            style: TextStyle(
              fontSize: 12,
              color: context.matsanamTextSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

class _WaitingGrade extends StatelessWidget {
  final bool hasSubmission;
  const _WaitingGrade({required this.hasSubmission});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: context.matsanamSoftPrimary,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.hourglass_top_rounded, color: context.matsanamPrimary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            hasSubmission
                ? 'Pengumpulan sudah diterima dan sedang menunggu penilaian Guru.'
                : 'Belum ada pengumpulan yang dapat dinilai.',
            style: const TextStyle(height: 1.4),
          ),
        ),
      ],
    ),
  );
}

class _DataNote extends StatelessWidget {
  const _DataNote();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: context.matsanamSoftPrimary,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.verified_user_outlined,
          size: 18,
          color: context.matsanamPrimary,
        ),
        SizedBox(width: 9),
        Expanded(
          child: Text(
            'Informasi pada halaman ini diambil dari data tugas dan penilaian yang tersedia pada akun Siswa.',
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
          Icon(
            Icons.cloud_off_outlined,
            size: 42,
            color: context.matsanamError,
          ),
          const SizedBox(height: 12),
          const Text(
            'Gagal memuat penilaian',
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

double _number(dynamic value, {double fallback = 0}) => value is num
    ? value.toDouble()
    : double.tryParse(value?.toString() ?? '') ?? fallback;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../services/api_exception.dart';
import '../../../services/siswa_learning_service.dart';
import '../../../utils/constants.dart';
import '../../auth/login_screen.dart';
import '../../../utils/theme_helpers.dart';

/// Student detail page adapted from feature/elin-perbaikan-ui.
/// Completion is intentionally local to the current app session; there is no
/// backend progress endpoint in the current project contract.
class SiswaMateriDetailScreen extends StatefulWidget {
  final int materiId;
  final bool initialCompleted;

  const SiswaMateriDetailScreen({
    super.key,
    required this.materiId,
    this.initialCompleted = false,
  });

  @override
  State<SiswaMateriDetailScreen> createState() =>
      _SiswaMateriDetailScreenState();
}

class _SiswaMateriDetailScreenState extends State<SiswaMateriDetailScreen> {
  final _service = SiswaLearningService();
  final _noteController = TextEditingController();
  Map<String, dynamic>? _data;
  bool _loading = true;
  bool _savingFile = false;
  bool _isCompleted = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.initialCompleted;
    _load();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (mounted)
      setState(() {
        _loading = true;
        _error = null;
      });
    try {
      final value = await _service.detailMateri(widget.materiId);
      if (!mounted) return;
      setState(() {
        _data = value;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.unauthorized) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
        return;
      }
      setState(() {
        _error = error.message;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat detail materi: $error';
        _loading = false;
      });
    }
  }

  Future<void> _download() async {
    final url = _data?['file_url']?.toString();
    if (url == null || url.isEmpty || _savingFile) return;
    setState(() => _savingFile = true);
    try {
      final bytes = await _service.downloadAuthorizedFile(url);
      final name =
          (_data?['nama_file'] ??
                  'materi-${widget.materiId}.${_data?['ekstensi'] ?? 'pdf'}')
              .toString();
      final saved = await FilePicker.platform.saveFile(
        dialogTitle: 'Simpan materi',
        fileName: name,
        bytes: bytes,
      );
      if (mounted && saved != null)
        _message('Berkas materi berhasil disimpan.');
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.unauthorized) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      } else {
        _message('Gagal mengunduh materi: ${error.message}', error: true);
      }
    } catch (error) {
      if (mounted) _message('Gagal mengunduh materi: $error', error: true);
    } finally {
      if (mounted) setState(() => _savingFile = false);
    }
  }

  Future<void> _openLink() async {
    final raw = _data?['link']?.toString() ?? '';
    final uri = Uri.tryParse(raw);
    if (uri == null ||
        !uri.hasScheme ||
        !['http', 'https'].contains(uri.scheme)) {
      _message('Tautan materi tidak valid.', error: true);
      return;
    }
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && mounted)
        _message('Tautan tidak dapat dibuka.', error: true);
    } catch (error) {
      if (mounted) _message('Gagal membuka tautan: $error', error: true);
    }
  }

  void _message(String text, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: error ? AppColors.error : AppColors.success,
      ),
    );
  }

  void _close() => Navigator.of(context).pop(_isCompleted);

  @override
  Widget build(BuildContext context) {
    final data = _data ?? <String, dynamic>{};
    final colors = Theme.of(context).colorScheme;
    final rawType = (data['tipe'] ?? 'materi').toString().toLowerCase();
    final typeLabel = rawType == 'pdf'
        ? 'PDF'
        : rawType == 'video'
            ? 'VIDEO'
            : rawType == 'link'
                ? 'LINK'
                : rawType.toUpperCase();
    final hasFile = data['ada_file'] == true;
    final hasLink = data['ada_link'] == true;
    final date = DateTime.tryParse(data['tanggal_dibuat']?.toString() ?? '');
    final dateLabel = date == null
        ? 'Tanggal belum tersedia'
        : DateFormat('dd MMM yyyy', 'id_ID').format(date.toLocal());

    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Scaffold(
        backgroundColor: context.matsanamPage,
        appBar: AppBar(
          title: const Text('Detail Materi'),
          leading: IconButton(
            onPressed: _close,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Navigator.of(context).pushNamed('/siswa/profil'),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person_outline_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _DetailError(message: _error!, onRetry: _load)
                : ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                    children: [
                      _DetailCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _TypePill(value: typeLabel),
                                const SizedBox(width: 6),
                                _StatusPill(done: _isCompleted),
                                const Spacer(),
                                Text(
                                  dateLabel,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 13),
                            Text(
                              (data['judul'] ?? '-').toString(),
                              style: TextStyle(
                                fontSize: 20,
                                height: 1.16,
                                fontWeight: FontWeight.w900,
                                color: colors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 9),
                            Row(
                              children: [
                                Icon(Icons.menu_book_rounded,
                                    size: 14, color: colors.primary),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '${data['mapel'] ?? '-'} • ${data['kelas'] ?? '-'}',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Icon(Icons.person_outline_rounded,
                                    size: 14, color: colors.onSurfaceVariant),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Guru: ${data['guru'] ?? '-'}',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 11),
                      _DetailCard(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: colors.primaryContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.lightbulb_outline_rounded,
                                  size: 18, color: colors.primary),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tips Belajar Efektif',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: colors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Baca materi dengan teliti, catat poin penting, lalu buka lampiran atau tautan sebelum mengerjakan latihan.',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      height: 1.4,
                                      fontWeight: FontWeight.w500,
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        background: colors.primaryContainer.withValues(alpha: .35),
                      ),
                      const SizedBox(height: 11),
                      _DetailCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Deskripsi Materi',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: colors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              (data['deskripsi'] ?? 'Tidak ada deskripsi tambahan.')
                                  .toString(),
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 11),
                      _DetailCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Media & Bahan Belajar',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: colors.onSurface,
                                    ),
                                  ),
                                ),
                                _CountPill(label: '${(hasFile ? 1 : 0) + (hasLink ? 1 : 0)} Berkas'),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (hasFile)
                              Container(
                                padding: const EdgeInsets.all(11),
                                decoration: BoxDecoration(
                                  color: colors.surfaceContainerHighest.withValues(alpha: .42),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: colors.outlineVariant),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEE2E2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.picture_as_pdf_rounded,
                                        color: Color(0xFFDC2626),
                                        size: 21,
                                      ),
                                    ),
                                    const SizedBox(width: 9),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            (data['nama_file'] ?? 'Berkas materi').toString(),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w900,
                                              color: colors.onSurface,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            'Format: ${(data['ekstensi'] ?? rawType).toString().toUpperCase()}',
                                            style: TextStyle(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w600,
                                              color: colors.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    IconButton(
                                      tooltip: 'Unduh berkas',
                                      onPressed: _savingFile ? null : _download,
                                      icon: _savingFile
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            )
                                          : Icon(Icons.download_rounded, color: colors.primary),
                                    ),
                                  ],
                                ),
                              ),
                            if (hasFile && hasLink) const SizedBox(height: 9),
                            if (hasLink)
                              Container(
                                padding: const EdgeInsets.all(11),
                                decoration: BoxDecoration(
                                  color: colors.surfaceContainerHighest.withValues(alpha: .42),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: colors.outlineVariant),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF7ED),
                                        borderRadius: BorderRadius.circular(9),
                                      ),
                                      child: Icon(
                                        rawType == 'video'
                                            ? Icons.play_circle_outline
                                            : Icons.link_rounded,
                                        color: const Color(0xFFB45309),
                                      ),
                                    ),
                                    const SizedBox(width: 9),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            rawType == 'video' ? 'Video Pembelajaran' : 'Tautan Materi',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w900,
                                              color: colors.onSurface,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            (data['link'] ?? '').toString(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 9.5,
                                              color: colors.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    ElevatedButton(
                                      onPressed: _openLink,
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
                                      ),
                                      child: Text(rawType == 'video' ? 'Putar Video' : 'Buka Link'),
                                    ),
                                  ],
                                ),
                              ),
                            if (!hasFile && !hasLink)
                              Text(
                                'Belum ada lampiran untuk materi ini.',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 11),
                      _DetailCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Catatan Pribadi Siswa',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w900,
                                      color: colors.onSurface,
                                    ),
                                  ),
                                ),
                                Text(
                                  'Lokal',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 9),
                            TextField(
                              controller: _noteController,
                              minLines: 3,
                              maxLines: 4,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: colors.onSurface,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Tulis ringkasan atau catatan penting materi ini...',
                                hintStyle: TextStyle(
                                  fontSize: 10.5,
                                  color: colors.onSurfaceVariant.withValues(alpha: .75),
                                ),
                                filled: true,
                                fillColor: colors.surfaceContainerHighest.withValues(alpha: .35),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(11),
                                  borderSide: BorderSide(color: colors.outlineVariant),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(11),
                                  borderSide: BorderSide(color: colors.outlineVariant),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(11),
                                  borderSide: BorderSide(color: colors.primary, width: 1.4),
                                ),
                                contentPadding: const EdgeInsets.all(11),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Catatan ini hanya tersedia selama halaman dibuka dan belum disimpan ke server.',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w500,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 13),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _isCompleted
                              ? null
                              : () {
                                  setState(() => _isCompleted = true);
                                  _message('Materi ditandai sudah dipelajari.');
                                },
                          icon: Icon(
                            _isCompleted
                                ? Icons.check_circle_rounded
                                : Icons.task_alt_rounded,
                          ),
                          label: Text(
                            _isCompleted
                                ? 'Sudah Dipelajari'
                                : 'Tandai Selesai Dipelajari',
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF047857),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(0xFF047857),
                            disabledForegroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Status progres belajar tersimpan selama sesi aplikasi.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: context.matsanamTextMuted,
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

}

class _DetailCard extends StatelessWidget {
  final Widget child;
  final Color? background;
  const _DetailCard({required this.child, this.background});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: background ?? Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: Theme.of(context).dividerColor.withValues(alpha: .5),
      ),
    ),
    child: child,
  );
}

class _CountPill extends StatelessWidget {
  final String label;
  const _CountPill({required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w900,
          color: colors.primary,
        ),
      ),
    );
  }
}

class _TypePill extends StatelessWidget {
  final String value;
  const _TypePill({required this.value});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: context.matsanamSoftPrimary,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      value,
      style: TextStyle(
        color: context.matsanamPrimary,
        fontSize: 11,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _StatusPill extends StatelessWidget {
  final bool done;
  const _StatusPill({required this.done});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: done
          ? context.matsanamSuccess.withValues(alpha: .12)
          : context.matsanamWarning.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      done ? 'Selesai Dipelajari' : 'Belum Dipelajari',
      style: TextStyle(
        color: done ? context.matsanamSuccess : context.matsanamWarning,
        fontWeight: FontWeight.w700,
        fontSize: 10.5,
      ),
    ),
  );
}

class _DetailError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _DetailError({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 42,
            color: context.matsanamTextMuted,
          ),
          const SizedBox(height: 10),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    ),
  );
}

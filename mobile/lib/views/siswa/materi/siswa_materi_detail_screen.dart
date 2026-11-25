import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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
    final tipe = (data['tipe'] ?? 'materi').toString().toUpperCase();
    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detail Materi'),
          leading: IconButton(
            onPressed: _close,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Center(child: _StatusPill(done: _isCompleted)),
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? _DetailError(message: _error!, onRetry: _load)
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                children: [
                  _DetailCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _TypePill(value: tipe),
                            const Spacer(),
                            _StatusPill(done: _isCompleted),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          '${data['judul'] ?? '-'}',
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${data['mapel'] ?? '-'} • ${data['kelas'] ?? '-'}',
                          style: TextStyle(
                            color: context.matsanamTextSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Guru: ${data['guru'] ?? '-'}',
                          style: TextStyle(
                            color: context.matsanamTextSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _DetailCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Deskripsi Materi',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          (data['deskripsi'] ?? 'Tidak ada deskripsi tambahan.')
                              .toString(),
                          style: const TextStyle(height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _DetailCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Media & Bahan Belajar',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (data['ada_file'] == true)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              Icons.insert_drive_file_outlined,
                              color: context.matsanamPrimary,
                            ),
                            title: Text(
                              '${data['nama_file'] ?? 'Berkas materi'}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              'Format: ${data['ekstensi'] ?? 'File'}',
                            ),
                            trailing: _savingFile
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : IconButton(
                                    tooltip: 'Unduh berkas',
                                    onPressed: _download,
                                    icon: const Icon(Icons.download_rounded),
                                  ),
                          ),
                        if (data['ada_link'] == true)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              Icons.link_rounded,
                              color: context.matsanamPrimary,
                            ),
                            title: const Text('Buka tautan materi'),
                            subtitle: Text(
                              '${data['link']}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: const Icon(Icons.open_in_new_rounded),
                            onTap: _openLink,
                          ),
                        if (data['ada_file'] != true &&
                            data['ada_link'] != true)
                          Text(
                            'Belum ada lampiran untuk materi ini.',
                            style: TextStyle(
                              color: context.matsanamTextSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
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
                            : Icons.done_all_rounded,
                      ),
                      label: Text(
                        _isCompleted
                            ? 'Sudah Dipelajari'
                            : 'Tandai Sudah Dipelajari',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Status progres ini disimpan selama sesi aplikasi; belum disinkronkan ke server.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
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
  const _DetailCard({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: Theme.of(context).dividerColor.withValues(alpha: .5),
      ),
    ),
    child: child,
  );
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

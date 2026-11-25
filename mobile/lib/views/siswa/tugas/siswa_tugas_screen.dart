import 'package:file_picker/file_picker.dart';
import '../../../utils/camera_task_attachment.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../services/api_exception.dart';
import '../../../services/siswa_learning_service.dart';
import '../../../utils/constants.dart';
import '../../../widgets/common/siswa_bottom_navigation.dart';
import '../dashboard/dashboard_siswa_page.dart';
import '../materi/siswa_materi_screen.dart';
import '../nilai/siswa_nilai_screen.dart';
import '../nilai/detail_hasil_penilaian_screen.dart';
import 'status_pengumpulan_screen.dart';
import '../pengaturan/profil_siswa_screen.dart';

class SiswaTugasScreen extends StatefulWidget {
  const SiswaTugasScreen({super.key});
  @override
  State<SiswaTugasScreen> createState() => _SiswaTugasScreenState();
}

class _SiswaTugasScreenState extends State<SiswaTugasScreen> {
  final _service = SiswaLearningService();
  final _search = TextEditingController();
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  String? _error;
  String _filter = 'semua';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _service.tugas(status: _filter, query: _search.text);
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Terjadi kesalahan saat memuat tugas.';
        _loading = false;
      });
    }
  }

  void _tab(int index) {
    final Widget page = switch (index) {
      0 => const DashboardSiswaPage(),
      1 => const SiswaMateriScreen(),
      2 => const SiswaTugasScreen(),
      3 => const SiswaNilaiScreen(),
      _ => const ProfilSiswaScreen(),
    };
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Matsanam Siswa',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            Text(
              'Tugas Pembelajaran',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Cari tugas',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search_rounded),
                  onPressed: _load,
                ),
              ),
              onSubmitted: (_) => _load(),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _chip('semua', 'Semua'),
                _chip('belum', 'Belum Dikumpulkan'),
                _chip('dikumpulkan', 'Dikumpulkan'),
                _chip('dinilai', 'Sudah Dinilai'),
                _chip('terlambat', 'Terlambat'),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? _Empty(
                    icon: Icons.cloud_off_outlined,
                    title: 'Gagal memuat tugas',
                    subtitle: _error!,
                    action: _load,
                  )
                : _items.isEmpty
                ? const _Empty(
                    icon: Icons.assignment_outlined,
                    title: 'Tidak ada tugas',
                    subtitle: 'Belum ada tugas yang sesuai dengan filter ini.',
                  )
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        final status = (item['status'] ?? '').toString();
                        final late =
                            status == 'terlambat' ||
                            status == 'melewati_deadline';
                        final graded = status == 'sudah_dinilai';
                        final submitted =
                            status == 'sudah_dikumpulkan' ||
                            graded ||
                            status == 'terlambat';
                        final color = graded
                            ? AppColors.success
                            : late
                            ? AppColors.error
                            : submitted
                            ? AppColors.primary
                            : AppColors.warning;
                        return _Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: color.withValues(alpha: .10),
                              child: Icon(
                                Icons.assignment_outlined,
                                color: color,
                              ),
                            ),
                            title: Text(
                              '${item['judul'] ?? '-'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                '${item['mapel'] ?? '-'} • ${item['guru'] ?? 'Guru'}\nDeadline: ${_date(item['deadline'])}',
                                style: const TextStyle(height: 1.5),
                              ),
                            ),
                            isThreeLine: true,
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SiswaTugasDetailScreen(
                                  tugasId: (item['id'] as num).toInt(),
                                ),
                              ),
                            ).then((_) => _load()),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: SiswaBottomNavigationBar(
        currentIndex: 2,
        onTap: _tab,
      ),
    );
  }

  Widget _chip(String value, String label) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: ChoiceChip(
      label: Text(label),
      selected: _filter == value,
      onSelected: (_) {
        setState(() => _filter = value);
        _load();
      },
    ),
  );
  String _date(dynamic value) {
    final d = DateTime.tryParse(value?.toString() ?? '');
    return d == null
        ? '-'
        : DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(d.toLocal());
  }
}

class SiswaTugasDetailScreen extends StatefulWidget {
  final int tugasId;
  const SiswaTugasDetailScreen({super.key, required this.tugasId});
  @override
  State<SiswaTugasDetailScreen> createState() => _SiswaTugasDetailScreenState();
}

class _SiswaTugasDetailScreenState extends State<SiswaTugasDetailScreen> {
  final _service = SiswaLearningService();
  final _answer = TextEditingController();
  Map<String, dynamic> _data = {};
  final List<PlatformFile> _files = [];
  bool _loading = true, _sending = false, _removeExistingFile = false;
  bool _uploadFailed = false;
  double? _uploadProgress;
  String _uploadBatchId = DateTime.now().microsecondsSinceEpoch.toRadixString(
    36,
  );
  String? _lastUploadFingerprint;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _answer.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final data = await _service.detailTugas(widget.tugasId);
      if (!mounted) return;
      final submission = data['pengumpulan'] is Map
          ? Map<String, dynamic>.from(data['pengumpulan'])
          : <String, dynamic>{};
      setState(() {
        _data = data;
        _answer.text = (submission['jawaban'] ?? '').toString();
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (mounted)
        setState(() {
          _error = e.toString();
          _loading = false;
        });
    }
  }

  Future<void> _pickFile() async {
    const allowed = [
      'pdf',
      'doc',
      'docx',
      'xls',
      'xlsx',
      'ppt',
      'pptx',
      'jpg',
      'jpeg',
      'png',
      'txt',
      'zip',
    ];
    const maxFileBytes = 20 * 1024 * 1024;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowed,
      allowMultiple: true,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    if (_files.length + result.files.length > 20) {
      _snack('Maksimal 20 file dalam satu pengumpulan.', error: true);
      return;
    }

    final tooLarge = result.files.where((file) => file.size > maxFileBytes);
    if (tooLarge.isNotEmpty) {
      final names = tooLarge.map((file) => file.name).join(', ');
      _snack(
        'Setiap file maksimal 20 MB. Ukuran terlalu besar: $names',
        error: true,
      );
      return;
    }

    final unreadable = result.files.where((file) => file.bytes == null);
    if (unreadable.isNotEmpty) {
      _snack(
        'Ada file yang tidak dapat dibaca. Silakan pilih ulang.',
        error: true,
      );
      return;
    }

    setState(() {
      _files.addAll(result.files);
    });
  }

  Future<void> _capturePhoto() async {
    try {
      final photo = await captureTaskPhoto(namePrefix: 'jawaban_tugas');
      if (photo == null || !mounted) return;
      if (photo.size > 20 * 1024 * 1024) {
        _snack('Foto melebihi batas 20 MB dan tidak ditambahkan.', error: true);
        return;
      }
      if (photo.bytes == null) {
        _snack('Foto tidak dapat dibaca. Silakan ambil ulang.', error: true);
        return;
      }
      if (_files.length >= 20) {
        _snack('Maksimal 20 file dalam satu pengumpulan.', error: true);
        return;
      }
      final duplicate = _files.any(
        (file) => file.name == photo.name && file.size == photo.size,
      );
      if (duplicate) return;
      setState(() => _files.add(photo));
      _snack('Foto berhasil ditambahkan sebagai lampiran.');
    } catch (error) {
      _snack('Gagal mengambil foto: $error', error: true);
    }
  }

  List<Map<String, dynamic>> _taskAttachmentFiles() {
    final rawFiles = _data['lampiran_files'];
    if (rawFiles is List && rawFiles.isNotEmpty) {
      return rawFiles.whereType<Map>().map((item) {
        final file = Map<String, dynamic>.from(item);
        return <String, dynamic>{
          'id': file['id'],
          'name': file['file_name'] ?? 'Lampiran dari Guru',
          'url': file['file_url'],
          'size_bytes': file['size_bytes'],
          'available': file['available'] != false,
        };
      }).toList();
    }

    // Legacy single-file response from older backend builds.
    if (_data['lampiran_url'] != null && _data['lampiran_nama_file'] != null) {
      return [
        {
          'name': _data['lampiran_nama_file'],
          'url': _data['lampiran_url'],
          'size_bytes': null,
          'available': true,
        },
      ];
    }
    return [];
  }

  List<Map<String, dynamic>> _existingSubmissionFiles(
    Map<String, dynamic> submission,
  ) {
    final rawFiles = submission['files'];
    if (rawFiles is List && rawFiles.isNotEmpty) {
      return rawFiles.whereType<Map>().map((item) {
        final file = Map<String, dynamic>.from(item);
        return <String, dynamic>{
          'name': file['file_name'] ?? file['name'] ?? 'Lampiran',
          'url': file['file_url'] ?? file['url'],
          'size_bytes': file['size_bytes'],
        };
      }).toList();
    }

    if (submission['file_name'] != null && submission['file_url'] != null) {
      return [
        {
          'name': submission['file_name'],
          'url': submission['file_url'],
          'size_bytes': null,
        },
      ];
    }
    return [];
  }

  String _formatFileSize(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / 1024).toStringAsFixed(0)} KB';
  }

  Future<void> _downloadLampiran(String? url, String? fileName) async {
    if (url == null || url.isEmpty) return;

    final resolvedName = fileName?.trim() ?? '';
    final extensionMatch = RegExp(
      r'\.([A-Za-z0-9]{1,10})$',
    ).firstMatch(resolvedName);
    const allowedExtensions = {
      'pdf',
      'doc',
      'docx',
      'xls',
      'xlsx',
      'ppt',
      'pptx',
      'jpg',
      'jpeg',
      'png',
      'txt',
      'zip',
      'rar',
    };
    final extension = extensionMatch?.group(1)?.toLowerCase();

    if (extension == null || !allowedExtensions.contains(extension)) {
      _snack(
        'Nama file lampiran dari server tidak memiliki ekstensi yang valid. Minta Guru memeriksa atau mengunggah ulang lampiran.',
        error: true,
      );
      return;
    }

    try {
      final bytes = await _service.downloadAuthorizedFile(url);
      final savedPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Simpan lampiran tugas',
        fileName: resolvedName,
        bytes: bytes,
      );
      if (!mounted) return;
      if (savedPath != null) {
        _snack('Lampiran berhasil disimpan.');
      }
    } catch (e) {
      if (mounted) _snack('Gagal mengunduh lampiran: $e', error: true);
    }
  }

  Future<void> _submit() async {
    final submission = _data['pengumpulan'] is Map
        ? Map<String, dynamic>.from(_data['pengumpulan'])
        : <String, dynamic>{};
    final existingFiles = _existingSubmissionFiles(submission);
    final hasExistingFiles = existingFiles.isNotEmpty && !_removeExistingFile;

    if (_answer.text.trim().isEmpty && _files.isEmpty && !hasExistingFiles) {
      _snack(
        'Isi jawaban atau lampirkan minimal satu file sebelum mengumpulkan.',
        error: true,
      );
      return;
    }

    final fingerprint = [
      widget.tugasId,
      _answer.text.trim(),
      _removeExistingFile,
      ..._files.map(
        (file) =>
            '${file.name}:${file.size}:${file.bytes == null ? 0 : Object.hashAll(file.bytes!)}',
      ),
    ].join('|');
    if (_lastUploadFingerprint != fingerprint) {
      _uploadBatchId = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
      _lastUploadFingerprint = fingerprint;
    }

    setState(() {
      _sending = true;
      _uploadFailed = false;
      _uploadProgress = _files.isEmpty ? null : 0;
    });
    try {
      await _service.kumpulkanTugas(
        tugasId: widget.tugasId,
        jawaban: _answer.text.trim(),
        files: List<PlatformFile>.from(_files),
        hapusFile: _removeExistingFile,
        uploadBatchId: _uploadBatchId,
        onProgress: (progress) {
          if (!mounted || _files.isEmpty) return;
          setState(() => _uploadProgress = progress);
        },
      );
      if (!mounted) return;
      _snack('Pengumpulan tugas berhasil disimpan.');
      await _load();
      setState(() {
        _files.clear();
        _removeExistingFile = false;
        _uploadFailed = false;
        _uploadProgress = null;
        _uploadBatchId = DateTime.now().microsecondsSinceEpoch.toRadixString(
          36,
        );
        _lastUploadFingerprint = null;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _uploadFailed = _files.isNotEmpty);
        _snack(
          '${e.toString()}. File tetap tersimpan di daftar; tekan tombol pengumpulan lagi untuk retry.',
          error: true,
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _snack(String message, {bool error = false}) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: error ? AppColors.error : AppColors.success,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final submission = _data['pengumpulan'] is Map
        ? Map<String, dynamic>.from(_data['pengumpulan'])
        : <String, dynamic>{};
    final nilai = submission['nilai'] is Map
        ? Map<String, dynamic>.from(submission['nilai'])
        : null;
    final status = (_data['status'] ?? '').toString();
    final locked = nilai != null;
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Tugas')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(_error!),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Badge(
                          text: _statusLabel(status),
                          color: _statusColor(status),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${_data['judul'] ?? '-'}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_data['mapel'] ?? '-'} • ${_data['kelas'] ?? '-'}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          'Guru: ${_data['guru'] ?? '-'}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _info('Deadline', _date(_data['deadline'])),
                        _info('Bobot tugas', '${_data['bobot'] ?? '-'}'),
                        _info('KKM mapel', '${_data['kkm'] ?? '-'}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Instruksi Tugas',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          (_data['deskripsi'] ??
                                  'Tidak ada instruksi tambahan.')
                              .toString(),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_taskAttachmentFiles().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _Card(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Lampiran dari Guru',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Pilih satu file untuk diunduh.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          ..._taskAttachmentFiles().map((file) {
                            final name = file['name']?.toString() ?? 'Lampiran';
                            final size = file['size_bytes'];
                            final available = file['available'] != false;
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(
                                Icons.insert_drive_file_outlined,
                              ),
                              title: Text(
                                name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                !available
                                    ? 'File tidak ditemukan di penyimpanan'
                                    : size is num
                                    ? '${_formatFileSize(size.toInt())} • Ketuk untuk mengunduh'
                                    : 'Ketuk untuk mengunduh file ini',
                              ),
                              trailing: const Icon(Icons.download_rounded),
                              enabled: available,
                              onTap: available
                                  ? () => _downloadLampiran(
                                      file['url']?.toString(),
                                      name,
                                    )
                                  : null,
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                _Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Jawaban dan Pengumpulan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _answer,
                          maxLines: 5,
                          enabled: !locked,
                          decoration: const InputDecoration(
                            labelText: 'Tulis jawaban',
                            alignLabelWithHint: true,
                            hintText:
                                'Tuliskan jawaban atau keterangan tugas...',
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_existingSubmissionFiles(submission).isNotEmpty &&
                            !_removeExistingFile) ...[
                          const Text(
                            'Lampiran yang sudah dikumpulkan',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          ..._existingSubmissionFiles(submission).map((file) {
                            final name = file['name']?.toString() ?? 'Lampiran';
                            final size = file['size_bytes'];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(
                                Icons.insert_drive_file_outlined,
                              ),
                              title: Text(
                                name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                size is num
                                    ? '${_formatFileSize(size.toInt())} • Ketuk untuk mengunduh'
                                    : 'File terkumpul • Ketuk untuk mengunduh',
                              ),
                              onTap: () => _downloadLampiran(
                                file['url']?.toString(),
                                name,
                              ),
                            );
                          }),
                          if (!locked)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: () =>
                                    setState(() => _removeExistingFile = true),
                                icon: const Icon(Icons.delete_outline_rounded),
                                label: const Text('Hapus semua lampiran lama'),
                              ),
                            ),
                        ],
                        if (_removeExistingFile)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Text(
                              'Lampiran lama akan dihapus saat pengumpulan diperbarui.',
                              style: TextStyle(color: AppColors.warning),
                            ),
                          ),
                        if (_files.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          const Text(
                            'File yang akan diunggah',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          ..._files.asMap().entries.map((entry) {
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
                                tooltip: 'Hapus pilihan file',
                                icon: const Icon(Icons.close_rounded),
                                onPressed: _sending
                                    ? null
                                    : () => setState(
                                        () => _files.removeAt(index),
                                      ),
                              ),
                            );
                          }),
                        ],
                        if (!locked)
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _sending ? null : _pickFile,
                                  icon: const Icon(Icons.upload_file_rounded),
                                  label: const Text('Pilih File'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _sending ? null : _capturePhoto,
                                  icon: const Icon(Icons.camera_alt_outlined),
                                  label: const Text('Ambil Foto'),
                                ),
                              ),
                            ],
                          ),
                        if (!locked)
                          const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text(
                              'Kamu dapat memilih beberapa file sekaligus. Batas 20 MB berlaku untuk setiap file.',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        if (_sending && _uploadProgress != null) ...[
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
                              'Pengiriman belum terkonfirmasi. Retry memakai ID yang sama agar lampiran tidak terkirim ganda.',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                        if (nilai != null) ...[
                          const Divider(height: 24),
                          Text(
                            'Nilai: ${nilai['nilai']}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.success,
                            ),
                          ),
                          Text(
                            'Feedback Guru: ${nilai['catatan'] ?? 'Belum ada feedback.'}',
                          ),
                        ] else if (submission.isNotEmpty)
                          const Text(
                            'Menunggu penilaian Guru.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        const SizedBox(height: 14),
                        if (!locked)
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _sending ? null : _submit,
                              icon: _sending
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.send_rounded),
                              label: Text(
                                _uploadFailed
                                    ? 'Coba Kirim Lagi'
                                    : (submission.isEmpty
                                          ? 'Kirim Pengumpulan'
                                          : 'Perbarui Pengumpulan'),
                              ),
                            ),
                          ),
                        if (locked)
                          const Text(
                            'Pengumpulan dikunci karena Guru sudah memberikan nilai.',
                            style: TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (submission.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            StatusPengumpulanScreen(tugasId: widget.tugasId),
                      ),
                    ),
                    icon: const Icon(Icons.timeline_rounded),
                    label: const Text('Lihat Status Pengumpulan'),
                  ),
                  if (nilai != null) ...[
                    const SizedBox(height: 8),
                    FilledButton.icon(
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
                  ],
                ],
              ],
            ),
    );
  }

  Widget _info(String label, String value) => Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Row(
      children: [
        SizedBox(
          width: 145,
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
  String _date(dynamic value) {
    final d = DateTime.tryParse(value?.toString() ?? '');
    return d == null
        ? '-'
        : DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(d.toLocal());
  }

  String _statusLabel(String status) => switch (status) {
    'sudah_dinilai' => 'Sudah Dinilai',
    'sudah_dikumpulkan' => 'Sudah Dikumpulkan',
    'terlambat' => 'Dikumpulkan Terlambat',
    'melewati_deadline' => 'Deadline Terlewati',
    _ => 'Belum Dikumpulkan',
  };
  Color _statusColor(String status) => status == 'sudah_dinilai'
      ? AppColors.success
      : (status == 'terlambat' || status == 'melewati_deadline')
      ? AppColors.error
      : status == 'sudah_dikumpulkan'
      ? AppColors.primary
      : AppColors.warning;
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) => Container(
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

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge({required this.text, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .10),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      text,
      style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 11),
    ),
  );
}

class _Empty extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? action;
  const _Empty({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 42, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          if (action != null)
            TextButton(onPressed: action, child: const Text('Coba Lagi')),
        ],
      ),
    ),
  );
}

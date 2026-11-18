import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../../services/absensi_service.dart';
import '../../../utils/constants.dart';

class VerifikasiSuratGuruScreen extends StatefulWidget {
  const VerifikasiSuratGuruScreen({super.key});

  @override
  State<VerifikasiSuratGuruScreen> createState() =>
      _VerifikasiSuratGuruScreenState();
}

class _VerifikasiSuratGuruScreenState extends State<VerifikasiSuratGuruScreen> {
  final AbsensiService _service = AbsensiService();
  final List<Map<String, dynamic>> _items = [];
  final Map<String, dynamic> _summary = {
    'pending': 0,
    'disetujui': 0,
    'ditolak': 0,
  };

  String _selectedFilter = 'Semua';
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = false;
  int _page = 1;
  int? _processingId;
  int? _downloadingId;
  String? _error;

  String? get _statusQuery {
    switch (_selectedFilter) {
      case 'Pending':
        return 'pending';
      case 'Disetujui':
        return 'disetujui';
      case 'Ditolak':
        return 'ditolak';
      default:
        return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSurat();
  }

  Future<void> _loadSurat({bool loadMore = false}) async {
    if (loadMore && (_loadingMore || !_hasMore)) return;
    if (!loadMore) {
      setState(() {
        _loading = true;
        _error = null;
        _page = 1;
      });
    } else {
      setState(() => _loadingMore = true);
    }

    try {
      final result = await _service.daftarSuratVerifikasi(
        status: _statusQuery,
        page: loadMore ? _page + 1 : 1,
      );
      final paginator = Map<String, dynamic>.from(result['surats'] as Map);
      final rawItems = paginator['data'] is List
          ? paginator['data'] as List
          : const [];
      final nextItems = rawItems
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      final rawSummary = result['summary'];
      final summary = rawSummary is Map
          ? Map<String, dynamic>.from(rawSummary)
          : <String, dynamic>{};

      if (!mounted) return;
      setState(() {
        if (loadMore) {
          _items.addAll(nextItems);
          _page = (paginator['current_page'] as num?)?.toInt() ?? _page + 1;
        } else {
          _items
            ..clear()
            ..addAll(nextItems);
          _page = (paginator['current_page'] as num?)?.toInt() ?? 1;
        }
        _summary
          ..clear()
          ..addAll({
            'pending': summary['pending'] ?? 0,
            'disetujui': summary['disetujui'] ?? 0,
            'ditolak': summary['ditolak'] ?? 0,
          });
        final lastPage = (paginator['last_page'] as num?)?.toInt() ?? 1;
        _hasMore = _page < lastPage;
        _loading = false;
        _loadingMore = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadingMore = false;
        _error = error.toString().replaceFirst('Bad state: ', '');
      });
    }
  }

  Future<void> _selectFilter(String value) async {
    if (_selectedFilter == value) return;
    setState(() {
      _selectedFilter = value;
      _items.clear();
      _hasMore = false;
    });
    await _loadSurat();
  }

  Future<void> _downloadSurat(Map<String, dynamic> surat) async {
    final id = (surat['id'] as num?)?.toInt();
    if (id == null || _downloadingId != null) return;

    setState(() => _downloadingId = id);
    try {
      final bytes = await _service.unduhSuratVerifikasi(id);
      final name = surat['nama_file']?.toString().trim();
      final savedPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Simpan dokumen pengajuan',
        fileName: name == null || name.isEmpty ? 'surat-absensi-$id' : name,
        bytes: bytes,
      );
      if (!mounted) return;
      if (kIsWeb) {
        _showMessage('Unduhan dokumen dimulai.');
      } else if (savedPath != null) {
        _showMessage('Dokumen berhasil disimpan.');
      } else {
        _showMessage('Unduhan dibatalkan.');
      }
    } catch (error) {
      if (mounted) {
        _showMessage(
          error.toString().replaceFirst('Bad state: ', ''),
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _downloadingId = null);
    }
  }

  Future<void> _confirmApprove(Map<String, dynamic> surat) async {
    final id = (surat['id'] as num?)?.toInt();
    if (id == null || _processingId != null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Setujui Surat',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Setujui pengajuan ${_studentName(surat)} untuk tanggal '
          '${_formatDate(surat['tanggal_mulai'])} sampai '
          '${_formatDate(surat['tanggal_selesai'])}? '
          'Catatan presensi akan diperbarui sesuai jadwal kelas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
            child: const Text('Setujui'),
          ),
        ],
      ),
    );

    if (confirmed == true) await _processApproval(id);
  }

  Future<void> _processApproval(int id) async {
    setState(() => _processingId = id);
    try {
      final result = await _service.setujuiSurat(id);
      if (!mounted) return;
      final message =
          result['message']?.toString() ?? 'Surat berhasil disetujui.';
      _showMessage(message);
      await _loadSurat();
    } catch (error) {
      if (mounted) {
        _showMessage(
          error.toString().replaceFirst('Bad state: ', ''),
          isError: true,
        );
        await _loadSurat();
      }
    } finally {
      if (mounted) setState(() => _processingId = null);
    }
  }

  Future<void> _confirmReject(Map<String, dynamic> surat) async {
    final id = (surat['id'] as num?)?.toInt();
    if (id == null || _processingId != null) return;

    final controller = TextEditingController();
    String? validationMessage;
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text(
            'Tolak Surat',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tuliskan alasan penolakan untuk ${_studentName(surat)}.'),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                maxLength: 500,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Masukkan alasan penolakan...',
                  errorText: validationMessage,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = controller.text.trim();
                if (value.isEmpty) {
                  setDialogState(
                    () => validationMessage = 'Alasan wajib diisi.',
                  );
                  return;
                }
                Navigator.pop(dialogContext, value);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tolak Surat'),
            ),
          ],
        ),
      ),
    ).whenComplete(controller.dispose);

    if (reason != null && reason.trim().isNotEmpty) {
      await _processRejection(id, reason.trim());
    }
  }

  Future<void> _processRejection(int id, String reason) async {
    setState(() => _processingId = id);
    try {
      final result = await _service.tolakSurat(id, reason);
      if (!mounted) return;
      _showMessage(result['message']?.toString() ?? 'Surat berhasil ditolak.');
      await _loadSurat();
    } catch (error) {
      if (mounted) {
        _showMessage(
          error.toString().replaceFirst('Bad state: ', ''),
          isError: true,
        );
        await _loadSurat();
      }
    } finally {
      if (mounted) setState(() => _processingId = null);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _studentName(Map<String, dynamic> surat) {
    final student = surat['siswa'];
    if (student is Map) {
      return (student['nama_lengkap'] ?? 'Siswa').toString();
    }
    return 'Siswa';
  }

  String _formatDate(dynamic raw) {
    final value = raw?.toString() ?? '';
    final date = DateTime.tryParse(value);
    if (date == null) return value.isEmpty ? '-' : value;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  String _dateRange(Map<String, dynamic> surat) {
    final start = _formatDate(surat['tanggal_mulai']);
    final end = _formatDate(surat['tanggal_selesai']);
    return start == end ? start : '$start – $end';
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'disetujui':
        return 'Disetujui';
      case 'ditolak':
        return 'Ditolak';
      default:
        return 'Pending';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'disetujui':
        return AppColors.success;
      case 'ditolak':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  Color _statusBackground(String status) {
    switch (status) {
      case 'disetujui':
        return AppColors.successLight;
      case 'ditolak':
        return AppColors.errorLight;
      default:
        return AppColors.warningLight;
    }
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
            size: 20,
          ),
        ),
        title: const Text(
          'Verifikasi Surat',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: _loading || _processingId != null ? null : _loadSurat,
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.textSecondary,
            ),
          ),
          IconButton(
            tooltip: 'Bantuan',
            onPressed: _showHelpDialog,
            icon: const Icon(
              Icons.help_outline_rounded,
              color: AppColors.textSecondary,
              size: 22,
            ),
          ),
          Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(right: 16),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildFilterTabs(),
            Expanded(child: _buildSuratList()),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    const filters = ['Semua', 'Pending', 'Disetujui', 'Ditolak'];

    int? countFor(String label) {
      switch (label) {
        case 'Pending':
          return (_summary['pending'] as num?)?.toInt() ?? 0;
        case 'Disetujui':
          return (_summary['disetujui'] as num?)?.toInt() ?? 0;
        case 'Ditolak':
          return (_summary['ditolak'] as num?)?.toInt() ?? 0;
        default:
          return null;
      }
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          for (var index = 0; index < filters.length; index++) ...[
            if (index > 0) const SizedBox(width: 8),
            Expanded(
              child: _buildFilterButton(
                label: filters[index],
                value: filters[index],
                count: countFor(filters[index]),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterButton({
    required String label,
    required String value,
    int? count,
  }) {
    final selected = _selectedFilter == value;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: _loading || _processingId != null
          ? null
          : () => _selectFilter(value),
      child: Container(
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: selected ? null : Border.all(color: AppColors.border),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textPrimary,
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              if (count != null) ...[
                const SizedBox(width: 4),
                Text(
                  '($count)',
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuratList() {
    if (_loading && _items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _loadSurat,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }
    if (_items.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadSurat,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 100),
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.6),
            ),
            const SizedBox(height: 12),
            Text(
              _selectedFilter == 'Semua'
                  ? 'Belum ada pengajuan surat dari siswa.'
                  : 'Tidak ada surat dengan status $_selectedFilter.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSurat,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        itemCount: _items.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _items.length) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: OutlinedButton(
                onPressed: _loadingMore
                    ? null
                    : () => _loadSurat(loadMore: true),
                child: _loadingMore
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Muat Lebih Banyak'),
              ),
            );
          }
          return _buildSuratCard(_items[index]);
        },
      ),
    );
  }

  Widget _buildSuratCard(Map<String, dynamic> surat) {
    final student = surat['siswa'] is Map
        ? Map<String, dynamic>.from(surat['siswa'])
        : <String, dynamic>{};
    final name = (student['nama_lengkap'] ?? 'Siswa').toString();
    final nis = (student['nis'] ?? '-').toString();
    final nisn = (student['nisn'] ?? '-').toString();
    final kelas = (student['kelas'] ?? '-').toString();
    final kind = (surat['jenis'] ?? '').toString().toLowerCase();
    final status = (surat['status_verifikasi'] ?? 'pending')
        .toString()
        .toLowerCase();
    final id = (surat['id'] as num?)?.toInt();
    final pending = status == 'pending';
    final processing = id != null && _processingId == id;
    final downloading = id != null && _downloadingId == id;
    final hasDocument = surat['ada_dokumen'] == true;
    final reason = (surat['alasan'] ?? '').toString().trim();
    final verificationNote = (surat['catatan_verifikasi'] ?? '')
        .toString()
        .trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.description_outlined,
                        color: AppColors.primary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'NIS: $nis • NISN: $nisn • Kelas $kelas',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _statusBadge(status),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warningLight,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        kind == 'sakit' ? 'Sakit' : 'Izin',
                        style: const TextStyle(
                          color: AppColors.warning,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      _dateRange(surat),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      'Diajukan ${_formatDate(surat['tanggal_pengajuan'])}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                if (reason.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Keterangan',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reason,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
                if (verificationNote.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Catatan verifikasi: $verificationNote',
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
                if (surat['verifikator'] != null ||
                    surat['tanggal_verifikasi'] != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Diverifikasi ${surat['verifikator'] ?? '-'} • ${_formatDate(surat['tanggal_verifikasi'])}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
                if (hasDocument) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: downloading
                          ? null
                          : () => _downloadSurat(surat),
                      icon: downloading
                          ? const SizedBox(
                              width: 15,
                              height: 15,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.picture_as_pdf_outlined, size: 17),
                      label: Text(
                        downloading ? 'Mengunduh...' : 'Lihat / Unduh Surat',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (pending)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: processing || _processingId != null
                          ? null
                          : () => _confirmReject(surat),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Tolak',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: processing || _processingId != null
                          ? null
                          : () => _confirmApprove(surat),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: processing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Setujui',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: _statusBackground(status),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _statusLabel(status),
        style: TextStyle(
          color: _statusColor(status),
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Verifikasi Surat'),
        content: const Text(
          'Daftar ini menampilkan pengajuan sakit/izin dari siswa pada kelas yang Anda ampu. '
          'Periksa keterangan dan dokumen sebelum menyetujui atau menolak pengajuan. '
          'Persetujuan akan memperbarui catatan presensi berdasarkan jadwal kelas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Mengerti',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../services/api_exception.dart';
import '../../../services/siswa_learning_service.dart';
import '../../../utils/constants.dart';
import '../../../utils/theme_helpers.dart';
import '../../../widgets/common/siswa_bottom_navigation.dart';
import '../../auth/login_screen.dart';
import '../dashboard/dashboard_siswa_page.dart';
import '../nilai/siswa_nilai_screen.dart';
import '../pengaturan/profil_siswa_screen.dart';
import '../tugas/siswa_tugas_screen.dart';
import 'siswa_materi_detail_screen.dart';

class SiswaMateriScreen extends StatefulWidget {
  final int? mapelId;
  final String? namaMapel;

  const SiswaMateriScreen({super.key, this.mapelId, this.namaMapel});

  @override
  State<SiswaMateriScreen> createState() => _SiswaMateriScreenState();
}

class _SiswaMateriScreenState extends State<SiswaMateriScreen> {
  final _service = SiswaLearningService();
  final _searchController = TextEditingController();

  List<Map<String, dynamic>> _mapel = [];
  List<Map<String, dynamic>> _materi = [];
  final Set<int> _completedMateriIds = {};
  bool _loading = true;
  bool _downloadingAll = false;
  String? _error;
  String _tipe = 'semua';
  String _studyFilter = 'semua';
  String _query = '';

  static const _mapelPalette = <(Color, Color, IconData)>[
    (Color(0xFFEFF6FF), Color(0xFF1D4ED8), Icons.calculate_outlined),
    (Color(0xFFECFDF5), Color(0xFF059669), Icons.science_outlined),
    (Color(0xFFEEF2FF), Color(0xFF4F46E5), Icons.menu_book_rounded),
    (Color(0xFFFFF7ED), Color(0xFFEA580C), Icons.public_outlined),
    (Color(0xFFFEF2F2), Color(0xFFDC2626), Icons.account_balance_outlined),
    (Color(0xFFF0FDF4), Color(0xFF16A34A), Icons.sports_soccer_rounded),
    (Color(0xFFFDF2F8), Color(0xFFBE185D), Icons.palette_outlined),
    (Color(0xFFFFFBEB), Color(0xFFB45309), Icons.language_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (!mounted) return;
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (widget.mapelId == null) {
        final values = await _service.mapel();
        if (!mounted) return;
        setState(() {
          _mapel = values;
          _loading = false;
        });
      } else {
        final values = await _service.materi(
          mapelId: widget.mapelId,
          tipe: _tipe,
          query: _searchController.text,
        );
        if (!mounted) return;
        setState(() {
          _materi = values;
          _loading = false;
        });
      }
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
      if (error.unauthorized) _toLogin();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = widget.mapelId == null
            ? 'Terjadi kesalahan saat memuat mata pelajaran.'
            : 'Terjadi kesalahan saat memuat materi.';
        _loading = false;
      });
    }
  }

  void _toLogin() => Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );

  void _tab(int index) {
    final Widget page = switch (index) {
      0 => const DashboardSiswaPage(),
      1 => const SiswaMateriScreen(),
      2 => const SiswaTugasScreen(),
      3 => const SiswaNilaiScreen(),
      _ => const ProfilSiswaScreen(),
    };
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => page));
  }

  int _idOf(Map<String, dynamic> value) =>
      (value['id'] as num?)?.toInt() ?? 0;

  List<Map<String, dynamic>> get _filteredMapel {
    if (_query.isEmpty) return _mapel;
    return _mapel.where((item) {
      final name = (item['nama'] ?? '').toString().toLowerCase();
      final teacher = (item['guru'] ?? '').toString().toLowerCase();
      return name.contains(_query) || teacher.contains(_query);
    }).toList();
  }

  List<Map<String, dynamic>> get _filteredMateri {
    return _materi.where((item) {
      final id = _idOf(item);
      final completed = id > 0 && _completedMateriIds.contains(id);
      if (_studyFilter == 'belum' && completed) return false;
      if (_studyFilter == 'selesai' && !completed) return false;
      if (_query.isEmpty) return true;
      final title = (item['judul'] ?? '').toString().toLowerCase();
      final description = (item['deskripsi'] ?? '').toString().toLowerCase();
      return title.contains(_query) || description.contains(_query);
    }).toList();
  }

  Future<void> _openDetail(Map<String, dynamic> item) async {
    final id = _idOf(item);
    if (id <= 0) return;
    final completed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => SiswaMateriDetailScreen(
          materiId: id,
          initialCompleted: _completedMateriIds.contains(id),
        ),
      ),
    );
    if (completed == true && mounted) {
      setState(() => _completedMateriIds.add(id));
    }
  }

  Future<void> _downloadAll() async {
    if (_downloadingAll) return;
    final files = _filteredMateri.where((item) {
      final url = item['file_url']?.toString() ?? '';
      return url.isNotEmpty;
    }).toList();

    if (files.isEmpty) {
      _message('Belum ada berkas yang bisa diunduh.');
      return;
    }

    setState(() => _downloadingAll = true);
    var savedCount = 0;
    try {
      for (final item in files) {
        final id = _idOf(item);
        final url = item['file_url']?.toString() ?? '';
        if (id <= 0 || url.isEmpty) continue;
        final bytes = await _service.downloadAuthorizedFile(url);
        final title = (item['judul'] ?? 'materi-$id')
            .toString()
            .replaceAll(RegExp(r'[^a-zA-Z0-9_-]+'), '_');
        final extension = switch ((item['tipe'] ?? '').toString()) {
          'pdf' => 'pdf',
          'video' => 'mp4',
          _ => 'bin',
        };
        final saved = await FilePicker.platform.saveFile(
          dialogTitle: 'Simpan materi',
          fileName: '$title.$extension',
          bytes: bytes,
        );
        if (saved != null) savedCount++;
      }
      if (mounted) _message('$savedCount berkas berhasil disimpan.');
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.unauthorized) {
        _toLogin();
      } else {
        _message('Gagal mengunduh materi: ${error.message}', isError: true);
      }
    } catch (error) {
      if (mounted) _message('Gagal mengunduh materi: $error', isError: true);
    } finally {
      if (mounted) setState(() => _downloadingAll = false);
    }
  }

  void _message(String value, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value),
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSubjectList = widget.mapelId == null;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: context.matsanamPage,
      appBar: AppBar(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: !isSubjectList,
        leading: isSubjectList
            ? Padding(
                padding: const EdgeInsets.only(left: 14),
                child: Center(
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(Icons.school_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
              )
            : null,
        titleSpacing: isSubjectList ? 10 : 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isSubjectList ? 'Matsanam Siswa' : 'Detail Materi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: colors.onSurface,
              ),
            ),
            Text(
              isSubjectList ? 'Materi' : (widget.namaMapel ?? 'Daftar Materi'),
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Notifikasi',
            onPressed: () => _message('Tidak ada notifikasi baru.'),
            icon: Icon(Icons.notifications_none_rounded,
                color: colors.onSurface, size: 24),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _tab(4),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person_outline_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: colors.outlineVariant),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _StateMessage(
                  icon: Icons.cloud_off_outlined,
                  title: 'Gagal memuat ${isSubjectList ? 'mata pelajaran' : 'materi'}',
                  message: _error!,
                  action: _load,
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: isSubjectList ? _buildMapel() : _buildMateri(),
                ),
      bottomNavigationBar: SiswaBottomNavigationBar(
        currentIndex: 1,
        onTap: _tab,
      ),
    );
  }

  Widget _buildMapel() {
    final list = _filteredMapel;
    final colors = Theme.of(context).colorScheme;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
      children: [
        Text(
          'Materi Pembelajaran',
          style: TextStyle(
            fontSize: 22,
            height: 1.15,
            fontWeight: FontWeight.w900,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Pilih mata pelajaran untuk melihat daftar materi dan modul belajar.',
          style: TextStyle(
            fontSize: 12.5,
            height: 1.45,
            fontWeight: FontWeight.w500,
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 15),
        _SearchField(
          controller: _searchController,
          hint: 'Cari nama mata pelajaran...',
          onSubmitted: (_) {},
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Daftar Mapel Tersedia',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w900,
                  color: colors.onSurface,
                ),
              ),
            ),
            _CountPill(label: '${list.length} Mapel'),
          ],
        ),
        const SizedBox(height: 12),
        if (list.isEmpty)
          const _StateMessage(
            icon: Icons.menu_book_outlined,
            title: 'Mata pelajaran tidak ditemukan',
            message: 'Coba gunakan kata kunci pencarian yang berbeda.',
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.05,
            ),
            itemBuilder: (context, index) {
              final item = list[index];
              final style = _mapelPalette[index % _mapelPalette.length];
              final count = (item['jumlah_materi'] as num?)?.toInt() ?? 0;
              final teacher = (item['guru'] ?? 'Guru belum ditentukan').toString();
              final id = _idOf(item);

              return Material(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: id <= 0
                      ? null
                      : () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SiswaMateriScreen(
                                mapelId: id,
                                namaMapel: item['nama']?.toString(),
                              ),
                            ),
                          ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: style.$1,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(style.$3, color: style.$2, size: 18),
                            ),
                            const Spacer(),
                            Flexible(
                              child: _CountPill(label: '$count Modul', color: style.$2),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          (item['nama'] ?? '-').toString(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.5,
                            height: 1.15,
                            fontWeight: FontWeight.w900,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          teacher,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 9),
                        Row(
                          children: [
                            Text(
                              'Pilih Mapel',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: style.$2,
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.arrow_forward_rounded,
                                size: 15, color: style.$2),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.primaryContainer.withValues(alpha: .55),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.primary.withValues(alpha: .12)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, color: colors.primary, size: 18),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Materi yang ditampilkan mengikuti mata pelajaran pada jadwal kelas aktif.',
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMateri() {
    final colors = Theme.of(context).colorScheme;
    final visible = _filteredMateri;
    final total = _materi.length;
    final completed = _materi
        .where((item) => _completedMateriIds.contains(_idOf(item)))
        .length;
    final percent = total == 0 ? 0 : (completed / total * 100).round();
    final teacher = _materi.isNotEmpty
        ? (_materi.first['guru'] ?? 'Guru Mata Pelajaran').toString()
        : 'Guru Mata Pelajaran';
    final downloadable = _materi.where((item) {
      return (item['file_url'] ?? '').toString().isNotEmpty;
    }).length;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      children: [
        _SurfaceCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.menu_book_rounded,
                        color: colors.primary, size: 21),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MATA PELAJARAN',
                          style: TextStyle(
                            fontSize: 9.5,
                            letterSpacing: .5,
                            fontWeight: FontWeight.w900,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.namaMapel ?? 'Daftar Materi',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: colors.onSurface,
                          ),
                        ),
                        Text(
                          teacher,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _CountPill(label: '$total Modul'),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text('Progres Pembelajaran',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: colors.onSurfaceVariant,
                        )),
                  ),
                  Text(
                    '$completed dari $total selesai ($percent%)',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: total == 0 ? 0 : completed / total,
                  minHeight: 7,
                  backgroundColor: colors.surfaceContainerHighest,
                  color: colors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SearchField(
          controller: _searchController,
          hint: 'Cari judul bab atau topik materi...',
          onSubmitted: (_) => _load(),
        ),
        const SizedBox(height: 10),
        _FilterStrip(
          options: [
            ('semua', 'Semua Materi (${_materi.length})'),
            ('belum', 'Belum Dipelajari (${_materi.length - _completedMateriIds.where((id) => _materi.any((item) => _idOf(item) == id)).length})'),
            ('selesai', 'Sudah Selesai (${_materi.where((item) => _completedMateriIds.contains(_idOf(item))).length})'),
          ],
          selected: _studyFilter,
          onSelected: (value) => setState(() => _studyFilter = value),
        ),
        const SizedBox(height: 8),
        _FilterStrip(
          options: const [
            ('semua', 'Semua Tipe'),
            ('pdf', 'PDF'),
            ('video', 'Video'),
            ('link', 'Link'),
          ],
          selected: _tipe,
          onSelected: (value) {
            setState(() => _tipe = value);
            _load();
          },
        ),
        if (downloadable > 0) ...[
          const SizedBox(height: 12),
          _SurfaceCard(
            padding: const EdgeInsets.all(12),
            background: colors.primaryContainer.withValues(alpha: .42),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.cloud_download_outlined,
                      color: colors.primary, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Akses Belajar Offline',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: colors.onSurface,
                          )),
                      Text(
                        '$downloadable berkas materi tersedia untuk diunduh.',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                OutlinedButton.icon(
                  onPressed: _downloadingAll ? null : _downloadAll,
                  icon: _downloadingAll
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download_rounded, size: 14),
                  label: Text(_downloadingAll ? 'Proses' : 'Unduh Semua'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
                    textStyle: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        if (visible.isEmpty)
          _StateMessage(
            icon: Icons.menu_book_outlined,
            title: 'Materi tidak ditemukan',
            message: _studyFilter == 'selesai'
                ? 'Belum ada materi yang ditandai selesai dipelajari.'
                : 'Tidak ada materi yang sesuai dengan pencarian atau filter ini.',
            action: _load,
          )
        else
          ...visible.map((item) {
            final id = _idOf(item);
            final done = _completedMateriIds.contains(id);
            final type = (item['tipe'] ?? 'Materi').toString().toUpperCase();
            final hasFile = item['ada_file'] == true ||
                (item['file_url'] ?? '').toString().isNotEmpty;
            final hasLink = item['ada_link'] == true;
            final date = _date(item['tanggal_dibuat']);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _openDetail(item),
                  child: Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _TypePill(value: type),
                            const SizedBox(width: 6),
                            _StatusPill(done: done),
                            const Spacer(),
                            Text(date, style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: colors.onSurfaceVariant,
                            )),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          (item['judul'] ?? '-').toString(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.5,
                            height: 1.2,
                            fontWeight: FontWeight.w900,
                            color: colors.onSurface,
                          ),
                        ),
                        if ((item['deskripsi'] ?? '').toString().trim().isNotEmpty) ...[
                          const SizedBox(height: 5),
                          Text(
                            item['deskripsi'].toString(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.5,
                              height: 1.35,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                (item['guru'] ?? 'Guru Mata Pelajaran').toString(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ),
                            if (hasFile) ...[
                              Icon(Icons.attach_file_rounded,
                                  size: 13, color: colors.primary),
                              const SizedBox(width: 2),
                              Text('Berkas', style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: colors.primary,
                              )),
                              const SizedBox(width: 8),
                            ],
                            if (hasLink) ...[
                              Icon(Icons.link_rounded,
                                  size: 13, color: colors.tertiary),
                              const SizedBox(width: 2),
                              Text('Tautan', style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: colors.tertiary,
                              )),
                            ],
                          ],
                        ),
                        const Divider(height: 18),
                        Row(
                          children: [
                            const Spacer(),
                            Text(
                              'Buka Detail Materi',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                                color: colors.primary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_forward_rounded,
                                size: 14, color: colors.primary),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  String _date(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '');
    if (date == null) return 'Tanggal belum tersedia';
    return DateFormat('dd MMM yyyy', 'id_ID').format(date.toLocal());
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onSubmitted;
  const _SearchField({
    required this.controller,
    required this.hint,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      onSubmitted: onSubmitted,
      style: TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: colors.onSurface,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: colors.onSurfaceVariant.withValues(alpha: .8),
        ),
        prefixIcon: Icon(Icons.search_rounded,
            size: 19, color: colors.onSurfaceVariant),
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: colors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: colors.primary, width: 1.4),
        ),
      ),
    );
  }
}

class _FilterStrip extends StatelessWidget {
  final List<(String, String)> options;
  final String selected;
  final ValueChanged<String> onSelected;
  const _FilterStrip({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final option in options) ...[
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ChoiceChip(
                label: Text(option.$2),
                selected: selected == option.$1,
                onSelected: (_) => onSelected(option.$1),
                labelStyle: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: selected == option.$1
                      ? colors.onPrimary
                      : colors.onSurfaceVariant,
                ),
                selectedColor: colors.primary,
                backgroundColor: colors.surface,
                side: BorderSide(color: colors.outlineVariant),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? background;
  const _SurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background ?? colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: Theme.of(context).brightness == Brightness.dark ? .12 : .025,
            ),
            blurRadius: 9,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CountPill extends StatelessWidget {
  final String label;
  final Color? color;
  const _CountPill({required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground = color ?? colors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: foreground.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w900,
          color: foreground,
        ),
      ),
    );
  }
}

class _TypePill extends StatelessWidget {
  final String value;
  const _TypePill({required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final normalized = value.toLowerCase();
    final color = normalized == 'pdf'
        ? const Color(0xFF2563EB)
        : normalized == 'video'
            ? const Color(0xFFB45309)
            : colors.tertiary;
    return _CountPill(label: value, color: color);
  }
}

class _StatusPill extends StatelessWidget {
  final bool done;
  const _StatusPill({required this.done});

  @override
  Widget build(BuildContext context) {
    final color = done ? context.matsanamSuccess : context.matsanamWarning;
    return _CountPill(
      label: done ? 'Sudah Dipelajari' : 'Belum Dipelajari',
      color: color,
    );
  }
}

class _StateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? action;
  const _StateMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: colors.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 15,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                fontWeight: FontWeight.w500,
                color: colors.onSurfaceVariant,
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: 14),
              OutlinedButton(onPressed: action, child: const Text('Coba Lagi')),
            ],
          ],
        ),
      ),
    );
  }
}

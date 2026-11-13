import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import '../../../services/api_exception.dart';
import '../../../services/siswa_learning_service.dart';
import '../../../utils/constants.dart';
import '../../../widgets/common/siswa_bottom_navigation.dart';
import '../../auth/login_screen.dart';
import '../dashboard/dashboard_siswa_page.dart';
import '../nilai/siswa_nilai_screen.dart';
import '../pengaturan/profil_siswa_screen.dart';
import '../tugas/siswa_tugas_screen.dart';

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
  bool _loading = true;
  String? _error;
  String _tipe = 'semua';

  @override
  void initState() {
    super.initState();
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
        _mapel = await _service.mapel();
      } else {
        _materi = await _service.materi(
          mapelId: widget.mapelId,
          tipe: _tipe,
          query: _searchController.text,
        );
      }
      if (!mounted) return;
      setState(() => _loading = false);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
      if (e.unauthorized) _toLogin();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Terjadi kesalahan saat memuat materi.';
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
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final isSubjectList = widget.mapelId == null;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Matsanam Siswa',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            Text(
              isSubjectList
                  ? 'Materi Pembelajaran'
                  : widget.namaMapel ?? 'Daftar Materi',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _StateMessage(
              icon: Icons.cloud_off_outlined,
              title: 'Gagal memuat materi',
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
    if (_mapel.isEmpty)
      return const _StateMessage(
        icon: Icons.menu_book_outlined,
        title: 'Belum ada mata pelajaran',
        message: 'Mata pelajaran akan muncul setelah jadwal kelas ditetapkan.',
      );
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _mapel.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = _mapel[index];
        return _SurfaceCard(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppColors.primaryLight,
              child: Icon(Icons.menu_book_rounded, color: AppColors.primary),
            ),
            title: Text(
              '${item['nama'] ?? '-'}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(
              '${item['guru'] ?? 'Guru belum ditentukan'}\n${item['jumlah_materi'] ?? 0} materi',
              style: const TextStyle(height: 1.5),
            ),
            isThreeLine: true,
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SiswaMateriScreen(
                  mapelId: (item['id'] as num).toInt(),
                  namaMapel: item['nama']?.toString(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMateri() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Cari judul materi',
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
              _filterChip('semua', 'Semua'),
              _filterChip('pdf', 'PDF'),
              _filterChip('video', 'Video'),
              _filterChip('link', 'Link'),
            ],
          ),
        ),
        Expanded(
          child: _materi.isEmpty
              ? const _StateMessage(
                  icon: Icons.menu_book_outlined,
                  title: 'Belum ada materi',
                  message:
                      'Guru belum menerbitkan materi untuk mata pelajaran ini.',
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  itemCount: _materi.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = _materi[index];
                    final tipe = (item['tipe'] ?? '').toString();
                    final icon = tipe == 'pdf'
                        ? Icons.picture_as_pdf_outlined
                        : tipe == 'video'
                        ? Icons.play_circle_outline
                        : Icons.link_rounded;
                    return _SurfaceCard(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryLight,
                          child: Icon(icon, color: AppColors.primary),
                        ),
                        title: Text(
                          '${item['judul'] ?? '-'}',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle: Text(
                          '${item['guru'] ?? 'Guru'} • ${_date(item['tanggal_dibuat'])}\n${item['deskripsi'] ?? ''}',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        isThreeLine: true,
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SiswaMateriDetailScreen(
                              materiId: (item['id'] as num).toInt(),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _filterChip(String value, String label) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: ChoiceChip(
      label: Text(label),
      selected: _tipe == value,
      onSelected: (_) {
        setState(() => _tipe = value);
        _load();
      },
    ),
  );

  String _date(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '');
    return date == null
        ? '-'
        : DateFormat('dd MMM yyyy', 'id_ID').format(date.toLocal());
  }
}

class SiswaMateriDetailScreen extends StatefulWidget {
  final int materiId;
  const SiswaMateriDetailScreen({super.key, required this.materiId});
  @override
  State<SiswaMateriDetailScreen> createState() =>
      _SiswaMateriDetailScreenState();
}

class _SiswaMateriDetailScreenState extends State<SiswaMateriDetailScreen> {
  final _service = SiswaLearningService();
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;
  bool _savingFile = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _service.detailMateri(widget.materiId);
      if (mounted)
        setState(() {
          _data = data;
          _error = null;
          _loading = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _error = e.toString();
          _loading = false;
        });
    }
  }

  Future<void> _download() async {
    final url = _data?['file_url']?.toString();
    if (url == null || url.isEmpty) return;
    setState(() => _savingFile = true);
    try {
      final bytes = await _service.downloadAuthorizedFile(url);
      final fileName =
          (_data?['nama_file'] ??
                  'materi-${widget.materiId}.${_data?['ekstensi'] ?? 'pdf'}')
              .toString();
      await FilePicker.platform.saveFile(
        dialogTitle: 'Simpan materi',
        fileName: fileName,
        bytes: bytes,
      );
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berkas materi siap disimpan.')),
        );
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengunduh: $e')));
    } finally {
      if (mounted) setState(() => _savingFile = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _data ?? {};
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Materi')),
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
                _SurfaceCard(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Tag(
                          text: (data['tipe'] ?? 'materi')
                              .toString()
                              .toUpperCase(),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${data['judul'] ?? '-'}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${data['mapel'] ?? '-'} • ${data['kelas'] ?? '-'}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Guru: ${data['guru'] ?? '-'}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _SurfaceCard(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
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
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _SurfaceCard(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Lampiran',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (data['ada_file'] == true)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(
                              Icons.insert_drive_file_outlined,
                              color: AppColors.primary,
                            ),
                            title: Text(
                              '${data['nama_file'] ?? 'Berkas materi'}',
                            ),
                            subtitle: Text('${data['ekstensi'] ?? 'File'}'),
                            trailing: _savingFile
                                ? const CircularProgressIndicator()
                                : IconButton(
                                    icon: const Icon(Icons.download_rounded),
                                    onPressed: _download,
                                  ),
                          ),
                        if (data['ada_link'] == true)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(
                              Icons.link_rounded,
                              color: AppColors.primary,
                            ),
                            title: const Text('Buka tautan materi'),
                            subtitle: Text(
                              '${data['link']}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () async {
                              final uri = Uri.tryParse('${data['link']}');
                              if (uri != null)
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                            },
                          ),
                        if (data['ada_file'] != true &&
                            data['ada_link'] != true)
                          const Text('Materi ini tidak memiliki lampiran.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  final Widget child;
  const _SurfaceCard({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: Theme.of(context).dividerColor.withValues(alpha: .55),
      ),
    ),
    child: child,
  );
}

class _Tag extends StatelessWidget {
  final String text;
  const _Tag({required this.text});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: AppColors.primaryLight,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 11,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
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
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 44, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
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

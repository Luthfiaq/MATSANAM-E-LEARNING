import 'package:flutter/material.dart';
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
import 'siswa_materi_detail_screen.dart';
import '../../../utils/theme_helpers.dart';

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
              style: TextStyle(
                fontSize: 11,
                color: context.matsanamTextSecondary,
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
            leading: CircleAvatar(
              backgroundColor: context.matsanamSoftPrimary,
              child: Icon(
                Icons.menu_book_rounded,
                color: context.matsanamPrimary,
              ),
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
                          backgroundColor: context.matsanamSoftPrimary,
                          child: Icon(icon, color: context.matsanamPrimary),
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
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_completedMateriIds.contains(
                              (item['id'] as num).toInt(),
                            ))
                              Padding(
                                padding: EdgeInsets.only(right: 6),
                                child: Icon(
                                  Icons.check_circle_rounded,
                                  size: 18,
                                  color: context.matsanamSuccess,
                                ),
                              ),
                            const Icon(Icons.chevron_right_rounded),
                          ],
                        ),
                        onTap: () async {
                          final materiId = (item['id'] as num).toInt();
                          final completed = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SiswaMateriDetailScreen(
                                materiId: materiId,
                                initialCompleted: _completedMateriIds.contains(
                                  materiId,
                                ),
                              ),
                            ),
                          );
                          if (completed == true && mounted) {
                            setState(() => _completedMateriIds.add(materiId));
                          }
                        },
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
          Icon(icon, size: 44, color: context.matsanamTextMuted),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: context.matsanamTextSecondary),
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

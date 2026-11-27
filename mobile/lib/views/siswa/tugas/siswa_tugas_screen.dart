import 'package:file_picker/file_picker.dart';
import '../../../utils/camera_task_attachment.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../services/api_exception.dart';
import '../../../services/siswa_learning_service.dart';
import '../../../utils/constants.dart';
import '../../../widgets/common/siswa_bottom_navigation.dart';
import '../../../widgets/common/persistent_tab_shell.dart';
import '../dashboard/dashboard_siswa_page.dart';
import '../materi/siswa_materi_screen.dart';
import '../nilai/siswa_nilai_screen.dart';
import '../nilai/detail_hasil_penilaian_screen.dart';
import 'status_pengumpulan_screen.dart';
import '../pengaturan/profil_siswa_screen.dart';
import '../../../utils/theme_helpers.dart';
import '../../../utils/session.dart';
import '../notifikasi/siswa_notifikasi_screen.dart';

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
  String _statusTab = 'aktif';
  String _mapelFilter = 'Semua Mapel';
  String _kelasLabel = 'Kelas belum ditetapkan';
  String _periodeLabel = 'Semester Aktif';
  String _query = '';

  @override
  void initState() {
    super.initState();
    _search.addListener(_handleSearchChanged);
    _load();
  }

  void _handleSearchChanged() {
    if (!mounted) return;
    setState(() => _query = _search.text.trim().toLowerCase());
  }

  @override
  void dispose() {
    _search.removeListener(_handleSearchChanged);
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Fetch all tasks once. Status tabs, subject chips, and search are
      // filtered locally so their counters remain consistent with the list.
      final items = await _service.tugas(status: 'semua');
      final profile = await Session.getProfile();
      if (!mounted) return;

      Map<String, dynamic>? firstWithClass;
      for (final item in items) {
        if ((item['kelas'] ?? '').toString().trim().isNotEmpty) {
          firstWithClass = item;
          break;
        }
      }
      final rawProfileClass = profile?['kelas'];
      final profileClass = rawProfileClass is Map
          ? (rawProfileClass['nama_kelas'] ?? rawProfileClass['nama'] ?? '')
                .toString()
          : (rawProfileClass ?? '').toString();
      final taskClass = firstWithClass?['kelas']?.toString() ?? '';

      Map<String, dynamic>? firstWithPeriod;
      for (final item in items) {
        if ((item['semester'] ?? '').toString().trim().isNotEmpty ||
            (item['tahun_ajaran'] ?? '').toString().trim().isNotEmpty) {
          firstWithPeriod = item;
          break;
        }
      }
      final semester = firstWithPeriod?['semester']?.toString().trim() ?? '';
      final tahunAjaran =
          firstWithPeriod?['tahun_ajaran']?.toString().trim() ?? '';
      final periodLabel = semester.isNotEmpty && tahunAjaran.isNotEmpty
          ? 'Semester $semester $tahunAjaran'
          : (firstWithPeriod?['periode']?.toString().trim().isNotEmpty ?? false)
          ? firstWithPeriod!['periode'].toString()
          : 'Semester Aktif';

      setState(() {
        _items = items;
        _kelasLabel = taskClass.isNotEmpty
            ? taskClass
            : (profileClass.isNotEmpty ? profileClass : 'Kelas belum ditetapkan');
        _periodeLabel = periodLabel;
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

  String _groupForStatus(String status) {
    if (status == 'sudah_dinilai') return 'selesai';
    if (status == 'sudah_dikumpulkan' || status == 'terlambat') {
      return 'menunggu';
    }
    return 'aktif';
  }

  int _countFor(String tab) =>
      _items.where((item) => _groupForStatus('${item['status'] ?? ''}') == tab).length;

  List<String> get _availableSubjects {
    final subjects = _items
        .map((item) => (item['mapel'] ?? '').toString().trim())
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return ['Semua Mapel', ...subjects];
  }

  List<Map<String, dynamic>> get _filteredItems {
    return _items.where((item) {
      final status = (item['status'] ?? '').toString();
      if (_groupForStatus(status) != _statusTab) return false;

      final mapel = (item['mapel'] ?? '').toString();
      if (_mapelFilter != 'Semua Mapel' && mapel != _mapelFilter) return false;

      if (_query.isEmpty) return true;
      final searchable = [
        item['judul'],
        item['mapel'],
        item['guru'],
        item['deskripsi'],
        item['jenis'],
      ].map((value) => value?.toString().toLowerCase() ?? '').join(' ');
      return searchable.contains(_query);
    }).toList();
  }

  void _tab(int index) {
    final Widget page = switch (index) {
      0 => const DashboardSiswaPage(),
      1 => const SiswaMateriScreen(),
      2 => const SiswaTugasScreen(),
      3 => const SiswaNilaiScreen(),
      _ => const ProfilSiswaScreen(),
    };
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  void _openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SiswaNotifikasiScreen()),
    );
  }

  void _openProfile() {
    final tabs = PersistentTabScope.maybeOf(context);
    if (tabs != null) {
      tabs.onSelect(4);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProfilSiswaScreen()),
    );
  }

  String _date(dynamic value) {
    final d = DateTime.tryParse(value?.toString() ?? '');
    return d == null
        ? '-'
        : DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(d.toLocal());
  }

  String _deadlineBadge(Map<String, dynamic> item) {
    final status = (item['status'] ?? '').toString();
    if (status == 'sudah_dinilai') return 'Selesai';
    if (status == 'sudah_dikumpulkan') return 'Menunggu Nilai';
    if (status == 'terlambat') return 'Terlambat';
    final deadline = DateTime.tryParse(item['deadline']?.toString() ?? '')?.toLocal();
    if (deadline == null) return 'Tenggat Tugas';
    final remaining = deadline.difference(DateTime.now());
    if (remaining.isNegative) return 'Terlambat';
    if (remaining.inDays >= 1) return 'Sisa ${remaining.inDays} Hari';
    if (remaining.inHours >= 1) return 'Sisa ${remaining.inHours} Jam';
    final minutes = remaining.inMinutes < 1 ? 1 : remaining.inMinutes;
    return 'Sisa $minutes Menit';
  }

  Color _taskStatusColor(Map<String, dynamic> item) {
    final status = (item['status'] ?? '').toString();
    if (status == 'sudah_dinilai') return const Color(0xFF059669);
    if (status == 'sudah_dikumpulkan') return const Color(0xFF2563EB);
    if (status == 'terlambat' || status == 'melewati_deadline') {
      return const Color(0xFFDC2626);
    }
    final deadline = DateTime.tryParse(item['deadline']?.toString() ?? '')?.toLocal();
    if (deadline != null && deadline.difference(DateTime.now()).inHours < 24) {
      return const Color(0xFFD97706);
    }
    return const Color(0xFF2563EB);
  }

  IconData _subjectIcon(String subject) {
    final value = subject.toLowerCase();
    if (value.contains('matematika')) return Icons.calculate_outlined;
    if (value.contains('bahasa')) return Icons.translate_rounded;
    if (value.contains('ipa') || value.contains('alam')) return Icons.science_outlined;
    if (value.contains('sosial') || value.contains('ips')) return Icons.public_outlined;
    return Icons.assignment_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final filtered = _filteredItems;
    final activeCount = _countFor('aktif');
    return Scaffold(
      backgroundColor: context.matsanamPage,
      appBar: AppBar(
        toolbarHeight: 68,
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Matsanam Siswa',
              style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, 
                fontSize: 12,
                height: 1.15,
                letterSpacing: .15,
                fontWeight: FontWeight.w500,
                color: context.matsanamTextSecondary,
              ),
            ),
            Text(
              'Siswa: Daftar Tugas',
              style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, 
                fontSize: 17,
                height: 1.2,
                letterSpacing: .1,
                fontWeight: FontWeight.w600,
                color: context.matsanamText,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Notifikasi',
            onPressed: _openNotifications,
            icon: const Icon(Icons.notifications_none_rounded, size: 25),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 14, left: 2),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _openProfile,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 23,
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: colors.outlineVariant,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _Empty(
              icon: Icons.cloud_off_outlined,
              title: 'Gagal memuat tugas',
              subtitle: _error!,
              action: _load,
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                children: [
                  _TaskSummaryCard(
                    kelas: _kelasLabel,
                    periode: _periodeLabel,
                    activeCount: activeCount,
                  ),
                  const SizedBox(height: 14),
                  _TaskStatusTabs(
                    selected: _statusTab,
                    activeCount: activeCount,
                    waitingCount: _countFor('menunggu'),
                    doneCount: _countFor('selesai'),
                    onChanged: (value) => setState(() => _statusTab = value),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _search,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Cari nama tugas atau materi...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 21),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Hapus pencarian',
                              onPressed: _search.clear,
                              icon: const Icon(Icons.close_rounded, size: 18),
                            ),
                      filled: true,
                      fillColor: context.matsanamSurface,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      hintStyle: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, 
                        color: context.matsanamTextMuted,
                        fontSize: 13,
                      ),
                      prefixIconColor: context.matsanamTextSecondary,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: context.matsanamBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 42,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _availableSubjects.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final subject = _availableSubjects[index];
                        final selected = subject == _mapelFilter;
                        return ChoiceChip(
                          label: Text(
                            subject,
                            style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, 
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0,
                              color: selected ? Theme.of(context).colorScheme.onPrimary : context.matsanamTextSecondary,
                            ),
                          ),
                          selected: selected,
                          showCheckmark: false,
                          backgroundColor: context.matsanamSurface,
                          selectedColor: Theme.of(context).colorScheme.primary,
                          side: BorderSide(
                            color: selected ? Theme.of(context).colorScheme.primary : context.matsanamBorder,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          onSelected: (_) => setState(() => _mapelFilter = subject),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (filtered.isEmpty)
                    const _Empty(
                      icon: Icons.assignment_outlined,
                      title: 'Tidak ada tugas',
                      subtitle: 'Belum ada tugas yang sesuai dengan filter ini.',
                    )
                  else
                    ...filtered.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _TaskListCard(
                          item: item,
                          statusText: _deadlineBadge(item),
                          statusColor: _taskStatusColor(item),
                          subjectIcon: _subjectIcon((item['mapel'] ?? '').toString()),
                          deadlineText: _date(item['deadline']),
                          onTap: () => Navigator.of(context)
                              .push(
                                MaterialPageRoute(
                                  builder: (_) => SiswaTugasDetailScreen(
                                    tugasId: (item['id'] as num).toInt(),
                                  ),
                                ),
                              )
                              .then((_) => _load()),
                        ),
                      ),
                    ),
                  const SizedBox(height: 2),
                  const _TaskStudyTip(),
                ],
              ),
            ),
      bottomNavigationBar: SiswaBottomNavigationBar(
        currentIndex: 2,
        onTap: _tab,
      ),
    );
  }
}

class _TaskSummaryCard extends StatelessWidget {
  final String kelas;
  final String periode;
  final int activeCount;
  const _TaskSummaryCard({
    required this.kelas,
    required this.periode,
    required this.activeCount,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: context.matsanamSurface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: context.matsanamBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: context.matsanamIsDark ? .12 : .035,
            ),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tugas Siswa',
                  style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, 
                    fontSize: 18.5,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                    color: context.matsanamText,
                  ),
                ),
                const SizedBox(height: 3),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: kelas,
                        style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, 
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: colors.primary,
                        ),
                      ),
                      TextSpan(
                        text: '  •  $periode',
                        style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, 
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: context.matsanamTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 13),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.matsanamSoftWarning,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$activeCount Tugas Perlu Diselesaikan',
                    style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, 
                      fontSize: 12,
                      height: 1.2,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0,
                      color: context.matsanamWarning,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: context.matsanamSoftPrimary,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              Icons.assignment_turned_in_outlined,
              color: colors.primary,
              size: 27,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskStatusTabs extends StatelessWidget {
  final String selected;
  final int activeCount;
  final int waitingCount;
  final int doneCount;
  final ValueChanged<String> onChanged;
  const _TaskStatusTabs({
    required this.selected,
    required this.activeCount,
    required this.waitingCount,
    required this.doneCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final entries = [
      ('aktif', 'Tugas Aktif', activeCount),
      ('menunggu', 'Menunggu', waitingCount),
      ('selesai', 'Selesai', doneCount),
    ];
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.matsanamSoftSurface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: context.matsanamBorder.withValues(alpha: .55)),
      ),
      child: Row(
        children: entries.map((entry) {
          final isSelected = selected == entry.$1;
          final foreground = isSelected
              ? colors.onPrimary
              : colors.onSurfaceVariant;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(entry.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: isSelected ? colors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          entry.$2,
                          style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, 
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0,
                            color: foreground,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colors.onPrimary.withValues(alpha: .16)
                                : context.matsanamBorder.withValues(alpha: .65),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Text(
                            '${entry.$3}',
                            style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, 
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: foreground,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TaskListCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final String statusText;
  final Color statusColor;
  final IconData subjectIcon;
  final String deadlineText;
  final VoidCallback onTap;
  const _TaskListCard({
    required this.item,
    required this.statusText,
    required this.statusColor,
    required this.subjectIcon,
    required this.deadlineText,
    required this.onTap,
  });

  String _jenisLabel(dynamic value) => switch ((value ?? '').toString().toLowerCase()) {
        'quiz' || 'kuis' => 'Kuis',
        'uts' => 'UTS',
        'uas' => 'UAS',
        _ => 'Tugas',
      };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isGraded = item['status'] == 'sudah_dinilai';
    final isSubmitted = item['status'] == 'sudah_dikumpulkan' || item['status'] == 'terlambat';
    final title = (item['judul'] ?? '-').toString();
    final subject = (item['mapel'] ?? 'Mata Pelajaran').toString();
    final teacher = (item['guru'] ?? 'Guru Mata Pelajaran').toString();
    final description = (item['deskripsi'] ?? '').toString().trim();
    final accent = statusColor;

    return Container(
      decoration: BoxDecoration(
        color: context.matsanamSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.matsanamBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: context.matsanamIsDark ? .12 : .028,
            ),
            blurRadius: 9,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 4, color: accent),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 13, 15, 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(subjectIcon, size: 17, color: accent),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              '$subject  •  $teacher',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, 
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0,
                                color: context.matsanamTextSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 7),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: .12),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  statusText,
                                  style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, 
                                    fontSize: 11,
                                    height: 1.2,
                                    fontWeight: FontWeight.w700,
                                    color: accent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, 
                          fontSize: 17,
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                          color: context.matsanamText,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(Icons.schedule_rounded, size: 15, color: accent),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              'Batas pengumpulan: $deadlineText',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, 
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0,
                                color: accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 9),
                      Wrap(
                        spacing: 7,
                        runSpacing: 6,
                        children: [
                          _TaskMetaPill(
                            icon: Icons.emoji_events_outlined,
                            text: 'Bobot: ${item['bobot'] ?? 0} Poin',
                          ),
                          _TaskMetaPill(
                            icon: Icons.person_outline_rounded,
                            text: _jenisLabel(item['jenis']),
                          ),
                        ],
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: context.matsanamSoftPrimary,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Text(
                            description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, 
                              fontSize: 12,
                              height: 1.35,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 11),
                      Container(
                        height: 46,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isGraded
                                  ? Icons.verified_outlined
                                  : isSubmitted
                                      ? Icons.visibility_outlined
                                      : Icons.rocket_launch_rounded,
                              color: colors.onPrimary,
                              size: 17,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isGraded || isSubmitted
                                  ? 'Lihat Detail Tugas'
                                  : 'Kumpulkan Tugas Sekarang',
                              style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, 
                                fontSize: 13.5,
                                height: 1.2,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0,
                                color: colors.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TaskMetaPill extends StatelessWidget {
  final IconData icon;
  final String text;
  const _TaskMetaPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: context.matsanamSoftPrimary,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, 
                fontSize: 11.5,
                height: 1.2,
                fontWeight: FontWeight.w600,
                color: context.matsanamTextSecondary,
              ),
            ),
          ],
        ),
      );
}

class _TaskStudyTip extends StatelessWidget {
  const _TaskStudyTip();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: context.matsanamSoftPrimary,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: colors.primary.withValues(alpha: .22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: .14),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.lightbulb_outline_rounded, color: colors.primary),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tips Belajar',
                  style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, 
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                    color: context.matsanamText,
                  ),
                ),
                Text(
                  'Jangan menunda pengumpulan tugas agar terhindar dari pemotongan nilai keterlambatan otomatis oleh sistem madrasah.',
                  style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, 
                    fontSize: 12,
                    height: 1.4,
                    letterSpacing: 0,
                    color: context.matsanamTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

  String _shortDate(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '')?.toLocal();
    return date == null ? '-' : DateFormat('dd MMM, HH:mm', 'id_ID').format(date);
  }

  String _timeBadge(String status, dynamic rawDeadline) {
    if (status == 'sudah_dinilai') return 'Sudah Dinilai';
    if (status == 'sudah_dikumpulkan') return 'Menunggu Penilaian';
    if (status == 'terlambat') return 'Terlambat';
    final deadline = DateTime.tryParse(rawDeadline?.toString() ?? '')?.toLocal();
    if (deadline == null) return 'Deadline Tugas';
    final remaining = deadline.difference(DateTime.now());
    if (remaining.isNegative) return 'Deadline Terlewati';
    if (remaining.inDays >= 1) return 'Sisa ${remaining.inDays} Hari';
    if (remaining.inHours >= 1) return 'Sisa ${remaining.inHours} Jam';
    final minutes = remaining.inMinutes < 1 ? 1 : remaining.inMinutes;
    return 'Sisa $minutes Menit';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final submission = _data['pengumpulan'] is Map
        ? Map<String, dynamic>.from(_data['pengumpulan'])
        : <String, dynamic>{};
    final nilai = submission['nilai'] is Map
        ? Map<String, dynamic>.from(submission['nilai'])
        : null;
    final status = (_data['status'] ?? 'belum_dikumpulkan').toString();
    final locked = nilai != null;
    final statusColor = _statusColor(status);
    final title = (_data['judul'] ?? 'Detail Tugas').toString();
    final mapel = (_data['mapel'] ?? 'Mata Pelajaran').toString();
    final kelas = (_data['kelas'] ?? 'Kelas Aktif').toString();
    final teacher = (_data['guru'] ?? 'Guru Mata Pelajaran').toString();
    final deadline = _data['deadline'];
    final attachments = _taskAttachmentFiles();
    final previousFiles = _existingSubmissionFiles(submission);
    final submitLabel = _uploadFailed
        ? 'Coba Kirim Lagi'
        : (submission.isEmpty ? 'Kumpulkan Tugas Sekarang' : 'Perbarui Pengumpulan');

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        toolbarHeight: 72,
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded, size: 29),
        ),
        title: Text(
          'Detail Tugas',
          style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, 
            fontSize: 18,
            height: 1.2,
            letterSpacing: .1,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF17233B),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfilSiswaScreen()),
              ),
              child: Container(
                width: 45,
                height: 45,
                decoration: const BoxDecoration(
                  color: Color(0xFF1D4ED8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 26),
              ),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE8ECF3)),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off_outlined, size: 42, color: Color(0xFF94A3B8)),
                    const SizedBox(height: 12),
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    OutlinedButton(onPressed: _load, child: const Text('Coba Lagi')),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFE7EBF3)),
                    boxShadow: const [
                      BoxShadow(color: Color(0x060F172A), blurRadius: 12, offset: Offset(0, 3)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(color: const Color(0xFFEFF4FF), borderRadius: BorderRadius.circular(10)),
                            child: Text('TUGAS', style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, fontSize: 12, height: 1.2, letterSpacing: .2, fontWeight: FontWeight.w700, color: const Color(0xFF1D4ED8))),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                            decoration: BoxDecoration(color: statusColor.withValues(alpha: .12), borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(locked ? Icons.verified_rounded : Icons.schedule_rounded, size: 16, color: statusColor),
                                const SizedBox(width: 6),
                                Text(_timeBadge(status, deadline), style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, fontSize: 11.5, height: 1.2, letterSpacing: 0, fontWeight: FontWeight.w700, color: statusColor)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, fontSize: 21, height: 1.2, fontWeight: FontWeight.w700, letterSpacing: 0, color: const Color(0xFF17233B)),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '$mapel • $kelas',
                        style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, fontSize: 13.5, height: 1.35, letterSpacing: 0, fontWeight: FontWeight.w500, color: const Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Guru: $teacher',
                        style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, fontSize: 12.5, height: 1.35, letterSpacing: 0, fontWeight: FontWeight.w500, color: const Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                        decoration: BoxDecoration(color: const Color(0xFFF0F2FF), borderRadius: BorderRadius.circular(15)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _TaskDetailMeta(label: 'Batas Waktu', value: _shortDate(deadline), valueColor: deadline != null && DateTime.tryParse(deadline.toString())?.isBefore(DateTime.now()) == true ? const Color(0xFFD97706) : const Color(0xFF17233B))),
                            const SizedBox(width: 8),
                            Expanded(child: _TaskDetailMeta(label: 'Bobot Nilai', value: '${_data['bobot'] ?? 0} Poin', valueColor: const Color(0xFF17233B))),
                            const SizedBox(width: 8),
                            Expanded(child: _TaskDetailMeta(label: 'Status', value: _statusLabel(status), valueColor: statusColor)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _TaskSectionCard(
                  title: 'Instruksi Tugas',
                  icon: Icons.menu_book_rounded,
                  child: Text(
                    (_data['deskripsi'] ?? 'Tidak ada instruksi tambahan.').toString(),
                    style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, fontSize: 14, height: 1.45, letterSpacing: 0, color: const Color(0xFF475569)),
                  ),
                ),
                if (attachments.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _TaskSectionCard(
                    title: 'Berkas dari Guru',
                    icon: Icons.attach_file_rounded,
                    child: Column(
                      children: attachments.map((file) {
                        final name = file['name']?.toString() ?? 'Lampiran';
                        final size = file['size_bytes'];
                        final available = file['available'] != false;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(color: const Color(0xFFF7F8FC), borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            dense: true,
                            leading: const Icon(Icons.picture_as_pdf_outlined, color: Color(0xFF2563EB)),
                            title: Text(name, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, fontSize: 11.5, fontWeight: FontWeight.w700, color: const Color(0xFF17233B))),
                            subtitle: Text(!available ? 'File tidak ditemukan di penyimpanan' : size is num ? _formatFileSize(size.toInt()) : 'Lampiran tugas', style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, fontSize: 10, color: const Color(0xFF64748B))),
                            trailing: Icon(Icons.download_rounded, color: available ? const Color(0xFF2563EB) : const Color(0xFF94A3B8)),
                            enabled: available,
                            onTap: available ? () => _downloadLampiran(file['url']?.toString(), name) : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                _TaskSectionCard(
                  title: 'Unggah Lembar Jawaban',
                  icon: Icons.upload_file_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!locked)
                        Material(
                          color: const Color(0xFFF0F2FF),
                          borderRadius: BorderRadius.circular(17),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(17),
                            onTap: _sending ? null : _pickFile,
                            child: Container(
                              width: double.infinity,
                              constraints: const BoxConstraints(minHeight: 156),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(17),
                                border: Border.all(color: const Color(0xFFDCE4FF), width: 1.2),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.add_photo_alternate_outlined, size: 42, color: Color(0xFF1D4ED8)),
                                  const SizedBox(height: 9),
                                  Text('Ketuk untuk Ganti atau Tambah Berkas', textAlign: TextAlign.center, style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, fontSize: 14, height: 1.35, letterSpacing: 0, fontWeight: FontWeight.w600, color: const Color(0xFF17233B))),
                                  const SizedBox(height: 5),
                                  Text('PDF, DOC, DOCX, JPG, PNG dan lainnya (Maks. 20 MB/file)', textAlign: TextAlign.center, style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, fontSize: 11.5, height: 1.4, letterSpacing: 0, color: const Color(0xFF94A3B8))),
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (!locked) ...[
                        const SizedBox(height: 9),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _sending ? null : _capturePhoto,
                            icon: const Icon(Icons.camera_alt_outlined, size: 18),
                            label: Text('Ambil Foto', style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, fontSize: 12.5, fontWeight: FontWeight.w600)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF1D4ED8),
                              side: const BorderSide(color: Color(0xFFD6E1F7)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ],
                      if (previousFiles.isNotEmpty && !_removeExistingFile) ...[
                        const SizedBox(height: 13),
                        Text('Berkas yang Sudah Dikumpulkan', style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF17233B))),
                        ...previousFiles.map((file) {
                          final name = file['name']?.toString() ?? 'Lampiran';
                          final size = file['size_bytes'];
                          return _SubmissionFileTile(
                            name: name,
                            subtitle: size is num ? _formatFileSize(size.toInt()) : 'File terkumpul',
                            onTap: () => _downloadLampiran(file['url']?.toString(), name),
                          );
                        }),
                        if (!locked)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () => setState(() => _removeExistingFile = true),
                              icon: const Icon(Icons.delete_outline_rounded, size: 18),
                              label: Text('Hapus semua lampiran lama', style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, fontSize: 11, fontWeight: FontWeight.w600)),
                            ),
                          ),
                      ],
                      if (_removeExistingFile)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text('Lampiran lama akan dihapus saat pengumpulan diperbarui.', style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, fontSize: 11, color: const Color(0xFFD97706))),
                        ),
                      if (_files.isNotEmpty) ...[
                        const SizedBox(height: 13),
                        Text('File yang Akan Diunggah', style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF17233B))),
                        ..._files.asMap().entries.map((entry) => _SubmissionFileTile(
                              name: entry.value.name,
                              subtitle: _formatFileSize(entry.value.size),
                              trailing: IconButton(
                                tooltip: 'Hapus pilihan file',
                                onPressed: _sending ? null : () => setState(() => _files.removeAt(entry.key)),
                                icon: const Icon(Icons.close_rounded, size: 19),
                              ),
                            )),
                      ],
                      const SizedBox(height: 14),
                      Text('Catatan Tambahan Siswa (Opsional)', style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0, color: const Color(0xFF475569))),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _answer,
                        enabled: !locked,
                        maxLines: 3,
                        minLines: 3,
                        style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, fontSize: 13.5, height: 1.4, letterSpacing: 0, color: const Color(0xFF17233B)),
                        decoration: InputDecoration(
                          hintText: 'Tuliskan catatan untuk guru jika ada...',
                          hintStyle: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, fontSize: 12.5, color: const Color(0xFF94A3B8), letterSpacing: 0),
                          filled: true,
                          fillColor: const Color(0xFFF0F2FF),
                          contentPadding: const EdgeInsets.all(15),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFB9C9F7), width: 1.3)),
                          disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                        ),
                      ),
                      if (_sending && _uploadProgress != null) ...[
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(value: _uploadProgress, minHeight: 7, backgroundColor: const Color(0xFFE2E8F0)),
                        ),
                        const SizedBox(height: 5),
                        Text('Mengunggah lampiran ${(100 * (_uploadProgress ?? 0)).round()}%', style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, fontSize: 11, color: const Color(0xFF64748B))),
                      ],
                      if (_uploadFailed)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text('Pengiriman belum terkonfirmasi. Coba kirim ulang; sistem akan mencegah lampiran ganda.', style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, fontSize: 11, color: const Color(0xFFD97706))),
                        ),
                      if (locked) ...[
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Nilai: ${nilai['nilai']}', style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF047857))),
                              Text('Feedback Guru: ${nilai['catatan'] ?? 'Belum ada feedback.'}', style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, fontSize: 11, color: const Color(0xFF475569))),
                            ],
                          ),
                        ),
                      ] else if (submission.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text('Pengumpulan tersimpan. Kamu masih dapat memperbarui jawaban sebelum nilai diberikan.', style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, fontSize: 11, color: const Color(0xFF64748B))),
                      ],
                    ],
                  ),
                ),
                if (submission.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => StatusPengumpulanScreen(tugasId: widget.tugasId)),
                    ),
                    icon: const Icon(Icons.timeline_rounded),
                    label: Text('Lihat Status Pengumpulan', style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, fontSize: 12.5, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                  if (nilai != null) ...[
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => DetailHasilPenilaianScreen(tugasId: widget.tugasId)),
                      ),
                      icon: const Icon(Icons.assessment_outlined),
                      label: Text('Lihat Detail Hasil Penilaian', style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, fontSize: 12.5, fontWeight: FontWeight.w600)),
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF1D4ED8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                  ],
                ],
              ],
            ),
      bottomNavigationBar: _loading || _error != null
          ? null
          : SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                decoration: BoxDecoration(
                  color: colors.surface,
                  boxShadow: const [BoxShadow(color: Color(0x100F172A), blurRadius: 12, offset: Offset(0, -3))],
                ),
                child: SizedBox(
                  height: 62,
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: locked || _sending ? (locked ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailHasilPenilaianScreen(tugasId: widget.tugasId))) : null) : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFF94A3B8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    icon: _sending
                        ? const SizedBox(width: 19, height: 19, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Icon(locked ? Icons.assessment_outlined : Icons.rocket_launch_rounded, size: 22),
                    label: Text(
                      _sending ? 'Mengirim Pengumpulan...' : locked ? 'Lihat Hasil Penilaian' : submitLabel,
                      style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, fontSize: 15.5, height: 1.2, letterSpacing: 0, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ),
              ),
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
            style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, fontSize: 12, color: context.matsanamTextSecondary),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, fontSize: 12.5, fontWeight: FontWeight.w700),
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

class _TaskDetailMeta extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  const _TaskDetailMeta({required this.label, required this.value, required this.valueColor});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, fontSize: 11.5, fontWeight: FontWeight.w600, letterSpacing: 0, color: const Color(0xFF94A3B8))),
          const SizedBox(height: 3),
          Text(value, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, fontSize: 12, height: 1.3, fontWeight: FontWeight.w700, letterSpacing: 0, color: valueColor)),
        ],
      );
}

class _TaskSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _TaskSectionCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(17, 16, 17, 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE7EBF3)),
          boxShadow: const [BoxShadow(color: Color(0x050F172A), blurRadius: 10, offset: Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF1D4ED8), size: 21),
                const SizedBox(width: 9),
                Expanded(child: Text(title, style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, fontSize: 16.5, height: 1.2, fontWeight: FontWeight.w700, letterSpacing: 0, color: const Color(0xFF17233B)))),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      );
}

class _SubmissionFileTile extends StatelessWidget {
  final String name;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  const _SubmissionFileTile({required this.name, required this.subtitle, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 7),
        decoration: BoxDecoration(color: const Color(0xFFF7F8FC), borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          dense: true,
          onTap: onTap,
          leading: const Icon(Icons.insert_drive_file_outlined, color: Color(0xFF2563EB)),
          title: Text(name, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, fontSize: 11.5, fontWeight: FontWeight.w700, color: const Color(0xFF17233B))),
          subtitle: Text(subtitle, style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, fontSize: 10, color: const Color(0xFF64748B))),
          trailing: trailing ?? (onTap == null ? null : const Icon(Icons.download_rounded, color: Color(0xFF2563EB))),
        ),
      );
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
          Icon(icon, size: 42, color: context.matsanamTextMuted),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: context.matsanamText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, fontSize: 12, color: context.matsanamTextSecondary),
          ),
          if (action != null)
            TextButton(onPressed: action, child: const Text('Coba Lagi')),
        ],
      ),
    ),
  );
}

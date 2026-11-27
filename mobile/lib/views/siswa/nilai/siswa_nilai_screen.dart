import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../widgets/common/persistent_tab_shell.dart';
import 'package:intl/intl.dart';

import '../../../services/api_exception.dart';
import '../../../services/siswa_learning_service.dart';
import '../../../utils/constants.dart';
import '../../../widgets/common/siswa_bottom_navigation.dart';
import '../../auth/login_screen.dart';
import '../dashboard/dashboard_siswa_page.dart';
import '../materi/siswa_materi_screen.dart';
import '../pengaturan/profil_siswa_screen.dart';
import '../tugas/siswa_tugas_screen.dart';
import 'detail_hasil_penilaian_screen.dart';
import '../../../utils/theme_helpers.dart';

class SiswaNilaiScreen extends StatefulWidget {
  const SiswaNilaiScreen({super.key});

  @override
  State<SiswaNilaiScreen> createState() => _SiswaNilaiScreenState();
}

class _SiswaNilaiScreenState extends State<SiswaNilaiScreen> {
  final _service = SiswaLearningService();
  final _searchController = TextEditingController();

  List<Map<String, dynamic>> _items = [];
  Map<int, String> _teacherByMapel = {};
  bool _loading = true;
  String? _error;
  bool _downloadingRekap = false;
  String _query = '';

  static const _palette = <(Color, Color, IconData)>[
    (Color(0xFFEFF6FF), Color(0xFF1D4ED8), Icons.straighten_rounded),
    (Color(0xFFECFDF5), Color(0xFF059669), Icons.biotech_rounded),
    (Color(0xFFEEF2FF), Color(0xFF4F46E5), Icons.menu_book_rounded),
    (Color(0xFFFFF7ED), Color(0xFFEA580C), Icons.public_rounded),
    (Color(0xFFECFDF5), Color(0xFF047857), Icons.mosque_rounded),
    (Color(0xFFF0FDF4), Color(0xFF15803D), Icons.auto_stories_rounded),
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
      final items = await _service.nilai();
      final teacherByMapel = <int, String>{};
      // Guru pengampu comes from the existing subject endpoint; no new API
      // contract or hard-coded teacher names are introduced.
      try {
        final subjects = await _service.mapel();
        for (final subject in subjects) {
          final id = (subject['id'] as num?)?.toInt();
          final teacher = (subject['guru'] ?? '').toString().trim();
          if (id != null && teacher.isNotEmpty) teacherByMapel[id] = teacher;
        }
      } catch (_) {
        // The grade list remains usable if the optional teacher lookup fails.
      }
      if (!mounted) return;
      setState(() {
        _items = items;
        _teacherByMapel = teacherByMapel;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.unauthorized) {
        _toLogin();
        return;
      }
      setState(() {
        _error = error.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat nilai.';
        _loading = false;
      });
    }
  }

  void _toLogin() => Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );

  Future<void> _downloadRekapPdf() async {
    if (_downloadingRekap) return;
    setState(() => _downloadingRekap = true);
    try {
      final bytes = await _service.unduhRekapNilaiPdf();
      final saved = await FilePicker.platform.saveFile(
        dialogTitle: 'Simpan rekap nilai',
        fileName: 'rekap_nilai_semester.pdf',
        bytes: bytes,
      );
      if (mounted && saved != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF rekap nilai berhasil disimpan.')),
        );
      }
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.unauthorized) {
        _toLogin();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengunduh rekap nilai: ${error.message}')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengunduh rekap nilai: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _downloadingRekap = false);
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
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => page));
  }

  List<Map<String, dynamic>> get _filteredItems {
    if (_query.isEmpty) return _items;
    return _items.where((item) {
      final name = (item['mapel'] ?? '').toString().toLowerCase();
      final id = (item['mapel_id'] as num?)?.toInt();
      final teacher = _teacherByMapel[id ?? -1]?.toLowerCase() ?? '';
      return name.contains(_query) || teacher.contains(_query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final filtered = _filteredItems;
    final totalGraded = _items.fold<int>(
      0,
      (total, item) => total + ((item['jumlah_dinilai'] as num?)?.toInt() ?? 0),
    );

    return Scaffold(
      backgroundColor: context.matsanamPage,
      appBar: AppBar(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nilai Pilih Mapel',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: colors.onSurface,
              ),
            ),
            Text(
              'Matsanam E-Learning',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Notifikasi',
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tidak ada notifikasi baru.')),
            ),
            icon: Icon(Icons.notifications_none_rounded,
                color: colors.onSurface, size: 24),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                final tabs = PersistentTabScope.maybeOf(context);
                if (tabs != null) {
                  tabs.onSelect(4);
                } else {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const ProfilSiswaScreen()),
                  );
                }
              },
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
              ? _Empty(
                  icon: Icons.cloud_off_outlined,
                  title: 'Gagal memuat nilai',
                  subtitle: _error!,
                  action: _load,
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 26),
                    children: [
                      TextField(
                        controller: _searchController,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Cari nama mata pelajaran...',
                          hintStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: colors.onSurfaceVariant,
                          ),
                          prefixIcon: Icon(Icons.search_rounded,
                              color: colors.onSurfaceVariant, size: 20),
                          filled: true,
                          fillColor: colors.surface,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(13),
                            borderSide: BorderSide(color: colors.outlineVariant),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(13),
                            borderSide: BorderSide(color: colors.primary, width: 1.4),
                          ),
                        ),
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
                              'Pilih Mata Pelajaran',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w900,
                                color: colors.onSurface,
                              ),
                            ),
                          ),
                          _GradeCountPill(label: '${filtered.length} Mapel Terdaftar'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (filtered.isEmpty)
                        _Empty(
                          icon: Icons.bar_chart_outlined,
                          title: _items.isEmpty ? 'Belum ada nilai' : 'Mapel tidak ditemukan',
                          subtitle: _items.isEmpty
                              ? 'Nilai akan tampil setelah Guru menyelesaikan penilaian tugas.'
                              : 'Coba gunakan kata kunci pencarian yang berbeda.',
                        )
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filtered.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.05,
                          ),
                          itemBuilder: (context, index) {
                            final item = filtered[index];
                            final style = _palette[index % _palette.length];
                            final mapelId = (item['mapel_id'] as num?)?.toInt() ?? 0;
                            final name = (item['mapel'] ?? '-').toString();
                            final teacher = _teacherByMapel[mapelId] ??
                                '${item['jumlah_dinilai'] ?? 0} penilaian • KKM ${item['kkm'] ?? '-'}';
                            final average = (item['rata_rata'] as num?)?.toDouble();
                            final averageLabel = average == null
                                ? 'Rerata: -'
                                : 'Rerata: ${average.toStringAsFixed(1)}';

                            return Material(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: mapelId <= 0
                                    ? null
                                    : () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => SiswaNilaiMapelScreen(
                                              mapelId: mapelId,
                                              namaMapel: name,
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
                                            width: 35,
                                            height: 35,
                                            decoration: BoxDecoration(
                                              color: style.$1,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Icon(style.$3, color: style.$2, size: 19),
                                          ),
                                          const Spacer(),
                                          Flexible(
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: style.$1,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                averageLabel,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w900,
                                                  color: style.$2,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Text(
                                        name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13,
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
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w600,
                                          color: colors.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 9),
                                      Row(
                                        children: [
                                          Text('Lihat Nilai', style: TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w900,
                                            color: style.$2,
                                          )),
                                          const Spacer(),
                                          Icon(Icons.arrow_forward_rounded,
                                              size: 14, color: style.$2),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: colors.outlineVariant),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: colors.primaryContainer,
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: Icon(Icons.description_outlined,
                                  color: colors.primary, size: 21),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Rekap Nilai Semester',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w900,
                                      color: colors.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$totalGraded penilaian telah diperiksa',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: _downloadingRekap ? null : _downloadRekapPdf,
                              icon: _downloadingRekap
                                  ? const SizedBox(
                                      width: 13,
                                      height: 13,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.download_rounded, size: 14),
                              label: Text(_downloadingRekap ? 'Proses' : 'Unduh PDF'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                                textStyle: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: SiswaBottomNavigationBar(currentIndex: 3, onTap: _tab),
    );
  }
}

class _GradeCountPill extends StatelessWidget {
  final String label;
  const _GradeCountPill({required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: .7),
        borderRadius: BorderRadius.circular(9),
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

class SiswaNilaiMapelScreen extends StatefulWidget {
  final int mapelId;
  final String? namaMapel;
  const SiswaNilaiMapelScreen({
    super.key,
    required this.mapelId,
    this.namaMapel,
  });
  @override
  State<SiswaNilaiMapelScreen> createState() => _SiswaNilaiMapelScreenState();
}

class _SiswaNilaiMapelScreenState extends State<SiswaNilaiMapelScreen> {
  final _service = SiswaLearningService();
  Map<String, dynamic> _data = {};
  bool _loading = true;
  String? _error;
  String _tabKategori = 'semua';
  bool _downloadingPdf = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted)
      setState(() {
        _loading = true;
        _error = null;
      });
    try {
      final value = await _service.nilaiMapel(widget.mapelId);
      if (mounted)
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
      if (mounted)
        setState(() {
          _error = error.toString();
          _loading = false;
        });
    }
  }

  Future<void> _downloadPdf() async {
    if (_downloadingPdf) return;
    setState(() => _downloadingPdf = true);
    try {
      final bytes = await _service.unduhNilaiMapelPdf(widget.mapelId);
      final saved = await FilePicker.platform.saveFile(
        dialogTitle: 'Simpan rincian nilai mata pelajaran',
        fileName: 'nilai_mapel_${widget.mapelId}.pdf',
        bytes: bytes,
      );
      if (mounted && saved != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF rincian nilai berhasil disimpan.')),
        );
      }
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.unauthorized) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengunduh rincian nilai: ${error.message}'),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengunduh rincian nilai: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _downloadingPdf = false);
    }
  }

  bool _matchesCategory(Map<String, dynamic> item) {
    if (_tabKategori == 'semua') return true;
    final jenis = (item['jenis'] ?? '').toString().toLowerCase();
    final isExam =
        jenis.contains('ujian') ||
        jenis.contains('quiz') ||
        jenis.contains('ulangan');
    return _tabKategori == 'ujian' ? isExam : !isExam;
  }

  // Same score bands used by the earlier Elin UI commit for its visual predicate.
  String _predikatFromScore(double? score) {
    if (score == null) return '-';
    if (score >= 90) return 'A';
    if (score >= 80) return 'B';
    if (score >= 70) return 'C';
    return 'D';
  }

  String _labelPredikat(String predikat) => switch (predikat) {
        'A' => 'Sangat Baik',
        'B' => 'Baik',
        'C' => 'Cukup',
        'D' => 'Perlu Bimbingan',
        _ => 'Belum tersedia',
      };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final mapel = _data['mapel'] is Map
        ? Map<String, dynamic>.from(_data['mapel'])
        : <String, dynamic>{};
    final hasil = _data['hasil'] is List
        ? (_data['hasil'] as List)
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList()
        : <Map<String, dynamic>>[];
    final hasilTampil = hasil.where(_matchesCategory).toList();
    final rataRata = (_data['rata_rata'] as num?)?.toDouble();
    final kkm = (mapel['kkm'] as num?)?.toDouble() ?? 0;
    final hasKkm = kkm > 0;
    final rataTuntas = rataRata != null && hasKkm && rataRata >= kkm;
    final progress = rataRata == null
        ? 0.0
        : (rataRata / 100).clamp(0.0, 1.0).toDouble();
    final predikat = _predikatFromScore(rataRata);
    final teacher = hasil
        .map((item) => (item['guru'] ?? '').toString().trim())
        .firstWhere((name) => name.isNotEmpty, orElse: () => 'Guru Mata Pelajaran');
    final feedbackItem = hasil.firstWhere(
      (item) => (item['catatan'] ?? '').toString().trim().isNotEmpty,
      orElse: () => <String, dynamic>{},
    );
    final feedback = (feedbackItem['catatan'] ?? '').toString().trim();
    final mapelName = (mapel['nama'] ?? widget.namaMapel ?? 'Detail Nilai').toString();

    return Scaffold(
      backgroundColor: context.matsanamPage,
      appBar: AppBar(
        title: Text(
          'Detail Nilai Mapel & Rapor',
          style: TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w900,
            color: colors.onSurface,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Notifikasi',
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tidak ada notifikasi baru.')),
            ),
            icon: Icon(Icons.notifications_none_rounded, color: colors.onSurface),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                final tabs = PersistentTabScope.maybeOf(context);
                if (tabs != null) {
                  tabs.onSelect(4);
                } else {
                  Navigator.of(context).pushNamed('/siswa/profil');
                }
              },
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
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _load,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                    children: [
                      _Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: colors.primaryContainer,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'NILAI MATA PELAJARAN',
                                      style: TextStyle(
                                        fontSize: 9,
                                        letterSpacing: .35,
                                        fontWeight: FontWeight.w900,
                                        color: colors.primary,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  _Pill(
                                    label: hasKkm ? 'KKM ${kkm.toStringAsFixed(0)}' : 'KKM belum diatur',
                                    color: colors.primary,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                mapelName,
                                style: TextStyle(
                                  fontSize: 19,
                                  height: 1.15,
                                  fontWeight: FontWeight.w900,
                                  color: colors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.person_outline_rounded,
                                      size: 15, color: colors.primary),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Guru: $teacher',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: colors.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'NILAI RATA-RATA MAPEL',
                                            style: TextStyle(
                                              fontSize: 9.5,
                                              letterSpacing: .45,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white70,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.baseline,
                                            textBaseline: TextBaseline.alphabetic,
                                            children: [
                                              Text(
                                                rataRata == null ? '-' : rataRata.toStringAsFixed(1),
                                                style: const TextStyle(
                                                  fontSize: 30,
                                                  height: 1,
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              const Text('/ 100', style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white70,
                                              )),
                                            ],
                                          ),
                                          const SizedBox(height: 7),
                                          Row(
                                            children: [
                                              Icon(
                                                rataRata == null
                                                    ? Icons.info_outline_rounded
                                                    : rataTuntas
                                                        ? Icons.verified_rounded
                                                        : Icons.flag_outlined,
                                                size: 14,
                                                color: const Color(0xFF6EE7B7),
                                              ),
                                              const SizedBox(width: 5),
                                              Flexible(
                                                child: Text(
                                                  rataRata == null
                                                      ? 'Belum ada nilai'
                                                      : !hasKkm
                                                          ? 'Nilai tersedia'
                                                          : rataTuntas
                                                              ? 'Tuntas KKM (${kkm.toStringAsFixed(0)})'
                                                              : 'Belum mencapai KKM (${kkm.toStringAsFixed(0)})',
                                                  style: const TextStyle(
                                                    fontSize: 10.5,
                                                    fontWeight: FontWeight.w800,
                                                    color: Color(0xFFA7F3D0),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      width: 82,
                                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: .16),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        children: [
                                          const Text('PREDIKAT', style: TextStyle(
                                            fontSize: 8.5,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white70,
                                          )),
                                          const SizedBox(height: 2),
                                          Text(
                                            predikat,
                                            style: const TextStyle(
                                              fontSize: 23,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            _labelPredikat(predikat),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            style: const TextStyle(
                                              fontSize: 8.5,
                                              height: 1.1,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
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
                      const SizedBox(height: 13),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest.withValues(alpha: .65),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _GradeCategoryTab(
                                label: 'Semua (${hasil.length})',
                                active: _tabKategori == 'semua',
                                onTap: () => setState(() => _tabKategori = 'semua'),
                              ),
                            ),
                            Expanded(
                              child: _GradeCategoryTab(
                                label: 'Tugas & PR',
                                active: _tabKategori == 'tugas',
                                onTap: () => setState(() => _tabKategori = 'tugas'),
                              ),
                            ),
                            Expanded(
                              child: _GradeCategoryTab(
                                label: 'Ujian & Quiz',
                                active: _tabKategori == 'ujian',
                                onTap: () => setState(() => _tabKategori = 'ujian'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 11),
                      if (hasilTampil.isEmpty)
                        const _Empty(
                          icon: Icons.hourglass_empty_rounded,
                          title: 'Belum ada penilaian',
                          subtitle: 'Belum ada hasil pada kategori ini.',
                        ),
                      ...hasilTampil.asMap().entries.map((entry) {
                        final item = entry.value;
                        final score = (item['nilai'] as num?)?.toDouble();
                        final status = item['status_ketuntasan']?.toString() ??
                            'menunggu_penilaian';
                        final complete = status == 'tuntas';
                        final tugasId = (item['tugas_id'] as num?)?.toInt();
                        final kind = (item['jenis'] ?? 'Tugas').toString();
                        final isExam = kind.toLowerCase().contains('ujian') ||
                            kind.toLowerCase().contains('quiz') ||
                            kind.toLowerCase().contains('ulangan');
                        final statusColor = score == null
                            ? context.matsanamWarning
                            : complete
                                ? context.matsanamSuccess
                                : context.matsanamError;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 9),
                          child: _Card(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(15),
                              onTap: tugasId == null
                                  ? null
                                  : () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => DetailHasilPenilaianScreen(
                                            tugasId: tugasId,
                                          ),
                                        ),
                                      ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 34,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        color: colors.primaryContainer,
                                        borderRadius: BorderRadius.circular(9),
                                      ),
                                      child: Icon(
                                        isExam ? Icons.fact_check_outlined : Icons.assignment_outlined,
                                        color: colors.primary,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            (item['judul_tugas'] ?? '-').toString(),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12,
                                              height: 1.15,
                                              fontWeight: FontWeight.w900,
                                              color: colors.onSurface,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${item['jenis'] ?? 'Tugas'} • ${_date(item['tanggal_penilaian'])}',
                                            style: TextStyle(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w600,
                                              color: colors.onSurfaceVariant,
                                            ),
                                          ),
                                          const SizedBox(height: 7),
                                          _Pill(
                                            label: score == null
                                                ? 'Menunggu Penilaian'
                                                : complete
                                                    ? 'Tuntas'
                                                    : 'Belum Tuntas',
                                            color: statusColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          score == null ? '—' : score.toStringAsFixed(0),
                                          style: TextStyle(
                                            fontSize: 19,
                                            fontWeight: FontWeight.w900,
                                            color: score == null
                                                ? context.matsanamTextSecondary
                                                : context.matsanamPrimary,
                                          ),
                                        ),
                                        Text('/ 100', style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: colors.onSurfaceVariant,
                                        )),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                      if (feedback.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        _Card(
                          child: Padding(
                            padding: const EdgeInsets.all(13),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 31,
                                  height: 31,
                                  decoration: BoxDecoration(
                                    color: colors.primaryContainer,
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  child: Icon(Icons.format_quote_rounded,
                                      color: colors.primary, size: 18),
                                ),
                                const SizedBox(width: 9),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Catatan Guru Pengampu',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w900,
                                          color: colors.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        feedback,
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          height: 1.45,
                                          fontWeight: FontWeight.w500,
                                          color: colors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      _Card(
                        child: Padding(
                          padding: const EdgeInsets.all(13),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Rata - Rata',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: colors.onSurface,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    rataRata == null
                                        ? '— / 100'
                                        : '${rataRata.toStringAsFixed(1)} / 100',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: colors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 7,
                                  backgroundColor: colors.surfaceContainerHighest,
                                  color: rataRata == null
                                      ? colors.outline
                                      : rataTuntas
                                          ? context.matsanamSuccess
                                          : context.matsanamWarning,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                !hasKkm
                                    ? 'KKM belum tersedia untuk mata pelajaran ini.'
                                    : rataTuntas
                                        ? 'Rata-rata telah memenuhi KKM ${kkm.toStringAsFixed(0)}.'
                                        : 'Rata-rata belum mencapai KKM ${kkm.toStringAsFixed(0)}.',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w600,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _downloadingPdf ? null : _downloadPdf,
                          icon: _downloadingPdf
                              ? const SizedBox(
                                  width: 17,
                                  height: 17,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.picture_as_pdf_outlined, size: 18),
                          label: Text(
                            _downloadingPdf
                                ? 'Mengunduh PDF...'
                                : 'Unduh Rincian Nilai Mapel PDF',
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: colors.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  String _date(dynamic value) {
    final d = DateTime.tryParse(value?.toString() ?? '');
    return d == null
        ? 'Belum dinilai'
        : DateFormat('dd MMM yyyy', 'id_ID').format(d.toLocal());
  }
}

class _GradeCategoryTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _GradeCategoryTab({
    required this.label,
    required this.active,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(10),
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 5),
      decoration: BoxDecoration(
        color: active
            ? Theme.of(context).colorScheme.surface
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: active
              ? context.matsanamPrimary
              : context.matsanamTextSecondary,
        ),
      ),
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

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  const _Pill({required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 11),
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
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: context.matsanamTextSecondary),
          ),
          if (action != null)
            TextButton(onPressed: action, child: const Text('Coba Lagi')),
        ],
      ),
    ),
  );
}

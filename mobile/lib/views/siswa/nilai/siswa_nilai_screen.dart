import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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

class SiswaNilaiScreen extends StatefulWidget {
  const SiswaNilaiScreen({super.key});
  @override
  State<SiswaNilaiScreen> createState() => _SiswaNilaiScreenState();
}

class _SiswaNilaiScreenState extends State<SiswaNilaiScreen> {
  final _service = SiswaLearningService();
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  String? _error;
  bool _downloadingRekap = false;

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
      final items = await _service.nilai();
      if (mounted)
        setState(() {
          _items = items;
          _loading = false;
        });
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.unauthorized) {
        _toLogin();
        return;
      }
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (mounted)
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
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      actions: [
        IconButton(
          tooltip: _downloadingRekap ? 'Mengunduh rekap nilai' : 'Unduh rekap nilai PDF',
          onPressed: _downloadingRekap ? null : _downloadRekapPdf,
          icon: _downloadingRekap
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.picture_as_pdf_outlined),
        ),
      ],
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Matsanam Siswa',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          Text(
            'Nilai Akademik',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
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
        : _items.isEmpty
        ? const _Empty(
            icon: Icons.bar_chart_outlined,
            title: 'Belum ada nilai',
            subtitle:
                'Nilai akan tampil setelah Guru menyelesaikan penilaian tugas.',
          )
        : RefreshIndicator(
            onRefresh: _load,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = _items[index];
                final avg = (item['rata_rata'] as num?)?.toDouble();
                final kkm = (item['kkm'] as num?)?.toDouble() ?? 0;
                return _Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primaryLight,
                      child: Icon(
                        Icons.menu_book_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    title: Text(
                      '${item['mapel'] ?? '-'}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      '${item['jumlah_dinilai'] ?? 0} penilaian • KKM $kkm',
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          avg == null ? '-' : avg.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        const Text(
                          'Rata-rata tugas',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SiswaNilaiMapelScreen(
                          mapelId: (item['mapel_id'] as num).toInt(),
                          namaMapel: item['mapel']?.toString(),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
    bottomNavigationBar: SiswaBottomNavigationBar(currentIndex: 3, onTap: _tab),
  );
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
    if (mounted) setState(() { _loading = true; _error = null; });
    try {
      final value = await _service.nilaiMapel(widget.mapelId);
      if (mounted) setState(() { _data = value; _loading = false; });
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.unauthorized) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
        return;
      }
      setState(() { _error = error.message; _loading = false; });
    } catch (error) {
      if (mounted) setState(() { _error = error.toString(); _loading = false; });
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
          SnackBar(content: Text('Gagal mengunduh rincian nilai: ${error.message}')),
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
    final isExam = jenis.contains('ujian') || jenis.contains('quiz') || jenis.contains('ulangan');
    return _tabKategori == 'ujian' ? isExam : !isExam;
  }

  @override
  Widget build(BuildContext context) {
    final mapel = _data['mapel'] is Map
        ? Map<String, dynamic>.from(_data['mapel'])
        : <String, dynamic>{};
    final hasil = _data['hasil'] is List
        ? (_data['hasil'] as List)
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
        : <Map<String, dynamic>>[];
    final hasilTampil = hasil.where(_matchesCategory).toList();
    final rataRata = (_data['rata_rata'] as num?)?.toDouble();
    final kkm = (mapel['kkm'] as num?)?.toDouble() ?? 0;
    final rataTuntas = rataRata != null && rataRata >= kkm;
    final progress = rataRata == null ? 0.0 : (rataRata / 100).clamp(0.0, 1.0);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.namaMapel ?? mapel['nama']?.toString() ?? 'Detail Nilai',
        ),
        actions: [
          IconButton(tooltip: 'Muat ulang', onPressed: _load, icon: const Icon(Icons.refresh_rounded)),
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
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${mapel['nama'] ?? widget.namaMapel ?? '-'}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    'KKM: ${mapel['kkm'] ?? '-'}',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              rataRata == null ? '-' : rataRata.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 7,
                            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                            color: rataRata == null
                                ? AppColors.textMuted
                                : rataTuntas ? AppColors.success : AppColors.warning,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              rataRata == null
                                  ? Icons.info_outline_rounded
                                  : rataTuntas
                                      ? Icons.verified_rounded
                                      : Icons.flag_outlined,
                              size: 16,
                              color: rataRata == null
                                  ? AppColors.textMuted
                                  : rataTuntas ? AppColors.success : AppColors.warning,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                rataRata == null
                                    ? 'Belum ada nilai untuk dihitung.'
                                    : rataTuntas
                                        ? 'Rata-rata sudah mencapai KKM.'
                                        : 'Rata-rata masih di bawah KKM.',
                                style: TextStyle(
                                  color: rataRata == null
                                      ? AppColors.textSecondary
                                      : rataTuntas ? AppColors.success : AppColors.warning,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: .65),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    Expanded(child: _GradeCategoryTab(label: 'Semua (${hasil.length})', active: _tabKategori == 'semua', onTap: () => setState(() => _tabKategori = 'semua'))),
                    Expanded(child: _GradeCategoryTab(label: 'Tugas & PR', active: _tabKategori == 'tugas', onTap: () => setState(() => _tabKategori = 'tugas'))),
                    Expanded(child: _GradeCategoryTab(label: 'Ujian & Quiz', active: _tabKategori == 'ujian', onTap: () => setState(() => _tabKategori = 'ujian'))),
                  ]),
                ),
                const SizedBox(height: 12),
                if (hasilTampil.isEmpty)
                  const _Empty(
                    icon: Icons.hourglass_empty_rounded,
                    title: 'Belum ada penilaian',
                    subtitle: 'Belum ada hasil pada kategori ini.',
                  ),
                ...hasilTampil.map((item) {
                  final score = (item['nilai'] as num?)?.toDouble();
                  final status =
                      item['status_ketuntasan']?.toString() ??
                      'menunggu_penilaian';
                  final complete = status == 'tuntas';
                  final tugasId = (item['tugas_id'] as num?)?.toInt();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _Card(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
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
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${item['judul_tugas'] ?? '-'}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    score == null
                                        ? 'Menunggu'
                                        : score.toStringAsFixed(1),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: score == null
                                          ? AppColors.warning
                                          : AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${item['jenis'] ?? 'Tugas'} • ${_date(item['tanggal_penilaian'])}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _Pill(
                                label: status == 'tuntas'
                                    ? 'Tuntas'
                                    : status == 'belum_tuntas'
                                    ? 'Belum Tuntas'
                                    : 'Menunggu Penilaian',
                                color: score == null
                                    ? AppColors.warning
                                    : complete
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                              if ((item['catatan'] ?? '')
                                  .toString()
                                  .trim()
                                  .isNotEmpty) ...[
                                const Divider(height: 20),
                                const Text(
                                  'Feedback Guru',
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 4),
                                Text('${item['catatan']}'),
                              ],
                              const SizedBox(height: 8),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'Lihat detail',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppColors.primary,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
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
                          : 'Unduh Rincian Nilai PDF',
                    ),
                  ),
                ),
              ],
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
  const _GradeCategoryTab({required this.label, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(10),
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 5),
      decoration: BoxDecoration(
        color: active ? Theme.of(context).colorScheme.surface : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
          color: active ? AppColors.primary : AppColors.textSecondary)),
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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../services/api_exception.dart';
import '../../../services/siswa_learning_service.dart';
import '../../../utils/constants.dart';
import '../../../widgets/common/siswa_bottom_navigation.dart';
import '../dashboard/dashboard_siswa_page.dart';
import '../materi/siswa_materi_screen.dart';
import '../pengaturan/profil_siswa_screen.dart';
import '../tugas/siswa_tugas_screen.dart';

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
      if (mounted)
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
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final value = await _service.nilaiMapel(widget.mapelId);
      if (mounted)
        setState(() {
          _data = value;
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.namaMapel ?? mapel['nama']?.toString() ?? 'Detail Nilai',
        ),
      ),
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
                    padding: const EdgeInsets.all(16),
                    child: Row(
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
                          _data['rata_rata'] == null
                              ? '-'
                              : ((_data['rata_rata'] as num).toDouble())
                                    .toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (hasil.isEmpty)
                  const _Empty(
                    icon: Icons.hourglass_empty_rounded,
                    title: 'Belum ada penilaian',
                    subtitle:
                        'Pengumpulan tugas pada mata pelajaran ini belum dinilai.',
                  ),
                ...hasil.map((item) {
                  final score = (item['nilai'] as num?)?.toDouble();
                  final status =
                      item['status_ketuntasan']?.toString() ??
                      'menunggu_penilaian';
                  final complete = status == 'tuntas';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _Card(
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
                          ],
                        ),
                      ),
                    ),
                  );
                }),
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

import 'package:flutter/material.dart';
import '../../../services/siswa_learning_service.dart';
import '../../../utils/constants.dart';

class RekapAbsensiScreen extends StatefulWidget {
  const RekapAbsensiScreen({super.key});

  @override
  State<RekapAbsensiScreen> createState() => _RekapAbsensiScreenState();
}

class _RekapAbsensiScreenState extends State<RekapAbsensiScreen> {
  final _service = SiswaLearningService();

  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  String _filter = 'semua';
  Map<String, dynamic> _result = {};
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = false;
  int _page = 1;
  String? _error;

  String _isoDate(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

  DateTime get _monthStart =>
      DateTime(_selectedMonth.year, _selectedMonth.month, 1);
  DateTime get _monthEnd =>
      DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool loadMore = false}) async {
    if (loadMore && (!_hasMore || _loadingMore || _loading)) return;

    if (loadMore) {
      setState(() => _loadingMore = true);
    } else {
      setState(() {
        _loading = true;
        _error = null;
        _page = 1;
      });
    }

    final requestedPage = loadMore ? _page + 1 : 1;
    try {
      final data = await _service.riwayatAbsensi(
        dari: _isoDate(_monthStart),
        sampai: _isoDate(_monthEnd),
        status: _filter,
        page: requestedPage,
      );
      final paginator = data['data'] is Map
          ? Map<String, dynamic>.from(data['data'])
          : <String, dynamic>{};
      final raw = paginator['data'];
      final nextItems = raw is List
          ? raw
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList()
          : <Map<String, dynamic>>[];

      if (!mounted) return;
      setState(() {
        _result = data;
        _items = loadMore ? [..._items, ...nextItems] : nextItems;
        _page = requestedPage;
        _hasMore = paginator['next_page_url'] != null;
        _loading = false;
        _loadingMore = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  Future<void> _pickMonth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020, 1),
      lastDate: DateTime(now.year, now.month, now.day),
      helpText: 'Pilih bulan riwayat',
      fieldLabelText: 'Tanggal dalam bulan',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(
            context,
          ).colorScheme.copyWith(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );

    if (picked == null) return;
    setState(() {
      _selectedMonth = DateTime(picked.year, picked.month);
      _filter = 'semua';
    });
    await _load();
  }

  Future<void> _setFilter(String value) async {
    if (_filter == value) return;
    setState(() => _filter = value);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final summary = _result['summary'] is Map
        ? Map<String, dynamic>.from(_result['summary'])
        : <String, dynamic>{};
    final profile = _result['profile'] is Map
        ? Map<String, dynamic>.from(_result['profile'])
        : <String, dynamic>{};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Absensi'),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: _loading ? null : () => _load(),
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _loading && _items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _error != null && _items.isEmpty
          ? _ErrorState(message: _error!, onRetry: _load)
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                children: [
                  _StudentSummaryHeader(
                    name: profile['nama_lengkap']?.toString() ?? 'Siswa',
                    className:
                        profile['kelas']?.toString() ??
                        'Kelas belum ditetapkan',
                  ),
                  const SizedBox(height: 14),
                  _MonthSelector(
                    label: _formatMonth(_selectedMonth),
                    onTap: _pickMonth,
                  ),
                  const SizedBox(height: 14),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 2.25,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: [
                      _SummaryCard(
                        label: 'Hadir',
                        value: summary['hadir'] ?? 0,
                        color: AppColors.success,
                        icon: Icons.check_circle_outline_rounded,
                      ),
                      _SummaryCard(
                        label: 'Izin',
                        value: summary['izin'] ?? 0,
                        color: AppColors.primary,
                        icon: Icons.event_note_outlined,
                      ),
                      _SummaryCard(
                        label: 'Sakit',
                        value: summary['sakit'] ?? 0,
                        color: AppColors.warning,
                        icon: Icons.medical_services_outlined,
                      ),
                      _SummaryCard(
                        label: 'Alpa',
                        value: summary['alpa'] ?? 0,
                        color: AppColors.error,
                        icon: Icons.cancel_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Riwayat Kehadiran',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _StatusFilter(
                          label: 'Semua',
                          value: 'semua',
                          selected: _filter,
                          onTap: _setFilter,
                        ),
                        _StatusFilter(
                          label: 'Hadir',
                          value: 'hadir',
                          selected: _filter,
                          onTap: _setFilter,
                        ),
                        _StatusFilter(
                          label: 'Izin',
                          value: 'izin',
                          selected: _filter,
                          onTap: _setFilter,
                        ),
                        _StatusFilter(
                          label: 'Sakit',
                          value: 'sakit',
                          selected: _filter,
                          onTap: _setFilter,
                        ),
                        _StatusFilter(
                          label: 'Alpa',
                          value: 'alpa',
                          selected: _filter,
                          onTap: _setFilter,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _InlineError(message: _error!, onRetry: _load),
                    ),
                  if (_items.isEmpty)
                    _EmptyHistory(monthLabel: _formatMonth(_selectedMonth))
                  else ...[
                    ..._items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _AttendanceRow(
                          item: item,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  DetailRiwayatAbsensiScreen(absensi: item),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_hasMore)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 12),
                        child: OutlinedButton.icon(
                          onPressed: _loadingMore
                              ? null
                              : () => _load(loadMore: true),
                          icon: _loadingMore
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.expand_more_rounded),
                          label: Text(
                            _loadingMore
                                ? 'Memuat…'
                                : 'Muat Riwayat Berikutnya',
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(44),
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: Text(
                          'Semua riwayat pada periode ini sudah ditampilkan.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ),
                  ],
                ],
              ),
            ),
    );
  }
}

class DetailRiwayatAbsensiScreen extends StatelessWidget {
  final Map<String, dynamic> absensi;
  const DetailRiwayatAbsensiScreen({super.key, required this.absensi});

  @override
  Widget build(BuildContext context) {
    final status = (absensi['status'] ?? '-').toString();
    final statusColor = _statusColor(status);
    final hasLetter = absensi['surat_id'] != null;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Riwayat')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(_statusIcon(status), color: statusColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        absensi['mapel']?.toString() ?? 'Mata pelajaran',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _StatusPill(status: status, color: statusColor),
                const SizedBox(height: 12),
                Text(
                  _formatDate(absensi['tanggal']),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _DetailTile(label: 'Tanggal', value: _formatDate(absensi['tanggal'])),
          _DetailTile(
            label: 'Waktu presensi',
            value: _formatTime(absensi['waktu_absen']),
          ),
          _DetailTile(label: 'Kelas siswa', value: _value(absensi['kelas'])),
          _DetailTile(label: 'Guru pengampu', value: _value(absensi['guru'])),
          _DetailTile(
            label: 'Jam pelajaran',
            value: _value(absensi['jam_mulai']),
          ),
          _DetailTile(
            label: 'Metode presensi',
            value: _method(absensi['metode']),
          ),
          _DetailTile(
            label: 'Keterangan',
            value: _value(absensi['keterangan']),
          ),
          if (hasLetter) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.description_outlined,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Surat pendukung',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _DetailLine(
                    label: 'Jenis',
                    value: _title(absensi['surat_jenis']),
                  ),
                  _DetailLine(
                    label: 'Status verifikasi',
                    value: _title(absensi['surat_status_verifikasi']),
                  ),
                  _DetailLine(
                    label: 'Tanggal verifikasi',
                    value: _formatDateTime(absensi['surat_tanggal_verifikasi']),
                  ),
                  _DetailLine(
                    label: 'Diverifikasi oleh',
                    value: _value(absensi['surat_verifikator']),
                  ),
                  if ((absensi['surat_catatan_verifikasi'] ?? '')
                      .toString()
                      .trim()
                      .isNotEmpty)
                    _DetailLine(
                      label: 'Catatan verifikator',
                      value: absensi['surat_catatan_verifikasi'].toString(),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StudentSummaryHeader extends StatelessWidget {
  final String name;
  final String className;
  const _StudentSummaryHeader({required this.name, required this.className});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final initials = name.trim().isEmpty
        ? 'S'
        : name
              .trim()
              .split(RegExp(r'\s+'))
              .take(2)
              .map((part) => part[0])
              .join()
              .toUpperCase();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: .10),
              shape: BoxShape.circle,
            ),
            child: Text(
              initials,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  className,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
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

class _MonthSelector extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _MonthSelector({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Periode',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.keyboard_arrow_down_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final dynamic value;
  final Color color;
  final IconData icon;
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$value',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
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

class _StatusFilter extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final ValueChanged<String> onTap;
  const _StatusFilter({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = selected == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: active,
        onSelected: (_) => onTap(value),
        showCheckmark: false,
        selectedColor: AppColors.primary,
        backgroundColor: Theme.of(context).colorScheme.surface,
        side: BorderSide(
          color: active
              ? AppColors.primary
              : Theme.of(context).colorScheme.outlineVariant,
        ),
        labelStyle: TextStyle(
          color: active
              ? Colors.white
              : Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _AttendanceRow extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;
  const _AttendanceRow({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final status = item['status']?.toString() ?? '-';
    final color = _statusColor(status);
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(_statusIcon(status), color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['mapel']?.toString() ?? 'Mata pelajaran',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${_formatDate(item['tanggal'])} • ${item['guru'] ?? 'Guru'}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    if (item['surat_id'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Terkait surat pengajuan',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: AppColors.primary),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _StatusPill(status: status, color: color),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(item['waktu_absen']),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                color: scheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;
  final Color color;
  const _StatusPill({required this.status, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      _title(status),
      style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 11),
    ),
  );
}

class _DetailTile extends StatelessWidget {
  final String label;
  final String value;
  const _DetailTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 9),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}

class _DetailLine extends StatelessWidget {
  final String label;
  final String value;
  const _DetailLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 132,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

class _EmptyHistory extends StatelessWidget {
  final String monthLabel;
  const _EmptyHistory({required this.monthLabel});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 34),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: Column(
      children: [
        const Icon(
          Icons.event_busy_outlined,
          size: 42,
          color: AppColors.textMuted,
        ),
        const SizedBox(height: 10),
        Text(
          'Belum ada catatan absensi',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 5),
        Text(
          'Belum ada riwayat untuk $monthLabel. Coba pilih periode lain.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    ),
  );
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 42,
            color: AppColors.error,
          ),
          const SizedBox(height: 12),
          Text(
            'Riwayat belum dapat dimuat',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    ),
  );
}

class _InlineError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _InlineError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.error.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        const Icon(Icons.error_outline_rounded, color: AppColors.error),
        const SizedBox(width: 8),
        Expanded(
          child: Text(message, style: Theme.of(context).textTheme.bodySmall),
        ),
        TextButton(onPressed: onRetry, child: const Text('Ulangi')),
      ],
    ),
  );
}

Color _statusColor(String value) => switch (value) {
  'hadir' => AppColors.success,
  'izin' => AppColors.primary,
  'sakit' => AppColors.warning,
  'alpa' => AppColors.error,
  _ => AppColors.textSecondary,
};

IconData _statusIcon(String value) => switch (value) {
  'hadir' => Icons.check_rounded,
  'izin' => Icons.event_note_outlined,
  'sakit' => Icons.medical_services_outlined,
  'alpa' => Icons.close_rounded,
  _ => Icons.event_available_outlined,
};

String _title(dynamic value) {
  final text = value?.toString().trim() ?? '';
  if (text.isEmpty) return '-';
  return '${text[0].toUpperCase()}${text.substring(1)}';
}

String _value(dynamic value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? '-' : text;
}

const _monthNames = <String>[
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

String _formatMonth(DateTime date) =>
    '${_monthNames[date.month - 1]} ${date.year}';

String _formatDate(dynamic value) {
  final date = DateTime.tryParse(value?.toString() ?? '');
  if (date == null) return '-';
  final local = date.toLocal();
  return '${local.day} ${_monthNames[local.month - 1]} ${local.year}';
}

String _formatDateTime(dynamic value) {
  final date = DateTime.tryParse(value?.toString() ?? '');
  if (date == null) return '-';
  final local = date.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '${local.day} ${_monthNames[local.month - 1]} ${local.year}, $hour:$minute';
}

String _formatTime(dynamic value) {
  final text = value?.toString().trim() ?? '';
  if (text.isEmpty) return '—';
  return text.length >= 5 ? text.substring(0, 5) : text;
}

String _method(dynamic value) => switch (value?.toString()) {
  'qr' => 'QR Code',
  'manual' => 'Pencatatan manual',
  _ => _value(value),
};

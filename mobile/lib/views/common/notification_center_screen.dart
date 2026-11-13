import 'package:flutter/material.dart';

import '../../models/notification_model.dart';
import '../../services/api_exception.dart';
import '../../services/notification_service.dart';
import '../../utils/constants.dart';
import '../../utils/session.dart';
import '../auth/login_screen.dart';
import '../guru/absensi/verifikasi_surat_screen.dart';
import '../siswa/absensi/status_pengajuan_screen.dart';
import '../siswa/materi/siswa_materi_screen.dart';
import '../siswa/nilai/siswa_nilai_screen.dart';
import '../siswa/tugas/siswa_tugas_screen.dart';

class NotificationCenterScreen extends StatefulWidget {
  final String title;

  const NotificationCenterScreen({super.key, this.title = 'Notifikasi'});

  @override
  State<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  final _service = NotificationService();
  final _scrollController = ScrollController();
  final List<NotificationItem> _items = [];

  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = false;
  String _filter = 'all';
  String? _error;
  String _role = 'siswa';
  int _unreadCount = 0;
  int _page = 1;
  int _feedRequestId = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _initialize();
  }

  Future<void> _initialize() async {
    final role = await Session.getRole();
    if (!mounted) return;
    if (role != null && role.isNotEmpty) setState(() => _role = role);
    await _load();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _loadingMore || !_hasMore) return;
    if (_scrollController.position.extentAfter < 280) _loadMore();
  }

  Future<void> _load({bool refresh = false}) async {
    if (!mounted) return;
    final requestId = ++_feedRequestId;
    setState(() {
      _loading = true;
      _loadingMore = false;
      _error = null;
      if (refresh) {
        _page = 1;
        _hasMore = false;
        _items.clear();
      }
    });

    try {
      final result = await _service.fetch(filter: _filter, page: 1);
      if (!mounted || requestId != _feedRequestId) return;
      setState(() {
        _items
          ..clear()
          ..addAll(result.items);
        _unreadCount = result.unreadCount;
        _page = result.currentPage;
        _hasMore = result.hasMore;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted || requestId != _feedRequestId) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
      if (error.unauthorized) _toLogin();
    } catch (_) {
      if (!mounted || requestId != _feedRequestId) return;
      setState(() {
        _error = 'Terjadi kesalahan saat memuat notifikasi.';
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loading || _loadingMore || !_hasMore) return;
    final requestId = _feedRequestId;
    setState(() => _loadingMore = true);
    try {
      final result = await _service.fetch(filter: _filter, page: _page + 1);
      if (!mounted || requestId != _feedRequestId) return;
      setState(() {
        _items.addAll(result.items);
        _unreadCount = result.unreadCount;
        _page = result.currentPage;
        _hasMore = result.hasMore;
        _loadingMore = false;
      });
    } on ApiException catch (error) {
      if (!mounted || requestId != _feedRequestId) return;
      setState(() => _loadingMore = false);
      if (error.unauthorized) _toLogin();
    } catch (_) {
      if (mounted && requestId == _feedRequestId) {
        setState(() => _loadingMore = false);
      }
    }
  }

  void _toLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Future<void> _markAllRead() async {
    if (_unreadCount == 0) return;
    try {
      await _service.markAllAsRead();
      if (!mounted) return;
      setState(() {
        if (_filter == 'unread') {
          _items.clear();
          _hasMore = false;
        } else {
          for (var index = 0; index < _items.length; index++) {
            _items[index] = _items[index].markRead();
          }
        }
        _unreadCount = 0;
      });
      _message('Semua notifikasi ditandai sudah dibaca.');
    } catch (error) {
      _message('Gagal memperbarui notifikasi: $error');
    }
  }

  Future<void> _open(NotificationItem item) async {
    if (!item.isRead) {
      try {
        await _service.markAsRead(item.id);
        if (!mounted) return;
        final index = _items.indexWhere((entry) => entry.id == item.id);
        if (_filter == 'unread') {
          // Offset pagination shifts when an item is removed from the unread
          // result set. Reload page one so the next page cannot skip an item.
          await _load(refresh: true);
        } else if (index >= 0) {
          setState(() {
            _items[index] = item.markRead();
            if (_unreadCount > 0) _unreadCount--;
          });
        }
      } catch (error) {
        _message('Tidak dapat memperbarui status baca: $error');
      }
    }

    if (!mounted) return;
    final metadata = item.metadata;
    final type = item.type;

    if (_role == 'siswa') {
      switch (type) {
        case 'materi_baru':
          final mapelId = int.tryParse(metadata['mapel_id']?.toString() ?? '');
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SiswaMateriScreen(mapelId: mapelId),
            ),
          );
          return;
        case 'tugas_baru':
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const SiswaTugasScreen()));
          return;
        case 'nilai_diterbitkan':
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const SiswaNilaiScreen()));
          return;
        case 'status_pengajuan_izin':
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const StatusPengajuanScreen()),
          );
          return;
      }
    } else if (_role == 'guru') {
      switch (type) {
        case 'pengajuan_izin':
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const VerifikasiSuratGuruScreen(),
            ),
          );
          return;
        case 'pengumpulan_tugas':
          Navigator.of(context).pushNamed('/guru/nilai');
          return;
      }
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(item.title),
        content: Text(item.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _message(String value) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(value), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title),
            Text(
              _unreadCount > 0
                  ? '$_unreadCount belum dibaca'
                  : 'Semua pemberitahuan sudah dibaca',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton.icon(
              onPressed: _markAllRead,
              icon: const Icon(Icons.done_all_rounded, size: 18),
              label: const Text('Baca semua'),
            ),
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: () => _load(refresh: true),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                _filterChip('all', 'Semua'),
                const SizedBox(width: 8),
                _filterChip('unread', 'Belum dibaca'),
              ],
            ),
          ),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _filterChip(String value, String label) => ChoiceChip(
    label: Text(label),
    selected: _filter == value,
    onSelected: (selected) {
      if (!selected || _filter == value) return;
      setState(() => _filter = value);
      _load(refresh: true);
    },
  );

  Widget _buildList() {
    if (_loading && _items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _items.isEmpty) {
      return _StateMessage(
        icon: Icons.cloud_off_outlined,
        title: 'Gagal memuat notifikasi',
        message: _error!,
        action: () => _load(refresh: true),
      );
    }
    if (_items.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _load(refresh: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 90),
            Icon(
              _filter == 'unread'
                  ? Icons.mark_email_read_outlined
                  : Icons.notifications_none_rounded,
              size: 58,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 14),
            Center(
              child: Text(
                _filter == 'unread'
                    ? 'Tidak ada notifikasi yang belum dibaca'
                    : 'Belum ada notifikasi',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 6),
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 36),
                child: Text(
                  'Pemberitahuan materi, tugas, nilai, dan aktivitas akan muncul di sini.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _load(refresh: true),
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: _items.length + (_loadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 9),
        itemBuilder: (context, index) {
          if (index >= _items.length) {
            return const Padding(
              padding: EdgeInsets.all(18),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final item = _items[index];
          return _NotificationTile(item: item, onTap: () => _open(item));
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback onTap;

  const _NotificationTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final icon = switch (item.type) {
      'materi_baru' => Icons.menu_book_outlined,
      'tugas_baru' => Icons.assignment_outlined,
      'nilai_diterbitkan' => Icons.grade_outlined,
      'status_pengajuan_izin' || 'pengajuan_izin' => Icons.fact_check_outlined,
      'pengumpulan_tugas' => Icons.upload_file_outlined,
      _ => Icons.notifications_active_outlined,
    };
    return Material(
      color: item.isRead
          ? colors.surface
          : colors.primaryContainer.withValues(alpha: .38),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: colors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: item.isRead
                            ? FontWeight.w600
                            : FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.body,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.45,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDate(item.createdAt),
                      style: TextStyle(
                        fontSize: 10,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (!item.isRead)
                Container(
                  width: 9,
                  height: 9,
                  margin: const EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                  ),
                )
              else
                Icon(
                  Icons.chevron_right_rounded,
                  color: colors.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? value) {
    if (value == null) return 'Waktu tidak tersedia';
    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year;
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/$year • $hour:$minute';
  }
}

class _StateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback action;

  const _StateMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.action,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: action,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Coba lagi'),
          ),
        ],
      ),
    ),
  );
}

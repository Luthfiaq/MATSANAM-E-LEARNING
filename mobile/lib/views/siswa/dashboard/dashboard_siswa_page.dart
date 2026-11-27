import 'package:flutter/material.dart';

import '../../../widgets/common/persistent_tab_shell.dart';

import '../../../models/dashboard_model.dart';
import '../../../services/api_exception.dart';
import '../../../services/auth_service.dart';
import '../../../services/dashboard_service.dart';
import '../../../services/notification_service.dart';
import '../../../utils/constants.dart';
import '../../../widgets/common/siswa_bottom_navigation.dart';
import '../../auth/login_screen.dart';
import '../absensi/absensi_screen.dart';
import '../jadwal/siswa_jadwal_screen.dart';
import '../materi/siswa_materi_screen.dart';
import '../nilai/siswa_nilai_screen.dart';
import '../notifikasi/siswa_notifikasi_screen.dart';
import '../pengaturan/profil_siswa_screen.dart';
import '../tugas/siswa_tugas_screen.dart';
import '../materi/siswa_materi_detail_screen.dart';

class DashboardSiswaPage extends StatefulWidget {
  const DashboardSiswaPage({super.key});

  @override
  State<DashboardSiswaPage> createState() => _DashboardSiswaPageState();
}

class _DashboardSiswaPageState extends State<DashboardSiswaPage> {
  final _service = DashboardService();

  DashboardSiswa? _data;
  String? _error;
  bool _loading = true;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _muat();
    _muatUnreadCount();
  }

  Future<void> _muat({bool dariRefresh = false}) async {
    if (!dariRefresh) setState(() => _loading = true);
    try {
      final d = await _service.fetch();
      if (!mounted) return;
      setState(() {
        _data = d;
        _error = null;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (e.unauthorized) {
        await AuthService().logout();
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
        return;
      }
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Terjadi kesalahan saat memuat data.';
        _loading = false;
      });
    }
  }

  void _bukaTugas() => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const SiswaTugasScreen()));

  void _bukaMateri() => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const SiswaMateriScreen()));

  void _bukaNilai() => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const SiswaNilaiScreen()));

  Future<void> _muatUnreadCount() async {
    try {
      final count = await NotificationService().unreadCount();
      if (mounted) setState(() => _unreadCount = count);
    } catch (_) {
      // The notification badge must not block the dashboard when the API is offline.
    }
  }

  Future<void> _bukaNotifikasi() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SiswaNotifikasiScreen()));
    if (mounted) _muatUnreadCount();
  }

  void _bukaBantuan() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Bantuan Siswa'),
        content: const Text(
          'Untuk bantuan akun, materi, tugas, atau presensi, hubungi Admin/Tata Usaha MTsN 6 Nganjuk.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _bukaJadwal() => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const SiswaJadwalScreen()));

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

  Future<void> _bukaAbsensi() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AbsensiScreen()));
    if (mounted) _muat(dariRefresh: true);
  }

  void _profil() {
    final tabs = PersistentTabScope.maybeOf(context);
    if (tabs != null) {
      tabs.onSelect(4);
    } else {
      Navigator.of(context).pushNamed('/siswa/profil');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _AppBar(
        jumlahNotifikasi: _unreadCount,
        onLonceng: _bukaNotifikasi,
        onProfil: _profil,
      ),
      body: _buildBody(),
      bottomNavigationBar: SiswaBottomNavigationBar(
        currentIndex: 0,
        onTap: _tab,
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _data == null) {
      return _ErrorView(message: _error!, onRetry: _muat);
    }
    final d = _data!;
    final now = DateTime.now();
    final jadwalAktif = d.jadwal
        .where((j) => j.faseSekarang(now) != JadwalFase.selesai)
        .toList();

    return RefreshIndicator(
      onRefresh: () => _muat(dariRefresh: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _Banner(data: d, kelasMenunggu: jadwalAktif.length),
          const SizedBox(height: 14),
          _StatsRow(data: d),
          const SizedBox(height: 16),
          _AksesCepat(
            onScan: _bukaAbsensi,
            onMateri: _bukaMateri,
            onKumpul: _bukaTugas,
            onNilai: _bukaNilai,
            onBantuan: _bukaBantuan,
          ),
          const SizedBox(height: 22),
          _SectionHeader(
            color: AppColors.success,
            title: 'Jadwal & Presensi Hari Ini',
            trailing: GestureDetector(
              onTap: _bukaJadwal,
              child: Text(
                'Lihat Semua',
                style: TextStyle(
                  fontSize: 12.5,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (d.jadwal.isEmpty)
            const _EmptyCard(
              icon: Icons.event_available_outlined,
              text: 'Tidak ada jadwal pelajaran hari ini',
            )
          else if (jadwalAktif.isEmpty)
            const _EmptyCard(
              icon: Icons.task_alt_rounded,
              text: 'Semua pelajaran hari ini sudah selesai',
            )
          else
            ...jadwalAktif
                .take(3)
                .map(
                  (j) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _JadwalCard(
                      jadwal: j,
                      now: now,
                      onScan: _bukaAbsensi,
                    ),
                  ),
                ),
          const SizedBox(height: 10),
          _SectionHeader(
            color: AppColors.error,
            title: 'Deadline Tugas',
            trailing: GestureDetector(
              onTap: _bukaTugas,
              child: Text(
                'Semua (${d.deadlineTotal})',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (d.deadline.isEmpty)
            const _EmptyCard(
              icon: Icons.celebration_outlined,
              text: 'Tidak ada tugas aktif. Mantap!',
            )
          else
            ...d.deadline.map(
              (t) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TugasCard(tugas: t, onTap: _bukaTugas),
              ),
            ),
          const SizedBox(height: 10),
          _SectionHeader(
            color: AppColors.primary,
            title: 'Materi Baru',
            trailing: GestureDetector(
              onTap: _bukaMateri,
              child: const Text(
                'E-Library',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (d.materi.isEmpty)
            const _EmptyCard(
              icon: Icons.menu_book_outlined,
              text: 'Belum ada materi baru',
            )
          else
            ...d.materi.map(
              (m) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _MateriCard(
                  materi: m,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SiswaMateriDetailScreen(materiId: m.id),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/* ===================== App bar & bottom nav ===================== */

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  final int jumlahNotifikasi;
  final VoidCallback onLonceng;
  final VoidCallback onProfil;
  const _AppBar({
    required this.jumlahNotifikasi,
    required this.onLonceng,
    required this.onProfil,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surface,
      elevation: 0.5,
      shadowColor: Colors.black26,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Matsanam Siswa',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Siswa: Dashboard',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: colors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      onPressed: onLonceng,
                      icon: Icon(
                        Icons.notifications_none_rounded,
                        size: 26,
                        color: colors.onSurface,
                      ),
                    ),
                    if (jumlahNotifikasi > 0)
                      Positioned(
                        top: 5,
                        right: 3,
                        child: Container(
                          constraints: const BoxConstraints(
                            minWidth: 17,
                            minHeight: 17,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: colors.surface,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            jumlahNotifikasi > 9 ? '9+' : '$jumlahNotifikasi',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onProfil,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      size: 22,
                      color: Colors.white,
                    ),
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

/* ===================== Banner & statistik ===================== */

class _Banner extends StatelessWidget {
  final DashboardSiswa data;
  final int kelasMenunggu;
  const _Banner({required this.data, required this.kelasMenunggu});

  String get _salam {
    final h = DateTime.now().hour;
    if (h < 11) return 'Pagi';
    if (h < 15) return 'Siang';
    if (h < 18) return 'Sore';
    return 'Malam';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1E4FD0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.circle,
                        size: 7,
                        color: Color(0xFF34D399),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Siswa Aktif • Kelas ${data.kelas}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'NIS: ${data.nis}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Selamat $_salam, ${data.namaPanggilan} 👋',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.bolt_rounded,
                size: 17,
                color: Color(0xFF5EEAD4),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Hari ini ada ${data.tugasAktif} tugas aktif & $kelasMenunggu kelas menunggu',
                  style: const TextStyle(color: Colors.white, fontSize: 13.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.white.withValues(alpha: 0.25), height: 1),
          const SizedBox(height: 10),
          Text(
            data.periode != null
                ? 'Semester ${data.periode}'
                : 'Semester aktif',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}


class _StatsRow extends StatelessWidget {
  final DashboardSiswa data;
  const _StatsRow({required this.data});

  @override
  Widget build(BuildContext context) {
    final hadir = data.kehadiranPersen;
    final rerata = data.rerataNilai;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Tugas',
            value: '${data.tugasAktif}',
            caption: 'Tugas Aktif',
            icon: Icons.assignment_outlined,
            color: dark ? const Color(0xFF60A5FA) : AppColors.primary,
            soft: dark ? const Color(0xFF1E3A8A) : AppColors.infoLight,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Hadir',
            value: hadir != null ? '$hadir%' : '-',
            caption: 'Bulan Ini',
            icon: Icons.check_circle_outline_rounded,
            color: dark ? const Color(0xFF34D399) : AppColors.success,
            soft: dark ? const Color(0xFF123D31) : AppColors.successLight,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Rerata',
            value: rerata != null ? rerata.toStringAsFixed(1) : '-',
            caption: 'Nilai Tugas',
            icon: Icons.star_border_rounded,
            color: dark ? const Color(0xFFFBBF24) : const Color(0xFFF59E0B),
            soft: dark ? const Color(0xFF4B3718) : AppColors.warningLight,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String caption;
  final IconData icon;
  final Color color;
  final Color soft;

  const _StatCard({
    required this.label,
    required this.value,
    required this.caption,
    required this.icon,
    required this.color,
    required this.soft,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark ? const Color(0xFF1E293B) : Colors.white;
    final primaryText = isDark
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF0F172A);
    final secondaryText = isDark
        ? const Color(0xFFCBD5E1)
        : const Color(0xFF64748B);
    final outline = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);

    // Keep the animation, but use a uniform outer border. Flutter does not
    // allow a non-uniform BorderSide color together with borderRadius.
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      width: double.infinity,
      height: 116,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: outline, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.045),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Colored accent is a separate widget, not a differently colored
            // side of the rounded Border. This avoids the paint assertion.
            SizedBox(
              width: 4,
              child: ColoredBox(color: color),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(11, 10, 9, 9),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: secondaryText,
                              fontSize: 12,
                              height: 1.1,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Container(
                          width: 25,
                          height: 25,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: soft,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(icon, size: 15, color: color),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: primaryText,
                            fontSize: 24,
                            height: 1,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: secondaryText,
                            fontSize: 10.5,
                            height: 1.1,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ===================== Akses cepat ===================== */

/* ===================== Akses cepat ===================== */


class _AksesCepat extends StatelessWidget {
  final VoidCallback onScan;
  final VoidCallback onMateri;
  final VoidCallback onKumpul;
  final VoidCallback onNilai;
  final VoidCallback onBantuan;
  const _AksesCepat({
    required this.onScan,
    required this.onMateri,
    required this.onKumpul,
    required this.onNilai,
    required this.onBantuan,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _kartu(context),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Akses Cepat',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),
              GestureDetector(
                onTap: onBantuan,
                child: Text(
                  'Bantuan Siswa',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: colors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _AksesItem(
                  icon: Icons.qr_code_scanner_rounded,
                  label: 'Scan QR\nAbsen',
                  bg: dark ? const Color(0xFF1E3A8A) : AppColors.primary,
                  fg: Colors.white,
                  badge: true,
                  onTap: onScan,
                ),
              ),
              Expanded(
                child: _AksesItem(
                  icon: Icons.menu_book_rounded,
                  label: 'Materi\nBelajar',
                  bg: dark ? const Color(0xFF1E3A8A) : const Color(0xFFE0E7FF),
                  fg: dark ? const Color(0xFFBFDBFE) : AppColors.primaryDark,
                  onTap: onMateri,
                ),
              ),
              Expanded(
                child: _AksesItem(
                  icon: Icons.cloud_upload_outlined,
                  label: 'Kumpul\nTugas',
                  bg: dark ? const Color(0xFF123D31) : AppColors.secondaryLight,
                  fg: dark ? const Color(0xFF6EE7B7) : AppColors.success,
                  onTap: onKumpul,
                ),
              ),
              Expanded(
                child: _AksesItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'Cek\nNilai',
                  bg: dark ? const Color(0xFF1E3A8A) : const Color(0xFFE0E7FF),
                  fg: dark ? const Color(0xFFBFDBFE) : AppColors.primaryDark,
                  onTap: onNilai,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AksesItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;
  final bool badge;
  const _AksesItem({
    required this.icon,
    required this.label,
    required this.bg,
    required this.fg,
    required this.onTap,
    this.badge = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 25, color: fg),
              ),
              if (badge)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.surface, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.photo_camera_rounded,
                      size: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.25,
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

/* ===================== Section & kartu ===================== */

/* ===================== Section & kartu ===================== */


class _SectionHeader extends StatelessWidget {
  final Color color;
  final String title;
  final Widget trailing;
  const _SectionHeader({
    required this.color,
    required this.title,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(Icons.circle, size: 9, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),
        ),
        trailing,
      ],
    );
  }
}

BoxDecoration _kartu(BuildContext context) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  return BoxDecoration(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(
      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.55),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: dark ? 0.16 : 0.04),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );
}

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String text;
  const _EmptyCard({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      decoration: _kartu(context),
      child: Column(
        children: [
          Icon(icon, size: 30, color: colors.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}


class _JadwalCard extends StatelessWidget {
  final JadwalHariIni jadwal;
  final DateTime now;
  final VoidCallback onScan;
  const _JadwalCard({
    required this.jadwal,
    required this.now,
    required this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    final fase = jadwal.faseSekarang(now);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;
    final (chipText, chipBg, chipFg) = switch (fase) {
      JadwalFase.berlangsung => (
          'Sedang Berlangsung',
          dark ? const Color(0xFF123D31) : AppColors.successLight,
          dark ? const Color(0xFF34D399) : AppColors.success,
        ),
      JadwalFase.akan => (
          'Akan Datang',
          dark ? const Color(0xFF1E3A8A) : AppColors.infoLight,
          dark ? const Color(0xFFBFDBFE) : AppColors.primaryDark,
        ),
      JadwalFase.selesai => (
          'Selesai',
          dark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          colors.onSurfaceVariant,
        ),
    };
    final matematika = jadwal.mapel.toLowerCase().contains('matematika');

    return Container(
      decoration: _kartu(context),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: chipBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, size: 7, color: chipFg),
                          const SizedBox(width: 5),
                          Text(
                            chipText,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: chipFg,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.access_time_rounded, size: 14, color: colors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      '${jadwal.jamMulai} - ${jadwal.jamSelesai} WIB',
                      style: TextStyle(fontSize: 12.5, color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            jadwal.mapel,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: colors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.person_outline_rounded, size: 15, color: colors.onSurfaceVariant),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  jadwal.guru,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(Icons.meeting_room_outlined, size: 15, color: colors.onSurfaceVariant),
                              const SizedBox(width: 5),
                              Text(
                                'Ruang ${jadwal.ruangan}',
                                style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: dark ? const Color(0xFF1E3A8A) : AppColors.infoLight,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        matematika ? Icons.calculate_outlined : Icons.auto_stories_outlined,
                        size: 25,
                        color: dark ? const Color(0xFFBFDBFE) : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            color: dark ? const Color(0xFF263449) : const Color(0xFFEFF4FD),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Icon(Icons.circle, size: 9, color: dark ? const Color(0xFF34D399) : AppColors.success),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Toleransi s/d ${jadwal.batasToleransi} WIB',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                ),
                _AksiPresensi(jadwal: jadwal, fase: fase, onScan: onScan),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _AksiPresensi extends StatelessWidget {
  final JadwalHariIni jadwal;
  final JadwalFase fase;
  final VoidCallback onScan;
  const _AksiPresensi({
    required this.jadwal,
    required this.fase,
    required this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;
    if (jadwal.sudahAbsen) {
      final status = (jadwal.statusAbsen ?? '').trim().toLowerCase();
      final label = status.isEmpty
          ? 'Tercatat'
          : '${status[0].toUpperCase()}${status.substring(1)}';
      final hadir = status == 'hadir';
      final foreground = hadir
          ? (dark ? const Color(0xFF34D399) : AppColors.success)
          : (dark ? const Color(0xFFFBBF24) : AppColors.warning);
      final background = hadir
          ? (dark ? const Color(0xFF123D31) : AppColors.successLight)
          : (dark ? const Color(0xFF4B3718) : AppColors.warningLight);
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hadir ? Icons.check_circle_rounded : Icons.info_outline_rounded,
              size: 15,
              color: foreground,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: foreground,
              ),
            ),
          ],
        ),
      );
    }

    if (fase == JadwalFase.berlangsung) {
      return ElevatedButton.icon(
        onPressed: onScan,
        icon: const Icon(Icons.qr_code_scanner_rounded, size: 16),
        label: const Text(
          'Scan QR Hadir',
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF047857),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }

    return Text(
      fase == JadwalFase.akan ? 'Belum dimulai' : 'Tidak tercatat',
      style: TextStyle(fontSize: 12.5, color: colors.onSurfaceVariant),
    );
  }
}


class _TugasCard extends StatelessWidget {
  final DeadlineTugas tugas;
  final VoidCallback onTap;
  const _TugasCard({required this.tugas, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;
    final urgent = tugas.sisaMenit < 6 * 60;
    final chipBg = urgent ? AppColors.error : const Color(0xFFF59E0B);
    final percent = (tugas.progress * 100).round();
    final matematika = tugas.mapel.toLowerCase().contains('matematika');
    final softPrimary = dark ? const Color(0xFF1E3A8A) : const Color(0xFFE0E7FF);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _kartu(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: chipBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  tugas.labelSisa,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tugas.mapel,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.5, color: colors.onSurfaceVariant),
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: matematika ? softPrimary : (dark ? const Color(0xFF4B3718) : AppColors.warningLight),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: matematika
                    ? Center(
                        child: Text(
                          'Σ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: dark ? const Color(0xFFBFDBFE) : AppColors.primaryDark,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.edit_note_rounded,
                        size: 22,
                        color: dark ? const Color(0xFFFBBF24) : AppColors.warning,
                      ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            tugas.judul,
            style: TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),
          if (tugas.totalSiswa > 0) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pengumpulan Kelas: ${tugas.sudahKumpul}/${tugas.totalSiswa} Siswa',
                  style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                ),
                Text(
                  '$percent%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: tugas.progress,
                minHeight: 7,
                backgroundColor: dark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                color: colors.primary,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (tugas.adaLampiran)
                Row(
                  children: [
                    Icon(Icons.attach_file_rounded, size: 16, color: colors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      'Ada File Lampiran',
                      style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                    ),
                  ],
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: dark ? const Color(0xFF263449) : const Color(0xFFE8EEF9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tugas.jenisLabel,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              urgent
                  ? ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: colors.onPrimary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Kerjakan', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, size: 15),
                        ],
                      ),
                    )
                  : TextButton(
                      onPressed: onTap,
                      style: TextButton.styleFrom(
                        backgroundColor: softPrimary,
                        foregroundColor: dark ? const Color(0xFFBFDBFE) : AppColors.primaryDark,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        'Rincian',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}


class _MateriCard extends StatelessWidget {
  final MateriBaru materi;
  final VoidCallback onTap;
  const _MateriCard({required this.materi, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;
    final softPrimary = dark ? const Color(0xFF1E3A8A) : const Color(0xFFE0E7FF);
    final softInfo = dark ? const Color(0xFF1E3A8A) : AppColors.infoLight;
    final primaryIcon = dark ? const Color(0xFFBFDBFE) : AppColors.primaryDark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: _kartu(context),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: softPrimary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.play_lesson_outlined, size: 27, color: primaryIcon),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (materi.ekstensi.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: softInfo,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            materi.ekstensi,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: primaryIcon,
                            ),
                          ),
                        ),
                      Expanded(
                        child: Text(
                          materi.mapel,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    materi.judul,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Diunggah oleh ${materi.guru}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: softPrimary,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(Icons.chevron_right_rounded, size: 22, color: primaryIcon),
            ),
          ],
        ),
      ),
    );
  }
}


class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 52, color: colors.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


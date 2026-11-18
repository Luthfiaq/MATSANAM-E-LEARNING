import 'package:flutter/material.dart';

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
    Navigator.of(context).pushNamed('/siswa/profil');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.primary,
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
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
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

  static String _labelTanggal(String? hari, DateTime now) {
    const bln = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    const namaHari = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    return '${hari ?? namaHari[now.weekday - 1]}, ${now.day} ${bln[now.month - 1]}';
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
    return Material(
      color: Colors.white,
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
                const Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Matsanam Siswa',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Siswa: Dashboard',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
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
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        size: 26,
                        color: AppColors.textPrimary,
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
                            border: Border.all(color: Colors.white, width: 1.5),
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
                      color: AppColors.primaryDark,
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

class _BottomNav extends StatelessWidget {
  final ValueChanged<int> onTap;
  const _BottomNav({required this.onTap});

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_rounded, 'Beranda'),
      (Icons.menu_book_rounded, 'Materi'),
      (Icons.assignment_outlined, 'Tugas'),
      (Icons.bar_chart_rounded, 'Nilai'),
      (Icons.person_outline_rounded, 'Profil'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: List.generate(items.length, (i) {
              final aktif = i == 0; // halaman ini = Beranda
              final warna = aktif ? AppColors.primary : const Color(0xFF475569);
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(items[i].$1, size: 24, color: warna),
                      const SizedBox(height: 3),
                      Text(
                        items[i].$2,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: aktif ? FontWeight.w800 : FontWeight.w600,
                          color: warna,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
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
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Tugas',
            value: '${data.tugasAktif}',
            caption: 'Tugas Aktif',
            icon: Icons.assignment_outlined,
            color: AppColors.primary,
            soft: AppColors.infoLight,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Hadir',
            value: hadir != null ? '$hadir%' : '-',
            caption: 'Bulan Ini',
            icon: Icons.check_circle_outline_rounded,
            color: AppColors.success,
            soft: AppColors.successLight,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Rerata',
            value: rerata != null ? rerata.toStringAsFixed(1) : '-',
            caption: 'Nilai Tugas',
            icon: Icons.star_border_rounded,
            color: const Color(0xFFF59E0B),
            soft: AppColors.warningLight,
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
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: color, width: 3.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: soft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 15, color: color),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            caption,
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Akses Cepat',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: onBantuan,
                child: const Text(
                  'Bantuan Siswa',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
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
                  bg: AppColors.primary,
                  fg: Colors.white,
                  badge: true,
                  onTap: onScan,
                ),
              ),
              Expanded(
                child: _AksesItem(
                  icon: Icons.menu_book_rounded,
                  label: 'Materi\nBelajar',
                  bg: const Color(0xFFE0E7FF),
                  fg: AppColors.primaryDark,
                  onTap: onMateri,
                ),
              ),
              Expanded(
                child: _AksesItem(
                  icon: Icons.cloud_upload_outlined,
                  label: 'Kumpul\nTugas',
                  bg: AppColors.secondaryLight,
                  fg: AppColors.success,
                  onTap: onKumpul,
                ),
              ),
              Expanded(
                child: _AksesItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'Cek\nNilai',
                  bg: const Color(0xFFE0E7FF),
                  fg: AppColors.primaryDark,
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
  final bool badge;
  final VoidCallback onTap;
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
                      border: Border.all(color: Colors.white, width: 1.5),
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
            style: const TextStyle(
              fontSize: 12,
              height: 1.25,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

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
    return Row(
      children: [
        Icon(Icons.circle, size: 9, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        trailing,
      ],
    );
  }
}

BoxDecoration _kartu() => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(18),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ],
);

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String text;
  const _EmptyCard({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      decoration: _kartu(),
      child: Column(
        children: [
          Icon(icon, size: 30, color: const Color(0xFF94A3B8)),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppColors.textSecondary,
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
    final (chipText, chipBg, chipFg) = switch (fase) {
      JadwalFase.berlangsung => (
        'Sedang Berlangsung',
        AppColors.successLight,
        AppColors.success,
      ),
      JadwalFase.akan => (
        'Akan Datang',
        AppColors.infoLight,
        AppColors.primaryDark,
      ),
      JadwalFase.selesai => (
        'Selesai',
        const Color(0xFFE2E8F0),
        AppColors.textSecondary,
      ),
    };

    final matematika = jadwal.mapel.toLowerCase().contains('matematika');

    return Container(
      decoration: _kartu(),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
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
                    const Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${jadwal.jamMulai} - ${jadwal.jamSelesai} WIB',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
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
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.person_outline_rounded,
                                size: 15,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  jadwal.guru,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(
                                Icons.meeting_room_outlined,
                                size: 15,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Ruang ${jadwal.ruangan}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
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
                        color: AppColors.infoLight,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        matematika
                            ? Icons.calculate_outlined
                            : Icons.auto_stories_outlined,
                        size: 25,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            color: const Color(0xFFEFF4FD),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.circle, size: 9, color: AppColors.success),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Toleransi s/d ${jadwal.batasToleransi} WIB',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
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
    if (jadwal.sudahAbsen) {
      final s = (jadwal.statusAbsen ?? '').trim().toLowerCase();
      final label = s.isEmpty
          ? 'Tercatat'
          : '${s[0].toUpperCase()}${s.substring(1)}';
      final ok = s == 'hadir';
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: ok ? AppColors.successLight : AppColors.warningLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              ok ? Icons.check_circle_rounded : Icons.info_outline_rounded,
              size: 15,
              color: ok ? AppColors.success : AppColors.warning,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: ok ? AppColors.success : AppColors.warning,
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }

    return Text(
      fase == JadwalFase.akan ? 'Belum dimulai' : 'Tidak tercatat',
      style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
    );
  }
}

class _TugasCard extends StatelessWidget {
  final DeadlineTugas tugas;
  final VoidCallback onTap;
  const _TugasCard({required this.tugas, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final merah = tugas.sisaMenit < 6 * 60;
    final chipBg = merah ? AppColors.error : const Color(0xFFF59E0B);
    final persen = (tugas.progress * 100).round();
    final matematika = tugas.mapel.toLowerCase().contains('matematika');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _kartu(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
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
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: matematika
                      ? const Color(0xFFE0E7FF)
                      : AppColors.warningLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: matematika
                    ? const Center(
                        child: Text(
                          'Σ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.edit_note_rounded,
                        size: 22,
                        color: AppColors.warning,
                      ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            tugas.judul,
            style: const TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          if (tugas.totalSiswa > 0) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pengumpulan Kelas: ${tugas.sudahKumpul}/${tugas.totalSiswa} Siswa',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '$persen%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
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
                backgroundColor: const Color(0xFFE2E8F0),
                color: AppColors.primary,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (tugas.adaLampiran)
                const Row(
                  children: [
                    Icon(
                      Icons.attach_file_rounded,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Ada File Lampiran',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EEF9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tugas.jenisLabel,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              merah
                  ? ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Kerjakan',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, size: 15),
                        ],
                      ),
                    )
                  : TextButton(
                      onPressed: onTap,
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFE0E7FF),
                        foregroundColor: AppColors.primaryDark,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Rincian',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: _kartu(),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E7FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.play_lesson_outlined,
                size: 27,
                color: AppColors.primaryDark,
              ),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: AppColors.infoLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            materi.ekstensi,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                      Expanded(
                        child: Text(
                          materi.mapel,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    materi.judul,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Diunggah oleh ${materi.guru}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E7FF),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: AppColors.primaryDark,
              ),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 52,
              color: Color(0xFF94A3B8),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

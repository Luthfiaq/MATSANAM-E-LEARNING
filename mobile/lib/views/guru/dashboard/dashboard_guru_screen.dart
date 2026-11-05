import 'package:flutter/material.dart';

class DashboardGuruScreen extends StatelessWidget {
  const DashboardGuruScreen({super.key});

  static const Color primary = Color(0xFF2563EB);
  static const Color green = Color(0xFF059669);

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                const Icon(Icons.circle, color: green, size: 7),
                const SizedBox(width: 6),
                Text(
                  'GURU AKTIF',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    letterSpacing: 0.7,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () =>
                _showMessage(context, 'Belum ada notifikasi baru'),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/pengaturan'),
            icon: const Icon(Icons.person_outline_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _welcomeBanner(),
              const SizedBox(height: 16),
              _statistics(context),
              const SizedBox(height: 24),
              _sectionTitle(context, 'MENU UTAMA', trailing: 'Akses Cepat'),
              const SizedBox(height: 12),
              _menuGrid(context),
              const SizedBox(height: 24),
              _sectionTitle(
                context,
                'AKTIVITAS TERBARU & PERHATIAN',
                icon: Icons.notifications_active_outlined,
              ),
              const SizedBox(height: 12),
              _taskActivity(context),
              const SizedBox(height: 12),
              _attendanceActivity(context),
              const SizedBox(height: 12),
              _materialActivity(context),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _bottomNavigation(context),
    );
  }

  Widget _welcomeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _BannerTag(),
              Icon(Icons.school_outlined, color: Colors.white70, size: 23),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Selamat Pagi, Imam ðŸ‘‹',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.assignment_outlined,
                color: Colors.white70,
                size: 14,
              ),
              SizedBox(width: 6),
              Text(
                '12 tugas menunggu dinilai',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statistics(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _statCard(context, 'AKTIF', '3', 'Kelas')),
        const SizedBox(width: 10),
        Expanded(child: _statCard(context, 'TOTAL', '92', 'Siswa')),
        const SizedBox(width: 10),
        Expanded(child: _statCard(context, 'KEHADIRAN', '80', 'Siswa')),
      ],
    );
  }

  Widget _statCard(
    BuildContext context,
    String title,
    String value,
    String subtitle,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(
    BuildContext context,
    String title, {
    String? trailing,
    IconData? icon,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 6),
                Icon(icon, color: colors.onSurfaceVariant, size: 15),
              ],
            ],
          ),
        ),
        if (trailing != null)
          Text(
            trailing,
            style: TextStyle(
              color: colors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }

  Widget _menuGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _menuCard(
                context,
                Icons.menu_book_outlined,
                'Materi',
                'Mata Pelajaran & Kelas',
                primary,
                const Color(0xFFEFF6FF),
                onTap: () =>
                    Navigator.pushReplacementNamed(context, '/materi'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _menuCard(
                context,
                Icons.assignment_outlined,
                'Tugas',
                'Penugasan & Evaluasi',
                const Color(0xFF2563EB),
                const Color(0xFFEFF6FF),
                badge: '12',
                onTap: () => Navigator.pushNamed(context, '/tugas'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _menuCard(
                context,
                Icons.fact_check_outlined,
                'Absensi',
                'Presensi & QR Code',
                green,
                const Color(0xFFECFDF5),
                onTap: () => _showMessage(
                  context,
                  'Halaman Absensi sedang disiapkan',
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _menuCard(
                context,
                Icons.bar_chart_rounded,
                'Nilai',
                'Input & Rekap Siswa',
                const Color(0xFF9333EA),
                const Color(0xFFFAF5FF),
                onTap: () => _showMessage(
                  context,
                  'Halaman Nilai sedang disiapkan',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _menuCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    Color light, {
    String? badge,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 126,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: light,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: colors.tertiaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        color: colors.onTertiaryContainer,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _taskActivity(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return _activityCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _activityIcon(
                Icons.assignment_turned_in_outlined,
                const Color(0xFFEFF6FF),
                primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tugas Mandiri 04 (SPLDV)',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Matematika â€¢ Kelas 9A',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colors.tertiaryContainer,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  '12 Perlu Nilai',
                  style: TextStyle(
                    color: colors.onTertiaryContainer,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pengumpulan Siswa',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              Text(
                '28/32 Siswa (87%)',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            child: LinearProgressIndicator(
              value: 0.87,
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 12),
          Divider(color: colors.outlineVariant),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _showMessage(
                context,
                'Halaman Penilaian sedang disiapkan',
              ),
              child: const Text('Buka Penilaian'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _attendanceActivity(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return _activityCard(
      context,
      child: Column(
        children: [
          Row(
            children: [
              _activityIcon(
                Icons.qr_code_scanner_rounded,
                const Color(0xFFECFDF5),
                green,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Absensi Kelas 9A Hari Ini',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Selesai di-generate QR',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: green,
                      ),
                    ),
                  ],
                ),
              ),
              _statusChip(context, 'Aktif'),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _attendanceNumber('30 Hadir', green),
                _attendanceNumber('2 Sakit', const Color(0xFFD97706)),
                _attendanceNumber('0 Alpa', colors.onSurfaceVariant),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _materialActivity(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return _activityCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _activityIcon(
                Icons.upload_file_rounded,
                colors.primaryContainer,
                colors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MATERI BARU DITAMBAHKAN',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Trigonometri Dasar',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Kelas 9B â€¢ Matematika Peminatan',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '3 Berkas',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _fileChip(
                context,
                Icons.picture_as_pdf_rounded,
                'Modul_01.pdf',
                const Color(0xFFDC2626),
              ),
              _fileChip(
                context,
                Icons.slideshow_rounded,
                'Slide.pptx',
                const Color(0xFFC2410C),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _activityCard(
    BuildContext context, {
    required Widget child,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: child,
    );
  }

  Widget _activityIcon(
    IconData icon,
    Color background,
    Color foreground,
  ) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: foreground, size: 21),
    );
  }

  Widget _statusChip(BuildContext context, String label) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors.onSecondaryContainer,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _attendanceNumber(String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, color: color, size: 8),
        const SizedBox(width: 5),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _fileChip(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomNavigation(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 11,
      unselectedFontSize: 11,
      onTap: (index) {
  if (index == 1) {
    Navigator.pushReplacementNamed(context, '/materi');
  } else if (index == 2) {
    Navigator.pushNamed(context, '/tugas');
  } else if (index == 4) {
    Navigator.pushNamed(context, '/pengaturan');
  } else if (index == 3) {
    _showMessage(context, 'Halaman Absensi sedang disiapkan');
  }
},
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.grid_view_rounded),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book_rounded),
          label: 'Materi',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_outlined),
          label: 'Tugas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.fact_check_outlined),
          label: 'Absensi',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          label: 'Profil',
        ),
      ],
    );
  }
}

class _BannerTag extends StatelessWidget {
  const _BannerTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(Icons.circle, color: Color(0xFF10B981), size: 8),
          SizedBox(width: 6),
          Text(
            'Tahun Ajaran 2026/2027',
            style: TextStyle(color: Colors.white, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
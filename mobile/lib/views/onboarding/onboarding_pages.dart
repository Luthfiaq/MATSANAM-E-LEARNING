import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../utils/constants.dart';
import '../../widgets/common/school_logo.dart';

/// ---------- Halaman 1: Akses Materi & Modul Belajar Digital ----------
class OnboardingPage1 extends StatelessWidget {
  const OnboardingPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return _PageScroll(
      children: [
        SizedBox(
          height: 300,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Kartu utama
              Positioned(
                left: 8,
                right: 8,
                top: 56,
                child: _FloatCard(
                  radius: 22,
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const _MiniDot(color: AppColors.success),
                          const SizedBox(width: 6),
                          const Expanded(
                            child: Text(
                              'Kelas Digital 7-A',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.successLight,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.wifi_rounded,
                                  size: 14,
                                  color: AppColors.success,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Tersambung',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: const Icon(
                                Icons.menu_book_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Modul IPA Terpadu',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Bab 3: Klasifikasi Makhluk Hidup',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.cloud_download_outlined,
                              size: 20,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: const LinearProgressIndicator(
                                value: 0.75,
                                minHeight: 7,
                                backgroundColor: Color(0xFFDBE4F3),
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            '75%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              // Kartu logo (kiri atas)
              Positioned(
                left: 0,
                top: 0,
                child: Transform.rotate(
                  angle: -0.05,
                  child: _FloatCard(
                    radius: 16,
                    padding: const EdgeInsets.fromLTRB(8, 8, 14, 8),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SchoolLogo(size: 34),
                        SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'MTsN 6',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Hebat Bermartabat',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Chip sigma (kanan atas)
              Positioned(
                right: 0,
                top: 28,
                child: Transform.rotate(
                  angle: 0.12,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.infoLight,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Σ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
              // Chip mikroskop (kiri bawah)
              Positioned(
                left: 0,
                top: 170,
                child: Transform.rotate(
                  angle: -0.1,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE4D6),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(
                      Icons.biotech_rounded,
                      size: 21,
                      color: AppColors.accentOrange,
                    ),
                  ),
                ),
              ),
              // Kartu video (kanan bawah)
              Positioned(
                right: 6,
                top: 196,
                child: _FloatCard(
                  radius: 16,
                  padding: const EdgeInsets.fromLTRB(10, 10, 16, 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          color: AppColors.secondaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          size: 22,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Video Edukasi',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Tersedia Offline',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Pill bawah
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Center(
                  child: _Pill(
                    icon: Icons.auto_stories_rounded,
                    text: 'E-LEARNING TERPADU',
                    bg: Color(0xFFDBEAFE),
                    fg: AppColors.primaryDark,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const _Title('Akses Materi &\nModul Belajar Digital'),
        const SizedBox(height: 10),
        const _Desc(
          'Pelajari materi pelajaran, tonton video edukasi, dan unduh lembar kerja yang dibagikan bapak/ibu guru langsung dari ponsel Anda.',
        ),
        const SizedBox(height: 20),
        const Row(
          children: [
            Expanded(
              child: _FeatureTile(
                icon: Icons.download_for_offline_outlined,
                label: 'Bisa Offline',
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _FeatureTile(
                icon: Icons.play_circle_outline_rounded,
                label: 'Tatap Maya',
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _FeatureTile(
                icon: Icons.assignment_outlined,
                label: 'Modul Resmi',
                color: AppColors.accentOrange,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// ---------- Halaman 2: Presensi Mandiri & Kelola Izin Otomatis ----------
class OnboardingPage2 extends StatelessWidget {
  const OnboardingPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return _PageScroll(
      children: [
        Container(
          height: 330,
          padding: const EdgeInsets.fromLTRB(16, 22, 16, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Color(0xFFE8EEFC), Color(0xFFF1F5FD), Color(0xFFE4F6EE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: AppColors.border),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: _FloatCard(
                  radius: 20,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFF273244),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned.fill(
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: CustomPaint(
                                    painter: _DashedRectPainter(
                                      color: Colors.white54,
                                    ),
                                  ),
                                ),
                              ),
                              const _QrArt(size: 104),
                              Positioned(
                                bottom: 22,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.qr_code_scanner_rounded,
                                        size: 14,
                                        color: AppColors.success,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        'Kelas 8-B • Presensi',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF3FB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 46),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tercatat Hadir',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '06:42 WIB • Gerbang',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.successLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '100%',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.success,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Badge validasi
              Positioned(
                right: -4,
                top: -12,
                child: _FloatCard(
                  radius: 14,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        size: 16,
                        color: Color(0xFFF59E0B),
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Validasi MTsN 6',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Centang hadir
              Positioned(
                left: 20,
                bottom: 27,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
              // Kartu izin dokter
              Positioned(
                left: -12,
                bottom: 4,
                child: _FloatCard(
                  radius: 14,
                  padding: const EdgeInsets.fromLTRB(10, 9, 16, 9),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.infoLight,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Icon(
                          Icons.medical_services_outlined,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 9),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Izin Dokter',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Tersambung TU',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
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
        const SizedBox(height: 18),
        const Center(
          child: _Pill(
            icon: Icons.how_to_reg_outlined,
            text: 'Presensi & Kehadiran Cepat',
            bg: Color(0xFFEAF1FF),
            fg: AppColors.primaryDark,
            small: true,
          ),
        ),
        const SizedBox(height: 14),
        const _Title('Presensi Mandiri &\nKelola Izin Otomatis'),
        const SizedBox(height: 10),
        const _Desc(
          'Absensi harian cukup sekali pindai QR Code di kelas dan ajukan izin sakit langsung lampirkan surat foto dokter tanpa ribet membawa berkas fisik.',
        ),
        const SizedBox(height: 16),
        const Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            _SmallChip(
              icon: Icons.qr_code_scanner_rounded,
              text: 'Scan 1 Detik',
              color: AppColors.success,
            ),
            _SmallChip(
              icon: Icons.upload_file_rounded,
              text: 'Upload Resep/Surat',
              color: AppColors.primary,
            ),
            _SmallChip(
              icon: Icons.notifications_active_outlined,
              text: 'Notif Wali Murid',
              color: AppColors.success,
            ),
          ],
        ),
      ],
    );
  }
}

/// ---------- Halaman 3: Pantau Tugas & Nilai Rapor Terpadu ----------
class OnboardingPage3 extends StatelessWidget {
  const OnboardingPage3({super.key});

  @override
  Widget build(BuildContext context) {
    return _PageScroll(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
            gradient: const LinearGradient(
              colors: [Color(0xFFF3F6FD), Color(0xFFEAF0FC)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      size: 18,
                      color: AppColors.success,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'MADRASAH HEBAT BERMARTABAT',
                      style: TextStyle(
                        fontSize: 11.5,
                        letterSpacing: 0.3,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF065F46),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const SchoolLogoCard(size: 96),
              const SizedBox(height: 10),
              const Text(
                'MTsN 6 NGANJUK',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Mandiri Berprestasi, Menuju Generasi Qur\'ani &\nBerakhlak Mulia',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Expanded(
                    child: _BadgeCard(
                      icon: Icons.shield_rounded,
                      text: 'Resmi Kemenag RI',
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _BadgeCard(
                      icon: Icons.star_rounded,
                      text: 'Akreditasi A Unggul',
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Center(
          child: _Pill(
            icon: Icons.auto_awesome_rounded,
            text: 'Transparansi Akademik',
            bg: Color(0xFFEAF1FF),
            fg: AppColors.primaryDark,
            small: true,
          ),
        ),
        const SizedBox(height: 14),
        const _Title('Pantau Tugas & Nilai\nRapor Terpadu'),
        const SizedBox(height: 10),
        const _Desc(
          'Kumpulkan tugas kelas tepat waktu, pantau umpan balik koreksi guru secara real-time, dan cek buku rapor semester Anda kapan saja secara transparan.',
        ),
      ],
    );
  }
}

/* ===================== Widget bantu ===================== */

class _PageScroll extends StatelessWidget {
  final List<Widget> children;
  const _PageScroll({required this.children});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
      child: Column(children: children),
    );
  }
}

class _Title extends StatelessWidget {
  final String text;
  const _Title(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    textAlign: TextAlign.center,
    style: const TextStyle(
      fontSize: 27,
      height: 1.2,
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
    ),
  );
}

class _Desc extends StatelessWidget {
  final String text;
  const _Desc(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    textAlign: TextAlign.center,
    style: const TextStyle(
      fontSize: 14.5,
      height: 1.5,
      color: AppColors.textSecondary,
    ),
  );
}

class _FloatCard extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsets padding;
  const _FloatCard({
    required this.child,
    required this.radius,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _MiniDot extends StatelessWidget {
  final Color color;
  const _MiniDot({required this.color});

  @override
  Widget build(BuildContext context) => Container(
    width: 7,
    height: 7,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color bg;
  final Color fg;
  final double letterSpacing;
  final bool small;
  const _Pill({
    required this.icon,
    required this.text,
    required this.bg,
    required this.fg,
    this.letterSpacing = 0,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: small ? 6 : 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: fg),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: small ? 12 : 11.5,
              letterSpacing: letterSpacing,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _FeatureTile({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _SmallChip({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF0FB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _BadgeCard({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ilustrasi QR sederhana (blok biru/hijau di atas kartu putih).
class _QrArt extends StatelessWidget {
  final double size;
  const _QrArt({required this.size});

  @override
  Widget build(BuildContext context) {
    Widget finder(double w, double h) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary, width: 4),
        borderRadius: BorderRadius.circular(2),
        color: Colors.white,
      ),
    );

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Stack(
        children: [
          Positioned(left: 0, top: 0, child: finder(34, 44)),
          Positioned(right: 0, top: 0, child: finder(34, 34)),
          Positioned(
            left: 40,
            top: 0,
            child: Container(width: 14, height: 18, color: AppColors.primary),
          ),
          Positioned(
            left: 40,
            top: 24,
            child: Container(width: 14, height: 14, color: AppColors.success),
          ),
          Positioned(
            left: 0,
            top: 50,
            child: Container(
              width: 16,
              height: 16,
              color: const Color(0xFF5B8DEF),
            ),
          ),
          Positioned(
            left: 20,
            top: 50,
            child: Container(width: 14, height: 16, color: AppColors.primary),
          ),
          Positioned(
            right: 0,
            top: 40,
            child: Container(width: 14, height: 14, color: AppColors.success),
          ),
          Positioned(left: 38, bottom: 0, child: finder(36, 40)),
          Positioned(
            left: 0,
            bottom: 0,
            child: Container(
              width: 32,
              height: 14,
              color: const Color(0xFF5B8DEF),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  final Color color;
  _DashedRectPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    const dash = 7.0;
    const gap = 5.0;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(10),
    );
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      double d = 0;
      while (d < metric.length) {
        canvas.drawPath(
          metric.extractPath(d, math.min(d + dash, metric.length)),
          paint,
        );
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRectPainter old) => old.color != color;
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/api_config.dart';
import '../../utils/constants.dart';
import '../../utils/session.dart';
import '../../widgets/common/guru_bottom_navigation.dart';
import '../../widgets/common/notification_bell_button.dart';
import '../auth/login_screen.dart';
import 'notifikasi/guru_notifikasi_screen.dart';

class DashboardGuruScreen extends StatefulWidget {
  const DashboardGuruScreen({super.key});

  @override
  State<DashboardGuruScreen> createState() => _DashboardGuruScreenState();
}

class _DashboardGuruScreenState extends State<DashboardGuruScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _dashboardData = {};

  Color get _surface => Theme.of(context).colorScheme.surface;
  Color get _border => Theme.of(context).colorScheme.outlineVariant;
  Color get _textPrimary => Theme.of(context).colorScheme.onSurface;
  Color get _textSecondary => Theme.of(context).colorScheme.onSurfaceVariant;
  Color get _primary => Theme.of(context).colorScheme.primary;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  String get _teacherFirstName {
    final fullName = (_dashboardData['nama_guru'] ?? 'Guru').toString().trim();
    if (fullName.isEmpty) return 'Guru';
    return fullName.split(RegExp(r'\s+')).first;
  }

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;

      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) {
        await Session.clearLogin();
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
          (_) => false,
        );
        return;
      }

      final response = await http
          .get(
            Uri.parse(ApiConfig.guruDashboard),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(ApiConfig.timeout);

      if (!mounted) return;
      if (response.statusCode == 401) {
        await Session.clearLogin();
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
          (_) => false,
        );
        return;
      }

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      // Tanggapi hanya JSON valid; jangan menampilkan payload contoh ketika
      // API tidak mengirim ringkasan dashboard yang diharapkan.
      final decoded = json.decode(response.body);
      if (decoded is! Map ||
          decoded['success'] != true ||
          decoded['data'] is! Map) {
        throw const FormatException('Format respons dashboard tidak sesuai.');
      }

      final dashboard = Map<String, dynamic>.from(decoded['data'] as Map);
      if (!mounted) return;
      setState(() {
        _dashboardData = dashboard;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      debugPrint('Dashboard Guru gagal dimuat: $error');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Dashboard belum dapat dimuat. Periksa koneksi backend.',
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Coba Lagi',
            textColor: Colors.white,
            onPressed: _loadDashboard,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: TextStyle(
                color: _textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'GURU AKTIF',
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          NotificationBellButton(
            onPressed: () async {
              await Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => const GuruNotifikasiScreen(),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.person_outline,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboard,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeCard(),
                    const SizedBox(height: 16),
                    _buildStatsRow(),
                    const SizedBox(height: 24),
                    _buildMenuSection(),
                    const SizedBox(height: 24),
                    _buildRecentActivity(),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const GuruBottomNavigation(currentIndex: 0),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _dashboardData['tahun_ajaran'] ?? 'Periode akademik',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.school_outlined, color: Colors.white, size: 22),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '$_greeting, $_teacherFirstName 👋',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.assignment_outlined,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                '${_dashboardData['tugas_menunggu'] ?? 0} tugas menunggu dinilai',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'AKTIF',
            '${_dashboardData['total_kelas'] ?? '—'}',
            'Kelas',
            _primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'TOTAL',
            '${_dashboardData['total_siswa'] ?? '—'}',
            'Siswa',
            Theme.of(context).colorScheme.tertiary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'KEHADIRAN',
            '${_dashboardData['kehadiran'] ?? '—'}',
            'Siswa',
            const Color(0xFF059669),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    String subtitle,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: _textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(subtitle, style: TextStyle(color: _textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'MENU UTAMA',
              style: TextStyle(
                color: _textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Akses Cepat',
              style: TextStyle(
                color: _primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildMenuItem(
                'Materi',
                'Materi & Modul Ajar',
                Icons.book_outlined,
                _primary,
                route: '/materi',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMenuItem(
                'Tugas',
                'Penugasan & Evaluasi',
                Icons.assignment_outlined,
                _primary,
                badge: '${_dashboardData['tugas_menunggu'] ?? 0}',
                route: '/guru/tugas/pilih-mapel',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMenuItem(
                'Absensi',
                'Presensi & QR Code',
                Icons.qr_code_scanner,
                const Color(0xFF059669),
                route: '/guru/absensi/pilih-mapel',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMenuItem(
                'Nilai',
                'Input & Rekap Siswa',
                Icons.bar_chart_rounded,
                const Color(0xFF9333EA),
                route: '/guru/nilai',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    String title,
    String subtitle,
    IconData icon,
    Color color, {
    String? badge,
    String? route,
  }) {
    return GestureDetector(
      onTap: () {
        if (route != null) {
          Navigator.pushNamed(context, route);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                if (badge != null) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF78350F)
                          : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFFFDE68A)
                            : const Color(0xFFD97706),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: _textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: _textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'AKTIVITAS TERBARU & PERHATIAN',
              style: TextStyle(
                color: _textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            IconButton(
              tooltip: 'Buka notifikasi',
              onPressed: () async {
                await Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => const GuruNotifikasiScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.notifications_outlined, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
          ),
          child: Column(
            children: [
              Icon(Icons.history_rounded, size: 28, color: _textSecondary),
              const SizedBox(height: 8),
              Text(
                'Belum ada ringkasan aktivitas',
                style: TextStyle(
                  color: _textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Aktivitas terbaru belum disediakan oleh API dashboard.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

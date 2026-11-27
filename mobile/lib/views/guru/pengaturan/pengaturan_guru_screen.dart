import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/auth_service.dart';
import '../../../services/notification_service.dart';
import '../../../utils/session.dart';
import '../../auth/login_screen.dart';
import '../../auth/change_password_screen.dart';
import '../../../main.dart';
import '../../../widgets/common/guru_bottom_navigation.dart';
import '../../../widgets/common/font_family_setting.dart';
import '../../../widgets/common/notification_bell_button.dart';
import '../notifikasi/guru_notifikasi_screen.dart';

class PengaturanGuruScreen extends StatefulWidget {
  const PengaturanGuruScreen({super.key});

  @override
  State<PengaturanGuruScreen> createState() => _PengaturanGuruScreenState();
}

class _PengaturanGuruScreenState extends State<PengaturanGuruScreen> {
  Color get primary => Theme.of(context).colorScheme.primary;
  static const Color green = Color(0xFF059669);

  String selectedTheme = 'Terang';

  bool tugasBaru = true;
  bool pengajuanIzin = true;

  String teacherName = 'Memuat profil...';
  String teacherNip = 'NIP: -';
  String teacherEmail = '-';
  bool _profileLoading = true;

  @override
  void initState() {
    super.initState();
    _restoreThemePreference();
    _loadTeacherProfile();
  }

  Future<void> _restoreThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString('siswa_theme') ?? 'Terang';
      if (!mounted) return;
      setState(() {
        if (['Terang', 'Gelap', 'Sistem'].contains(savedTheme)) {
          selectedTheme = savedTheme;
        }
      });
    } catch (_) {
      // Keep Light Mode as the safe default if local preferences are unavailable.
    }
  }

  Future<void> _loadTeacherProfile() async {
    try {
      final cachedProfile = await Session.getProfile();
      final cachedUser = await Session.getUser();
      Map<String, dynamic>? fresh;
      try {
        fresh = await AuthService().getCurrentUser();
      } catch (_) {
        // Cached user/profile remains useful when the API is temporarily offline.
      }
      Map<String, dynamic> remotePreferences = {};
      try {
        remotePreferences = await NotificationService().fetchPreferences();
      } catch (_) {
        // Keep defaults if the notification API is temporarily unreachable.
      }
      final freshProfile = fresh?['profile'];
      final freshUser = fresh?['user'];
      final profile = freshProfile is Map
          ? Map<String, dynamic>.from(freshProfile)
          : (cachedProfile ?? <String, dynamic>{});
      final user = freshUser is Map
          ? Map<String, dynamic>.from(freshUser)
          : (cachedUser ?? <String, dynamic>{});
      if (!mounted) return;
      setState(() {
        teacherName = (profile['nama_lengkap'] ?? user['name'] ?? 'Nama Guru')
            .toString();
        teacherNip = 'NIP: ${(profile['nip'] ?? '-').toString()}';
        teacherEmail = (user['email'] ?? '-').toString();
        tugasBaru = remotePreferences['pengumpulan_tugas'] as bool? ?? true;
        pengajuanIzin = remotePreferences['pengajuan_izin'] as bool? ?? true;
        _profileLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _profileLoading = false);
    }
  }

  String get teacherInitials {
    if (_profileLoading) return 'GU';
    const excluded = {
      'dra.',
      'dr.',
      'h.',
      'hj.',
      'prof.',
      's.pd.',
      'm.pd.',
      'm.e.',
      's.kom.',
      'm.si.',
      's.pd',
      'm.pd',
      'm.e',
      's.kom',
      'm.si',
    };
    final parts = teacherName
        .split(RegExp(r'[\s,]+'))
        .map((part) => part.trim())
        .where(
          (part) => part.isNotEmpty && !excluded.contains(part.toLowerCase()),
        )
        .toList();
    if (parts.isEmpty) return 'GU';
    final first = parts.first.substring(0, 1);
    final second = parts.length > 1 ? parts[1].substring(0, 1) : '';
    return '$first$second'.toUpperCase();
  }

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  Color get background =>
      isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

  Color get cardColor => isDark ? const Color(0xFF1E293B) : Colors.white;

  Color get textDark =>
      isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B);

  Color get textMuted =>
      isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B);

  Color get borderColor =>
      isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

  Color get softBlue =>
      isDark ? const Color(0xFF1E3A5F) : const Color(0xFFF0F5FF);

  Color get softIcon =>
      isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

  Future<void> _setNotificationPreference(String key, bool value) async {
    try {
      await NotificationService().updatePreferences({key: value});
      if (!mounted) return;
      setState(() {
        switch (key) {
          case 'pengumpulan_tugas':
            tugasBaru = value;
            break;
          case 'pengajuan_izin':
            pengajuanIzin = value;
            break;
        }
      });
    } catch (error) {
      _showMessage('Gagal menyimpan preferensi: $error');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  // MENGUBAH TEMA APLIKASI
  Future<void> _changeTheme(String theme) async {
    ThemeMode mode;

    switch (theme) {
      case 'Gelap':
        mode = ThemeMode.dark;
        break;
      case 'Sistem':
        mode = ThemeMode.system;
        break;
      default:
        mode = ThemeMode.light;
    }

    setState(() {
      selectedTheme = theme;
    });

    await MatsanamApp.ubahTema(context, mode);
    if (!mounted) return;
    _showMessage('Tema $theme berhasil diterapkan.');
  }

  Future<void> _changeFont(String font) async {
    await MatsanamApp.ubahFont(context, font);
    if (!mounted) return;
    _showMessage(
      font == MatsanamApp.defaultFontSelection
          ? 'Font default sesuai peran berhasil diterapkan.'
          : 'Font $font berhasil diterapkan untuk Guru dan Siswa.',
    );
  }

  // Ganti kata sandi memakai form dan endpoint autentikasi yang sama
  // dengan alur siswa; tidak menampilkan notifikasi sukses palsu.
  void _showChangePasswordDialog() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ChangePasswordScreen()),
    );
  }

  // DIALOG EMAIL
  void _showEmailDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cardColor,
          title: Text('Kontak & Email', style: TextStyle(color: textDark)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Email akun guru',
                style: TextStyle(color: textMuted, fontSize: 12),
              ),
              const SizedBox(height: 6),
              SelectableText(
                teacherEmail,
                style: TextStyle(color: primary, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Text(
                'Hubungi administrator sekolah jika ingin memperbarui alamat email akun.',
                style: TextStyle(fontSize: 13, color: textDark),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  // DIALOG LOGOUT
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cardColor,
          title: Text('Keluar dari Akun?', style: TextStyle(color: textDark)),
          content: Text(
            'Apakah kamu yakin ingin keluar dari akun Guru?',
            style: TextStyle(color: textMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                AuthService().logout().then((_) {
                  if (!mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                });
              },
              child: const Text('Ya, Keluar'),
            ),
          ],
        );
      },
    );
  }

  // JUDUL BAGIAN
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 9, top: 18),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.45,
          color: textMuted,
        ),
      ),
    );
  }

  // KARTU
  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }

  // PILIHAN TEMA
  Widget _themeOption({
    required IconData icon,
    required String title,
    required String value,
  }) {
    final isSelected = selectedTheme == value;

    return InkWell(
      borderRadius: BorderRadius.circular(9),
      onTap: () => _changeTheme(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected ? softBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          children: [
            Container(
              width: 29,
              height: 29,
              decoration: BoxDecoration(
                color: isSelected ? softBlue : softIcon,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 16,
                color: isSelected ? primary : textMuted,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: textDark,
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              size: 18,
              color: isSelected ? primary : textMuted,
            ),
          ],
        ),
      ),
    );
  }

  // PILIHAN AKUN
  Widget _accountOption({
    required IconData icon,
    required String title,
    required String trailing,
    required VoidCallback onTap,
    bool isEmail = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: softBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: primary, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: textDark,
                ),
              ),
            ),
            if (trailing.isNotEmpty)
              Flexible(
                child: Text(
                  trailing,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9,
                    color: isEmail ? primary : textMuted,
                    fontWeight: isEmail ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            const SizedBox(width: 5),
            Icon(Icons.chevron_right, size: 17, color: textMuted),
          ],
        ),
      ),
    );
  }

  // PENGATURAN NOTIFIKASI
  Widget _notificationOption({
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 9, height: 1.4, color: textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: green,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: isDark
                ? const Color(0xFF475569)
                : const Color(0xFFCBD5E1),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  // KARTU PROFIL GURU
  Widget _profileCard() {
    return _card(
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 49,
                height: 49,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  teacherInitials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: 13,
                  height: 13,
                  decoration: BoxDecoration(
                    color: green,
                    shape: BoxShape.circle,
                    border: Border.all(color: cardColor, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _profileLoading ? 'Memuat profil...' : teacherName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  teacherNip,
                  style: TextStyle(fontSize: 9, color: textMuted),
                ),
                const SizedBox(height: 3),
                Text(
                  'Guru • MTsN 6 Nganjuk',
                  style: TextStyle(fontSize: 9, color: textMuted),
                ),
                const SizedBox(height: 7),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF064E3B)
                        : const Color(0xFFE8F8F0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '●  STATUS: GURU AKTIF',
                    style: TextStyle(
                      color: Color(0xFF34D399),
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: textDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profil',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: textDark,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              '●  GURU AKTIF',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: green,
              ),
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
            tooltip: 'Notifikasi Guru',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: CircleAvatar(
              radius: 15,
              backgroundColor: primary,
              child: Text(
                teacherInitials,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),

      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(15, 5, 15, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _profileCard(),

              _sectionTitle('Pengaturan Tema Aplikasi'),

              _card(
                child: Column(
                  children: [
                    _themeOption(
                      icon: Icons.wb_sunny_rounded,
                      title: 'Mode Terang',
                      value: 'Terang',
                    ),
                    _themeOption(
                      icon: Icons.dark_mode_rounded,
                      title: 'Mode Gelap',
                      value: 'Gelap',
                    ),
                    _themeOption(
                      icon: Icons.settings_brightness_rounded,
                      title: 'Ikuti Sistem Operasi',
                      value: 'Sistem',
                    ),
                  ],
                ),
              ),

              _sectionTitle('Tipografi Aplikasi'),

              _card(
                child: FontFamilySetting(
                  onChanged: _changeFont,
                ),
              ),

              _sectionTitle('Keamanan & Akun'),

              _card(
                child: Column(
                  children: [
                    _accountOption(
                      icon: Icons.lock_outline_rounded,
                      title: 'Ganti Kata Sandi',
                      trailing: '',
                      onTap: _showChangePasswordDialog,
                    ),
                    Divider(height: 1, color: borderColor),
                    _accountOption(
                      icon: Icons.email_outlined,
                      title: 'Kontak & Email',
                      trailing: teacherEmail,
                      isEmail: true,
                      onTap: _showEmailDialog,
                    ),
                  ],
                ),
              ),

              _sectionTitle('Notifikasi Aktivitas'),

              _card(
                child: Column(
                  children: [
                    _notificationOption(
                      title: 'Tugas Baru Dikumpulkan Siswa',
                      description:
                          'Dapatkan pemberitahuan ketika siswa mengumpulkan tugas.',
                      value: tugasBaru,
                      onChanged: (value) => _setNotificationPreference(
                        'pengumpulan_tugas',
                        value,
                      ),
                    ),
                    Divider(height: 1, color: borderColor),
                    _notificationOption(
                      title: 'Pengajuan Izin Siswa',
                      description:
                          'Pemberitahuan saat siswa mengirim pengajuan izin atau sakit.',
                      value: pengajuanIzin,
                      onChanged: (value) =>
                          _setNotificationPreference('pengajuan_izin', value),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 43,
                child: ElevatedButton.icon(
                  onPressed: _showLogoutDialog,
                  icon: const Icon(Icons.logout_rounded, size: 17),
                  label: const Text(
                    'Keluar dari Akun (Logout)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 9),

              Center(
                child: Text(
                  'Versi 1.0.0 • Hak Cipta Matsanama E-Learning',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 8, color: textMuted),
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: const GuruBottomNavigation(currentIndex: 4),
    );
  }
}


import 'package:flutter/material.dart';
import '../../../main.dart';

class PengaturanGuruScreen extends StatefulWidget {
  const PengaturanGuruScreen({super.key});

  @override
  State<PengaturanGuruScreen> createState() =>
      _PengaturanGuruScreenState();
}

class _PengaturanGuruScreenState extends State<PengaturanGuruScreen> {
  static const Color primary = Color(0xFF2563EB);
  static const Color green = Color(0xFF087F5B);

  String selectedTheme = 'Terang';

  bool tugasBaru = true;
  bool nilaiDiperbarui = true;
  bool pengingatBelajar = true;

  final String teacherName = 'Imam Khalid, S.Pd';
  final String teacherNip = 'NIP: 198604012019031001';
  final String teacherEmail = 'imamkhalid@guru.sch.id';

  bool get isDark =>
      Theme.of(context).brightness == Brightness.dark;

  Color get background =>
      isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

  Color get cardColor =>
      isDark ? const Color(0xFF1E293B) : Colors.white;

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Menyesuaikan tampilan dengan tema aplikasi.
    if (Theme.of(context).brightness == Brightness.dark &&
        selectedTheme == 'Terang') {
      selectedTheme = 'Gelap';
    } else if (Theme.of(context).brightness == Brightness.light &&
        selectedTheme == 'Gelap') {
      selectedTheme = 'Terang';
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // MENGUBAH TEMA APLIKASI
  void _changeTheme(String theme) {
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

    MatsanamApp.ubahTema(context, mode);

    _showMessage('Tema $theme berhasil diterapkan.');
  }

  // DIALOG GANTI PASSWORD
  void _showChangePasswordDialog() {
    final oldController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cardColor,
          title: Text(
            'Ganti Kata Sandi',
            style: TextStyle(
              color: textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: oldController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Kata sandi lama',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Kata sandi baru',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Konfirmasi kata sandi',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (oldController.text.isEmpty ||
                    newController.text.isEmpty ||
                    confirmController.text.isEmpty) {
                  _showMessage('Semua kolom harus diisi.');
                  return;
                }

                if (newController.text.length < 6) {
                  _showMessage(
                    'Kata sandi baru minimal 6 karakter.',
                  );
                  return;
                }

                if (newController.text != confirmController.text) {
                  _showMessage(
                    'Konfirmasi kata sandi tidak cocok.',
                  );
                  return;
                }

                Navigator.pop(dialogContext);

                _showMessage(
                  'Permintaan ganti kata sandi berhasil disiapkan.',
                );
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    ).then((_) {
      oldController.dispose();
      newController.dispose();
      confirmController.dispose();
    });
  }

  // DIALOG EMAIL
  void _showEmailDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cardColor,
          title: Text(
            'Kontak & Email',
            style: TextStyle(color: textDark),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Email akun guru',
                style: TextStyle(
                  color: textMuted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              SelectableText(
                teacherEmail,
                style: const TextStyle(
                  color: primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Hubungi administrator sekolah jika ingin memperbarui alamat email akun.',
                style: TextStyle(
                  fontSize: 13,
                  color: textDark,
                ),
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
          title: Text(
            'Keluar dari Akun?',
            style: TextStyle(color: textDark),
          ),
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
                _showMessage(
                  'Fitur logout perlu dihubungkan dengan sistem autentikasi.',
                );
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
      padding: const EdgeInsets.only(
        left: 2,
        bottom: 9,
        top: 18,
      ),
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
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 11,
        ),
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
                  fontWeight: isSelected
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: textDark,
                ),
              ),
            ),
            Icon(
              isSelected
                  ? Icons.check_circle
                  : Icons.circle_outlined,
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
              child: Icon(
                icon,
                color: primary,
                size: 16,
              ),
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
                    fontWeight: isEmail
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            const SizedBox(width: 5),
            Icon(
              Icons.chevron_right,
              size: 17,
              color: textMuted,
            ),
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
                  style: TextStyle(
                    fontSize: 9,
                    height: 1.4,
                    color: textMuted,
                  ),
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
            materialTapTargetSize:
                MaterialTapTargetSize.shrinkWrap,
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
                child: const Text(
                  'IK',
                  style: TextStyle(
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
                    border: Border.all(
                      color: cardColor,
                      width: 2,
                    ),
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
                  teacherName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  teacherNip,
                  style: TextStyle(
                    fontSize: 9,
                    color: textMuted,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Guru • MTs Matsanama',
                  style: TextStyle(
                    fontSize: 9,
                    color: textMuted,
                  ),
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

  // NAVBAR BAWAH
  Widget _bottomNavigation() {
    const items = [
      (Icons.grid_view_rounded, 'Home'),
      (Icons.menu_book_rounded, 'Materi'),
      (Icons.assignment_rounded, 'Tugas'),
      (Icons.fact_check_rounded, 'Absensi'),
      (Icons.person_rounded, 'Profil'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        border: Border(
          top: BorderSide(color: borderColor),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 54,
          child: Row(
            children: List.generate(items.length, (index) {
              final selected = index == 4;

              return Expanded(
                child: InkWell(
                  onTap: () {
                    if (index == 0) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/',
                        (route) => route.isFirst,
                      );
                    } else if (index == 1) {
                      Navigator.pushNamed(context, '/materi');
                    } else if (index == 4) {
                      // Sudah berada di halaman Profil.
                    } else {
                      _showMessage(
                        'Menu ${items[index].$2} belum dihubungkan.',
                      );
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        items[index].$1,
                        size: 19,
                        color: selected ? primary : textMuted,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        items[index].$2,
                        style: TextStyle(
                          fontSize: 9,
                          color: selected ? primary : textMuted,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.normal,
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
          IconButton(
            onPressed: () {
              _showMessage('Tidak ada notifikasi baru.');
            },
            icon: Icon(
              Icons.notifications_none_rounded,
              color: textDark,
              size: 21,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: CircleAvatar(
              radius: 15,
              backgroundColor: primary,
              child: const Text(
                'IK',
                style: TextStyle(
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
                      onChanged: (value) {
                        setState(() => tugasBaru = value);
                      },
                    ),
                    Divider(height: 1, color: borderColor),
                    _notificationOption(
                      title: 'Nilai Diubah / Finalisasi Selesai',
                      description:
                          'Notifikasi saat nilai diperbarui atau proses finalisasi selesai.',
                      value: nilaiDiperbarui,
                      onChanged: (value) {
                        setState(() => nilaiDiperbarui = value);
                      },
                    ),
                    Divider(height: 1, color: borderColor),
                    _notificationOption(
                      title: 'Pengingat Batas Tenggat Waktu',
                      description:
                          'Pengingat terkait tenggat waktu tugas dan aktivitas belajar.',
                      value: pengingatBelajar,
                      onChanged: (value) {
                        setState(() => pengingatBelajar = value);
                      },
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
                  icon: const Icon(
                    Icons.logout_rounded,
                    size: 17,
                  ),
                  label: const Text(
                    'Keluar dari Akun (Logout)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
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
                  style: TextStyle(
                    fontSize: 8,
                    color: textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: _bottomNavigation(),
    );
  }
}
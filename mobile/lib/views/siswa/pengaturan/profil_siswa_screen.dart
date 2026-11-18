import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../main.dart';
import '../../../services/auth_service.dart';
import '../../../services/notification_service.dart';
import '../../../widgets/common/notification_bell_button.dart';
import '../../../widgets/common/siswa_bottom_navigation.dart';
import '../../auth/change_password_screen.dart';
import '../dashboard/dashboard_siswa_page.dart';
import '../materi/siswa_materi_screen.dart';
import '../nilai/siswa_nilai_screen.dart';
import '../notifikasi/siswa_notifikasi_screen.dart';
import '../tugas/siswa_tugas_screen.dart';
import '../../../utils/session.dart';

class ProfilSiswaScreen extends StatefulWidget {
  const ProfilSiswaScreen({super.key});
  @override
  State<ProfilSiswaScreen> createState() => _ProfilSiswaScreenState();
}

class _ProfilSiswaScreenState extends State<ProfilSiswaScreen> {
  static const blue = Color(0xFF0755D9);
  Map<String, dynamic> profile = {}, user = {};
  bool loading = true,
      tugas = true,
      nilai = true,
      materi = true,
      absensi = true;
  String theme = 'Terang';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = await Session.getProfile();
    final fresh = await AuthService().getCurrentUser();
    final p = fresh?['profile'];
    final u = fresh?['user'];
    Map<String, dynamic> remotePreferences = {};
    try {
      remotePreferences = await NotificationService().fetchPreferences();
    } catch (_) {
      // Keep the last local settings available if the server cannot be reached.
    }
    if (!mounted) return;
    setState(() {
      profile = p is Map ? Map<String, dynamic>.from(p) : (cached ?? {});
      user = u is Map ? Map<String, dynamic>.from(u) : {};
      theme = prefs.getString('siswa_theme') ?? 'Terang';
      tugas =
          remotePreferences['tugas_baru'] as bool? ??
          prefs.getBool('siswa_notif_tugas') ??
          true;
      nilai =
          remotePreferences['nilai'] as bool? ??
          prefs.getBool('siswa_notif_nilai') ??
          true;
      materi =
          remotePreferences['materi_baru'] as bool? ??
          prefs.getBool('siswa_notif_materi') ??
          true;
      absensi =
          remotePreferences['absensi'] as bool? ??
          prefs.getBool('siswa_notif_absensi') ??
          true;
      loading = false;
    });
  }

  Future<void> _setPreference(String key, bool value) async {
    try {
      await NotificationService().updatePreferences({key: value});
      final localKeys = <String, String>{
        'tugas_baru': 'siswa_notif_tugas',
        'nilai': 'siswa_notif_nilai',
        'materi_baru': 'siswa_notif_materi',
        'absensi': 'siswa_notif_absensi',
      };
      final localKey = localKeys[key];
      if (localKey != null) {
        (await SharedPreferences.getInstance()).setBool(localKey, value);
      }
      if (!mounted) return;
      setState(() {
        switch (key) {
          case 'tugas_baru':
            tugas = value;
            break;
          case 'nilai':
            nilai = value;
            break;
          case 'materi_baru':
            materi = value;
            break;
          case 'absensi':
            absensi = value;
            break;
        }
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan preferensi: $error')),
        );
      }
    }
  }

  Future<void> _changeTheme(String value) async {
    setState(() => theme = value);
    await (await SharedPreferences.getInstance()).setString(
      'siswa_theme',
      value,
    );
    if (mounted) {
      MatsanamApp.ubahTema(
        context,
        value == 'Gelap'
            ? ThemeMode.dark
            : value == 'Sistem'
            ? ThemeMode.system
            : ThemeMode.light,
      );
    }
  }

  void _info(String title, Map<String, String> values) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              ...values.entries.map(
                (e) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    e.key,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  subtitle: Text(
                    e.value.isEmpty ? '-' : e.value,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text(
          'Kamu perlu masuk kembali untuk mengakses data belajar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (yes != true) return;
    await AuthService().logout();
    if (mounted)
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
  }

  void _navigateTab(int index) {
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

  void _openPassword() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ChangePasswordScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final name = (profile['nama_lengkap'] ?? user['name'] ?? 'Siswa')
        .toString();
    final nis = (profile['nis'] ?? '-').toString();
    final kelas = (profile['kelas'] ?? '-').toString();
    final initial = name.trim().isEmpty ? 'S' : name.trim()[0].toUpperCase();
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Matsanam Siswa',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            Text(
              'Profil',
              style: TextStyle(fontSize: 11, color: Color(0xFF91A2BD)),
            ),
          ],
        ),
        actions: [
          NotificationBellButton(
            onPressed: () async {
              await Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => const SiswaNotifikasiScreen(),
                ),
              );
            },
            tooltip: 'Notifikasi Siswa',
          ),
          const Padding(
            padding: EdgeInsets.only(right: 14),
            child: CircleAvatar(
              backgroundColor: blue,
              child: Icon(Icons.person_outline, color: Colors.white),
            ),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _panel(
                  Column(
                    children: [
                      Container(
                        width: 78,
                        height: 78,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: blue,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'NIS: $nis • Kelas $kelas',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'MTsN 6 Nganjuk',
                        style: TextStyle(fontSize: 11),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Wali Kelas: Data belum tersedia',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                _heading(Icons.palette_outlined, 'Tema Tampilan Aplikasi'),
                _panel(
                  Column(
                    children: [
                      for (final item in [
                        (
                          'Terang',
                          Icons.wb_sunny_outlined,
                          'Mode Terang (Light Mode)',
                        ),
                        (
                          'Gelap',
                          Icons.dark_mode_outlined,
                          'Mode Gelap (Dark Mode)',
                        ),
                        (
                          'Sistem',
                          Icons.brightness_auto_outlined,
                          'Ikuti Sistem Operasi',
                        ),
                      ])
                        RadioListTile<String>(
                          dense: true,
                          value: item.$1,
                          groupValue: theme,
                          onChanged: (v) {
                            if (v != null) _changeTheme(v);
                          },
                          title: Text(
                            item.$3,
                            style: const TextStyle(fontSize: 13),
                          ),
                          secondary: Icon(item.$2, color: blue),
                        ),
                    ],
                  ),
                ),
                _heading(Icons.verified_user_outlined, 'Keamanan & Akun'),
                _panel(
                  Column(
                    children: [
                      _action(
                        Icons.lock_reset,
                        'Ganti Kata Sandi',
                        'Perbarui kata sandi akun',
                        _openPassword,
                      ),
                      _action(
                        Icons.badge_outlined,
                        'Data Diri Siswa & NISN',
                        'Profil terdaftar di database madrasah',
                        () => _info('Data Diri Siswa', {
                          'Nama Lengkap': name,
                          'NIS': nis,
                          'NISN': (profile['nisn'] ?? '-').toString(),
                          'Kelas': kelas,
                          'Email': (user['email'] ?? '-').toString(),
                        }),
                      ),
                      _action(
                        Icons.contact_phone_outlined,
                        'Kontak Orang Tua / Wali Siswa',
                        'Nomor darurat dan verifikasi WhatsApp',
                        () => _info('Kontak Orang Tua / Wali', {
                          'Informasi':
                              'Data wali belum tersedia pada API profil.',
                        }),
                      ),
                    ],
                  ),
                ),
                _heading(
                  Icons.notifications_active_outlined,
                  'Preferensi Notifikasi',
                ),
                _panel(
                  Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Preferensi disimpan pada akun dan digunakan untuk mengatur pemberitahuan di aplikasi.',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF91A2BD),
                          ),
                        ),
                      ),
                      _switch(
                        'Notifikasi Tugas Baru',
                        'Pemberitahuan saat Guru menerbitkan tugas baru beserta deadline-nya',
                        tugas,
                        (v) {
                          _setPreference('tugas_baru', v);
                        },
                      ),
                      _switch(
                        'Notifikasi Nilai & Evaluasi Guru',
                        'Umpan balik tugas dan ujian',
                        nilai,
                        (v) {
                          _setPreference('nilai', v);
                        },
                      ),
                      _switch(
                        'Materi Baru Diterbitkan',
                        'Unggahan modul atau dokumen ajar guru',
                        materi,
                        (v) {
                          _setPreference('materi_baru', v);
                        },
                      ),
                      _switch(
                        'Status Pengajuan Izin & Sakit',
                        'Pemberitahuan saat pengajuan izin atau sakit disetujui maupun ditolak',
                        absensi,
                        (v) {
                          _setPreference('absensi', v);
                        },
                      ),
                    ],
                  ),
                ),
                _heading(Icons.info_outline, 'Info & Bantuan'),
                _panel(
                  Column(
                    children: [
                      _action(
                        Icons.verified_outlined,
                        'Versi Aplikasi Siswa',
                        'Informasi versi aplikasi',
                        () => _info('Versi Aplikasi', {
                          'Versi': 'v2.4.0',
                          'Build': '2026.1',
                        }),
                      ),
                      _action(
                        Icons.support_agent_outlined,
                        'Bantuan & Layanan Siswa Madrasah',
                        'Pusat bantuan teknis dan akademik',
                        () => _info('Bantuan', {
                          'Informasi':
                              'Hubungi admin madrasah untuk bantuan akun.',
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: _logout,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFE12626),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text('Keluar dari Akun (Logout)'),
                  ),
                ),
                const SizedBox(height: 18),
                const Center(
                  child: Text(
                    'MTsN 6 Nganjuk • MATSANAM E-Learning',
                    style: TextStyle(fontSize: 10, color: Color(0xFF91A2BD)),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: SiswaBottomNavigationBar(
        currentIndex: 4,
        onTap: _navigateTab,
      ),
    );
  }

  Widget _panel(Widget child) => Container(
    margin: const EdgeInsets.only(bottom: 4),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
    ),
    child: child,
  );
  Widget _heading(IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 9),
    child: Row(
      children: [
        Icon(icon, color: blue, size: 18),
        const SizedBox(width: 7),
        Text(
          text,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );
  Widget _action(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) => ListTile(
    dense: true,
    contentPadding: EdgeInsets.zero,
    leading: Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: blue.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Icon(icon, color: blue, size: 19),
    ),
    title: Text(
      title,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    ),
    subtitle: Text(
      subtitle,
      style: const TextStyle(fontSize: 10, color: Color(0xFF91A2BD)),
    ),
    trailing: const Icon(Icons.chevron_right, color: Color(0xFF91A2BD)),
    onTap: onTap,
  );
  Widget _switch(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> changed,
  ) => SwitchListTile(
    dense: true,
    contentPadding: EdgeInsets.zero,
    title: Text(title, style: const TextStyle(fontSize: 13)),
    subtitle: Text(
      subtitle,
      style: const TextStyle(fontSize: 10, color: Color(0xFF91A2BD)),
    ),
    value: value,
    activeColor: blue,
    onChanged: changed,
  );
}

import 'package:flutter/material.dart';

import '../../../utils/constants.dart';

class SettingsGuruScreen extends StatefulWidget {
  const SettingsGuruScreen({super.key});

  @override
  State<SettingsGuruScreen> createState() => _SettingsGuruScreenState();
}

class _SettingsGuruScreenState extends State<SettingsGuruScreen> {
  final _namaController = TextEditingController(text: 'Pak Imam Kholik');
  final _emailController = TextEditingController(
    text: 'imam.kholik@matsanam.sch.id',
  );
  final _phoneController = TextEditingController(text: '081234567890');
  final _passwordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _tugasBaru = true;
  bool _deadlineMepet = true;
  bool _absensiBaru = false;
  bool _nilaiDiumumkan = true;
  bool _pengumumanSekolah = true;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
          ),
        ),
        title: const Text(
          'Pengaturan',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSection(),
            const SizedBox(height: 16),
            _buildNotificationsSection(),
            const SizedBox(height: 16),
            _buildSecuritySection(),
            const SizedBox(height: 16),
            _buildAboutSection(),
            const SizedBox(height: 24),
            _buildLogoutButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return _buildSettingsCard(
      title: 'Profil',
      children: [
        Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _namaController.text,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Guru Matematika',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.camera_alt_rounded, size: 16),
              label: const Text('Ganti'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Data Diri',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _buildProfileField(
          'Nama Lengkap',
          _namaController,
          icon: Icons.person_rounded,
        ),
        const SizedBox(height: 10),
        _buildProfileField(
          'Email',
          _emailController,
          icon: Icons.email_rounded,
        ),
        const SizedBox(height: 10),
        _buildProfileField(
          'No. Telepon',
          _phoneController,
          icon: Icons.phone_rounded,
        ),
      ],
    );
  }

  Widget _buildNotificationsSection() {
    return _buildSettingsCard(
      title: 'Notifikasi',
      children: [
        _buildNotificationToggle(
          'Tugas Baru',
          _tugasBaru,
          onChanged: (v) => setState(() => _tugasBaru = v),
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
        _buildNotificationToggle(
          'Deadline Mepet',
          _deadlineMepet,
          onChanged: (v) => setState(() => _deadlineMepet = v),
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
        _buildNotificationToggle(
          'Absensi Baru',
          _absensiBaru,
          onChanged: (v) => setState(() => _absensiBaru = v),
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
        _buildNotificationToggle(
          'Nilai Diumumkan',
          _nilaiDiumumkan,
          onChanged: (v) => setState(() => _nilaiDiumumkan = v),
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
        _buildNotificationToggle(
          'Pengumuman Sekolah',
          _pengumumanSekolah,
          onChanged: (v) => setState(() => _pengumumanSekolah = v),
        ),
      ],
    );
  }

  Widget _buildSecuritySection() {
    return _buildSettingsCard(
      title: 'Keamanan',
      children: [
        Text(
          'Ubah Password',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        _buildPasswordField('Password Saat Ini', _passwordController),
        const SizedBox(height: 12),
        _buildPasswordField('Password Baru', _newPasswordController),
        const SizedBox(height: 12),
        _buildPasswordField(
          'Konfirmasi Password Baru',
          _confirmPasswordController,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              if (_newPasswordController.text !=
                  _confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Password tidak cocok'),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Password berhasil diubah'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.key_rounded),
            label: const Text('Ubah Password'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: AppColors.primary),
              foregroundColor: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return _buildSettingsCard(
      title: 'Tentang Aplikasi',
      children: [
        _buildInfoRow('Versi', '1.0.0'),
        _buildInfoRow('Build', '1'),
        _buildInfoRow('Pengembang', 'Matsanam Digital Academic'),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.info_outline_rounded),
            label: const Text('Kebijakan Privasi & Syarat Ketentuan'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: AppColors.primary),
              foregroundColor: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField(
    String label,
    TextEditingController controller, {
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(icon, color: AppColors.textSecondary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Masukkan $label',
                    hintStyle: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationToggle(
    String label,
    bool value, {
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: controller,
            obscureText: true,
            decoration: InputDecoration(border: InputBorder.none),
            style: const TextStyle(color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text(
                'Logout',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              content: const Text('Apakah Anda yakin ingin logout?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  },
                  child: const Text(
                    'Logout',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ],
            ),
          );
        },
        icon: const Icon(Icons.logout_rounded),
        label: const Text('Keluar'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          shadowColor: AppColors.error.withOpacity(0.3),
        ),
      ),
    );
  }
}

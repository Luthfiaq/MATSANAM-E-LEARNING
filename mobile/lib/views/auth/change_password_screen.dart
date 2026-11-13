import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../utils/session.dart';
import '../../utils/constants.dart';
import '../guru/dashboard_guru_screen.dart';
import 'login_screen.dart';
import '../siswa/dashboard/dashboard_siswa_page.dart';

class ChangePasswordScreen extends StatefulWidget {
  final bool wajib;
  const ChangePasswordScreen({super.key, this.wajib = false});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  bool _showCurrent = false,
      _showNew = false,
      _showConfirm = false,
      _loading = false;
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AuthService().changePassword(
        currentPassword: _current.text,
        newPassword: _new.text,
      );
      if (!mounted) return;

      // Login already stores the validated role locally. Reuse it here rather
      // than issuing another /auth/me request after the password was changed.
      final role = await Session.getRole();
      if (!mounted) return;

      final Widget destination;
      if (role == 'guru') {
        destination = const DashboardGuruScreen();
      } else if (role == 'siswa') {
        destination = const DashboardSiswaPage();
      } else {
        // Do not guess the account role and accidentally route to the wrong
        // dashboard if the local session data is incomplete.
        await Session.clearLogin();
        if (!mounted) return;
        destination = const LoginScreen();
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => destination),
        (_) => false,
      );
    } catch (e) {
      if (mounted)
        setState(() {
          _error = e.toString().replaceFirst('Bad state: ', '');
          _loading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.wajib,
      child: Scaffold(
        appBar: widget.wajib
            ? null
            : AppBar(title: const Text('Ganti Kata Sandi')),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(22),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Icon(
                          Icons.lock_reset_rounded,
                          size: 48,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: Text(
                          widget.wajib
                              ? 'Perbarui Kata Sandi'
                              : 'Ganti Kata Sandi',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.wajib
                            ? 'Admin telah memberikan kata sandi sementara. Buat kata sandi baru sebelum melanjutkan ke aplikasi.'
                            : 'Gunakan kata sandi baru yang kuat dan tidak digunakan pada akun lain.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 28),
                      _label('Kata Sandi Saat Ini'),
                      TextFormField(
                        controller: _current,
                        obscureText: !_showCurrent,
                        decoration: _decoration(
                          'Masukkan kata sandi saat ini',
                          _showCurrent,
                          () => setState(() => _showCurrent = !_showCurrent),
                        ),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Kata sandi saat ini wajib diisi.'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      _label('Kata Sandi Baru'),
                      TextFormField(
                        controller: _new,
                        obscureText: !_showNew,
                        decoration: _decoration(
                          'Minimal 10 karakter',
                          _showNew,
                          () => setState(() => _showNew = !_showNew),
                        ),
                        validator: (v) => (v == null || v.length < 10)
                            ? 'Kata sandi minimal 10 karakter.'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      _label('Konfirmasi Kata Sandi Baru'),
                      TextFormField(
                        controller: _confirm,
                        obscureText: !_showConfirm,
                        decoration: _decoration(
                          'Ulangi kata sandi baru',
                          _showConfirm,
                          () => setState(() => _showConfirm = !_showConfirm),
                        ),
                        validator: (v) => v != _new.text
                            ? 'Konfirmasi kata sandi tidak sama.'
                            : null,
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.errorLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _error!,
                            style: const TextStyle(color: AppColors.error),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton(
                          onPressed: _loading ? null : _save,
                          child: _loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Simpan Kata Sandi'),
                        ),
                      ),
                      if (widget.wajib) ...[
                        const SizedBox(height: 12),
                        const Center(
                          child: Text(
                            'Penggantian kata sandi wajib dilakukan untuk melanjutkan.',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
    ),
  );
  InputDecoration _decoration(String hint, bool visible, VoidCallback toggle) =>
      InputDecoration(
        hintText: hint,
        suffixIcon: IconButton(
          onPressed: toggle,
          icon: Icon(
            visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          ),
        ),
      );
}

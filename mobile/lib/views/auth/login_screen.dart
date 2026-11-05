import 'package:flutter/material.dart';

import '../../services/api_exception.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../widgets/common/school_logo.dart';
import '../siswa/dashboard/dashboard_siswa_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  final _auth = AuthService();

  bool _obscure = true;
  bool _remember = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailC.dispose();
    _passC.dispose();
    super.dispose();
  }

  Future<void> _masuk() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _auth.login(
        email: _emailC.text.trim(),
        password: _passC.text,
        remember: _remember,
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardSiswaPage()),
        (_) => false,
      );
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Terjadi kesalahan. Coba lagi.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _infoAdmin(String judul) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(judul,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        content: const Text(
          'Silakan hubungi Admin TU MTsN 6 Nganjuk untuk bantuan akun atau pengaturan ulang kata sandi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  InputDecoration _dekor({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    OutlineInputBorder b(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c, width: w),
        );
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
      prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 22),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      enabledBorder: b(AppColors.border),
      focusedBorder: b(AppColors.primary, 1.6),
      errorBorder: b(AppColors.error),
      focusedErrorBorder: b(AppColors.error, 1.6),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Column(
              children: [
                const SchoolLogoCard(size: 84),
                const SizedBox(height: 14),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFBFD6FB)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 7, color: AppColors.success),
                      SizedBox(width: 6),
                      Text('MADRASAH DIGITAL ACADEMIC',
                          style: TextStyle(
                              fontSize: 11,
                              letterSpacing: 0.6,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text('MTsN 6 Nganjuk',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                const Text(
                  'Gerbang Layanan Terpadu e-Learning &\nPresensi',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14, height: 1.4, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 22),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Selamat Datang',
                            style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        const Text('Masukkan email dan kata sandi Anda',
                            style: TextStyle(
                                fontSize: 13.5, color: AppColors.textSecondary)),
                        const SizedBox(height: 18),
                        const Text('Email',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailC,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          decoration: _dekor(
                              hint: 'nama@matsanam.sch.id',
                              icon: Icons.mail_outline_rounded),
                          validator: (v) {
                            final t = (v ?? '').trim();
                            if (t.isEmpty) return 'Email wajib diisi';
                            if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                .hasMatch(t)) {
                              return 'Format email tidak valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text('Kata Sandi',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passC,
                          obscureText: _obscure,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          onFieldSubmitted: (_) => _masuk(),
                          decoration: _dekor(
                            hint: 'Masukkan kata sandi',
                            icon: Icons.lock_outline_rounded,
                            suffix: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: const Color(0xFF94A3B8),
                                size: 22,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Kata sandi wajib diisi'
                              : null,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _remember,
                                onChanged: (v) =>
                                    setState(() => _remember = v ?? false),
                                activeColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                                side: const BorderSide(
                                    color: Color(0xFFCBD5E1), width: 1.4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('Ingat Saya',
                                style: TextStyle(
                                    fontSize: 13.5,
                                    color: AppColors.textSecondary)),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => _infoAdmin('Lupa Kata Sandi?'),
                              child: const Text('Lupa Kata Sandi?',
                                  style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary)),
                            ),
                          ],
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.errorLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.error_outline_rounded,
                                    size: 18, color: AppColors.error),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(_error!,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.error)),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _masuk,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  AppColors.primary.withValues(alpha: 0.6),
                              disabledForegroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            child: _loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2.4, color: Colors.white),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Masuk Sekarang',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600)),
                                      SizedBox(width: 8),
                                      Icon(Icons.arrow_forward_rounded,
                                          size: 20),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                GestureDetector(
                  onTap: () => _infoAdmin('Kendala Masuk Akun'),
                  child: const Text.rich(
                    TextSpan(
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textSecondary),
                      children: [
                        TextSpan(text: 'Kendala masuk akun? '),
                        TextSpan(
                          text: 'Hubungi Admin TU Madrasah',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified_outlined,
                        size: 15, color: AppColors.success),
                    SizedBox(width: 5),
                    Text('Kemenag RI',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                    SizedBox(width: 8),
                    Text('•',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                    SizedBox(width: 8),
                    Text('Matsanam Mobile v2.4',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../utils/app_theme_state.dart';
import '../../utils/constants.dart';
import '../../widgets/common/school_logo.dart';
import '../siswa/siswa_tab_shell.dart';
import 'change_password_screen.dart';
import '../guru/guru_tab_shell.dart';

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
      final result = await _auth.login(
        email: _emailC.text.trim(),
        password: _passC.text,
        remember: _remember,
      );
      if (!mounted) return;

      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>;
        final user = data['user'] as Map<String, dynamic>;
        final role = user['role']?.toString();
        if (role == 'guru' || role == 'siswa') {
          AppThemeState.setActiveRole(role!);
        }
        final Widget tujuan;
        if (user['must_change_password'] == true) {
          tujuan = const ChangePasswordScreen(wajib: true);
        } else if (role == 'guru') {
          tujuan = const GuruTabShell();
        } else if (role == 'siswa') {
          tujuan = const SiswaTabShell();
        } else {
          await _auth.logout();
          setState(
            () => _error = 'Role akun tidak dikenali untuk aplikasi mobile.',
          );
          return;
        }

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => tujuan),
          (_) => false,
        );
      } else {
        setState(
          () => _error = result['message']?.toString() ?? 'Login gagal.',
        );
      }
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
        title: Text(
          judul,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
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
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color, width: width),
        );
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: colors.onSurfaceVariant.withValues(alpha: 0.78),
        fontSize: 15,
      ),
      prefixIcon: Icon(icon, color: colors.onSurfaceVariant, size: 22),
      suffixIcon: suffix,
      filled: true,
      fillColor: dark ? const Color(0xFF263449) : const Color(0xFFF1F5F9),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      enabledBorder: border(colors.outlineVariant),
      focusedBorder: border(colors.primary, 1.6),
      errorBorder: border(colors.error),
      focusedErrorBorder: border(colors.error, 1.6),
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Column(
              children: [
                const SchoolLogoCard(size: 84),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colors.outlineVariant),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 7, color: AppColors.success),
                      const SizedBox(width: 6),
                      Text(
                        'MADRASAH DIGITAL ACADEMIC',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 0.6,
                          fontWeight: FontWeight.w700,
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'MTsN 6 Nganjuk',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Gerbang Layanan Terpadu e-Learning &\nPresensi',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 22),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: colors.outlineVariant),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: dark ? 0.18 : 0.05),
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
                        Text(
                          'Selamat Datang',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Masukkan email dan kata sandi Anda',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailC,
                          style: TextStyle(color: colors.onSurface, fontSize: 15),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          decoration: _dekor(
                            hint: 'nama@matsanam.sch.id',
                            icon: Icons.mail_outline_rounded,
                          ),
                          validator: (value) {
                            final text = (value ?? '').trim();
                            if (text.isEmpty) return 'Email wajib diisi';
                            if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text)) {
                              return 'Format email tidak valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Kata Sandi',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passC,
                          style: TextStyle(color: colors.onSurface, fontSize: 15),
                          obscureText: _obscure,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          onFieldSubmitted: (_) => _masuk(),
                          decoration: _dekor(
                            hint: 'Masukkan kata sandi',
                            icon: Icons.lock_outline_rounded,
                            suffix: IconButton(
                              tooltip: _obscure
                                  ? 'Tampilkan kata sandi'
                                  : 'Sembunyikan kata sandi',
                              splashRadius: 20,
                              onPressed: () => setState(() => _obscure = !_obscure),
                              icon: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 180),
                                switchInCurve: Curves.easeOutCubic,
                                switchOutCurve: Curves.easeInCubic,
                                transitionBuilder: (child, animation) =>
                                    FadeTransition(
                                  opacity: animation,
                                  child: ScaleTransition(
                                    scale: Tween<double>(begin: 0.86, end: 1).animate(animation),
                                    child: child,
                                  ),
                                ),
                                child: Icon(
                                  _obscure
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  key: ValueKey<bool>(_obscure),
                                  color: colors.onSurfaceVariant,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                          validator: (value) => (value == null || value.isEmpty)
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
                                onChanged: (value) =>
                                    setState(() => _remember = value ?? false),
                                activeColor: colors.primary,
                                checkColor: colors.onPrimary,
                                side: BorderSide(
                                  color: colors.outline,
                                  width: 1.4,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Ingat Saya',
                              style: TextStyle(
                                fontSize: 13.5,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => _infoAdmin('Lupa Kata Sandi?'),
                              child: Text(
                                'Lupa Kata Sandi?',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: colors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colors.errorContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.error_outline_rounded,
                                  size: 18,
                                  color: colors.error,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: colors.onErrorContainer,
                                    ),
                                  ),
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
                              backgroundColor: colors.primary,
                              foregroundColor: colors.onPrimary,
                              disabledBackgroundColor:
                                  colors.primary.withValues(alpha: 0.6),
                              disabledForegroundColor: colors.onPrimary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ).copyWith(
                              animationDuration: const Duration(milliseconds: 180),
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 180),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              transitionBuilder: (child, animation) =>
                                  FadeTransition(
                                opacity: animation,
                                child: ScaleTransition(
                                  scale: Tween<double>(begin: 0.96, end: 1)
                                      .animate(animation),
                                  child: child,
                                ),
                              ),
                              child: _loading
                                  ? SizedBox(
                                      key: const ValueKey('login-loading'),
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                        color: colors.onPrimary,
                                      ),
                                    )
                                  : Row(
                                      key: const ValueKey('login-label'),
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Masuk Sekarang',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: colors.onPrimary,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 20,
                                          color: colors.onPrimary,
                                        ),
                                      ],
                                    ),
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
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.onSurfaceVariant,
                      ),
                      children: [
                        const TextSpan(text: 'Kendala masuk akun? '),
                        TextSpan(
                          text: 'Hubungi Admin TU Madrasah',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.verified_outlined,
                      size: 15,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Kemenag RI',
                      style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '•',
                      style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Matsanam Mobile v2.4',
                      style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                    ),
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


import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_emailCtrl.text.trim(), _passwordCtrl.text);
    if (ok && mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.green,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(height: 40),
              Text('Selamat\nDatang Kembali',
                style: GoogleFonts.syne(
                  fontSize: 36, fontWeight: FontWeight.w800,
                  color: Colors.white, height: 1.1, letterSpacing: -1)),
              const SizedBox(height: 8),
              Text('Masuk untuk melaporkan dan memantau hutan Indonesia.',
                style: GoogleFonts.dmSans(
                  fontSize: 14, color: Colors.white.withOpacity(0.55), height: 1.7)),
              const SizedBox(height: 40),

              // Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (auth.error != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.error.withOpacity(0.2)),
                        ),
                        child: Text(auth.error!,
                          style: GoogleFonts.dmSans(
                            fontSize: 13, color: AppColors.error)),
                      ),

                    _label('Email'),
                    const SizedBox(height: 8),
                    _TextField(
                      controller: _emailCtrl,
                      hint: 'email@contoh.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    _label('Password'),
                    const SizedBox(height: 8),
                    _TextField(
                      controller: _passwordCtrl,
                      hint: '••••••••',
                      obscure: _obscure,
                      suffix: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                          size: 18, color: AppColors.textLt),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label: 'Masuk',
                      loading: auth.loading,
                      onTap: _submit,
                      width: double.infinity,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Register link
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Belum punya akun? ',
                      style: GoogleFonts.dmSans(
                        fontSize: 14, color: Colors.white.withOpacity(0.55))),
                    GestureDetector(
                      onTap: () => context.go('/register'),
                      child: Text('Daftar Sekarang',
                        style: GoogleFonts.dmSans(
                          fontSize: 14, color: AppColors.lime,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.lime)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
    style: GoogleFonts.dmSans(
      fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDk));
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passCtrl     = TextEditingController();
  final _confirmCtrl  = TextEditingController();
  bool _obscure = true;

  Future<void> _submit() async {
    if (_passCtrl.text != _confirmCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password tidak cocok')));
      return;
    }
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      _nameCtrl.text.trim(),
      _emailCtrl.text.trim(),
      _passCtrl.text,
      _confirmCtrl.text,
    );
    if (ok && mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.green,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(height: 40),
              Text('Bergabung\nBersama Kami',
                style: GoogleFonts.syne(
                  fontSize: 36, fontWeight: FontWeight.w800,
                  color: Colors.white, height: 1.1, letterSpacing: -1)),
              const SizedBox(height: 8),
              Text('Daftar dan mulai jaga hutan Indonesia bersama.',
                style: GoogleFonts.dmSans(
                  fontSize: 14, color: Colors.white.withOpacity(0.55), height: 1.7)),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (auth.error != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.error.withOpacity(0.2)),
                        ),
                        child: Text(auth.error!,
                          style: GoogleFonts.dmSans(
                            fontSize: 13, color: AppColors.error)),
                      ),
                    _label('Nama Lengkap'),
                    const SizedBox(height: 8),
                    _TextField(controller: _nameCtrl, hint: 'Nama Anda'),
                    const SizedBox(height: 16),
                    _label('Email'),
                    const SizedBox(height: 8),
                    _TextField(
                      controller: _emailCtrl,
                      hint: 'email@contoh.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    _label('Password'),
                    const SizedBox(height: 8),
                    _TextField(
                      controller: _passCtrl,
                      hint: 'Min. 8 karakter',
                      obscure: _obscure,
                      suffix: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                          size: 18, color: AppColors.textLt),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _label('Konfirmasi Password'),
                    const SizedBox(height: 8),
                    _TextField(
                      controller: _confirmCtrl,
                      hint: 'Ulangi password',
                      obscure: true,
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label: 'Daftar Sekarang',
                      loading: auth.loading,
                      onTap: _submit,
                      width: double.infinity,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Sudah punya akun? ',
                      style: GoogleFonts.dmSans(
                        fontSize: 14, color: Colors.white.withOpacity(0.55))),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: Text('Masuk',
                        style: GoogleFonts.dmSans(
                          fontSize: 14, color: AppColors.lime,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.lime)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
    style: GoogleFonts.dmSans(
      fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDk));
}

// ── Shared text field
class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffix;

  const _TextField({
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.keyboardType,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    obscureText: obscure,
    keyboardType: keyboardType,
    style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textDk),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textLt),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.offWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.greenMd, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}

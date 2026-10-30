import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_button.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final auth = context.read<AuthService>();
    final ok = await auth.login(
      _usernameController.text,
      _passwordController.text,
    );
    if (!mounted) return;
    if (!ok) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username atau password salah.')),
      );
      return;
    }
    await auth.setLoggedIn(true);
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              isLight
                  ? 'assets/images/background.png'
                  : 'assets/images/background_dark.png',
              fit: BoxFit.fill,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 30.w),
              child: Column(
                children: [
                  60.verticalSpace,
                  CircleAvatar(
                    radius: 40.r,
                    backgroundColor: theme.primaryColorDark,
                    child: Image.asset('assets/images/ikon.png',
                        width: 50.w, height: 42.h),
                  )
                      .animate()
                      .fade(duration: 300.ms)
                      .slideY(begin: -1, curve: Curves.easeInSine, duration: 300.ms),
                  24.verticalSpace,
                  Text(
                    'Selamat Datang Kembali',
                    style: TextStyle(fontFamily: AppTheme.heading, fontSize: 24.sp, fontWeight: FontWeight.w700, color: theme.primaryColorDark),
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fade(duration: 300.ms)
                      .slideY(begin: -1, curve: Curves.easeInSine, duration: 300.ms),
                  12.verticalSpace,
                  Text(
                    'Masuk untuk mulai berbelanja rempah pilihan.',
                    style: TextStyle(fontFamily: AppTheme.body, fontSize: 14.sp, color: theme.hintColor),
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fade(duration: 300.ms)
                      .slideY(begin: 1, curve: Curves.easeInSine, duration: 300.ms),
                  30.verticalSpace,
                  Container(
                    padding: EdgeInsets.fromLTRB(22.w, 26.h, 22.w, 24.h),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(26.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.10),
                          blurRadius: 30,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'Username',
                              prefixIcon: const Icon(Icons.person_outline),
                              filled: true,
                              fillColor: const Color(0xFFF9F9F9),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.r),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Username wajib diisi';
                              }
                              return null;
                            },
                          ),
                          14.verticalSpace,
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscure,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF9F9F9),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.r),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Password wajib diisi';
                              }
                              if (v.length < 6) return 'Minimal 6 karakter';
                              return null;
                            },
                          ),
                          18.verticalSpace,
                          GradientButton(
                            label: 'Masuk',
                            icon: Icons.login,
                            loading: _loading,
                            onPressed: _login,
                          ),
                        ],
                      ),
                    ),
                  ),
                  24.verticalSpace,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

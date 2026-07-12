import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:transitops/core/extensions/context_extension.dart';
import 'package:transitops/core/routes/app_router.dart';
import 'package:transitops/core/widgets/app_text_field.dart';
import 'package:transitops/features/authentication/blocs/auth_bloc.dart';
import 'package:transitops/features/authentication/blocs/auth_event.dart';
import 'package:transitops/features/authentication/blocs/auth_state.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
const _kBg = Color(0xFF090D16);
const _kSurface = Color(0xFF111827);
const _kSurfaceRaised = Color(0xFF1E293B);
const _kAccent = Color(0xFF6366F1);
const _kAccentLight = Color(0xFF818CF8);
const _kError = Color(0xFFF87171);
const _kTextPrimary = Color(0xFFF8FAFC);
const _kTextSecondary = Color(0xFF94A3B8);
const _kBorder = Color(0xFF1E293B);

// ─── Feature bullets shown on the web branding panel ─────────────────────────
const _kFeatures = [
  (Icons.local_shipping_rounded, 'Real-time fleet tracking & dispatch'),
  (Icons.bar_chart_rounded, 'Cost analytics & ROI dashboards'),
  (Icons.shield_rounded, 'Driver safety scores & compliance'),
  (Icons.route_rounded, 'Smart trip planning & lifecycle'),
];

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();

  bool _obscurePass = true;
  bool _emailFocused = false;
  bool _passFocused = false;

  late AnimationController _anim;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
    _anim.forward();

    _emailFocus.addListener(
      () => setState(() => _emailFocused = _emailFocus.hasFocus),
    );
    _passFocus.addListener(
      () => setState(() => _passFocused = _passFocus.hasFocus),
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthLoginSubmitted(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
        ),
      );
    }
  }

  void _quickLogin(String email) {
    setState(() {
      _emailCtrl.text = email;
      _passCtrl.text = 'password123';
    });
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) _submit();
    });
  }

  // ─── Root ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: PremiumCard(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.directions_bus_filled,
                      size: 48,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'TransitOps',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to your account',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 32),
                    AppTextField(
                      label: 'Email',
                      hintText: 'name@transitops.smart',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Password',
                      hintText: '••••••••',
                      controller: _passwordController,
                      obscureText: true,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        // Proceed to dashboard on login
                        context.go('/dashboard');
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Sign In'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: () {}, child: const Text('Login')),
          ],
        ),
      ),
    );
  }
}

Widget _blob(double size, Color color, double opacity) => Container(
  width: size,
  height: size,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: color.withValues(alpha: opacity),
  ),
);

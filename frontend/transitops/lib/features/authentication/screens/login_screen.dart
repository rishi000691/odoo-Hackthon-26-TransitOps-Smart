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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: _kBg,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (ctx, state) {
          if (state is Authenticated) ctx.go(AppRouter.dashboardPath);
          if (state is AuthFailureState) _showError(ctx, state.message);
        },
        builder: (ctx, state) {
          return FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: context.isDesktop
                  ? Row(
                      children: [
                        Expanded(flex: 42, child: buildBrandingPanel()),
                        Expanded(flex: 58, child: buildFormPanel(isWeb: true)),
                      ],
                    )
                  : SafeArea(child: buildFormPanel(isWeb: false)),
            ),
          );
        },
      ),
    );
  }

  Widget buildBrandingPanel() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1a1040), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            left: -80,
            child: _blob(320, const Color(0xFF6366F1), 0.10),
          ),
          Positioned(
            bottom: -60,
            right: -60,
            child: _blob(260, const Color(0xFF818CF8), 0.08),
          ),
          Padding(
            padding: const EdgeInsets.all(56),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_kAccent, _kAccentLight],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: _kAccent.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.local_shipping_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'TransitOps',
                  style: GoogleFonts.outfit(
                    color: _kTextPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'The all-in-one fleet operations platform\nfor modern logistics teams.',
                  style: GoogleFonts.outfit(
                    color: _kTextSecondary,
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
                const Spacer(),
                ..._kFeatures.map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _kAccent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(f.$1, color: _kAccentLight, size: 18),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            f.$2,
                            style: GoogleFonts.outfit(
                              color: _kTextPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '© 2026 TransitOps Smart. All rights reserved.',
                  style: GoogleFonts.outfit(
                    color: _kTextSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFormPanel({required bool isWeb}) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isWeb ? 56 : 24,
          vertical: 40,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!isWeb) _mobileHeader(),
              if (!isWeb) const SizedBox(height: 32),
              _loginCard(),
              const SizedBox(height: 16),
              _registerPrompt(),
              const SizedBox(height: 28),
              _divider(),
              const SizedBox(height: 20),
              _quickPanel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mobileHeader() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_kAccent, _kAccentLight]),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: _kAccent.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.local_shipping_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'TransitOps',
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: _kTextPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Sign in to your fleet portal',
          style: GoogleFonts.outfit(fontSize: 14, color: _kTextSecondary),
        ),
      ],
    );
  }

  Widget _loginCard() {
    return Builder(
      builder: (ctx) {
        final state = ctx.watch<AuthBloc>().state;
        final loading = state is AuthLoading;
        return Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _kBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Welcome back',
                  style: GoogleFonts.outfit(
                    color: _kTextPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Enter your credentials to continue',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: _kTextSecondary,
                  ),
                ),
                const SizedBox(height: 26),
                _label('Email address'),
                const SizedBox(height: 8),
                _field(
                  ctrl: _emailCtrl,
                  focus: _emailFocus,
                  focused: _emailFocused,
                  hint: 'you@company.com',
                  icon: Icons.mail_outline_rounded,
                  type: TextInputType.emailAddress,
                  enabled: !loading,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email is required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _label('Password'),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Forgot password?',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: _kAccentLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _field(
                  ctrl: _passCtrl,
                  focus: _passFocus,
                  focused: _passFocused,
                  hint: '••••••••',
                  icon: Icons.lock_outline_rounded,
                  obscure: _obscurePass,
                  enabled: !loading,
                  suffix: IconButton(
                    icon: Icon(
                      _obscurePass
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 18,
                      color: _kTextSecondary,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePass = !_obscurePass),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    return null;
                  },
                ),
                const SizedBox(height: 28),
                _primaryBtn(
                  label: 'Sign in',
                  loading: loading,
                  onTap: loading ? null : _submit,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _registerPrompt() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        "Don't have an account?  ",
        style: GoogleFonts.outfit(fontSize: 13, color: _kTextSecondary),
      ),
      GestureDetector(
        onTap: () => context.go(AppRouter.registerPath),
        child: Text(
          'Create one',
          style: GoogleFonts.outfit(
            fontSize: 13,
            color: _kAccentLight,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );

  Widget _divider() => Row(
    children: [
      const Expanded(child: Divider(color: _kBorder, thickness: 1)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          'Quick demo',
          style: GoogleFonts.outfit(fontSize: 12, color: _kTextSecondary),
        ),
      ),
      const Expanded(child: Divider(color: _kBorder, thickness: 1)),
    ],
  );

  Widget _quickPanel() {
    final roles = [
      _QR(
        'Fleet Manager',
        Icons.admin_panel_settings_rounded,
        const Color(0xFFF59E0B),
        'manager@transitops.smart',
      ),
      _QR(
        'Driver',
        Icons.person_pin_rounded,
        const Color(0xFF10B981),
        'driver@transitops.smart',
      ),
      _QR(
        'Safety Officer',
        Icons.shield_rounded,
        const Color(0xFFF97316),
        'safety@transitops.smart',
      ),
      _QR(
        'Financial Analyst',
        Icons.bar_chart_rounded,
        const Color(0xFFA855F7),
        'finance@transitops.smart',
      ),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: roles.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.4,
      ),
      itemBuilder: (_, i) =>
          _QuickTile(role: roles[i], onTap: () => _quickLogin(roles[i].email)),
    );
  }

  // ─── Shared primitives ──────────────────────────────────────────────────────
  Widget _label(String t) => Text(
    t,
    style: GoogleFonts.outfit(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: _kTextPrimary,
    ),
  );

  Widget _field({
    required TextEditingController ctrl,
    required FocusNode focus,
    required bool focused,
    required String hint,
    required IconData icon,
    bool obscure = false,
    bool enabled = true,
    Widget? suffix,
    TextInputType? type,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      focusNode: focus,
      enabled: enabled,
      obscureText: obscure,
      keyboardType: type,
      style: GoogleFonts.outfit(color: _kTextPrimary, fontSize: 14),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.outfit(color: _kTextSecondary, fontSize: 14),
        fillColor: _kSurfaceRaised,
        filled: true,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 10),
          child: Icon(
            icon,
            size: 18,
            color: focused ? _kAccentLight : _kTextSecondary,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: suffix,
        errorStyle: GoogleFonts.outfit(color: _kError, fontSize: 12),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: focused ? _kAccent : _kBorder,
            width: focused ? 2 : 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kAccent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kError, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kError, width: 2),
        ),
      ),
    );
  }

  Widget _primaryBtn({
    required String label,
    required bool loading,
    required VoidCallback? onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kAccent, _kAccentLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: onTap != null
            ? [
                BoxShadow(
                  color: _kAccent.withValues(alpha: 0.38),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    label,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  void _showError(BuildContext ctx, String msg) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(msg, style: GoogleFonts.outfit(fontSize: 13))),
          ],
        ),
        backgroundColor: _kError,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

// ─── Quick Login data + tile ──────────────────────────────────────────────────
class _QR {
  final String label, email;
  final IconData icon;
  final Color color;
  const _QR(this.label, this.icon, this.color, this.email);
}

class _QuickTile extends StatefulWidget {
  final _QR role;
  final VoidCallback onTap;
  const _QuickTile({required this.role, required this.onTap});

  @override
  State<_QuickTile> createState() => _QuickTileState();
}

class _QuickTileState extends State<_QuickTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _hover
                ? widget.role.color.withValues(alpha: 0.10)
                : _kSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hover
                  ? widget.role.color.withValues(alpha: 0.45)
                  : _kBorder,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: widget.role.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  widget.role.icon,
                  color: widget.role.color,
                  size: 15,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.role.label,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _kTextPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:transitops/core/constants/enums.dart';
import 'package:transitops/core/extensions/context_extension.dart';
import 'package:transitops/core/routes/app_router.dart';
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

// ─── Role metadata ─────────────────────────────────────────────────────────────
class _RM {
  final UserRole role;
  final Color color;
  final IconData icon;
  final String label, desc;
  const _RM(this.role, this.color, this.icon, this.label, this.desc);
}

const _kRoles = [
  _RM(UserRole.fleetManager, Color(0xFFF59E0B),
      Icons.admin_panel_settings_rounded, 'Fleet Manager',
      'Manage vehicles, dispatches & full analytics'),
  _RM(UserRole.driver, Color(0xFF10B981), Icons.person_pin_rounded, 'Driver',
      'Receive trips, log fuel & submit reports'),
  _RM(UserRole.safetyOfficer, Color(0xFFF97316), Icons.shield_rounded,
      'Safety Officer', 'Monitor compliance & incident logs'),
  _RM(UserRole.financialAnalyst, Color(0xFFA855F7), Icons.bar_chart_rounded,
      'Financial Analyst', 'Track costs, ROI & export reports'),
];

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _emailFocused = false;
  bool _passFocused = false;
  bool _confirmFocused = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  UserRole _role = UserRole.driver;

  late AnimationController _anim;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650));
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
    _anim.forward();

    _emailFocus.addListener(
        () => setState(() => _emailFocused = _emailFocus.hasFocus));
    _passFocus.addListener(
        () => setState(() => _passFocused = _passFocus.hasFocus));
    _confirmFocus.addListener(
        () => setState(() => _confirmFocused = _confirmFocus.hasFocus));
  }

  @override
  void dispose() {
    _anim.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(AuthRegisterSubmitted(
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text,
            role: _role,
          ));
    }
  }

  // ─── Root ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (ctx, state) {
          if (state is Authenticated) ctx.go(AppRouter.dashboardPath);
          if (state is AuthFailureState) _showError(ctx, state.message);
        },
        builder: (ctx, state) {
          final loading = state is AuthLoading;
          return FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: context.isDesktop
                  ? Row(children: [
                      Expanded(flex: 40, child: _buildRolePanel()),
                      Expanded(flex: 60, child: _buildFormPanel(loading, isWeb: true)),
                    ])
                  : SafeArea(child: _buildFormPanel(loading, isWeb: false)),
            ),
          );
        },
      ),
    );
  }

  // ─── Left Role Panel (web) ─────────────────────────────────────────────────
  Widget _buildRolePanel() {
    final selected = _kRoles.firstWhere((r) => r.role == _role);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            selected.color.withValues(alpha: 0.18),
            const Color(0xFF0F172A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(children: [
        Positioned(
            top: -80,
            left: -60,
            child: _blob(280, selected.color, 0.08)),
        Padding(
          padding: const EdgeInsets.all(52),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [_kAccent, _kAccentLight]),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: _kAccent.withValues(alpha: 0.4),
                        blurRadius: 18,
                        offset: const Offset(0, 6))
                  ],
                ),
                child: const Icon(Icons.local_shipping_rounded,
                    color: Colors.white, size: 26),
              ),
              const SizedBox(height: 20),
              Text('Join TransitOps',
                  style: GoogleFonts.outfit(
                      color: _kTextPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5)),
              const SizedBox(height: 8),
              Text('Choose your role to get started\nwith the right tools.',
                  style: GoogleFonts.outfit(
                      color: _kTextSecondary, fontSize: 14, height: 1.6)),
              const SizedBox(height: 40),
              Text('Available Roles',
                  style: GoogleFonts.outfit(
                      color: _kTextSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0)),
              const SizedBox(height: 14),
              // Role cards in side panel (interactive on web)
              ..._kRoles.map((r) {
                final active = r.role == _role;
                return GestureDetector(
                  onTap: () => setState(() => _role = r.role),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: active
                          ? r.color.withValues(alpha: 0.14)
                          : Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: active
                              ? r.color.withValues(alpha: 0.45)
                              : Colors.white.withValues(alpha: 0.06),
                          width: active ? 1.5 : 1),
                    ),
                    child: Row(children: [
                      Icon(r.icon,
                          color: active ? r.color : _kTextSecondary,
                          size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.label,
                              style: GoogleFonts.outfit(
                                  color: active ? r.color : _kTextPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13)),
                          Text(r.desc,
                              style: GoogleFonts.outfit(
                                  color: _kTextSecondary, fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      )),
                      if (active)
                        Icon(Icons.check_circle_rounded,
                            color: r.color, size: 16),
                    ]),
                  ),
                );
              }),
              const Spacer(),
              Text('© 2026 TransitOps Smart',
                  style: GoogleFonts.outfit(
                      color: _kTextSecondary, fontSize: 12)),
            ],
          ),
        ),
      ]),
    );
  }

  // ─── Form Panel ────────────────────────────────────────────────────────────
  Widget _buildFormPanel(bool loading, {required bool isWeb}) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
            horizontal: isWeb ? 52 : 24, vertical: 40),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isWeb ? 420 : 500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!isWeb) _mobileHeader(),
              if (!isWeb) const SizedBox(height: 28),
              _formCard(loading, isWeb: isWeb),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account?  ',
                      style: GoogleFonts.outfit(
                          fontSize: 13, color: _kTextSecondary)),
                  GestureDetector(
                    onTap: () => context.go(AppRouter.loginPath),
                    child: Text('Sign in',
                        style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: _kAccentLight,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mobileHeader() => Column(children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_kAccent, _kAccentLight]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: _kAccent.withValues(alpha: 0.4),
                  blurRadius: 18,
                  offset: const Offset(0, 6))
            ],
          ),
          child:
              const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 16),
        Text('Create Account',
            style: GoogleFonts.outfit(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: _kTextPrimary,
                letterSpacing: -0.5)),
        const SizedBox(height: 6),
        Text('Join the TransitOps network',
            style: GoogleFonts.outfit(fontSize: 14, color: _kTextSecondary)),
      ]);

  // ─── Form Card ─────────────────────────────────────────────────────────────
  Widget _formCard(bool loading, {required bool isWeb}) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 32,
              offset: const Offset(0, 8))
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Account Details',
                style: GoogleFonts.outfit(
                    color: _kTextPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('Fill in your info and select a role',
                style: GoogleFonts.outfit(
                    fontSize: 13, color: _kTextSecondary)),
            const SizedBox(height: 24),

            // Email
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
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                    return 'Enter a valid email address';
                  }
                  return null;
                }),
            const SizedBox(height: 18),

            // Password
            _label('Password'),
            const SizedBox(height: 8),
            _field(
                ctrl: _passCtrl,
                focus: _passFocus,
                focused: _passFocused,
                hint: '••••••••',
                icon: Icons.lock_outline_rounded,
                obscure: _obscurePass,
                enabled: !loading,
                suffix: _eye(
                    obs: _obscurePass,
                    toggle: () =>
                        setState(() => _obscurePass = !_obscurePass)),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password is required';
                  if (v.length < 6) {
                    return 'Minimum 6 characters';
                  }
                  return null;
                }),
            const SizedBox(height: 18),

            // Confirm Password
            _label('Confirm password'),
            const SizedBox(height: 8),
            _field(
                ctrl: _confirmCtrl,
                focus: _confirmFocus,
                focused: _confirmFocused,
                hint: '••••••••',
                icon: Icons.lock_outline_rounded,
                obscure: _obscureConfirm,
                enabled: !loading,
                suffix: _eye(
                    obs: _obscureConfirm,
                    toggle: () => setState(
                        () => _obscureConfirm = !_obscureConfirm)),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (v != _passCtrl.text) return 'Passwords do not match';
                  return null;
                }),

            // Role picker on mobile/tablet (on web it's in side panel)
            if (!isWeb) ...[
              const SizedBox(height: 22),
              _label('Your role'),
              const SizedBox(height: 12),
              _mobileRolePicker(loading),
              const SizedBox(height: 12),
              _roleHint(),
            ],

            const SizedBox(height: 28),
            _primaryBtn(
                label: 'Create account',
                loading: loading,
                onTap: loading ? null : _submit),
          ],
        ),
      ),
    );
  }

  // ─── Role picker for mobile ─────────────────────────────────────────────────
  Widget _mobileRolePicker(bool loading) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.2),
      itemCount: _kRoles.length,
      itemBuilder: (_, i) {
        final r = _kRoles[i];
        final sel = _role == r.role;
        return GestureDetector(
          onTap: loading ? null : () => setState(() => _role = r.role),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: sel ? r.color.withValues(alpha: 0.11) : _kSurfaceRaised,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: sel ? r.color : _kBorder, width: sel ? 1.5 : 1),
            ),
            child: Row(children: [
              Icon(r.icon,
                  color: sel ? r.color : _kTextSecondary, size: 17),
              const SizedBox(width: 8),
              Expanded(
                child: Text(r.label,
                    style: GoogleFonts.outfit(
                        color: sel ? r.color : _kTextSecondary,
                        fontSize: 11,
                        fontWeight: sel ? FontWeight.w700 : FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ),
              if (sel)
                Icon(Icons.check_circle_rounded, color: r.color, size: 13),
            ]),
          ),
        );
      },
    );
  }

  Widget _roleHint() {
    final r = _kRoles.firstWhere((x) => x.role == _role);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: Container(
        key: ValueKey(_role),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: r.color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: r.color.withValues(alpha: 0.22)),
        ),
        child: Row(children: [
          Icon(r.icon, color: r.color, size: 16),
          const SizedBox(width: 10),
          Expanded(
              child: Text(r.desc,
                  style:
                      GoogleFonts.outfit(color: _kTextSecondary, fontSize: 12))),
        ]),
      ),
    );
  }

  // ─── Shared primitives ──────────────────────────────────────────────────────
  Widget _label(String t) => Text(t,
      style: GoogleFonts.outfit(
          fontSize: 13, fontWeight: FontWeight.w600, color: _kTextPrimary));

  Widget _eye({required bool obs, required VoidCallback toggle}) =>
      IconButton(
        icon: Icon(obs ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 18, color: _kTextSecondary),
        onPressed: toggle,
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
  }) =>
      TextFormField(
        controller: ctrl,
        focusNode: focus,
        enabled: enabled,
        obscureText: obscure,
        keyboardType: type,
        style: GoogleFonts.outfit(color: _kTextPrimary, fontSize: 14),
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              GoogleFonts.outfit(color: _kTextSecondary, fontSize: 14),
          fillColor: _kSurfaceRaised,
          filled: true,
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14, right: 10),
            child: Icon(icon, size: 18,
                color: focused ? _kAccentLight : _kTextSecondary),
          ),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 0, minHeight: 0),
          suffixIcon: suffix,
          errorStyle: GoogleFonts.outfit(color: _kError, fontSize: 12),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: focused ? _kAccent : _kBorder,
                  width: focused ? 2 : 1)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _kAccent, width: 2)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _kError, width: 1)),
          focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _kError, width: 2)),
        ),
      );

  Widget _primaryBtn(
      {required String label,
      required bool loading,
      required VoidCallback? onTap}) =>
      AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 48,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [_kAccent, _kAccentLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(10),
          boxShadow: onTap != null
              ? [
                  BoxShadow(
                      color: _kAccent.withValues(alpha: 0.38),
                      blurRadius: 16,
                      offset: const Offset(0, 4))
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
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                  : Text(label,
                      style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
            ),
          ),
        ),
      );

  void _showError(BuildContext ctx, String msg) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.error_outline, color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(msg, style: GoogleFonts.outfit(fontSize: 13))),
      ]),
      backgroundColor: _kError,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }
}

Widget _blob(double size, Color color, double opacity) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: opacity)));

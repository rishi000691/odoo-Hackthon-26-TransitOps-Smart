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
const _kError = Color(0xFFF87171);
const _kTextPrimary = Color(0xFFF8FAFC);
const _kTextSecondary = Color(0xFF94A3B8);
const _kBorder = Color(0xFF1E293B);
const _kAccent = Color(0xFF6366F1);
const _kAccentLight = Color(0xFF818CF8);

// ─── Role metadata ────────────────────────────────────────────────────────────
class _RoleOption {
  final UserRole role;
  final IconData icon;
  final String label, desc;
  final Color accent;
  final List<Color> gradient;

  const _RoleOption({
    required this.role,
    required this.icon,
    required this.label,
    required this.desc,
    required this.accent,
    required this.gradient,
  });
}

const _kRoles = [
  _RoleOption(
    role: UserRole.fleetManager,
    icon: Icons.admin_panel_settings_rounded,
    label: 'Fleet Manager',
    desc: 'Full fleet visibility & dispatch control',
    accent: Color(0xFFF59E0B),
    gradient: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
  ),
  _RoleOption(
    role: UserRole.driver,
    icon: Icons.person_pin_rounded,
    label: 'Driver',
    desc: 'Trip progress, checklist & safety score',
    accent: Color(0xFF10B981),
    gradient: [Color(0xFF10B981), Color(0xFF34D399)],
  ),
  _RoleOption(
    role: UserRole.safetyOfficer,
    icon: Icons.shield_rounded,
    label: 'Safety Officer',
    desc: 'Compliance monitoring & incident review',
    accent: Color(0xFFF97316),
    gradient: [Color(0xFFF97316), Color(0xFFFB923C)],
  ),
  _RoleOption(
    role: UserRole.financialAnalyst,
    icon: Icons.bar_chart_rounded,
    label: 'Financial Analyst',
    desc: 'Revenue, costs & ROI reporting',
    accent: Color(0xFFA855F7),
    gradient: [Color(0xFFA855F7), Color(0xFFC084FC)],
  ),
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
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();

  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();
  final _confirmFocus = FocusNode();
  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();

  bool _emailFocused = false;
  bool _passFocused = false;
  bool _confirmFocused = false;
  bool _firstNameFocused = false;
  bool _lastNameFocused = false;

  bool _obscurePass = true;
  bool _obscureConfirm = true;

  UserRole _selectedRole = UserRole.fleetManager;

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
        () => setState(() => _emailFocused = _emailFocus.hasFocus));
    _passFocus.addListener(
        () => setState(() => _passFocused = _passFocus.hasFocus));
    _confirmFocus.addListener(
        () => setState(() => _confirmFocused = _confirmFocus.hasFocus));
    _firstNameFocus.addListener(
        () => setState(() => _firstNameFocused = _firstNameFocus.hasFocus));
    _lastNameFocus.addListener(
        () => setState(() => _lastNameFocused = _lastNameFocus.hasFocus));
  }

  @override
  void dispose() {
    _anim.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    _confirmFocus.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthRegisterSubmitted(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
          firstName: _firstNameCtrl.text.trim(),
          lastName: _lastNameCtrl.text.trim(),
          role: _selectedRole,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedMeta =
        _kRoles.firstWhere((r) => r.role == _selectedRole);

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
                  ? Row(
                      children: [
                        Expanded(
                          flex: 40,
                          child: _WebRolePanel(
                            selectedMeta: selectedMeta,
                            selectedRole: _selectedRole,
                            onRoleChanged: (r) =>
                                setState(() => _selectedRole = r),
                          ),
                        ),
                        Expanded(
                          flex: 60,
                          child: _buildFormPanel(
                              isWeb: true,
                              loading: loading,
                              selectedMeta: selectedMeta),
                        ),
                      ],
                    )
                  : SafeArea(
                      child: _buildFormPanel(
                        isWeb: false,
                        loading: loading,
                        selectedMeta: selectedMeta,
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormPanel({
    required bool isWeb,
    required bool loading,
    required _RoleOption selectedMeta,
  }) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isWeb ? 56 : 24,
          vertical: 40,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!isWeb) _mobileHeader(selectedMeta),
              if (!isWeb) const SizedBox(height: 28),
              // Role picker — only shown on mobile (web has sidebar)
              if (!isWeb) ...[
                _label('Select role'),
                const SizedBox(height: 10),
                _mobileRolePicker(),
                const SizedBox(height: 24),
              ],
              _formCard(loading: loading, selectedMeta: selectedMeta),
              const SizedBox(height: 16),
              _loginPrompt(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mobileHeader(_RoleOption meta) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: meta.gradient),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: meta.accent.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(meta.icon, color: Colors.white, size: 30),
        ),
        const SizedBox(height: 18),
        Text(
          'Create Account',
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: _kTextPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Join the TransitOps fleet portal',
          style: GoogleFonts.outfit(
              fontSize: 14, color: _kTextSecondary),
        ),
      ],
    );
  }

  Widget _mobileRolePicker() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _kRoles.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.2,
      ),
      itemBuilder: (_, i) {
        final r = _kRoles[i];
        final active = _selectedRole == r.role;
        return GestureDetector(
          onTap: () => setState(() => _selectedRole = r.role),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color:
                  active ? r.accent.withValues(alpha: 0.10) : _kSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: active
                    ? r.accent.withValues(alpha: 0.5)
                    : _kBorder,
                width: active ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: r.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(r.icon, color: r.accent, size: 15),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    r.label,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color:
                          active ? r.accent : _kTextPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _formCard({
    required bool loading,
    required _RoleOption selectedMeta,
  }) {
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
              'Create your account',
              style: GoogleFonts.outfit(
                color: _kTextPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'All fields are required',
              style: GoogleFonts.outfit(
                  fontSize: 12, color: _kTextSecondary),
            ),
            const SizedBox(height: 24),
            // First Name and Last Name layout (Split on desktop/tablet, stacked on mobile)
            if (context.isDesktop)
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('First name'),
                        const SizedBox(height: 8),
                        _field(
                          ctrl: _firstNameCtrl,
                          focus: _firstNameFocus,
                          focused: _firstNameFocused,
                          hint: 'Alice',
                          icon: Icons.person_outline_rounded,
                          enabled: !loading,
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Last name'),
                        const SizedBox(height: 8),
                        _field(
                          ctrl: _lastNameCtrl,
                          focus: _lastNameFocus,
                          focused: _lastNameFocused,
                          hint: 'Smith',
                          icon: Icons.person_outline_rounded,
                          enabled: !loading,
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                      ],
                    ),
                  ),
                ],
              )
            else ...[
              _label('First name'),
              const SizedBox(height: 8),
              _field(
                ctrl: _firstNameCtrl,
                focus: _firstNameFocus,
                focused: _firstNameFocused,
                hint: 'Alice',
                icon: Icons.person_outline_rounded,
                enabled: !loading,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'First name is required' : null,
              ),
              const SizedBox(height: 16),
              _label('Last name'),
              const SizedBox(height: 8),
              _field(
                ctrl: _lastNameCtrl,
                focus: _lastNameFocus,
                focused: _lastNameFocused,
                hint: 'Smith',
                icon: Icons.person_outline_rounded,
                enabled: !loading,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Last name is required' : null,
              ),
            ],
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
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
                if (v.length < 6) return 'At least 6 characters';
                return null;
              },
            ),
            const SizedBox(height: 16),
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
              suffix: IconButton(
                icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 18,
                  color: _kTextSecondary,
                ),
                onPressed: () => setState(
                    () => _obscureConfirm = !_obscureConfirm),
              ),
              validator: (v) {
                if (v != _passCtrl.text) return 'Passwords do not match';
                return null;
              },
            ),
            const SizedBox(height: 28),
            _primaryBtn(
              label: 'Create account',
              loading: loading,
              onTap: loading ? null : _submit,
              accent: selectedMeta.accent,
              gradient: selectedMeta.gradient,
            ),
          ],
        ),
      ),
    );
  }

  Widget _loginPrompt() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Already have an account?  ',
            style: GoogleFonts.outfit(
                fontSize: 13, color: _kTextSecondary),
          ),
          GestureDetector(
            onTap: () => context.go(AppRouter.loginPath),
            child: Text(
              'Sign in',
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: _kAccentLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );

  // ─── Shared primitives ─────────────────────────────────────────────────────
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
        hintStyle:
            GoogleFonts.outfit(color: _kTextSecondary, fontSize: 14),
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
    Color accent = _kAccent,
    List<Color> gradient = const [_kAccent, _kAccentLight],
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: onTap != null
            ? [
                BoxShadow(
                  color: accent.withValues(alpha: 0.38),
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
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
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
            Expanded(
              child: Text(msg, style: GoogleFonts.outfit(fontSize: 13)),
            ),
          ],
        ),
        backgroundColor: _kError,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Web Role Panel (left sidebar shown only on desktop)
// ─────────────────────────────────────────────────────────────────────────────
class _WebRolePanel extends StatelessWidget {
  final _RoleOption selectedMeta;
  final UserRole selectedRole;
  final ValueChanged<UserRole> onRoleChanged;

  const _WebRolePanel({
    required this.selectedMeta,
    required this.selectedRole,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            selectedMeta.accent.withValues(alpha: 0.14),
            const Color(0xFF0F172A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: selectedMeta.gradient),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: selectedMeta.accent.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(Icons.local_shipping_rounded,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  'TransitOps',
                  style: GoogleFonts.outfit(
                    color: _kTextPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
            Text(
              'Choose your role',
              style: GoogleFonts.outfit(
                color: _kTextPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select the role that matches your position\nin the organisation.',
              style: GoogleFonts.outfit(
                color: _kTextSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            ..._kRoles.map(
              (r) => _WebRoleCard(
                option: r,
                selected: selectedRole == r.role,
                onTap: () => onRoleChanged(r.role),
              ),
            ),
            const Spacer(),
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: selectedMeta.accent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: selectedMeta.accent.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Icon(selectedMeta.icon,
                      color: selectedMeta.accent, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      selectedMeta.desc,
                      style: GoogleFonts.outfit(
                        color: _kTextPrimary,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WebRoleCard extends StatefulWidget {
  final _RoleOption option;
  final bool selected;
  final VoidCallback onTap;
  const _WebRoleCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_WebRoleCard> createState() => _WebRoleCardState();
}

class _WebRoleCardState extends State<_WebRoleCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.option;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: widget.selected
                ? r.accent.withValues(alpha: 0.12)
                : (_hover ? _kSurfaceRaised : _kSurface),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.selected
                  ? r.accent.withValues(alpha: 0.5)
                  : _kBorder,
              width: widget.selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: r.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(r.icon, color: r.accent, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.label,
                      style: GoogleFonts.outfit(
                        color: widget.selected ? r.accent : _kTextPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      r.desc,
                      style: GoogleFonts.outfit(
                        color: _kTextSecondary,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (widget.selected)
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: r.accent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check,
                      color: Colors.white, size: 11),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

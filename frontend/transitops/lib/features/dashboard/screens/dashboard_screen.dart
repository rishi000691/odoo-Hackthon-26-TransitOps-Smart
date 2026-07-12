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
const _kTextPrimary = Color(0xFFF8FAFC);
const _kTextSecondary = Color(0xFF94A3B8);
const _kBorder = Color(0xFF1E293B);

// ─── Role Metadata ────────────────────────────────────────────────────────────
class _RM {
  final Color accent;
  final List<Color> gradient;
  final IconData icon;
  final String label, tagline;
  const _RM({
    required this.accent,
    required this.gradient,
    required this.icon,
    required this.label,
    required this.tagline,
  });
}

const _kRM = <UserRole, _RM>{
  UserRole.fleetManager: _RM(
    accent: Color(0xFFF59E0B),
    gradient: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
    icon: Icons.admin_panel_settings_rounded,
    label: 'Fleet Manager',
    tagline: 'Full fleet access & dispatch control',
  ),
  UserRole.driver: _RM(
    accent: Color(0xFF10B981),
    gradient: [Color(0xFF10B981), Color(0xFF34D399)],
    icon: Icons.person_pin_rounded,
    label: 'Driver',
    tagline: 'Active dispatch, checklist & safety score',
  ),
  UserRole.safetyOfficer: _RM(
    accent: Color(0xFFF97316),
    gradient: [Color(0xFFF97316), Color(0xFFFB923C)],
    icon: Icons.shield_rounded,
    label: 'Safety Officer',
    tagline: 'Compliance monitoring & incident review',
  ),
  UserRole.financialAnalyst: _RM(
    accent: Color(0xFFA855F7),
    gradient: [Color(0xFFA855F7), Color(0xFFC084FC)],
    icon: Icons.bar_chart_rounded,
    label: 'Financial Analyst',
    tagline: 'Revenue, costs & ROI reporting',
  ),
};

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (ctx, state) {
        if (state is Unauthenticated) ctx.go(AppRouter.loginPath);
      },
      builder: (ctx, state) {
        if (state is! Authenticated) {
          return const Scaffold(
            backgroundColor: _kBg,
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF6366F1)),
            ),
          );
        }

        final user = state.user;
        final role = user.roles.isNotEmpty ? user.roles.first : UserRole.driver;
        final meta = _kRM[role]!;

        return Scaffold(
          backgroundColor: _kBg,
          body: FadeTransition(
            opacity: _fade,
            child: context.isDesktop
                ? _WebDashboard(user: user, role: role, meta: meta)
                : _MobileDashboard(user: user, role: role, meta: meta),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  WEB LAYOUT — fixed sidebar + scrollable content
// ─────────────────────────────────────────────────────────────────────────────
class _WebDashboard extends StatelessWidget {
  final dynamic user;
  final UserRole role;
  final _RM meta;
  const _WebDashboard({
    required this.user,
    required this.role,
    required this.meta,
  });

  @override
  Widget build(BuildContext context) {
    return _ContentArea(role: role, meta: meta, isWeb: true);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  MOBILE LAYOUT — collapsing AppBar + scroll body
// ─────────────────────────────────────────────────────────────────────────────
class _MobileDashboard extends StatelessWidget {
  final dynamic user;
  final UserRole role;
  final _RM meta;
  const _MobileDashboard({
    required this.user,
    required this.role,
    required this.meta,
  });

  @override
  Widget build(BuildContext context) {
    final email = user.email as String;
    final initials = email.isNotEmpty ? email[0].toUpperCase() : '?';

    return NestedScrollView(
      headerSliverBuilder: (_, innerBoxIsScrolled) => [
        SliverAppBar(
          expandedHeight: 160,
          floating: false,
          pinned: true,
          backgroundColor: _kSurface,
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Builder(
                builder: (ctx) => IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF87171).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: Color(0xFFF87171),
                      size: 18,
                    ),
                  ),
                  tooltip: 'Sign out',
                  onPressed: () =>
                      ctx.read<AuthBloc>().add(AuthLogoutRequested()),
                ),
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.parallax,
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [meta.accent.withValues(alpha: 0.15), _kBg],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: meta.gradient),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: meta.accent.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back',
                              style: GoogleFonts.outfit(
                                color: _kTextSecondary,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              email.split('@').first,
                              style: GoogleFonts.outfit(
                                color: _kTextPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _RoleBadge(meta: meta),
                ],
              ),
            ),
            title: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: meta.gradient),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Icon(
                    Icons.local_shipping_rounded,
                    color: Colors.white,
                    size: 13,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'TransitOps',
                  style: GoogleFonts.outfit(
                    color: _kTextPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      body: _ContentArea(role: role, meta: meta, isWeb: false),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Shared Content Area  (used by both web and mobile)
// ─────────────────────────────────────────────────────────────────────────────
class _ContentArea extends StatelessWidget {
  final UserRole role;
  final _RM meta;
  final bool isWeb;
  const _ContentArea({
    required this.role,
    required this.meta,
    required this.isWeb,
  });

  @override
  Widget build(BuildContext context) {
    final cols = context.statGridColumns;
    final hPad = isWeb ? 28.0 : 16.0;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionTitle('Overview'),
          const SizedBox(height: 14),
          _statsGrid(context, cols),
          const SizedBox(height: 28),
          ..._roleBody(context),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(
    t,
    style: GoogleFonts.outfit(
      color: _kTextPrimary,
      fontSize: 16,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
    ),
  );

  Widget _statsGrid(BuildContext ctx, int cols) {
    final stats = _statsForRole();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: isWeb ? 1.8 : 1.55,
      ),
      itemBuilder: (_, i) => _StatCard(stat: stats[i]),
    );
  }

  List<_Stat> _statsForRole() {
    switch (role) {
      case UserRole.fleetManager:
        return [
          _Stat(
            'Active Vehicles',
            '12 / 16',
            Icons.directions_car_rounded,
            const Color(0xFFF59E0B),
            '+2 this week',
          ),
          _Stat(
            'Utilization',
            '78.5%',
            Icons.query_stats_rounded,
            const Color(0xFF6366F1),
            '↑ 5.2%',
          ),
          _Stat(
            'Active Trips',
            '5',
            Icons.navigation_rounded,
            const Color(0xFF10B981),
            'Ongoing',
          ),
          _Stat(
            'Maintenance',
            '2 Active',
            Icons.build_circle_rounded,
            const Color(0xFFF97316),
            '1 scheduled',
          ),
        ];
      case UserRole.driver:
        return [
          _Stat(
            'Safety Score',
            '95.8',
            Icons.stars_rounded,
            const Color(0xFF10B981),
            'Top 10%',
          ),
          _Stat(
            'Trips Today',
            '1 Active',
            Icons.local_shipping_rounded,
            const Color(0xFF6366F1),
            'Dispatched',
          ),
          _Stat(
            'Distance',
            '420 km',
            Icons.straighten_rounded,
            const Color(0xFFF59E0B),
            'Planned',
          ),
          _Stat(
            'Fuel Logged',
            '42 L',
            Icons.local_gas_station_rounded,
            const Color(0xFFF97316),
            'Today',
          ),
        ];
      case UserRole.safetyOfficer:
        return [
          _Stat(
            'Overall Safety',
            '91.2%',
            Icons.verified_user_rounded,
            const Color(0xFFF97316),
            '↑ 1.4%',
          ),
          _Stat(
            'Alerts Today',
            '2 Issues',
            Icons.warning_amber_rounded,
            const Color(0xFFF87171),
            'Action needed',
          ),
          _Stat(
            'Exp. Licenses',
            '3',
            Icons.assignment_late_rounded,
            const Color(0xFFF59E0B),
            'Near expiry',
          ),
          _Stat(
            'Inspections',
            '100%',
            Icons.done_all_rounded,
            const Color(0xFF10B981),
            'All passed',
          ),
        ];
      case UserRole.financialAnalyst:
        return [
          _Stat(
            'Revenue',
            '\$12,400',
            Icons.monetization_on_rounded,
            const Color(0xFFA855F7),
            'This month',
          ),
          _Stat(
            'Fuel Costs',
            '\$3,150',
            Icons.local_gas_station_rounded,
            const Color(0xFFF97316),
            '25%',
          ),
          _Stat(
            'Maintenance',
            '\$1,800',
            Icons.construction_rounded,
            const Color(0xFFF59E0B),
            '14.5%',
          ),
          _Stat(
            'Net ROI',
            '14.9%',
            Icons.trending_up_rounded,
            const Color(0xFF10B981),
            '↑ 2.3%',
          ),
        ];
    }
  }

  List<Widget> _roleBody(BuildContext ctx) {
    switch (role) {
      case UserRole.fleetManager:
        return [
          _sectionTitle('Quick Actions'),
          const SizedBox(height: 14),
          if (isWeb)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.add_circle_outline_rounded,
                    title: 'Register Vehicle',
                    desc: 'Add registration, type, cargo cap & odometer.',
                    accent: meta.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.map_rounded,
                    title: 'Create Trip',
                    desc: 'Schedule a dispatch — driver + vehicle.',
                    accent: const Color(0xFF6366F1),
                  ),
                ),
              ],
            )
          else ...[
            _ActionCard(
              icon: Icons.add_circle_outline_rounded,
              title: 'Register Vehicle',
              desc: 'Add registration, type, cargo cap & odometer.',
              accent: meta.accent,
            ),
            const SizedBox(height: 10),
            _ActionCard(
              icon: Icons.map_rounded,
              title: 'Create Trip',
              desc: 'Schedule a dispatch — driver + vehicle.',
              accent: const Color(0xFF6366F1),
            ),
          ],
          const SizedBox(height: 28),
          _sectionTitle('Fleet Status'),
          const SizedBox(height: 14),
          if (isWeb) _webFleetTable() else _mobileFleetList(),
        ];

      case UserRole.driver:
        return [
          _sectionTitle("Today's Checklist"),
          const SizedBox(height: 14),
          const _ChecklistCard(
            items: [
              _CheckItem('Pre-trip exterior safety inspection', true),
              _CheckItem('Verify fuel log & odometer entry', true),
              _CheckItem('Record current trip distance', false),
              _CheckItem('Submit end-of-trip report', false),
            ],
          ),
          const SizedBox(height: 28),
          _sectionTitle('Active Dispatch'),
          const SizedBox(height: 14),
          _ActiveTripCard(accent: meta.accent, isWeb: isWeb),
        ];

      case UserRole.safetyOfficer:
        return [
          _sectionTitle('Recent Incidents'),
          const SizedBox(height: 14),
          if (isWeb)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _IncidentCard(
                    title: 'Speed Threshold Alert',
                    desc:
                        'Vehicle GJ-05-AB-1234 exceeded 90 km/h for 3 consecutive minutes.',
                    time: '2 hours ago',
                    level: 'High',
                    accent: const Color(0xFFF87171),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _IncidentCard(
                    title: 'Hard Braking',
                    desc:
                        'Driver Alex Mehta logged 2 abrupt deceleration events on NH-48.',
                    time: 'Yesterday, 4:32 PM',
                    level: 'Medium',
                    accent: const Color(0xFFF59E0B),
                  ),
                ),
              ],
            )
          else ...[
            _IncidentCard(
              title: 'Speed Threshold Alert',
              desc:
                  'Vehicle GJ-05-AB-1234 exceeded 90 km/h for 3 consecutive minutes.',
              time: '2 hours ago',
              level: 'High',
              accent: const Color(0xFFF87171),
            ),
            const SizedBox(height: 10),
            _IncidentCard(
              title: 'Hard Braking Detected',
              desc:
                  'Driver Alex Mehta logged 2 abrupt deceleration events on NH-48.',
              time: 'Yesterday, 4:32 PM',
              level: 'Medium',
              accent: const Color(0xFFF59E0B),
            ),
          ],
          const SizedBox(height: 28),
          _sectionTitle('License Expiry Tracker'),
          const SizedBox(height: 14),
          _LicenseRow(
            name: 'Rohan Patel',
            expiry: 'Expires in 12 days',
            color: const Color(0xFFF59E0B),
          ),
          _LicenseRow(
            name: 'Anita Sharma',
            expiry: 'Expires in 8 days',
            color: const Color(0xFFF97316),
          ),
          _LicenseRow(
            name: 'Dev Malhotra',
            expiry: 'Expires in 3 days',
            color: const Color(0xFFF87171),
          ),
        ];

      case UserRole.financialAnalyst:
        return [
          _sectionTitle('Expenditure Breakdown'),
          const SizedBox(height: 14),
          if (isWeb)
            Row(
              children: [
                Expanded(
                  child: _ExpenseRow(
                    label: 'Fuel',
                    amount: '\$3,150',
                    pct: 0.25,
                    accent: const Color(0xFFF97316),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ExpenseRow(
                    label: 'Maintenance',
                    amount: '\$1,800',
                    pct: 0.145,
                    accent: const Color(0xFFF59E0B),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ExpenseRow(
                    label: 'Insurance',
                    amount: '\$960',
                    pct: 0.077,
                    accent: const Color(0xFF6366F1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ExpenseRow(
                    label: 'Toll & Misc',
                    amount: '\$640',
                    pct: 0.052,
                    accent: const Color(0xFFA855F7),
                  ),
                ),
              ],
            )
          else ...[
            _ExpenseRow(
              label: 'Fuel Costs',
              amount: '\$3,150',
              pct: 0.25,
              accent: const Color(0xFFF97316),
            ),
            const SizedBox(height: 8),
            _ExpenseRow(
              label: 'Maintenance',
              amount: '\$1,800',
              pct: 0.145,
              accent: const Color(0xFFF59E0B),
            ),
            const SizedBox(height: 8),
            _ExpenseRow(
              label: 'Insurance',
              amount: '\$960',
              pct: 0.077,
              accent: const Color(0xFF6366F1),
            ),
            const SizedBox(height: 8),
            _ExpenseRow(
              label: 'Toll & Misc',
              amount: '\$640',
              pct: 0.052,
              accent: const Color(0xFFA855F7),
            ),
          ],
          const SizedBox(height: 28),
          _sectionTitle('Export'),
          const SizedBox(height: 14),
          _ActionCard(
            icon: Icons.download_for_offline_rounded,
            title: 'Export Financial Report (.CSV)',
            desc: 'Full summary: revenue, fuel, tolls & ROI breakdown.',
            accent: meta.accent,
          ),
        ];
    }
  }

  // ─── Fleet table for web ────────────────────────────────────────────────────
  Widget _webFleetTable() {
    final rows = [
      ('GJ-05-AB-1234', 'Truck', 'On Trip', const Color(0xFF10B981)),
      ('MH-12-CD-5678', 'Van', 'Available', const Color(0xFF6366F1)),
      ('DL-03-EF-9012', 'Truck', 'In Shop', const Color(0xFFF97316)),
      ('RJ-09-GH-3456', 'Sedan', 'Available', const Color(0xFF6366F1)),
    ];
    return Container(
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        children: [
          // Header row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: _kBorder)),
            ),
            child: Row(
              children: [
                _th('Registration', flex: 3),
                _th('Type', flex: 2),
                _th('Status', flex: 2),
              ],
            ),
          ),
          ...rows.map(
            (row) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: _kBorder)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.directions_car_rounded,
                          color: _kTextSecondary,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          row.$1,
                          style: GoogleFonts.outfit(
                            color: _kTextPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      row.$2,
                      style: GoogleFonts.outfit(
                        color: _kTextSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: row.$4.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        row.$3,
                        style: GoogleFonts.outfit(
                          color: row.$4,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _th(String label, {int flex = 1}) => Expanded(
    flex: flex,
    child: Text(
      label,
      style: GoogleFonts.outfit(
        color: _kTextSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      ),
    ),
  );

  Widget _mobileFleetList() {
    final rows = [
      ('GJ-05-AB-1234', 'On Trip', const Color(0xFF10B981)),
      ('MH-12-CD-5678', 'Available', const Color(0xFF6366F1)),
      ('DL-03-EF-9012', 'In Shop', const Color(0xFFF97316)),
      ('RJ-09-GH-3456', 'Available', const Color(0xFF6366F1)),
    ];
    return Column(
      children: rows
          .map((r) => _VehicleStatusRow(plate: r.$1, status: r.$2, color: r.$3))
          .toList(),
    );
  }
}

// ─── Role Badge ───────────────────────────────────────────────────────────────
class _RoleBadge extends StatelessWidget {
  final _RM meta;
  const _RoleBadge({required this.meta});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: meta.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: meta.accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(meta.icon, color: meta.accent, size: 11),
          const SizedBox(width: 5),
          Text(
            meta.label.toUpperCase(),
            style: GoogleFonts.outfit(
              color: meta.accent,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Shared sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _Stat {
  final String label, value, hint;
  final IconData icon;
  final Color color;
  const _Stat(this.label, this.value, this.icon, this.color, this.hint);
}

class _StatCard extends StatelessWidget {
  final _Stat stat;
  const _StatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: stat.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(stat.icon, color: stat.color, size: 16),
              ),
              Text(
                stat.hint,
                style: GoogleFonts.outfit(color: _kTextSecondary, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            stat.value,
            style: GoogleFonts.outfit(
              color: _kTextPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            stat.label,
            style: GoogleFonts.outfit(color: _kTextSecondary, fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatefulWidget {
  final IconData icon;
  final String title, desc;
  final Color accent;
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.desc,
    required this.accent,
  });

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () {},
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _hover ? widget.accent.withValues(alpha: 0.07) : _kSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hover ? widget.accent.withValues(alpha: 0.35) : _kBorder,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(widget.icon, color: widget.accent, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: GoogleFonts.outfit(
                        color: _kTextPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.desc,
                      style: GoogleFonts.outfit(
                        color: _kTextSecondary,
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: _hover ? widget.accent : _kTextSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VehicleStatusRow extends StatelessWidget {
  final String plate, status;
  final Color color;
  const _VehicleStatusRow({
    required this.plate,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.directions_car_rounded,
            color: _kTextSecondary,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              plate,
              style: GoogleFonts.outfit(
                color: _kTextPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status,
              style: GoogleFonts.outfit(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckItem {
  final String label;
  final bool done;
  const _CheckItem(this.label, this.done);
}

class _ChecklistCard extends StatelessWidget {
  final List<_CheckItem> items;
  const _ChecklistCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(
                  children: [
                    Icon(
                      item.done
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: item.done
                          ? const Color(0xFF10B981)
                          : _kTextSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.label,
                        style: GoogleFonts.outfit(
                          color: item.done ? _kTextSecondary : _kTextPrimary,
                          fontSize: 13,
                          decoration: item.done
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: _kTextSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ActiveTripCard extends StatelessWidget {
  final Color accent;
  final bool isWeb;
  const _ActiveTripCard({required this.accent, required this.isWeb});

  @override
  Widget build(BuildContext context) {
    final infoRows = [
      (Icons.trip_origin_rounded, 'Origin', 'Ahmedabad Logistics Hub'),
      (Icons.location_on_rounded, 'Destination', 'Mumbai Port Terminal 3'),
      (Icons.scale_rounded, 'Cargo Weight', '420 kg'),
      (Icons.straighten_rounded, 'Distance', '540 km planned'),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trip #1204',
                style: GoogleFonts.outfit(
                  color: _kTextPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Dispatched',
                  style: GoogleFonts.outfit(
                    color: accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: _kBorder, height: 1),
          const SizedBox(height: 14),
          if (isWeb)
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 4.0,
              mainAxisSpacing: 10,
              crossAxisSpacing: 16,
              children: infoRows
                  .map((r) => _TripInfoRow(r.$1, r.$2, r.$3))
                  .toList(),
            )
          else
            ...infoRows.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _TripInfoRow(r.$1, r.$2, r.$3),
              ),
            ),
        ],
      ),
    );
  }
}

class _TripInfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _TripInfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: _kTextSecondary, size: 15),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.outfit(color: _kTextSecondary, fontSize: 12),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.outfit(
              color: _kTextPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _IncidentCard extends StatelessWidget {
  final String title, desc, time, level;
  final Color accent;
  const _IncidentCard({
    required this.title,
    required this.desc,
    required this.time,
    required this.level,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.warning_amber_rounded, color: accent, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.outfit(
                          color: _kTextPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        level,
                        style: GoogleFonts.outfit(
                          color: accent,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  desc,
                  style: GoogleFonts.outfit(
                    color: _kTextSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  time,
                  style: GoogleFonts.outfit(
                    color: _kTextSecondary.withValues(alpha: 0.55),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LicenseRow extends StatelessWidget {
  final String name, expiry;
  final Color color;
  const _LicenseRow({
    required this.name,
    required this.expiry,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.badge_rounded, color: color, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.outfit(
                    color: _kTextPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  expiry,
                  style: GoogleFonts.outfit(color: color, fontSize: 11),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: _kTextSecondary, size: 18),
        ],
      ),
    );
  }
}

class _ExpenseRow extends StatelessWidget {
  final String label, amount;
  final double pct;
  final Color accent;
  const _ExpenseRow({
    required this.label,
    required this.amount,
    required this.pct,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.outfit(color: _kTextSecondary, fontSize: 12),
              ),
              Text(
                amount,
                style: GoogleFonts.outfit(
                  color: _kTextPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 4,
              backgroundColor: _kSurfaceRaised,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(pct * 100).toStringAsFixed(1)}% of revenue',
            style: GoogleFonts.outfit(
              color: accent,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

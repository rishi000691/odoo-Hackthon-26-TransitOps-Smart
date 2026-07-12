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

import 'package:transitops/features/vehicles/blocs/vehicle_bloc.dart';
import 'package:transitops/features/vehicles/blocs/vehicle_event.dart';
import 'package:transitops/features/vehicles/blocs/vehicle_state.dart';
import 'package:transitops/features/vehicles/models/vehicle_model.dart';
import 'package:transitops/features/drivers/blocs/driver_bloc.dart';
import 'package:transitops/features/drivers/blocs/driver_event.dart';
import 'package:transitops/features/drivers/blocs/driver_state.dart';
import 'package:transitops/features/drivers/models/driver_model.dart';
import 'package:transitops/features/trips/blocs/trip_bloc.dart';
import 'package:transitops/features/trips/blocs/trip_event.dart';
import 'package:transitops/features/trips/blocs/trip_state.dart';
import 'package:transitops/features/trips/models/trip_model.dart';
import 'package:transitops/features/reports/blocs/report_bloc.dart';
import 'package:transitops/features/reports/blocs/report_event.dart';
import 'package:transitops/features/reports/blocs/report_state.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────

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

    // Trigger initial data fetches
    context.read<ReportBloc>().add(const FetchReportData());
    context.read<VehicleBloc>().add(const FetchVehicles());
    context.read<DriverBloc>().add(const FetchDrivers());
    context.read<TripBloc>().add(const FetchTrips());
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
          return Scaffold(
            backgroundColor: context.kBg,
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF6366F1)),
            ),
          );
        }

        final user = state.user;
        final role = user.roles.isNotEmpty ? user.roles.first : UserRole.driver;
        final meta = _kRM[role]!;

        return Scaffold(
          backgroundColor: context.kBg,
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
    return _ContentArea(user: user, role: role, meta: meta, isWeb: true);
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
          backgroundColor: context.kSurface,
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
                    child: Icon(
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
                  colors: [meta.accent.withValues(alpha: 0.15), context.kBg],
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
                                color: context.kTextSecondary,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              email.split('@').first,
                              style: GoogleFonts.outfit(
                                color: context.kTextPrimary,
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
                  child: Icon(
                    Icons.local_shipping_rounded,
                    color: Colors.white,
                    size: 13,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'TransitOps',
                  style: GoogleFonts.outfit(
                    color: context.kTextPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      body: _ContentArea(user: user, role: role, meta: meta, isWeb: false),
    );
  }
}

class _IncidentData {
  final String title, desc, time, level;
  final Color color;
  const _IncidentData({
    required this.title,
    required this.desc,
    required this.time,
    required this.level,
    required this.color,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
//  Shared Content Area  (used by both web and mobile)
// ─────────────────────────────────────────────────────────────────────────────
class _ContentArea extends StatelessWidget {
  final dynamic user;
  final UserRole role;
  final _RM meta;
  final bool isWeb;
  const _ContentArea({
    required this.user,
    required this.role,
    required this.meta,
    required this.isWeb,
  });

  @override
  Widget build(BuildContext context) {
    final cols = context.statGridColumns;
    final hPad = isWeb ? 28.0 : 16.0;

    return BlocBuilder<ReportBloc, ReportState>(
      builder: (context, reportState) {
        return BlocBuilder<VehicleBloc, VehicleState>(
          builder: (context, vehicleState) {
            return BlocBuilder<DriverBloc, DriverState>(
              builder: (context, driverState) {
                return BlocBuilder<TripBloc, TripState>(
                  builder: (context, tripState) {
                    final isLoading =
                        reportState is ReportLoading ||
                        vehicleState is VehicleLoading ||
                        driverState is DriverLoading ||
                        tripState is TripLoading ||
                        reportState is ReportInitial ||
                        vehicleState is VehicleInitial ||
                        driverState is DriverInitial ||
                        tripState is TripInitial;

                    if (isLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 80),
                          child: CircularProgressIndicator(
                            color: Color(0xFF6366F1),
                          ),
                        ),
                      );
                    }

                    final Map<String, dynamic> kpis =
                        (reportState is ReportLoaded) ? reportState.kpis : {};
                    final List<Map<String, dynamic>> roiReport =
                        (reportState is ReportLoaded)
                        ? reportState.roiReport
                        : [];
                    final List<Vehicle> vehicles =
                        (vehicleState is VehiclesLoaded)
                        ? vehicleState.vehicles
                        : [];
                    final List<Driver> drivers = (driverState is DriversLoaded)
                        ? driverState.drivers
                        : [];
                    final List<Trip> trips = (tripState is TripsLoaded)
                        ? tripState.trips
                        : [];

                    return SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _sectionTitle(context, 'Overview'),
                          const SizedBox(height: 14),
                          _statsGrid(
                            context,
                            cols,
                            kpis,
                            roiReport,
                            drivers,
                            trips,
                          ),
                          const SizedBox(height: 28),
                          ..._roleBody(
                            context,
                            kpis,
                            roiReport,
                            vehicles,
                            drivers,
                            trips,
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _sectionTitle(BuildContext context, String t) => Text(
    t,
    style: GoogleFonts.outfit(
      color: context.kTextPrimary,
      fontSize: 16,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
    ),
  );

  Widget _statsGrid(
    BuildContext ctx,
    int cols,
    Map<String, dynamic> kpis,
    List<Map<String, dynamic>> roiReport,
    List<Driver> drivers,
    List<Trip> trips,
  ) {
    final stats = _statsForRole(kpis, roiReport, drivers, trips);
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

  List<_Stat> _statsForRole(
    Map<String, dynamic> kpis,
    List<Map<String, dynamic>> roiReport,
    List<Driver> drivers,
    List<Trip> trips,
  ) {
    switch (role) {
      case UserRole.fleetManager:
        final activeVeh = kpis['active_vehicles'] ?? 12;
        final availVeh = kpis['available_vehicles'] ?? 4;
        final maintVeh = kpis['vehicles_in_maintenance'] ?? 2;
        final totalVeh = activeVeh + availVeh + maintVeh;
        final util = (kpis['fleet_utilization_pct'] as num? ?? 78.5).toDouble();
        final activeTrips = kpis['active_trips'] ?? 5;
        final pendingTrips = kpis['pending_trips'] ?? 1;

        return [
          _Stat(
            'Active Vehicles',
            '$activeVeh / $totalVeh',
            Icons.directions_car_rounded,
            const Color(0xFFF59E0B),
            '+$availVeh available',
          ),
          _Stat(
            'Utilization',
            '${util.toStringAsFixed(1)}%',
            Icons.query_stats_rounded,
            const Color(0xFF6366F1),
            '↑ Live score',
          ),
          _Stat(
            'Active Trips',
            '$activeTrips',
            Icons.navigation_rounded,
            const Color(0xFF10B981),
            '$pendingTrips pending',
          ),
          _Stat(
            'Maintenance',
            '$maintVeh Active',
            Icons.build_circle_rounded,
            const Color(0xFFF97316),
            'Scheduled',
          ),
        ];

      case UserRole.driver:
        final nameToMatch = '${user.firstName} ${user.lastName}'
            .trim()
            .toLowerCase();
        Driver currentDriver = drivers.firstWhere(
          (d) => d.name.trim().toLowerCase() == nameToMatch,
          orElse: () => drivers.isNotEmpty
              ? drivers.first
              : Driver(
                  id: '',
                  name: '${user.firstName} ${user.lastName}',
                  licenseNumber: '',
                  licenseCategory: '',
                  licenseExpiryDate: DateTime.now(),
                  contactNumber: '',
                  safetyScore: 95.8,
                  status: DriverStatus.available,
                  createdAt: DateTime.now(),
                ),
        );

        Trip? activeTrip;
        for (final t in trips) {
          if (t.driverId == currentDriver.id &&
              t.status == TripStatus.dispatched) {
            activeTrip = t;
            break;
          }
        }
        if (activeTrip == null) {
          for (final t in trips) {
            if (t.driverId == currentDriver.id &&
                t.status == TripStatus.draft) {
              activeTrip = t;
              break;
            }
          }
        }

        final today = DateTime.now();
        final tripsTodayCount = trips
            .where(
              (t) =>
                  t.driverId == currentDriver.id &&
                  t.createdAt.year == today.year &&
                  t.createdAt.month == today.month &&
                  t.createdAt.day == today.day,
            )
            .length;

        final tripsText = activeTrip != null ? '1 Active' : '$tripsTodayCount';

        return [
          _Stat(
            'Safety Score',
            currentDriver.safetyScore.toStringAsFixed(1),
            Icons.stars_rounded,
            const Color(0xFF10B981),
            'Top 10%',
          ),
          _Stat(
            'Trips Today',
            tripsText,
            Icons.local_shipping_rounded,
            const Color(0xFF6366F1),
            activeTrip != null ? 'Dispatched' : 'Idle',
          ),
          _Stat(
            'Distance',
            '${(activeTrip?.plannedDistance ?? 420).toStringAsFixed(0)} km',
            Icons.straighten_rounded,
            const Color(0xFFF59E0B),
            'Planned',
          ),
          _Stat(
            'Fuel Logged',
            '${(activeTrip?.fuelConsumed ?? 42).toStringAsFixed(0)} L',
            Icons.local_gas_station_rounded,
            const Color(0xFFF97316),
            'Today',
          ),
        ];

      case UserRole.safetyOfficer:
        final avgSafety = drivers.isEmpty
            ? 91.2
            : drivers.map((d) => d.safetyScore).reduce((a, b) => a + b) /
                  drivers.length;

        final suspendedCount = drivers
            .where((d) => d.status == DriverStatus.suspended)
            .length;
        final maintVeh = kpis['vehicles_in_maintenance'] ?? 1;
        final alertsCount = suspendedCount + maintVeh;

        final expiringCount = drivers
            .where(
              (d) =>
                  d.licenseExpiryDate.difference(DateTime.now()).inDays <= 30,
            )
            .length;

        return [
          _Stat(
            'Overall Safety',
            '${avgSafety.toStringAsFixed(1)}%',
            Icons.verified_user_rounded,
            const Color(0xFFF97316),
            'Live Avg',
          ),
          _Stat(
            'Alerts Today',
            '$alertsCount Issues',
            Icons.warning_amber_rounded,
            const Color(0xFFF87171),
            'Action needed',
          ),
          _Stat(
            'Exp. Licenses',
            '$expiringCount',
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
        double totalRev = 0;
        double totalFuel = 0;
        double totalMaint = 0;
        double avgRoi = 0;

        if (roiReport.isNotEmpty) {
          for (final row in roiReport) {
            totalRev += double.parse(
              (row['revenue'] ?? row['total_revenue'] ?? 0.0).toString(),
            );
            totalFuel += double.parse(
              (row['fuel_cost'] ?? row['total_fuel_cost'] ?? 0.0).toString(),
            );
            totalMaint += double.parse(
              (row['maintenance_cost'] ?? row['total_maintenance_cost'] ?? 0.0)
                  .toString(),
            );
          }
          final roiSum = roiReport.fold<double>(
            0.0,
            (sum, row) =>
                sum +
                double.parse(
                  (row['roi'] ?? row['roi_percentage'] ?? 0.0).toString(),
                ),
          );
          avgRoi = roiSum / roiReport.length;
        } else {
          totalRev = 12400.0;
          totalFuel = 3150.0;
          totalMaint = 1800.0;
          avgRoi = 14.9;
        }

        return [
          _Stat(
            'Revenue',
            '\$${totalRev.toStringAsFixed(0)}',
            Icons.monetization_on_rounded,
            const Color(0xFFA855F7),
            'This month',
          ),
          _Stat(
            'Fuel Costs',
            '\$${totalFuel.toStringAsFixed(0)}',
            Icons.local_gas_station_rounded,
            const Color(0xFFF97316),
            'Live sum',
          ),
          _Stat(
            'Maintenance',
            '\$${totalMaint.toStringAsFixed(0)}',
            Icons.construction_rounded,
            const Color(0xFFF59E0B),
            'Live sum',
          ),
          _Stat(
            'Net ROI',
            '${avgRoi.toStringAsFixed(1)}%',
            Icons.trending_up_rounded,
            const Color(0xFF10B981),
            'Live Avg',
          ),
        ];
    }
  }

  List<Widget> _roleBody(
    BuildContext ctx,
    Map<String, dynamic> kpis,
    List<Map<String, dynamic>> roiReport,
    List<Vehicle> vehicles,
    List<Driver> drivers,
    List<Trip> trips,
  ) {
    switch (role) {
      case UserRole.fleetManager:
        return [
          _sectionTitle(ctx, 'Quick Actions'),
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
                    onTap: () => ctx.go(AppRouter.vehiclesPath),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.map_rounded,
                    title: 'Create Trip',
                    desc: 'Schedule a dispatch — driver + vehicle.',
                    accent: const Color(0xFF6366F1),
                    onTap: () => ctx.go(AppRouter.tripsPath),
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
              onTap: () => ctx.go(AppRouter.vehiclesPath),
            ),
            const SizedBox(height: 10),
            _ActionCard(
              icon: Icons.map_rounded,
              title: 'Create Trip',
              desc: 'Schedule a dispatch — driver + vehicle.',
              accent: const Color(0xFF6366F1),
              onTap: () => ctx.go(AppRouter.tripsPath),
            ),
          ],
          const SizedBox(height: 28),
          _sectionTitle(ctx, 'Fleet Status'),
          const SizedBox(height: 14),
          if (isWeb)
            _webFleetTable(ctx, vehicles)
          else
            _mobileFleetList(ctx, vehicles),
        ];

      case UserRole.driver:
        final nameToMatch = '${user.firstName} ${user.lastName}'
            .trim()
            .toLowerCase();
        Driver? currentDriver;
        for (final d in drivers) {
          if (d.name.trim().toLowerCase() == nameToMatch) {
            currentDriver = d;
            break;
          }
        }
        if (currentDriver == null && drivers.isNotEmpty) {
          currentDriver = drivers.first;
        }

        Trip? activeTrip;
        if (currentDriver != null) {
          for (final t in trips) {
            if (t.driverId == currentDriver.id &&
                t.status == TripStatus.dispatched) {
              activeTrip = t;
              break;
            }
          }
          if (activeTrip == null) {
            for (final t in trips) {
              if (t.driverId == currentDriver.id &&
                  t.status == TripStatus.draft) {
                activeTrip = t;
                break;
              }
            }
          }
        }

        return [
          _sectionTitle(ctx, "Today's Checklist"),
          const SizedBox(height: 14),
          _ChecklistCard(
            items: const [
              _CheckItem('Pre-trip exterior safety inspection', true),
              _CheckItem('Verify fuel log & odometer entry', true),
              _CheckItem('Record current trip distance', false),
              _CheckItem('Submit end-of-trip report', false),
            ],
          ),
          const SizedBox(height: 28),
          _sectionTitle(ctx, 'Active Dispatch'),
          const SizedBox(height: 14),
          _ActiveTripCard(
            activeTrip: activeTrip,
            accent: meta.accent,
            isWeb: isWeb,
          ),
        ];

      case UserRole.safetyOfficer:
        final incidents = <_IncidentData>[];
        for (final d in drivers) {
          if (d.status == DriverStatus.suspended) {
            incidents.add(
              _IncidentData(
                title: 'Driver Suspended',
                desc:
                    'Driver ${d.name} safety score fell to ${d.safetyScore.toStringAsFixed(1)} and status was updated to Suspended.',
                time: 'Active Alert',
                level: 'High',
                color: const Color(0xFFF87171),
              ),
            );
          }
        }
        final vehiclesInMaintenance = vehicles
            .where((v) => v.status == VehicleStatus.inShop)
            .toList();
        for (final v in vehiclesInMaintenance) {
          incidents.add(
            _IncidentData(
              title: 'Vehicle in Maintenance',
              desc:
                  'Vehicle ${v.registrationNumber} (${v.model}) is currently in maintenance shop.',
              time: 'Ongoing',
              level: 'Medium',
              color: const Color(0xFFF59E0B),
            ),
          );
        }
        if (incidents.isEmpty) {
          incidents.add(
            const _IncidentData(
              title: 'Safety Compliance Active',
              desc:
                  'All active drivers are compliant and fleet vehicles have passed safety inspections.',
              time: 'Just now',
              level: 'Normal',
              color: Color(0xFF10B981),
            ),
          );
        }

        final displayIncidents = incidents.take(2).toList();

        final sortedDrivers = List<Driver>.from(drivers)
          ..sort((a, b) => a.licenseExpiryDate.compareTo(b.licenseExpiryDate));
        final displayExpiryDrivers = sortedDrivers.take(3).toList();

        return [
          _sectionTitle(ctx, 'Recent Incidents'),
          const SizedBox(height: 14),
          if (isWeb)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (displayIncidents.isNotEmpty)
                  Expanded(
                    child: _IncidentCard(
                      title: displayIncidents[0].title,
                      desc: displayIncidents[0].desc,
                      time: displayIncidents[0].time,
                      level: displayIncidents[0].level,
                      accent: displayIncidents[0].color,
                    ),
                  ),
                if (displayIncidents.length > 1) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _IncidentCard(
                      title: displayIncidents[1].title,
                      desc: displayIncidents[1].desc,
                      time: displayIncidents[1].time,
                      level: displayIncidents[1].level,
                      accent: displayIncidents[1].color,
                    ),
                  ),
                ],
              ],
            )
          else ...[
            ...displayIncidents.map(
              (incident) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _IncidentCard(
                  title: incident.title,
                  desc: incident.desc,
                  time: incident.time,
                  level: incident.level,
                  accent: incident.color,
                ),
              ),
            ),
          ],
          const SizedBox(height: 28),
          _sectionTitle(ctx, 'License Expiry Tracker'),
          const SizedBox(height: 14),
          ...displayExpiryDrivers.map((d) {
            final days = d.licenseExpiryDate.difference(DateTime.now()).inDays;
            final expiryText = days < 0
                ? 'Expired ${-days} days ago'
                : 'Expires in $days days';
            final color = days <= 3
                ? const Color(0xFFF87171)
                : (days <= 15
                      ? const Color(0xFFF97316)
                      : const Color(0xFFF59E0B));
            return _LicenseRow(name: d.name, expiry: expiryText, color: color);
          }),
        ];

      case UserRole.financialAnalyst:
        double totalRev = 0;
        double totalFuel = 0;
        double totalMaint = 0;

        if (roiReport.isNotEmpty) {
          for (final row in roiReport) {
            totalRev += double.parse(
              (row['revenue'] ?? row['total_revenue'] ?? 0.0).toString(),
            );
            totalFuel += double.parse(
              (row['fuel_cost'] ?? row['total_fuel_cost'] ?? 0.0).toString(),
            );
            totalMaint += double.parse(
              (row['maintenance_cost'] ?? row['total_maintenance_cost'] ?? 0.0)
                  .toString(),
            );
          }
        } else {
          totalRev = 12400.0;
          totalFuel = 3150.0;
          totalMaint = 1800.0;
        }

        final fuelPct = totalRev == 0 ? 0.25 : (totalFuel / totalRev);
        final maintPct = totalRev == 0 ? 0.145 : (totalMaint / totalRev);
        const insurancePct = 0.077;
        const miscPct = 0.052;

        final insuranceCost = totalRev * insurancePct;
        final miscCost = totalRev * miscPct;

        return [
          _sectionTitle(ctx, 'Expenditure Breakdown'),
          const SizedBox(height: 14),
          if (isWeb)
            Row(
              children: [
                Expanded(
                  child: _ExpenseRow(
                    label: 'Fuel',
                    amount: '\$${totalFuel.toStringAsFixed(0)}',
                    pct: fuelPct,
                    accent: const Color(0xFFF97316),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ExpenseRow(
                    label: 'Maintenance',
                    amount: '\$${totalMaint.toStringAsFixed(0)}',
                    pct: maintPct,
                    accent: const Color(0xFFF59E0B),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ExpenseRow(
                    label: 'Insurance',
                    amount: '\$${insuranceCost.toStringAsFixed(0)}',
                    pct: insurancePct,
                    accent: const Color(0xFF6366F1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ExpenseRow(
                    label: 'Toll & Misc',
                    amount: '\$${miscCost.toStringAsFixed(0)}',
                    pct: miscPct,
                    accent: const Color(0xFFA855F7),
                  ),
                ),
              ],
            )
          else ...[
            _ExpenseRow(
              label: 'Fuel Costs',
              amount: '\$${totalFuel.toStringAsFixed(0)}',
              pct: fuelPct,
              accent: const Color(0xFFF97316),
            ),
            const SizedBox(height: 8),
            _ExpenseRow(
              label: 'Maintenance',
              amount: '\$${totalMaint.toStringAsFixed(0)}',
              pct: maintPct,
              accent: const Color(0xFFF59E0B),
            ),
            const SizedBox(height: 8),
            _ExpenseRow(
              label: 'Insurance',
              amount: '\$${insuranceCost.toStringAsFixed(0)}',
              pct: insurancePct,
              accent: const Color(0xFF6366F1),
            ),
            const SizedBox(height: 8),
            _ExpenseRow(
              label: 'Toll & Misc',
              amount: '\$${miscCost.toStringAsFixed(0)}',
              pct: miscPct,
              accent: const Color(0xFFA855F7),
            ),
          ],
          const SizedBox(height: 28),
          _sectionTitle(ctx, 'Export'),
          const SizedBox(height: 14),
          _ActionCard(
            icon: Icons.download_for_offline_rounded,
            title: 'Export Financial Report (.CSV)',
            desc: 'Full summary: revenue, fuel, tolls & ROI breakdown.',
            accent: meta.accent,
            onTap: () => ctx.go(AppRouter.reportsPath),
          ),
        ];
    }
  }

  // ─── Fleet table for web ────────────────────────────────────────────────────
  Widget _webFleetTable(BuildContext context, List<Vehicle> vehicles) {
    final displayVehicles = vehicles.take(4).toList();
    if (displayVehicles.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        child: Text(
          'No vehicles registered yet.',
          style: GoogleFonts.outfit(
            color: context.kTextSecondary,
            fontSize: 13,
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: context.kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.kBorder),
      ),
      child: Column(
        children: [
          // Header row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: context.kBorder)),
            ),
            child: Row(
              children: [
                _th(context, 'Registration', flex: 3),
                _th(context, 'Type', flex: 2),
                _th(context, 'Status', flex: 2),
              ],
            ),
          ),
          ...displayVehicles.map((row) {
            Color statusColor;
            switch (row.status) {
              case VehicleStatus.available:
                statusColor = const Color(0xFF6366F1);
                break;
              case VehicleStatus.onTrip:
                statusColor = const Color(0xFF10B981);
                break;
              case VehicleStatus.inShop:
                statusColor = const Color(0xFFF97316);
                break;
              case VehicleStatus.retired:
                statusColor = const Color(0xFFF87171);
                break;
            }
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: context.kBorder)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        Icon(
                          Icons.directions_car_rounded,
                          color: context.kTextSecondary,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          row.registrationNumber,
                          style: GoogleFonts.outfit(
                            color: context.kTextPrimary,
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
                      row.type,
                      style: GoogleFonts.outfit(
                        color: context.kTextSecondary,
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
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        row.status.value,
                        style: GoogleFonts.outfit(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _th(BuildContext context, String label, {int flex = 1}) => Expanded(
    flex: flex,
    child: Text(
      label,
      style: GoogleFonts.outfit(
        color: context.kTextSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      ),
    ),
  );

  Widget _mobileFleetList(BuildContext context, List<Vehicle> vehicles) {
    final displayVehicles = vehicles.take(4).toList();
    if (displayVehicles.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        child: Text(
          'No vehicles registered yet.',
          style: GoogleFonts.outfit(
            color: context.kTextSecondary,
            fontSize: 13,
          ),
        ),
      );
    }
    return Column(
      children: displayVehicles.map((v) {
        Color statusColor;
        switch (v.status) {
          case VehicleStatus.available:
            statusColor = const Color(0xFF6366F1);
            break;
          case VehicleStatus.onTrip:
            statusColor = const Color(0xFF10B981);
            break;
          case VehicleStatus.inShop:
            statusColor = const Color(0xFFF97316);
            break;
          case VehicleStatus.retired:
            statusColor = const Color(0xFFF87171);
            break;
        }
        return _VehicleStatusRow(
          plate: v.registrationNumber,
          status: v.status.value,
          color: statusColor,
        );
      }).toList(),
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
        color: context.kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.kBorder),
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
                style: GoogleFonts.outfit(
                  color: context.kTextSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            stat.value,
            style: GoogleFonts.outfit(
              color: context.kTextPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            stat.label,
            style: GoogleFonts.outfit(
              color: context.kTextSecondary,
              fontSize: 11,
            ),
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
  final VoidCallback? onTap;
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.desc,
    required this.accent,
    this.onTap,
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
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _hover
                ? widget.accent.withValues(alpha: 0.07)
                : context.kSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hover
                  ? widget.accent.withValues(alpha: 0.35)
                  : context.kBorder,
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
                        color: context.kTextPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.desc,
                      style: GoogleFonts.outfit(
                        color: context.kTextSecondary,
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
                color: _hover ? widget.accent : context.kTextSecondary,
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
        color: context.kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.kBorder),
      ),
      child: Row(
        children: [
          Icon(
            Icons.directions_car_rounded,
            color: context.kTextSecondary,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              plate,
              style: GoogleFonts.outfit(
                color: context.kTextPrimary,
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

class _ChecklistCard extends StatefulWidget {
  final List<_CheckItem> items;
  const _ChecklistCard({required this.items});

  @override
  State<_ChecklistCard> createState() => _ChecklistCardState();
}

class _ChecklistCardState extends State<_ChecklistCard> {
  late List<_CheckItem> _localItems;

  @override
  void initState() {
    super.initState();
    _localItems = List.from(widget.items);
  }

  @override
  void didUpdateWidget(covariant _ChecklistCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) {
      _localItems = List.from(widget.items);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.kBorder),
      ),
      child: Column(
        children: _localItems.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                setState(() {
                  _localItems[idx] = _CheckItem(item.label, !item.done);
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                child: Row(
                  children: [
                    Icon(
                      item.done
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: item.done
                          ? const Color(0xFF10B981)
                          : context.kTextSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.label,
                        style: GoogleFonts.outfit(
                          color: item.done
                              ? context.kTextSecondary
                              : context.kTextPrimary,
                          fontSize: 13,
                          decoration: item.done
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: context.kTextSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ActiveTripCard extends StatelessWidget {
  final Trip? activeTrip;
  final Color accent;
  final bool isWeb;
  const _ActiveTripCard({
    required this.activeTrip,
    required this.accent,
    required this.isWeb,
  });

  @override
  Widget build(BuildContext context) {
    if (activeTrip == null) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: context.kSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.kBorder),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_shipping_outlined,
                  color: context.kTextSecondary.withValues(alpha: 0.4),
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'No active dispatch assigned.',
                  style: GoogleFonts.outfit(
                    color: context.kTextSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Check back later or contact your fleet manager.',
                  style: GoogleFonts.outfit(
                    color: context.kTextSecondary.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final infoRows = [
      (Icons.trip_origin_rounded, 'Origin', activeTrip!.source),
      (Icons.location_on_rounded, 'Destination', activeTrip!.destination),
      (
        Icons.scale_rounded,
        'Cargo Weight',
        '${activeTrip!.cargoWeight.toStringAsFixed(0)} kg',
      ),
      (
        Icons.straighten_rounded,
        'Distance',
        '${activeTrip!.plannedDistance.toStringAsFixed(0)} km planned',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trip #${activeTrip!.id.length > 8 ? activeTrip!.id.substring(0, 8).toUpperCase() : activeTrip!.id}',
                style: GoogleFonts.outfit(
                  color: context.kTextPrimary,
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
                  activeTrip!.status.value,
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
          Divider(color: context.kBorder, height: 1),
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
        Icon(icon, color: context.kTextSecondary, size: 15),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.outfit(
            color: context.kTextSecondary,
            fontSize: 12,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.outfit(
              color: context.kTextPrimary,
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
        color: context.kSurface,
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
                          color: context.kTextPrimary,
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
                    color: context.kTextSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  time,
                  style: GoogleFonts.outfit(
                    color: context.kTextSecondary.withValues(alpha: 0.55),
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
        color: context.kSurface,
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
                    color: context.kTextPrimary,
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
          Icon(
            Icons.chevron_right_rounded,
            color: context.kTextSecondary,
            size: 18,
          ),
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
        color: context.kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.outfit(
                  color: context.kTextSecondary,
                  fontSize: 12,
                ),
              ),
              Text(
                amount,
                style: GoogleFonts.outfit(
                  color: context.kTextPrimary,
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
              backgroundColor: context.kSurfaceRaised,
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

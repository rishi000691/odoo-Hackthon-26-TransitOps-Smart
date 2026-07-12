import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:transitops/core/constants/enums.dart';
import 'package:transitops/core/extensions/context_extension.dart';
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

class NavigationItem {
  final Widget icon;
  final Widget selectedIcon;
  final String label;

  const NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

class ResponsiveNavigationLayout extends StatelessWidget {
  final Widget child;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationItem> items;

  const ResponsiveNavigationLayout({
    super.key,
    required this.child,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.items,
  });

  String _getTitleForIndex(int index) {
    switch (index) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Vehicles';
      case 2:
        return 'Drivers';
      case 3:
        return 'Trips';
      case 4:
        return 'Maintenance';
      case 5:
        return 'Reports';
      default:
        return 'TransitOps';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
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

        if (!context.isDesktop) {
          return Scaffold(
            backgroundColor: _kBg,
            body: child,
            bottomNavigationBar: NavigationBar(
              backgroundColor: _kSurface,
              indicatorColor: meta.accent.withValues(alpha: 0.12),
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              destinations: items.map((item) {
                return NavigationDestination(
                  icon: item.icon,
                  selectedIcon: IconTheme(
                    data: IconThemeData(color: meta.accent),
                    child: item.selectedIcon,
                  ),
                  label: item.label,
                );
              }).toList(),
            ),
          );
        }

        return Scaffold(
          backgroundColor: _kBg,
          body: Row(
            children: [
              _Sidebar(
                meta: meta,
                email: user.email,
                selectedIndex: selectedIndex,
                onDestinationSelected: onDestinationSelected,
              ),
              Expanded(
                child: Column(
                  children: [
                    _WebTopBar(
                      email: user.email,
                      meta: meta,
                      title: _getTitleForIndex(selectedIndex),
                    ),
                    Expanded(
                      child: child,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Sidebar ──────────────────────────────────────────────────────────────────
class _Sidebar extends StatelessWidget {
  final _RM meta;
  final String email;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const _Sidebar({
    required this.meta,
    required this.email,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final navItems = [
      (Icons.dashboard_rounded, 'Dashboard'),
      (Icons.directions_car_rounded, 'Vehicles'),
      (Icons.person_pin_rounded, 'Drivers'),
      (Icons.navigation_rounded, 'Trips'),
      (Icons.build_circle_rounded, 'Maintenance'),
      (Icons.bar_chart_rounded, 'Reports'),
    ];

    return Container(
      width: 240,
      color: _kSurface,
      child: Column(
        children: [
          // Brand
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: _kBorder)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: meta.gradient),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.local_shipping_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'TransitOps',
                  style: GoogleFonts.outfit(
                    color: _kTextPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          // Nav items
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 8),
                    child: Text(
                      'MENU',
                      style: GoogleFonts.outfit(
                        color: _kTextSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  for (int i = 0; i < navItems.length; i++)
                    _NavTile(
                      icon: navItems[i].$1,
                      label: navItems[i].$2,
                      active: selectedIndex == i,
                      accent: meta.accent,
                      onTap: () => onDestinationSelected(i),
                    ),
                ],
              ),
            ),
          ),
          // User card at bottom
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: _kBorder)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: meta.gradient),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      email.isNotEmpty ? email[0].toUpperCase() : '?',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        email.split('@').first,
                        style: GoogleFonts.outfit(
                          color: _kTextPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        email,
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
                IconButton(
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFF87171),
                    size: 18,
                  ),
                  tooltip: 'Sign out',
                  onPressed: () =>
                      context.read<AuthBloc>().add(AuthLogoutRequested()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Color accent;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.label,
    required this.active,
    required this.accent,
    required this.onTap,
  });

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> {
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
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: widget.active
                ? widget.accent.withValues(alpha: 0.12)
                : (_hover ? _kSurfaceRaised : Colors.transparent),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 18,
                color: widget.active
                    ? widget.accent
                    : (_hover ? _kTextPrimary : _kTextSecondary),
              ),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: GoogleFonts.outfit(
                  color: widget.active
                      ? widget.accent
                      : (_hover ? _kTextPrimary : _kTextSecondary),
                  fontSize: 14,
                  fontWeight: widget.active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Web Top Bar ──────────────────────────────────────────────────────────────
class _WebTopBar extends StatelessWidget {
  final String email;
  final _RM meta;
  final String title;

  const _WebTopBar({
    required this.email,
    required this.meta,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: _kSurface,
        border: Border(bottom: BorderSide(color: _kBorder)),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              color: _kTextPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          // Role badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: meta.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: meta.accent.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(meta.icon, color: meta.accent, size: 13),
                const SizedBox(width: 6),
                Text(
                  meta.label.toUpperCase(),
                  style: GoogleFonts.outfit(
                    color: meta.accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Notification placeholder
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _kSurfaceRaised,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: _kTextSecondary,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

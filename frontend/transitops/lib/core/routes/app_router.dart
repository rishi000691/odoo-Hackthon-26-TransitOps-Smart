import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/authentication/screens/login_screen.dart';
import '../../features/authentication/screens/register_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/vehicles/screens/vehicles_screen.dart';
import '../../features/drivers/screens/drivers_screen.dart';
import '../../features/trips/screens/trips_screen.dart';
import '../../features/maintenance/screens/maintenance_screen.dart';
import '../../features/reports/screens/reports_screen.dart';
import '../services/service_locator.dart';
import '../../features/authentication/repositories/auth_repository.dart';
import '../widgets/responsive_navigation_layout.dart';

class AppRouter {
  AppRouter._();

  static const String loginPath = '/login';
  static const String registerPath = '/register';
  static const String dashboardPath = '/dashboard';
  static const String vehiclesPath = '/vehicles';
  static const String driversPath = '/drivers';
  static const String tripsPath = '/trips';
  static const String maintenancePath = '/maintenance';
  static const String reportsPath = '/reports';

  static final GoRouter router = GoRouter(
    initialLocation: loginPath,
    routes: [
      GoRoute(
        path: loginPath,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: registerPath,
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          int currentIndex = 0;
          if (state.uri.path.startsWith(vehiclesPath)) {
            currentIndex = 1;
          } else if (state.uri.path.startsWith(driversPath)) {
            currentIndex = 2;
          } else if (state.uri.path.startsWith(tripsPath)) {
            currentIndex = 3;
          } else if (state.uri.path.startsWith(maintenancePath)) {
            currentIndex = 4;
          } else if (state.uri.path.startsWith(reportsPath)) {
            currentIndex = 5;
          }

          return ResponsiveNavigationLayout(
            selectedIndex: currentIndex,
            onDestinationSelected: (index) {
              switch (index) {
                case 0:
                  context.go(dashboardPath);
                  break;
                case 1:
                  context.go(vehiclesPath);
                  break;
                case 2:
                  context.go(driversPath);
                  break;
                case 3:
                  context.go(tripsPath);
                  break;
                case 4:
                  context.go(maintenancePath);
                  break;
                case 5:
                  context.go(reportsPath);
                  break;
              }
            },
            items: const [
              NavigationItem(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              NavigationItem(
                icon: Icon(Icons.directions_bus_outlined),
                selectedIcon: Icon(Icons.directions_bus),
                label: 'Vehicles',
              ),
              NavigationItem(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: 'Drivers',
              ),
              NavigationItem(
                icon: Icon(Icons.navigation_outlined),
                selectedIcon: Icon(Icons.navigation),
                label: 'Trips',
              ),
              NavigationItem(
                icon: Icon(Icons.build_circle_outlined),
                selectedIcon: Icon(Icons.build_circle),
                label: 'Maintenance',
              ),
              NavigationItem(
                icon: Icon(Icons.bar_chart_outlined),
                selectedIcon: Icon(Icons.bar_chart),
                label: 'Reports',
              ),
            ],
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: dashboardPath,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: vehiclesPath,
            builder: (context, state) => const VehiclesScreen(),
          ),
          GoRoute(
            path: driversPath,
            builder: (context, state) => const DriversScreen(),
          ),
          GoRoute(
            path: tripsPath,
            builder: (context, state) => const TripsScreen(),
          ),
          GoRoute(
            path: maintenancePath,
            builder: (context, state) => const MaintenanceScreen(),
          ),
          GoRoute(
            path: reportsPath,
            builder: (context, state) => const ReportsScreen(),
          ),
        ],
      ),
    ],
    // Redirect logic to guard paths based on session state
    redirect: (context, state) async {
      final authRepo = locator<AuthRepository>();
      final loggedIn = await authRepo.isLoggedIn();

      final goingToLogin = state.matchedLocation == loginPath;
      final goingToRegister = state.matchedLocation == registerPath;

      if (!loggedIn) {
        // If not logged in, force navigation to /login unless going to /register
        if (!goingToLogin && !goingToRegister) {
          return loginPath;
        }
      } else {
        // If logged in, block /login and /register, redirecting to /dashboard
        if (goingToLogin || goingToRegister) {
          return dashboardPath;
        }
      }

      return null;
    },
  );
}

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
import '../constants/enums.dart';

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
          return ResponsiveNavigationLayout(
            currentPath: state.uri.path,
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

        // Dynamic role-based route guarding
        final user = await authRepo.getCurrentUser();
        if (user != null) {
          final role = user.roles.isNotEmpty ? user.roles.first : UserRole.driver;
          final path = state.matchedLocation;

          if (path == vehiclesPath && role != UserRole.fleetManager) {
            return dashboardPath;
          }
          if (path == driversPath && role != UserRole.safetyOfficer) {
            return dashboardPath;
          }
          if (path == tripsPath && role != UserRole.driver) {
            return dashboardPath;
          }
          if (path == maintenancePath && role != UserRole.fleetManager) {
            return dashboardPath;
          }
          if (path == reportsPath && role != UserRole.fleetManager && role != UserRole.financialAnalyst) {
            return dashboardPath;
          }
        }
      }

      return null;
    },
  );
}

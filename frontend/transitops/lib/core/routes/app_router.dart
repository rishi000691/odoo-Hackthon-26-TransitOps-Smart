import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/authentication/screens/login_screen.dart';
import '../../features/authentication/screens/register_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
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

  static final GoRouter router = GoRouter(
    initialLocation: loginPath,
    routes: [
      GoRoute(
        path: loginPath,
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          int currentIndex = 0;
          if (state.uri.path.startsWith(vehiclesPath)) {
            currentIndex = 1;
          } else if (state.uri.path.startsWith(driversPath)) {
            currentIndex = 2;
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
            builder: (context, state) => Scaffold(
              appBar: AppBar(title: const Text('Vehicles')),
              body: const Center(child: Text('Vehicles Screen Placeholder')),
            ),
          ),
          GoRoute(
            path: driversPath,
            builder: (context, state) => Scaffold(
              appBar: AppBar(title: const Text('Drivers')),
              body: const Center(child: Text('Drivers Screen Placeholder')),
            ),
          ),
        ],
      ),
    ],
    // Redirect logic stub
    redirect: (context, state) {
      return null;
    },
  );
}

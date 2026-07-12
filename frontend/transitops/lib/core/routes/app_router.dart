import 'package:go_router/go_router.dart';
import '../../features/authentication/screens/login_screen.dart';
import '../../features/authentication/screens/register_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../services/service_locator.dart';
import '../../features/authentication/repositories/auth_repository.dart';

class AppRouter {
  AppRouter._();

  static const String loginPath = '/login';
  static const String registerPath = '/register';
  static const String dashboardPath = '/dashboard';

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
      GoRoute(
        path: dashboardPath,
        builder: (context, state) => const DashboardScreen(),
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

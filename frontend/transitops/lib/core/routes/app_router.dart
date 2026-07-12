import 'package:go_router/go_router.dart';
import '../../features/authentication/screens/login_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';

class AppRouter {
  AppRouter._();

  static const String loginPath = '/login';
  static const String dashboardPath = '/dashboard';

  static final GoRouter router = GoRouter(
    initialLocation: loginPath,
    routes: [
      GoRoute(
        path: loginPath,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: dashboardPath,
        builder: (context, state) => const DashboardScreen(),
      ),
    ],
    // Redirect logic stub (could be coupled with AuthBloc authentication status)
    redirect: (context, state) {
      // In the future, read AuthState to redirect automatically:
      // If unauthenticated and not on /login -> redirect to /login
      // If authenticated and on /login -> redirect to /dashboard
      return null;
    },
  );
}

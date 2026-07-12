import 'package:flutter/material.dart';
import 'core/config/app_config.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize App Configuration (Defaulting to Dev Environment)
  AppConfig.initialize(
    const AppConfig(
      environment: AppEnvironment.dev,
      apiBaseUrl: 'https://api.transitops.smart/v1',
    ),
  );

  // Set up dependency injection
  await setupLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TransitOps',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode:
          ThemeMode.system, // Automatically matches platform light/dark modes
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}

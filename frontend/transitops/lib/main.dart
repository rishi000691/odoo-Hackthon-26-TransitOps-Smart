import 'package:flutter/material.dart';
import 'core/config/app_config.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize App Configuration (Defaulting to Dev Environment)
  AppConfig.initialize(
    const AppConfig(
      environment: AppEnvironment.dev,
      apiBaseUrl: 'https://api.transitops.smart/v1',
    ),
  );

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
      themeMode: ThemeMode.system, // Automatically matches platform light/dark modes
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}

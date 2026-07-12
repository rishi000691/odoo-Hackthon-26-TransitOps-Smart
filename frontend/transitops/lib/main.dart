import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/config/app_config.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/service_locator.dart';
import 'features/authentication/blocs/auth_bloc.dart';
import 'features/authentication/blocs/auth_event.dart';
import 'features/authentication/repositories/auth_repository.dart';

import 'features/vehicles/blocs/vehicle_bloc.dart';
import 'features/vehicles/repositories/vehicle_repository.dart';
import 'features/drivers/blocs/driver_bloc.dart';
import 'features/drivers/repositories/driver_repository.dart';
import 'features/trips/blocs/trip_bloc.dart';
import 'features/trips/repositories/trip_repository.dart';
import 'features/maintenance/blocs/maintenance_bloc.dart';
import 'features/maintenance/repositories/maintenance_repository.dart';
import 'features/expenses/blocs/expense_bloc.dart';
import 'features/expenses/repositories/expense_repository.dart';
import 'features/reports/blocs/report_bloc.dart';
import 'features/reports/repositories/report_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize App Configuration (Defaulting to Dev Environment)
  AppConfig.initialize(
    const AppConfig(
      environment: AppEnvironment.dev,
      apiBaseUrl: 'http://localhost:5005/api/v1',
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
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) =>
              AuthBloc(authRepository: locator<AuthRepository>())
                ..add(AuthCheckRequested()),
        ),
        BlocProvider<VehicleBloc>(
          create: (context) =>
              VehicleBloc(vehicleRepository: locator<VehicleRepository>()),
        ),
        BlocProvider<DriverBloc>(
          create: (context) =>
              DriverBloc(driverRepository: locator<DriverRepository>()),
        ),
        BlocProvider<TripBloc>(
          create: (context) =>
              TripBloc(tripRepository: locator<TripRepository>()),
        ),
        BlocProvider<MaintenanceBloc>(
          create: (context) =>
              MaintenanceBloc(maintenanceRepository: locator<MaintenanceRepository>()),
        ),
        BlocProvider<ExpenseBloc>(
          create: (context) =>
              ExpenseBloc(expenseRepository: locator<ExpenseRepository>()),
        ),
        BlocProvider<ReportBloc>(
          create: (context) =>
              ReportBloc(reportRepository: locator<ReportRepository>()),
        ),
      ],
      child: MaterialApp.router(
        title: 'TransitOps',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode:
            ThemeMode.system, // Automatically matches platform light/dark modes
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

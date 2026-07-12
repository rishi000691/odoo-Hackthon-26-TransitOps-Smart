import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:transitops/core/config/app_config.dart';
import 'package:transitops/core/storage/secure_storage_service.dart';
import 'package:transitops/core/network/api_client.dart';
import 'package:transitops/core/theme/theme_cubit.dart';

// Repositories
import 'package:transitops/features/authentication/repositories/auth_repository.dart';
import 'package:transitops/features/vehicles/repositories/vehicle_repository.dart';
import 'package:transitops/features/drivers/repositories/driver_repository.dart';
import 'package:transitops/features/trips/repositories/trip_repository.dart';
import 'package:transitops/features/maintenance/repositories/maintenance_repository.dart';
import 'package:transitops/features/expenses/repositories/expense_repository.dart';
import 'package:transitops/features/reports/repositories/report_repository.dart';

final GetIt locator = GetIt.instance;

Future<void> setupLocator() async {
  // Secure Storage
  locator.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(),
  );

  // Theme Cubit — registered here so it survives navigation and is accessible
  // from both MaterialApp (for themeMode) and ResponsiveNavigationLayout (toggle).
  locator.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(storage: locator<SecureStorageService>()),
  );

  // Dio Client & Custom ApiClient wrapper
  locator.registerLazySingleton<Dio>(() => Dio());
  locator.registerLazySingleton<ApiClient>(
    () => ApiClient(
      dio: locator<Dio>(),
      secureStorage: locator<SecureStorageService>(),
      baseUrl: AppConfig.instance.apiBaseUrl,
    ),
  );

  // Register Repositories
  locator.registerLazySingleton<AuthRepository>(
    () => AuthRepository(apiClient: locator<ApiClient>()),
  );
  locator.registerLazySingleton<VehicleRepository>(
    () => VehicleRepository(apiClient: locator<ApiClient>()),
  );
  locator.registerLazySingleton<DriverRepository>(
    () => DriverRepository(apiClient: locator<ApiClient>()),
  );
  locator.registerLazySingleton<TripRepository>(
    () => TripRepository(apiClient: locator<ApiClient>()),
  );
  locator.registerLazySingleton<MaintenanceRepository>(
    () => MaintenanceRepository(apiClient: locator<ApiClient>()),
  );
  locator.registerLazySingleton<ExpenseRepository>(
    () => ExpenseRepository(apiClient: locator<ApiClient>()),
  );
  locator.registerLazySingleton<ReportRepository>(
    () => ReportRepository(apiClient: locator<ApiClient>()),
  );
}

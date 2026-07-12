import 'package:transitops/core/network/api_response.dart';
import 'package:transitops/features/drivers/models/driver_model.dart';

abstract class DriverState {
  const DriverState();
}

class DriverInitial extends DriverState {}

class DriverLoading extends DriverState {}

class DriversLoaded extends DriverState {
  final List<Driver> drivers;
  final ApiMeta? meta;

  const DriversLoaded(this.drivers, this.meta);
}

class DriverDetailLoaded extends DriverState {
  final Driver driver;

  const DriverDetailLoaded(this.driver);
}

class DriverOperationSuccess extends DriverState {
  final String message;

  const DriverOperationSuccess(this.message);
}

class DriverError extends DriverState {
  final String message;

  const DriverError(this.message);
}

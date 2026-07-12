import 'package:transitops/core/network/api_response.dart';
import 'package:transitops/features/vehicles/models/vehicle_model.dart';

abstract class VehicleState {
  const VehicleState();
}

class VehicleInitial extends VehicleState {}

class VehicleLoading extends VehicleState {}

class VehiclesLoaded extends VehicleState {
  final List<Vehicle> vehicles;
  final ApiMeta? meta;

  const VehiclesLoaded(this.vehicles, this.meta);
}

class VehicleDetailLoaded extends VehicleState {
  final Vehicle vehicle;

  const VehicleDetailLoaded(this.vehicle);
}

class VehicleOperationSuccess extends VehicleState {
  final String message;

  const VehicleOperationSuccess(this.message);
}

class VehicleError extends VehicleState {
  final String message;

  const VehicleError(this.message);
}

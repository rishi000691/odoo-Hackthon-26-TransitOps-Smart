abstract class VehicleEvent {
  const VehicleEvent();
}

class FetchVehicles extends VehicleEvent {
  final String? type;
  final String? status;
  final String? region;
  final int? page;
  final int? limit;

  const FetchVehicles({
    this.type,
    this.status,
    this.region,
    this.page,
    this.limit,
  });
}

class FetchVehicleDetails extends VehicleEvent {
  final String id;
  const FetchVehicleDetails(this.id);
}

class AddVehicle extends VehicleEvent {
  final String registrationNumber;
  final String model;
  final String type;
  final double maxLoadCapacity;
  final double currentOdometer;
  final double acquisitionCost;

  const AddVehicle({
    required this.registrationNumber,
    required this.model,
    required this.type,
    required this.maxLoadCapacity,
    required this.currentOdometer,
    required this.acquisitionCost,
  });
}

class UpdateVehicle extends VehicleEvent {
  final String id;
  final Map<String, dynamic> fields;

  const UpdateVehicle({required this.id, required this.fields});
}

class DeleteVehicle extends VehicleEvent {
  final String id;
  const DeleteVehicle(this.id);
}

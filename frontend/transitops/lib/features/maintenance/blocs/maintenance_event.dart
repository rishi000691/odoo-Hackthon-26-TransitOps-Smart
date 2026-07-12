abstract class MaintenanceEvent {
  const MaintenanceEvent();
}

class FetchMaintenanceLogs extends MaintenanceEvent {
  final String? status;
  final String? vehicleId;

  const FetchMaintenanceLogs({this.status, this.vehicleId});
}

class CreateMaintenanceLog extends MaintenanceEvent {
  final String vehicleId;
  final String description;
  final double cost;

  const CreateMaintenanceLog({
    required this.vehicleId,
    required this.description,
    required this.cost,
  });
}

class CloseMaintenanceLog extends MaintenanceEvent {
  final String id;
  final double cost;

  const CloseMaintenanceLog({
    required this.id,
    required this.cost,
  });
}

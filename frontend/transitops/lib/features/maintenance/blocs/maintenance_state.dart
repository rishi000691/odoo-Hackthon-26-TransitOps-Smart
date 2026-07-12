import 'package:transitops/core/network/api_response.dart';
import 'package:transitops/features/maintenance/models/maintenance_log_model.dart';

abstract class MaintenanceState {
  const MaintenanceState();
}

class MaintenanceInitial extends MaintenanceState {}

class MaintenanceLoading extends MaintenanceState {}

class MaintenanceLogsLoaded extends MaintenanceState {
  final List<MaintenanceLog> logs;
  final ApiMeta? meta;

  const MaintenanceLogsLoaded(this.logs, this.meta);
}

class MaintenanceDetailLoaded extends MaintenanceState {
  final MaintenanceLog log;

  const MaintenanceDetailLoaded(this.log);
}

class MaintenanceOperationSuccess extends MaintenanceState {
  final String message;

  const MaintenanceOperationSuccess(this.message);
}

class MaintenanceError extends MaintenanceState {
  final String message;

  const MaintenanceError(this.message);
}

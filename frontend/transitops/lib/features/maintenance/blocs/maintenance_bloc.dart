import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transitops/features/maintenance/repositories/maintenance_repository.dart';
import 'maintenance_event.dart';
import 'maintenance_state.dart';

class MaintenanceBloc extends Bloc<MaintenanceEvent, MaintenanceState> {
  final MaintenanceRepository maintenanceRepository;

  MaintenanceBloc({required this.maintenanceRepository}) : super(MaintenanceInitial()) {
    on<FetchMaintenanceLogs>(_onFetchMaintenanceLogs);
    on<CreateMaintenanceLog>(_onCreateMaintenanceLog);
    on<CloseMaintenanceLog>(_onCloseMaintenanceLog);
  }

  Future<void> _onFetchMaintenanceLogs(
    FetchMaintenanceLogs event,
    Emitter<MaintenanceState> emit,
  ) async {
    emit(MaintenanceLoading());
    try {
      final apiResponse = await maintenanceRepository.getMaintenanceLogs(
        status: event.status,
        vehicleId: event.vehicleId,
      );
      emit(MaintenanceLogsLoaded(apiResponse.data ?? [], apiResponse.meta));
    } catch (e) {
      emit(MaintenanceError(e.toString()));
    }
  }

  Future<void> _onCreateMaintenanceLog(
    CreateMaintenanceLog event,
    Emitter<MaintenanceState> emit,
  ) async {
    emit(MaintenanceLoading());
    try {
      await maintenanceRepository.createMaintenanceLog(
        vehicleId: event.vehicleId,
        description: event.description,
        cost: event.cost,
      );
      emit(const MaintenanceOperationSuccess('Maintenance log logged successfully'));
    } catch (e) {
      emit(MaintenanceError(e.toString()));
    }
  }

  Future<void> _onCloseMaintenanceLog(
    CloseMaintenanceLog event,
    Emitter<MaintenanceState> emit,
  ) async {
    emit(MaintenanceLoading());
    try {
      final updated = await maintenanceRepository.closeMaintenanceLog(
        event.id,
        event.cost,
      );
      emit(MaintenanceDetailLoaded(updated));
    } catch (e) {
      emit(MaintenanceError(e.toString()));
    }
  }
}

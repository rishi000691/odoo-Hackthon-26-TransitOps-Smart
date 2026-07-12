import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transitops/features/vehicles/repositories/vehicle_repository.dart';
import 'vehicle_event.dart';
import 'vehicle_state.dart';

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  final VehicleRepository vehicleRepository;

  VehicleBloc({required this.vehicleRepository}) : super(VehicleInitial()) {
    on<FetchVehicles>(_onFetchVehicles);
    on<FetchVehicleDetails>(_onFetchVehicleDetails);
    on<AddVehicle>(_onAddVehicle);
    on<UpdateVehicle>(_onUpdateVehicle);
    on<DeleteVehicle>(_onDeleteVehicle);
  }

  Future<void> _onFetchVehicles(
    FetchVehicles event,
    Emitter<VehicleState> emit,
  ) async {
    emit(VehicleLoading());
    try {
      final apiResponse = await vehicleRepository.getVehicles(
        type: event.type,
        status: event.status,
        region: event.region,
        page: event.page,
        limit: event.limit,
      );
      emit(VehiclesLoaded(apiResponse.data ?? [], apiResponse.meta));
    } catch (e) {
      emit(VehicleError(e.toString()));
    }
  }

  Future<void> _onFetchVehicleDetails(
    FetchVehicleDetails event,
    Emitter<VehicleState> emit,
  ) async {
    emit(VehicleLoading());
    try {
      final vehicle = await vehicleRepository.getVehicleById(event.id);
      emit(VehicleDetailLoaded(vehicle));
    } catch (e) {
      emit(VehicleError(e.toString()));
    }
  }

  Future<void> _onAddVehicle(
    AddVehicle event,
    Emitter<VehicleState> emit,
  ) async {
    emit(VehicleLoading());
    try {
      await vehicleRepository.createVehicle(
        registrationNumber: event.registrationNumber,
        model: event.model,
        type: event.type,
        maxLoadCapacity: event.maxLoadCapacity,
        currentOdometer: event.currentOdometer,
        acquisitionCost: event.acquisitionCost,
      );
      emit(const VehicleOperationSuccess('Vehicle added successfully'));
    } catch (e) {
      emit(VehicleError(e.toString()));
    }
  }

  Future<void> _onUpdateVehicle(
    UpdateVehicle event,
    Emitter<VehicleState> emit,
  ) async {
    emit(VehicleLoading());
    try {
      final updated = await vehicleRepository.updateVehicle(event.id, event.fields);
      emit(VehicleDetailLoaded(updated));
    } catch (e) {
      emit(VehicleError(e.toString()));
    }
  }

  Future<void> _onDeleteVehicle(
    DeleteVehicle event,
    Emitter<VehicleState> emit,
  ) async {
    emit(VehicleLoading());
    try {
      await vehicleRepository.retireVehicle(event.id);
      emit(const VehicleOperationSuccess('Vehicle retired successfully'));
    } catch (e) {
      emit(VehicleError(e.toString()));
    }
  }
}

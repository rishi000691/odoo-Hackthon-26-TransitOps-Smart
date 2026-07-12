import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transitops/features/drivers/repositories/driver_repository.dart';
import 'driver_event.dart';
import 'driver_state.dart';

class DriverBloc extends Bloc<DriverEvent, DriverState> {
  final DriverRepository driverRepository;

  DriverBloc({required this.driverRepository}) : super(DriverInitial()) {
    on<FetchDrivers>(_onFetchDrivers);
    on<FetchDriverDetails>(_onFetchDriverDetails);
    on<AddDriver>(_onAddDriver);
    on<UpdateDriver>(_onUpdateDriver);
  }

  Future<void> _onFetchDrivers(
    FetchDrivers event,
    Emitter<DriverState> emit,
  ) async {
    emit(DriverLoading());
    try {
      final apiResponse = await driverRepository.getDrivers(
        status: event.status,
        page: event.page,
        limit: event.limit,
      );
      emit(DriversLoaded(apiResponse.data ?? [], apiResponse.meta));
    } catch (e) {
      emit(DriverError(e.toString()));
    }
  }

  Future<void> _onFetchDriverDetails(
    FetchDriverDetails event,
    Emitter<DriverState> emit,
  ) async {
    emit(DriverLoading());
    try {
      final driver = await driverRepository.getDriverById(event.id);
      emit(DriverDetailLoaded(driver));
    } catch (e) {
      emit(DriverError(e.toString()));
    }
  }

  Future<void> _onAddDriver(
    AddDriver event,
    Emitter<DriverState> emit,
  ) async {
    emit(DriverLoading());
    try {
      await driverRepository.createDriver(
        name: event.name,
        licenseNumber: event.licenseNumber,
        licenseCategory: event.licenseCategory,
        licenseExpiryDate: event.licenseExpiryDate,
        contactNumber: event.contactNumber,
        safetyScore: event.safetyScore,
      );
      emit(const DriverOperationSuccess('Driver added successfully'));
    } catch (e) {
      emit(DriverError(e.toString()));
    }
  }

  Future<void> _onUpdateDriver(
    UpdateDriver event,
    Emitter<DriverState> emit,
  ) async {
    emit(DriverLoading());
    try {
      final updated = await driverRepository.updateDriver(event.id, event.fields);
      emit(DriverDetailLoaded(updated));
    } catch (e) {
      emit(DriverError(e.toString()));
    }
  }
}

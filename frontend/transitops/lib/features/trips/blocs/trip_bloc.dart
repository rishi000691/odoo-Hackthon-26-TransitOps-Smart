import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transitops/features/trips/repositories/trip_repository.dart';
import 'trip_event.dart';
import 'trip_state.dart';

class TripBloc extends Bloc<TripEvent, TripState> {
  final TripRepository tripRepository;

  TripBloc({required this.tripRepository}) : super(TripInitial()) {
    on<FetchTrips>(_onFetchTrips);
    on<CreateTrip>(_onCreateTrip);
    on<DispatchTrip>(_onDispatchTrip);
    on<CompleteTrip>(_onCompleteTrip);
    on<CancelTrip>(_onCancelTrip);
  }

  Future<void> _onFetchTrips(
    FetchTrips event,
    Emitter<TripState> emit,
  ) async {
    emit(TripLoading());
    try {
      final apiResponse = await tripRepository.getTrips(
        status: event.status,
        driverId: event.driverId,
        vehicleId: event.vehicleId,
        page: event.page,
        limit: event.limit,
      );
      emit(TripsLoaded(apiResponse.data ?? [], apiResponse.meta));
    } catch (e) {
      emit(TripError(e.toString()));
    }
  }

  Future<void> _onCreateTrip(
    CreateTrip event,
    Emitter<TripState> emit,
  ) async {
    emit(TripLoading());
    try {
      await tripRepository.createTrip(
        source: event.source,
        destination: event.destination,
        vehicleId: event.vehicleId,
        driverId: event.driverId,
        cargoWeight: event.cargoWeight,
        plannedDistance: event.plannedDistance,
      );
      emit(const TripOperationSuccess('Trip created successfully'));
    } catch (e) {
      emit(TripError(e.toString()));
    }
  }

  Future<void> _onDispatchTrip(
    DispatchTrip event,
    Emitter<TripState> emit,
  ) async {
    emit(TripLoading());
    try {
      final updated = await tripRepository.dispatchTrip(event.id);
      emit(TripDetailLoaded(updated));
    } catch (e) {
      emit(TripError(e.toString()));
    }
  }

  Future<void> _onCompleteTrip(
    CompleteTrip event,
    Emitter<TripState> emit,
  ) async {
    emit(TripLoading());
    try {
      final updated = await tripRepository.completeTrip(
        event.id,
        actualDistance: event.actualDistance,
        fuelConsumed: event.fuelConsumed,
        revenue: event.revenue,
      );
      emit(TripDetailLoaded(updated));
    } catch (e) {
      emit(TripError(e.toString()));
    }
  }

  Future<void> _onCancelTrip(
    CancelTrip event,
    Emitter<TripState> emit,
  ) async {
    emit(TripLoading());
    try {
      final updated = await tripRepository.cancelTrip(event.id);
      emit(TripDetailLoaded(updated));
    } catch (e) {
      emit(TripError(e.toString()));
    }
  }
}

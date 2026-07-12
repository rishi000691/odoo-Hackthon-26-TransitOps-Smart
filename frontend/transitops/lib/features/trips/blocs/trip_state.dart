import 'package:transitops/core/network/api_response.dart';
import 'package:transitops/features/trips/models/trip_model.dart';

abstract class TripState {
  const TripState();
}

class TripInitial extends TripState {}

class TripLoading extends TripState {}

class TripsLoaded extends TripState {
  final List<Trip> trips;
  final ApiMeta? meta;

  const TripsLoaded(this.trips, this.meta);
}

class TripDetailLoaded extends TripState {
  final Trip trip;

  const TripDetailLoaded(this.trip);
}

class TripOperationSuccess extends TripState {
  final String message;

  const TripOperationSuccess(this.message);
}

class TripError extends TripState {
  final String message;

  const TripError(this.message);
}

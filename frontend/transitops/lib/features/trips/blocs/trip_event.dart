abstract class TripEvent {
  const TripEvent();
}

class FetchTrips extends TripEvent {
  final String? status;
  final String? driverId;
  final String? vehicleId;
  final int? page;
  final int? limit;

  const FetchTrips({
    this.status,
    this.driverId,
    this.vehicleId,
    this.page,
    this.limit,
  });
}

class CreateTrip extends TripEvent {
  final String source;
  final String destination;
  final String vehicleId;
  final String driverId;
  final double cargoWeight;
  final double plannedDistance;

  const CreateTrip({
    required this.source,
    required this.destination,
    required this.vehicleId,
    required this.driverId,
    required this.cargoWeight,
    required this.plannedDistance,
  });
}

class DispatchTrip extends TripEvent {
  final String id;
  const DispatchTrip(this.id);
}

class CompleteTrip extends TripEvent {
  final String id;
  final double? actualDistance;
  final double? fuelConsumed;
  final double? revenue;

  const CompleteTrip({
    required this.id,
    this.actualDistance,
    this.fuelConsumed,
    this.revenue,
  });
}

class CancelTrip extends TripEvent {
  final String id;
  const CancelTrip(this.id);
}

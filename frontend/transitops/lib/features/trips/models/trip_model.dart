import 'package:transitops/core/constants/enums.dart';

class Trip {
  final String id;
  final String source;
  final String destination;
  final String vehicleId;
  final String driverId;
  final double cargoWeight;
  final double plannedDistance;
  final double? actualDistance;
  final TripStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;

  Trip({
    required this.id,
    required this.source,
    required this.destination,
    required this.vehicleId,
    required this.driverId,
    required this.cargoWeight,
    required this.plannedDistance,
    this.actualDistance,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as String,
      source: json['source'] as String,
      destination: json['destination'] as String,
      vehicleId: json['vehicle_id'] as String,
      driverId: json['driver_id'] as String,
      cargoWeight: (json['cargo_weight'] as num).toDouble(),
      plannedDistance: (json['planned_distance'] as num).toDouble(),
      actualDistance: (json['actual_distance'] as num?)?.toDouble(),
      status: TripStatus.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'source': source,
      'destination': destination,
      'vehicle_id': vehicleId,
      'driver_id': driverId,
      'cargo_weight': cargoWeight,
      'planned_distance': plannedDistance,
      'actual_distance': actualDistance,
      'status': status.value,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Trip(id: $id, source: $source, destination: $destination, status: $status)';
  }
}

import 'package:transitops/core/constants/enums.dart';

class Vehicle {
  final String id;
  final String registrationNumber;
  final String model;
  final String type; // e.g. "Van", "Truck", "Sedan"
  final double maxLoadCapacity;
  final double currentOdometer;
  final double acquisitionCost;
  final VehicleStatus status;
  final String? region;
  final DateTime createdAt;

  Vehicle({
    required this.id,
    required this.registrationNumber,
    required this.model,
    required this.type,
    required this.maxLoadCapacity,
    required this.currentOdometer,
    required this.acquisitionCost,
    required this.status,
    this.region,
    required this.createdAt,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String,
      registrationNumber: json['registration_number'] as String,
      model: json['model'] as String,
      type: json['type'] as String,
      maxLoadCapacity: double.parse(json['max_load_capacity'].toString()),
      currentOdometer: double.parse(json['current_odometer'].toString()),
      acquisitionCost: double.parse(json['acquisition_cost'].toString()),
      status: VehicleStatus.fromString(json['status'] as String),
      region: json['region'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'registration_number': registrationNumber,
      'model': model,
      'type': type,
      'max_load_capacity': maxLoadCapacity,
      'current_odometer': currentOdometer,
      'acquisition_cost': acquisitionCost,
      'status': status.value,
      'region': region,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Vehicle(id: $id, registrationNumber: $registrationNumber, model: $model, status: $status, region: $region)';
  }
}

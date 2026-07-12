import 'package:transitops/core/constants/enums.dart';

class MaintenanceLog {
  final String id;
  final String vehicleId;
  final String description;
  final double cost;
  final DateTime startDate;
  final DateTime? endDate;
  final MaintenanceStatus status;

  MaintenanceLog({
    required this.id,
    required this.vehicleId,
    required this.description,
    required this.cost,
    required this.startDate,
    this.endDate,
    required this.status,
  });

  factory MaintenanceLog.fromJson(Map<String, dynamic> json) {
    return MaintenanceLog(
      id: json['id'] as String,
      vehicleId: json['vehicle_id'] as String,
      description: json['description'] as String,
      cost: (json['cost'] as num).toDouble(),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date'] as String) : null,
      status: MaintenanceStatus.fromString(json['status'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'description': description,
      'cost': cost,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate?.toIso8601String().split('T')[0],
      'status': status.value,
    };
  }

  @override
  String toString() {
    return 'MaintenanceLog(id: $id, vehicleId: $vehicleId, status: $status)';
  }
}

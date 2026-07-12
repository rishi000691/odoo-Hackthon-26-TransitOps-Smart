class FuelLog {
  final String id;
  final String vehicleId;
  final double liters;
  final double cost;
  final DateTime date;

  FuelLog({
    required this.id,
    required this.vehicleId,
    required this.liters,
    required this.cost,
    required this.date,
  });

  factory FuelLog.fromJson(Map<String, dynamic> json) {
    return FuelLog(
      id: json['id'] as String,
      vehicleId: json['vehicle_id'] as String,
      liters: double.parse(json['liters'].toString()),
      cost: double.parse(json['cost'].toString()),
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'liters': liters,
      'cost': cost,
      'date': date.toIso8601String().split('T')[0],
    };
  }

  @override
  String toString() {
    return 'FuelLog(id: $id, vehicleId: $vehicleId, liters: $liters, cost: $cost)';
  }
}

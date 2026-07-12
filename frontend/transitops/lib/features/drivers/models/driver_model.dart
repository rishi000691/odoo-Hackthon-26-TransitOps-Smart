import 'package:transitops/core/constants/enums.dart';

class Driver {
  final String id;
  final String name;
  final String licenseNumber;
  final String licenseCategory; // "A", "B", "C", "D"
  final DateTime licenseExpiryDate;
  final String contactNumber;
  final double safetyScore;
  final DriverStatus status;
  final DateTime createdAt;

  Driver({
    required this.id,
    required this.name,
    required this.licenseNumber,
    required this.licenseCategory,
    required this.licenseExpiryDate,
    required this.contactNumber,
    required this.safetyScore,
    required this.status,
    required this.createdAt,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] as String,
      name: json['name'] as String,
      licenseNumber: json['license_number'] as String,
      licenseCategory: json['license_category'] as String,
      licenseExpiryDate: DateTime.parse(json['license_expiry_date'] as String),
      contactNumber: json['contact_number'] as String,
      safetyScore: double.parse(json['safety_score'].toString()),
      status: DriverStatus.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'license_number': licenseNumber,
      'license_category': licenseCategory,
      'license_expiry_date': licenseExpiryDate.toIso8601String().split(
        'T',
      )[0], // yyyy-MM-dd format
      'contact_number': contactNumber,
      'safety_score': safetyScore,
      'status': status.value,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Driver(id: $id, name: $name, licenseNumber: $licenseNumber, status: $status)';
  }
}

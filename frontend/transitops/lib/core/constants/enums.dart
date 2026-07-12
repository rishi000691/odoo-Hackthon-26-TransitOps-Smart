enum UserRole {
  fleetManager('Fleet Manager'),
  driver('Driver'),
  safetyOfficer('Safety Officer'),
  financialAnalyst('Financial Analyst');

  final String value;
  const UserRole(this.value);

  static UserRole fromString(String val) {
    return UserRole.values.firstWhere(
      (e) => e.value == val,
      orElse: () => UserRole.driver,
    );
  }

  @override
  String toString() => value;
}

enum VehicleStatus {
  available('Available'),
  onTrip('On Trip'),
  inShop('In Shop'),
  retired('Retired');

  final String value;
  const VehicleStatus(this.value);

  static VehicleStatus fromString(String val) {
    return VehicleStatus.values.firstWhere(
      (e) => e.value == val,
      orElse: () => VehicleStatus.available,
    );
  }

  @override
  String toString() => value;
}

enum DriverStatus {
  available('Available'),
  onTrip('On Trip'),
  offDuty('Off Duty'),
  suspended('Suspended');

  final String value;
  const DriverStatus(this.value);

  static DriverStatus fromString(String val) {
    return DriverStatus.values.firstWhere(
      (e) => e.value == val,
      orElse: () => DriverStatus.available,
    );
  }

  @override
  String toString() => value;
}

enum TripStatus {
  draft('Draft'),
  dispatched('Dispatched'),
  completed('Completed'),
  cancelled('Cancelled');

  final String value;
  const TripStatus(this.value);

  static TripStatus fromString(String val) {
    return TripStatus.values.firstWhere(
      (e) => e.value == val,
      orElse: () => TripStatus.draft,
    );
  }

  @override
  String toString() => value;
}

enum MaintenanceStatus {
  active('Active'),
  closed('Closed');

  final String value;
  const MaintenanceStatus(this.value);

  static MaintenanceStatus fromString(String val) {
    return MaintenanceStatus.values.firstWhere(
      (e) => e.value == val,
      orElse: () => MaintenanceStatus.active,
    );
  }

  @override
  String toString() => value;
}

enum ExpenseType {
  toll('Toll'),
  maintenance('Maintenance'),
  insurance('Insurance'),
  other('Other');

  final String value;
  const ExpenseType(this.value);

  static ExpenseType fromString(String val) {
    return ExpenseType.values.firstWhere(
      (e) => e.value == val,
      orElse: () => ExpenseType.other,
    );
  }

  @override
  String toString() => value;
}

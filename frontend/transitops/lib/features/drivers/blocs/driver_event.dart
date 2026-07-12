abstract class DriverEvent {
  const DriverEvent();
}

class FetchDrivers extends DriverEvent {
  final String? status;
  final int? page;
  final int? limit;

  const FetchDrivers({
    this.status,
    this.page,
    this.limit,
  });
}

class FetchDriverDetails extends DriverEvent {
  final String id;
  const FetchDriverDetails(this.id);
}

class AddDriver extends DriverEvent {
  final String name;
  final String licenseNumber;
  final String licenseCategory;
  final DateTime licenseExpiryDate;
  final String contactNumber;
  final double safetyScore;

  const AddDriver({
    required this.name,
    required this.licenseNumber,
    required this.licenseCategory,
    required this.licenseExpiryDate,
    required this.contactNumber,
    required this.safetyScore,
  });
}

class UpdateDriver extends DriverEvent {
  final String id;
  final Map<String, dynamic> fields;

  const UpdateDriver({required this.id, required this.fields});
}

class SendExpiryReminders extends DriverEvent {
  final int days;
  const SendExpiryReminders({this.days = 30});
}

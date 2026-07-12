abstract class ExpenseEvent {
  const ExpenseEvent();
}

class RecordFuelLog extends ExpenseEvent {
  final String vehicleId;
  final double liters;
  final double cost;

  const RecordFuelLog({
    required this.vehicleId,
    required this.liters,
    required this.cost,
  });
}

class RecordOtherExpense extends ExpenseEvent {
  final String vehicleId;
  final String expenseType;
  final double cost;

  const RecordOtherExpense({
    required this.vehicleId,
    required this.expenseType,
    required this.cost,
  });
}

class FetchVehicleFuelLogs extends ExpenseEvent {
  final String vehicleId;
  const FetchVehicleFuelLogs(this.vehicleId);
}

class FetchVehicleExpenses extends ExpenseEvent {
  final String vehicleId;
  const FetchVehicleExpenses(this.vehicleId);
}

import 'package:transitops/core/constants/enums.dart';

class Expense {
  final String id;
  final String vehicleId;
  final ExpenseType expenseType;
  final double cost;
  final DateTime date;

  Expense({
    required this.id,
    required this.vehicleId,
    required this.expenseType,
    required this.cost,
    required this.date,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      vehicleId: json['vehicle_id'] as String,
      expenseType: ExpenseType.fromString(json['expense_type'] as String),
      cost: double.parse(json['cost'].toString()),
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'expense_type': expenseType.value,
      'cost': cost,
      'date': date.toIso8601String().split('T')[0],
    };
  }

  @override
  String toString() {
    return 'Expense(id: $id, vehicleId: $vehicleId, type: $expenseType, cost: $cost)';
  }
}

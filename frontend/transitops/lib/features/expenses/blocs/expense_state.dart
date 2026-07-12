import 'package:transitops/features/expenses/models/expense_model.dart';
import 'package:transitops/features/expenses/models/fuel_log_model.dart';

abstract class ExpenseState {
  const ExpenseState();
}

class ExpenseInitial extends ExpenseState {}

class ExpenseLoading extends ExpenseState {}

class ExpenseOperationSuccess extends ExpenseState {
  final String message;
  const ExpenseOperationSuccess(this.message);
}

class FuelLogsLoaded extends ExpenseState {
  final List<FuelLog> fuelLogs;
  const FuelLogsLoaded(this.fuelLogs);
}

class ExpensesLoaded extends ExpenseState {
  final List<Expense> expenses;
  const ExpensesLoaded(this.expenses);
}

class ExpenseError extends ExpenseState {
  final String message;
  const ExpenseError(this.message);
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transitops/features/expenses/repositories/expense_repository.dart';
import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseRepository expenseRepository;

  ExpenseBloc({required this.expenseRepository}) : super(ExpenseInitial()) {
    on<RecordFuelLog>(_onRecordFuelLog);
    on<RecordOtherExpense>(_onRecordOtherExpense);
    on<FetchVehicleFuelLogs>(_onFetchVehicleFuelLogs);
    on<FetchVehicleExpenses>(_onFetchVehicleExpenses);
  }

  Future<void> _onRecordFuelLog(
    RecordFuelLog event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());
    try {
      await expenseRepository.createFuelLog(
        vehicleId: event.vehicleId,
        liters: event.liters,
        cost: event.cost,
      );
      emit(const ExpenseOperationSuccess('Fuel log recorded successfully'));
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  Future<void> _onRecordOtherExpense(
    RecordOtherExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());
    try {
      await expenseRepository.createExpense(
        vehicleId: event.vehicleId,
        expenseType: event.expenseType,
        cost: event.cost,
      );
      emit(const ExpenseOperationSuccess('Expense recorded successfully'));
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  Future<void> _onFetchVehicleFuelLogs(
    FetchVehicleFuelLogs event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());
    try {
      final logs = await expenseRepository.getFuelLogsByVehicle(event.vehicleId);
      emit(FuelLogsLoaded(logs));
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  Future<void> _onFetchVehicleExpenses(
    FetchVehicleExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());
    try {
      final expenses = await expenseRepository.getExpensesByVehicle(event.vehicleId);
      emit(ExpensesLoaded(expenses));
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }
}

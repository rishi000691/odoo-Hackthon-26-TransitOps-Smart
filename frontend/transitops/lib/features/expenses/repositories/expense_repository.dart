import 'package:dio/dio.dart';
import 'package:transitops/core/exceptions/exceptions.dart';
import 'package:transitops/core/network/api_client.dart';
import 'package:transitops/core/network/api_response.dart';
import 'package:transitops/features/expenses/models/expense_model.dart';
import 'package:transitops/features/expenses/models/fuel_log_model.dart';

class ExpenseRepository {
  final ApiClient apiClient;

  ExpenseRepository({required this.apiClient});

  Future<FuelLog> createFuelLog({
    required String vehicleId,
    required double liters,
    required double cost,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/expenses/fuel',
        data: {
          'vehicle_id': vehicleId,
          'liters': liters,
          'cost': cost,
        },
      );
      final apiResponse = ApiResponse<FuelLog>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => FuelLog.fromJson(data as Map<String, dynamic>),
      );
      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }
      throw const ServerFailure('Failed to parse fuel log response');
    } on DioException catch (e) {
      throw ApiClient.handleDioException(e);
    }
  }

  Future<Expense> createExpense({
    required String vehicleId,
    required String expenseType,
    required double cost,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/expenses/other',
        data: {
          'vehicle_id': vehicleId,
          'expense_type': expenseType,
          'cost': cost,
        },
      );
      final apiResponse = ApiResponse<Expense>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => Expense.fromJson(data as Map<String, dynamic>),
      );
      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }
      throw const ServerFailure('Failed to parse expense response');
    } on DioException catch (e) {
      throw ApiClient.handleDioException(e);
    }
  }

  Future<List<FuelLog>> getFuelLogsByVehicle(String vehicleId) async {
    try {
      final response = await apiClient.dio.get('/expenses/fuel/vehicle/$vehicleId');
      final apiResponse = ApiResponse<List<FuelLog>>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => (data as List<dynamic>)
            .map((e) => FuelLog.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      return apiResponse.data ?? [];
    } on DioException catch (e) {
      throw ApiClient.handleDioException(e);
    }
  }

  Future<List<Expense>> getExpensesByVehicle(String vehicleId) async {
    try {
      final response = await apiClient.dio.get('/expenses/other/vehicle/$vehicleId');
      final apiResponse = ApiResponse<List<Expense>>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => (data as List<dynamic>)
            .map((e) => Expense.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      return apiResponse.data ?? [];
    } on DioException catch (e) {
      throw ApiClient.handleDioException(e);
    }
  }
}

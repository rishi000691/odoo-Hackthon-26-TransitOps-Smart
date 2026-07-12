import 'package:dio/dio.dart';
import 'package:transitops/core/exceptions/exceptions.dart';
import 'package:transitops/core/network/api_client.dart';
import 'package:transitops/core/network/api_response.dart';
import 'package:transitops/features/maintenance/models/maintenance_log_model.dart';

class MaintenanceRepository {
  final ApiClient apiClient;

  MaintenanceRepository({required this.apiClient});

  Future<ApiResponse<List<MaintenanceLog>>> getMaintenanceLogs({
    String? status,
    String? vehicleId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;
      if (vehicleId != null) queryParams['vehicle_id'] = vehicleId;

      final response = await apiClient.dio.get(
        '/maintenance',
        queryParameters: queryParams,
      );

      return ApiResponse<List<MaintenanceLog>>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => (data as List<dynamic>)
            .map((e) => MaintenanceLog.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      throw ApiClient.handleDioException(e);
    }
  }

  Future<MaintenanceLog> createMaintenanceLog({
    required String vehicleId,
    required String description,
    required double cost,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/maintenance',
        data: {
          'vehicle_id': vehicleId,
          'description': description,
          'cost': cost,
        },
      );
      final apiResponse = ApiResponse<MaintenanceLog>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => MaintenanceLog.fromJson(data as Map<String, dynamic>),
      );
      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }
      throw const ServerFailure('Failed to parse created maintenance log response');
    } on DioException catch (e) {
      throw ApiClient.handleDioException(e);
    }
  }

  Future<MaintenanceLog> closeMaintenanceLog(String id, double cost) async {
    try {
      final response = await apiClient.dio.put(
        '/maintenance/$id/close',
        data: {
          'cost': cost,
        },
      );
      final apiResponse = ApiResponse<MaintenanceLog>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => MaintenanceLog.fromJson(data as Map<String, dynamic>),
      );
      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }
      throw const ServerFailure('Failed to parse closed maintenance log response');
    } on DioException catch (e) {
      throw ApiClient.handleDioException(e);
    }
  }
}

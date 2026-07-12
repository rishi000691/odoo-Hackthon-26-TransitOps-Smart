import 'package:dio/dio.dart';
import 'package:transitops/core/exceptions/exceptions.dart';
import 'package:transitops/core/network/api_client.dart';
import 'package:transitops/core/network/api_response.dart';
import 'package:transitops/features/drivers/models/driver_model.dart';

class DriverRepository {
  final ApiClient apiClient;

  DriverRepository({required this.apiClient});

  Future<ApiResponse<List<Driver>>> getDrivers({
    String? status,
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;

      final response = await apiClient.dio.get(
        '/drivers',
        queryParameters: queryParams,
      );

      return ApiResponse<List<Driver>>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => (data as List<dynamic>)
            .map((e) => Driver.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      throw ApiClient.handleDioException(e);
    }
  }

  Future<Driver> getDriverById(String id) async {
    try {
      final response = await apiClient.dio.get('/drivers/$id');
      final apiResponse = ApiResponse<Driver>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => Driver.fromJson(data as Map<String, dynamic>),
      );
      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }
      throw const ServerFailure('Failed to parse driver response');
    } on DioException catch (e) {
      throw ApiClient.handleDioException(e);
    }
  }

  Future<Driver> createDriver({
    required String name,
    required String licenseNumber,
    required String licenseCategory,
    required DateTime licenseExpiryDate,
    required String contactNumber,
    required double safetyScore,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/drivers',
        data: {
          'name': name,
          'license_number': licenseNumber,
          'license_category': licenseCategory,
          'license_expiry_date': licenseExpiryDate.toIso8601String().split('T')[0],
          'contact_number': contactNumber,
          'safety_score': safetyScore,
        },
      );
      final apiResponse = ApiResponse<Driver>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => Driver.fromJson(data as Map<String, dynamic>),
      );
      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }
      throw const ServerFailure('Failed to parse created driver response');
    } on DioException catch (e) {
      throw ApiClient.handleDioException(e);
    }
  }

  Future<Driver> updateDriver(String id, Map<String, dynamic> fields) async {
    try {
      final response = await apiClient.dio.put(
        '/drivers/$id',
        data: fields,
      );
      final apiResponse = ApiResponse<Driver>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => Driver.fromJson(data as Map<String, dynamic>),
      );
      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }
      throw const ServerFailure('Failed to parse updated driver response');
    } on DioException catch (e) {
      throw ApiClient.handleDioException(e);
    }
  }

  Future<String> sendExpiryReminders(int days) async {
    try {
      final response = await apiClient.dio.post(
        '/drivers/reminders/send',
        data: {'days': days},
      );
      final apiResponse = ApiResponse<dynamic>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data,
      );
      return apiResponse.message ?? 'Reminders processed successfully';
    } on DioException catch (e) {
      throw ApiClient.handleDioException(e);
    }
  }
}

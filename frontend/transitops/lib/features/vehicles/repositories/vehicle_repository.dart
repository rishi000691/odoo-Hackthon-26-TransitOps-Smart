import 'package:dio/dio.dart';
import 'package:transitops/core/exceptions/exceptions.dart';
import 'package:transitops/core/network/api_client.dart';
import 'package:transitops/core/network/api_response.dart';
import 'package:transitops/features/vehicles/models/vehicle_model.dart';

class VehicleRepository {
  final ApiClient apiClient;

  VehicleRepository({required this.apiClient});

  Future<ApiResponse<List<Vehicle>>> getVehicles({
    String? type,
    String? status,
    String? region,
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (type != null) queryParams['type'] = type;
      if (status != null) queryParams['status'] = status;
      if (region != null) queryParams['region'] = region;
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;

      final response = await apiClient.dio.get(
        '/vehicles',
        queryParameters: queryParams,
      );

      return ApiResponse<List<Vehicle>>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => (data as List<dynamic>)
            .map((e) => Vehicle.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      throw ApiClient.handleDioException(e);
    }
  }

  Future<Vehicle> getVehicleById(String id) async {
    try {
      final response = await apiClient.dio.get('/vehicles/$id');
      final apiResponse = ApiResponse<Vehicle>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => Vehicle.fromJson(data as Map<String, dynamic>),
      );
      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }
      throw const ServerFailure('Failed to parse vehicle response');
    } on DioException catch (e) {
      throw ApiClient.handleDioException(e);
    }
  }

  Future<Vehicle> createVehicle({
    required String registrationNumber,
    required String model,
    required String type,
    required double maxLoadCapacity,
    required double currentOdometer,
    required double acquisitionCost,
    String? region,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/vehicles',
        data: {
          'registration_number': registrationNumber,
          'model': model,
          'type': type,
          'max_load_capacity': maxLoadCapacity,
          'current_odometer': currentOdometer,
          'acquisition_cost': acquisitionCost,
          if (region != null) 'region': region,
        },
      );
      final apiResponse = ApiResponse<Vehicle>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => Vehicle.fromJson(data as Map<String, dynamic>),
      );
      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }
      throw const ServerFailure('Failed to parse created vehicle response');
    } on DioException catch (e) {
      throw ApiClient.handleDioException(e);
    }
  }

  Future<Vehicle> updateVehicle(String id, Map<String, dynamic> fields) async {
    try {
      final response = await apiClient.dio.put(
        '/vehicles/$id',
        data: fields,
      );
      final apiResponse = ApiResponse<Vehicle>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => Vehicle.fromJson(data as Map<String, dynamic>),
      );
      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }
      throw const ServerFailure('Failed to parse updated vehicle response');
    } on DioException catch (e) {
      throw ApiClient.handleDioException(e);
    }
  }

  Future<void> retireVehicle(String id) async {
    try {
      await apiClient.dio.delete('/vehicles/$id');
    } on DioException catch (e) {
      throw ApiClient.handleDioException(e);
    }
  }
}

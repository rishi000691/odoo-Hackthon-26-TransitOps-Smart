import 'package:dio/dio.dart';
import 'package:transitops/core/exceptions/exceptions.dart';
import 'package:transitops/core/network/api_client.dart';
import 'package:transitops/core/network/api_response.dart';
import 'package:transitops/features/trips/models/trip_model.dart';

class TripRepository {
  final ApiClient apiClient;

  TripRepository({required this.apiClient});

  Future<ApiResponse<List<Trip>>> getTrips({
    String? status,
    String? driverId,
    String? vehicleId,
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;
      if (driverId != null) queryParams['driver_id'] = driverId;
      if (vehicleId != null) queryParams['vehicle_id'] = vehicleId;
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;

      final response = await apiClient.dio.get(
        '/trips',
        queryParameters: queryParams,
      );

      return ApiResponse<List<Trip>>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => (data as List<dynamic>)
            .map((e) => Trip.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      throw ApiClient.handleDioException(e);
    }
  }

  Future<Trip> createTrip({
    required String source,
    required String destination,
    required String vehicleId,
    required String driverId,
    required double cargoWeight,
    required double plannedDistance,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/trips',
        data: {
          'source': source,
          'destination': destination,
          'vehicle_id': vehicleId,
          'driver_id': driverId,
          'cargo_weight': cargoWeight,
          'planned_distance': plannedDistance,
        },
      );
      final apiResponse = ApiResponse<Trip>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => Trip.fromJson(data as Map<String, dynamic>),
      );
      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }
      throw const ServerFailure('Failed to parse created trip response');
    } on DioException catch (e) {
      throw ApiClient.handleDioException(e);
    }
  }

  Future<Trip> dispatchTrip(String id) async {
    try {
      final response = await apiClient.dio.post('/trips/$id/dispatch');
      final apiResponse = ApiResponse<Trip>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => Trip.fromJson(data as Map<String, dynamic>),
      );
      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }
      throw const ServerFailure('Failed to parse dispatch trip response');
    } on DioException catch (e) {
      throw ApiClient.handleDioException(e);
    }
  }

  Future<Trip> completeTrip(
    String id, {
    double? actualDistance,
    double? fuelConsumed,
    double? revenue,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/trips/$id/complete',
        data: {
          if (actualDistance != null) 'actual_distance': actualDistance,
          if (fuelConsumed != null) 'fuel_consumed': fuelConsumed,
          if (revenue != null) 'revenue': revenue,
        },
      );
      final apiResponse = ApiResponse<Trip>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => Trip.fromJson(data as Map<String, dynamic>),
      );
      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }
      throw const ServerFailure('Failed to parse complete trip response');
    } on DioException catch (e) {
      throw ApiClient.handleDioException(e);
    }
  }

  Future<Trip> cancelTrip(String id) async {
    try {
      final response = await apiClient.dio.post('/trips/$id/cancel');
      final apiResponse = ApiResponse<Trip>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => Trip.fromJson(data as Map<String, dynamic>),
      );
      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }
      throw const ServerFailure('Failed to parse cancel trip response');
    } on DioException catch (e) {
      throw ApiClient.handleDioException(e);
    }
  }
}

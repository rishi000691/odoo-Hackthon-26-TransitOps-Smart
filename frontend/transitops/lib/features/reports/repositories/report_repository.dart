import 'package:dio/dio.dart';
import 'package:transitops/core/exceptions/exceptions.dart';
import 'package:transitops/core/network/api_client.dart';
import 'package:transitops/core/network/api_response.dart';

class ReportRepository {
  final ApiClient apiClient;

  ReportRepository({required this.apiClient});

  Future<Map<String, dynamic>> getDashboardKpis() async {
    try {
      final response = await apiClient.dio.get('/reports/kpis');
      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as Map<String, dynamic>,
      );
      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }
      throw const ServerFailure('Failed to parse KPIs response');
    } on DioException catch (e) {
      throw ApiClient.handleDioException(e);
    }
  }

  Future<List<Map<String, dynamic>>> getRoiReport() async {
    try {
      final response = await apiClient.dio.get('/reports/roi');
      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as List<dynamic>,
      );
      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
      throw const ServerFailure('Failed to parse ROI report response');
    } on DioException catch (e) {
      throw ApiClient.handleDioException(e);
    }
  }

  Future<String> exportReportCsv(String reportType) async {
    try {
      final response = await apiClient.dio.get<String>(
        '/reports/export/csv',
        queryParameters: {'report': reportType},
        options: Options(responseType: ResponseType.plain),
      );
      return response.data ?? '';
    } on DioException catch (e) {
      throw ApiClient.handleDioException(e);
    }
  }
}

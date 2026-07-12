import 'package:dio/dio.dart';
import '../storage/secure_storage_service.dart';
import '../exceptions/exceptions.dart';

class ApiClient {
  final Dio dio;
  final SecureStorageService secureStorage;

  ApiClient({
    required this.dio,
    required this.secureStorage,
    String? baseUrl,
  }) {
    dio.options.baseUrl = baseUrl ?? 'https://api.transitops.smart/v1'; // Default placeholder
    dio.options.connectTimeout = const Duration(seconds: 15);
    dio.options.receiveTimeout = const Duration(seconds: 15);

    // Register Interceptors
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Attaches JWT Token if present
          final token = await secureStorage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // Check for 401 Unauthorized errors
          if (error.response?.statusCode == 401) {
            final refreshed = await _attemptTokenRefresh();
            if (refreshed) {
              // Retry the original failed request
              final options = error.requestOptions;
              final retryResponse = await dio.request(
                options.path,
                data: options.data,
                queryParameters: options.queryParameters,
                options: Options(
                  method: options.method,
                  headers: options.headers,
                ),
              );
              return handler.resolve(retryResponse);
            } else {
              // If token refresh fails, clear storage (forces user logout)
              await secureStorage.clearAll();
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Map DioExceptions to our Failure classes defined in exceptions.dart
  static Failure handleDioException(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic> && data['error'] != null) {
        final errorJson = data['error'];
        final code = errorJson['code'] as String?;
        final message = errorJson['message'] as String? ?? 'An error occurred';

        if (e.response!.statusCode == 401 || code == 'UNAUTHORIZED') {
          return AuthFailure(message);
        } else if (e.response!.statusCode == 403 || code == 'FORBIDDEN') {
          return AuthFailure(message);
        }

        return ServerFailure(message, statusCode: e.response!.statusCode);
      }
      return ServerFailure(
        e.response!.statusMessage ?? 'Server returned ${e.response!.statusCode}',
        statusCode: e.response!.statusCode,
      );
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkFailure('Network connection timed out. Please try again.');
      default:
        return UnknownFailure(e.message ?? 'An unknown error occurred');
    }
  }

  /// Internal logic to handle token refreshing
  Future<bool> _attemptTokenRefresh() async {
    final refreshToken = await secureStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    try {
      // Create a clean Dio instance to prevent infinite interceptor loops
      final refreshDio = Dio(BaseOptions(baseUrl: dio.options.baseUrl));
      final response = await refreshDio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final newAccessToken = response.data['access_token'] as String?;
        final newRefreshToken = response.data['refresh_token'] as String?;

        if (newAccessToken != null) {
          await secureStorage.saveAccessToken(newAccessToken);
          if (newRefreshToken != null) {
            await secureStorage.saveRefreshToken(newRefreshToken);
          }
          return true;
        }
      }
    } catch (_) {
      // Refresh failed
    }

    return false;
  }
}

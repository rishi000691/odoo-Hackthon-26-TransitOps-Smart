import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:transitops/core/exceptions/exceptions.dart';
import 'package:transitops/core/network/api_client.dart';
import 'package:transitops/core/network/api_response.dart';
import 'package:transitops/features/authentication/models/user_model.dart';

class AuthRepository {
  final ApiClient apiClient;

  AuthRepository({required this.apiClient});

  Future<User> login(String email, String password) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final token = apiResponse.data!['token'] as String;
        final userJson = apiResponse.data!['user'] as Map<String, dynamic>;
        final user = User.fromJson(userJson);

        await apiClient.secureStorage.saveAccessToken(token);
        await apiClient.secureStorage.saveUserData(jsonEncode(userJson));

        return user;
      } else {
        throw const AuthFailure('Invalid login response');
      }
    } on DioException catch (e) {
      throw ApiClient.handleDioException(e);
    }
  }

  Future<void> logout() async {
    try {
      await apiClient.dio.post('/auth/logout');
    } on DioException catch (e) {
      // Even if network call fails, we still want to clean up local storage
      await apiClient.secureStorage.clearAll();
      throw ApiClient.handleDioException(e);
    } finally {
      await apiClient.secureStorage.clearAll();
    }
  }

  Future<User?> getCurrentUser() async {
    final userDataStr = await apiClient.secureStorage.getUserData();
    if (userDataStr != null) {
      try {
        final userDataMap = jsonDecode(userDataStr) as Map<String, dynamic>;
        return User.fromJson(userDataMap);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    final token = await apiClient.secureStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }
}

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:transitops/core/constants/enums.dart';
import 'package:transitops/core/exceptions/exceptions.dart';
import 'package:transitops/core/network/api_client.dart';
import 'package:transitops/core/network/api_response.dart';
import 'package:transitops/features/authentication/models/user_model.dart';

class AuthRepository {
  final ApiClient apiClient;

  // In-memory mock database of credentials for mock authentication
  static final List<Map<String, dynamic>> _mockUsers = [
    {
      'id': 'mock-uuid-manager-12345',
      'email': 'manager@transitops.smart',
      'password': 'password123',
      'first_name': 'Fleet',
      'last_name': 'Manager',
      'roles': ['Fleet Manager'],
    },
    {
      'id': 'mock-uuid-driver-12345',
      'email': 'driver@transitops.smart',
      'password': 'password123',
      'first_name': 'Active',
      'last_name': 'Driver',
      'roles': ['Driver'],
    },
    {
      'id': 'mock-uuid-safety-12345',
      'email': 'safety@transitops.smart',
      'password': 'password123',
      'first_name': 'Safety',
      'last_name': 'Officer',
      'roles': ['Safety Officer'],
    },
    {
      'id': 'mock-uuid-finance-12345',
      'email': 'finance@transitops.smart',
      'password': 'password123',
      'first_name': 'Financial',
      'last_name': 'Analyst',
      'roles': ['Financial Analyst'],
    },
  ];

  AuthRepository({required this.apiClient});

  Future<User> login(String email, String password) async {
    // 1. Try matching mock users first for smooth prototyping/testing
    final mockUserIndex = _mockUsers.indexWhere(
      (u) =>
          u['email'].toString().toLowerCase() == email.trim().toLowerCase() &&
          u['password'] == password,
    );

    if (mockUserIndex != -1) {
      final userJson = _mockUsers[mockUserIndex];
      final user = User.fromJson(userJson);

      await apiClient.secureStorage.saveAccessToken(
        'mock-jwt-token-${user.id}',
      );
      await apiClient.secureStorage.saveUserData(jsonEncode(userJson));

      return user;
    }

    // 2. Otherwise fall back to the actual backend endpoint
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

  Future<User> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required UserRole role,
  }) async {
    // 1. Try matching mock users first for smooth prototyping/testing
    if (email.trim().toLowerCase().endsWith('@transitops.smart')) {
      final exists = _mockUsers.any(
        (u) => u['email'].toString().toLowerCase() == email.trim().toLowerCase(),
      );

      if (exists) {
        throw const AuthFailure('Email is already registered.');
      }

      // Save to local in-memory DB
      final newId = 'mock-uuid-${DateTime.now().millisecondsSinceEpoch}';
      final userJson = {
        'id': newId,
        'email': email.trim(),
        'first_name': firstName,
        'last_name': lastName,
        'roles': [role.value],
      };

      _mockUsers.add({
        ...userJson,
        'password': password,
      });

      // Auto log-in by saving session state
      final user = User.fromJson(userJson);
      await apiClient.secureStorage.saveAccessToken('mock-jwt-token-$newId');
      await apiClient.secureStorage.saveUserData(jsonEncode(userJson));

      return user;
    }

    // 2. Otherwise call real API
    try {
      final response = await apiClient.dio.post(
        '/auth/register',
        data: {
          'email': email.trim(),
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
          'role_name': role.value,
        },
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        // Automatically login the user after registration to persist token and user details
        return await login(email, password);
      } else {
        throw const AuthFailure('Invalid registration response');
      }
    } on DioException catch (e) {
      throw ApiClient.handleDioException(e);
    }
  }

  Future<void> logout() async {
    try {
      await apiClient.dio.post('/auth/logout');
    } on DioException catch (e) {
      // Clean up locally even if request fails
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

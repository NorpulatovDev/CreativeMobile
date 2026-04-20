import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../models/models.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponse> login(LoginRequest request);
  Future<LoginResponse> refreshToken(String refreshToken);
  Future<void> logout(String refreshToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/auth/login',
        data: request.toJson(),
      );

      if (response.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'Empty response from server',
        );
      }

      return LoginResponse.fromJson(response.data!);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<LoginResponse> refreshToken(String refreshToken) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'Empty response from server',
        );
      }

      return LoginResponse.fromJson(response.data!);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<void> logout(String refreshToken) async {
    try {
      await _apiClient.post<void>(
        '/auth/logout',
        data: {'refreshToken': refreshToken},
      );
    } on DioException {
      rethrow;
    }
  }
}

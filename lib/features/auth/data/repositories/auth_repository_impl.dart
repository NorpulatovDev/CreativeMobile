import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/storage/token_storage.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/models.dart';

abstract class AuthRepository {
  Future<(UserModel?, Failure?)> login(String username, String password);
  Future<UserModel?> getCurrentUser();
  Future<void> logout();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;

  AuthRepositoryImpl(this._remoteDataSource, this._tokenStorage);

  @override
  Future<(UserModel?, Failure?)> login(String username, String password) async {
    try {
      final response = await _remoteDataSource.login(
        LoginRequest(username: username, password: password),
      );

      final user = UserModel(
        username: response.username,
        role: response.role,
        token: response.token,
      );

      await _tokenStorage.saveToken(response.token);

      return (user, null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return (null, const AuthFailure('Invalid username or password'));
      }
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return (null, const NetworkFailure('Unable to connect to server'));
      }
      final message = e.response?.data?['message'] ?? 'Login failed';
      return (null, ServerFailure(message));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final token = await _tokenStorage.getToken();
    if (token == null) return null;

    // Decode JWT to get user info (simple implementation)
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // For now, return a basic user since we have a valid token
      // In production, you might want to call a /me endpoint
      return UserModel(
        username: 'admin', // Could decode from JWT
        role: 'ADMIN',
        token: token,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await _tokenStorage.deleteToken();
  }
}
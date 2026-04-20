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

      await _tokenStorage.saveToken(response.accessToken);
      await _tokenStorage.saveRefreshToken(response.refreshToken);
      await _tokenStorage.saveUserData(
        adminId: response.adminId,
        username: response.username,
        role: response.role,
        branchId: response.branchId,
        branchName: response.branchName,
      );

      final user = UserModel(
        adminId: response.adminId,
        username: response.username,
        role: response.role,
        accessToken: response.accessToken,
        branchId: response.branchId,
        branchName: response.branchName,
      );

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
    final accessToken = await _tokenStorage.getToken();
    if (accessToken == null) return null;

    final userData = await _tokenStorage.getUserData();
    if (userData == null) return null;

    return UserModel(
      adminId: userData['adminId'] as int,
      username: userData['username'] as String,
      role: userData['role'] as String,
      accessToken: accessToken,
      branchId: userData['branchId'] as int?,
      branchName: userData['branchName'] as String?,
    );
  }

  @override
  Future<void> logout() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken != null) {
      try {
        await _remoteDataSource.logout(refreshToken);
      } catch (_) {
        // Best-effort server-side revocation; always clear local state
      }
    }
    await _tokenStorage.deleteAll();
  }
}

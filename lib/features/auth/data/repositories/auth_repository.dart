import 'package:injectable/injectable.dart';
import '../../../../core/storage/token_storage.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/models.dart';

abstract class AuthRepository {
  Future<LoginResponse> login(String username, String password);
  Future<void> logout();
  Future<bool> isLoggedIn();
}

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;

  AuthRepositoryImpl(this._remoteDataSource, this._tokenStorage);

  @override
  Future<LoginResponse> login(String username, String password) async {
    final request = LoginRequest(username: username, password: password);
    final response = await _remoteDataSource.login(request);
    await _tokenStorage.saveToken(response.token);
    return response;
  }

  @override
  Future<void> logout() async {
    await _tokenStorage.deleteToken();
  }

  @override
  Future<bool> isLoggedIn() async {
    return await _tokenStorage.hasToken();
  }
}

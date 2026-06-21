import 'package:dio/dio.dart';

import '../storage/token_storage.dart';

typedef LogoutCallback = Future<void> Function();

class ApiClient {
  final Dio _dio;
  final TokenStorage _tokenStorage;
  static LogoutCallback? _onLogout;

  static void setLogoutCallback(LogoutCallback callback) {
    _onLogout = callback;
  }

  ApiClient(this._tokenStorage) : _dio = _buildDio() {
    _dio.interceptors.add(
      AuthInterceptor(_tokenStorage, _dio.options.baseUrl),
    );
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  static Dio _buildDio() => Dio(BaseOptions(
        baseUrl: const String.fromEnvironment(
          'API_URL',
          // prod: https://nr-ogabek.uz/
          // Android emulator: http://10.0.2.2:8080
          // iOS simulator:    http://localhost:8080
          defaultValue: 'https://nr-ogabek.uz/',
        ),
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ));

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) =>
      _dio.get<T>(path, queryParameters: queryParameters);

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) =>
      _dio.post<T>(path, data: data, queryParameters: queryParameters);

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) =>
      _dio.put<T>(path, data: data, queryParameters: queryParameters);

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) =>
      _dio.patch<T>(path, data: data, queryParameters: queryParameters);

  Future<Response<T>> delete<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) =>
      _dio.delete<T>(path, queryParameters: queryParameters);
}

class AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;
  // Separate Dio instance with no interceptors — used for refresh calls and
  // retrying the original request so we never recurse into this interceptor.
  final Dio _retryDio;
  bool _isRefreshing = false;

  AuthInterceptor(this._tokenStorage, String baseUrl)
      : _retryDio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ));

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isPublicEndpoint(options.path)) {
      final token = await _tokenStorage.getToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      // Sync reads — both methods read from SharedPreferences' in-memory cache,
      // so there is no async overhead or race against concurrent requests.
      final activeBranchId = _tokenStorage.getActiveBranchFilterIdSync();
      final branchId =
          activeBranchId ?? (_tokenStorage.getUserDataSync()?['branchId'] as int?);
      if (branchId != null) {
        options.headers['X-Branch-Filter'] = branchId.toString();
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isPublicEndpoint(err.requestOptions.path)) {
      if (_isRefreshing) {
        handler.next(err);
        return;
      }

      _isRefreshing = true;
      try {
        final refreshToken = await _tokenStorage.getRefreshToken();
        if (refreshToken != null) {
          final refreshResp = await _retryDio.post<Map<String, dynamic>>(
            '/auth/refresh',
            data: {'refreshToken': refreshToken},
          );

          final data = refreshResp.data;
          if (data != null) {
            final newAccessToken = data['accessToken'] as String;
            final newRefreshToken = data['refreshToken'] as String;

            await _tokenStorage.saveToken(newAccessToken);
            await _tokenStorage.saveRefreshToken(newRefreshToken);

            // Persist updated user metadata from the new token response
            if (data['username'] != null) {
              await _tokenStorage.saveUserData(
                adminId: (data['adminId'] as num).toInt(),
                username: data['username'] as String,
                role: data['role'] as String,
                branchId: (data['branchId'] as num?)?.toInt(),
                branchName: data['branchName'] as String?,
              );
            }

            // Retry the original request with the new access token
            final retryOptions = err.requestOptions;
            retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
            final retryResp = await _retryDio.fetch(retryOptions);
            _isRefreshing = false;
            handler.resolve(retryResp);
            return;
          }
        }
      } catch (_) {
        // Refresh failed — fall through to logout
      }

      _isRefreshing = false;
      await _clearAndLogout();
    } else if (err.response?.statusCode == 403) {
      await _clearAndLogout();
    }

    handler.next(err);
  }

  bool _isPublicEndpoint(String path) =>
      path.startsWith('/auth/') || path.startsWith('auth/');

  Future<void> _clearAndLogout() async {
    await _tokenStorage.deleteAll();
    if (ApiClient._onLogout != null) {
      await ApiClient._onLogout!();
    }
  }
}

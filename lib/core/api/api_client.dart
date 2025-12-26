import 'package:dio/dio.dart';

import '../storage/token_storage.dart';

// Callback type for handling logout
typedef LogoutCallback = Future<void> Function();

class ApiClient {
  final Dio _dio;
  final TokenStorage _tokenStorage;
  static LogoutCallback? _onLogout;

  // Set the logout callback (called from main.dart or dependency injection)
  static void setLogoutCallback(LogoutCallback callback) {
    _onLogout = callback;
  }

  ApiClient(this._tokenStorage)
      : _dio = Dio(BaseOptions(
          baseUrl: const String.fromEnvironment(
            'API_URL',
            defaultValue: 'https://creativelearningcenter-production.up.railway.app/',
          ),
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        )) {
    _dio.interceptors.add(AuthInterceptor(_tokenStorage));
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.get<T>(path, queryParameters: queryParameters);
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.post<T>(path, data: data, queryParameters: queryParameters);
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.put<T>(path, data: data, queryParameters: queryParameters);
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.patch<T>(path, data: data, queryParameters: queryParameters);
  }

  Future<Response<T>> delete<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.delete<T>(path, queryParameters: queryParameters);
  }
}

class AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;

  AuthInterceptor(this._tokenStorage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.getToken();
    if (token != null && !_isPublicEndpoint(options.path)) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 || err.response?.statusCode == 403) {
      // Token expired or invalid - clear token and trigger logout
      await _tokenStorage.deleteToken();
      
      // Trigger logout callback to update AuthBloc state
      if (ApiClient._onLogout != null) {
        await ApiClient._onLogout!();
      }
    }
    handler.next(err);
  }

  bool _isPublicEndpoint(String path) {
    return path.startsWith('/auth/') || path.startsWith('auth/');
  }
}
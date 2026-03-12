import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';
import '../errors/exceptions.dart';

/// Central HTTP client built on Dio.
/// Handles auth tokens, logging, error mapping, and connectivity checks.
class ApiClient {
  static const String _baseUrl     = 'https://your-backend.com/api/v1';
  static const String _tokenKey    = 'auth_token';
  static const String _refreshKey  = 'refresh_token';

  late final Dio _dio;
  final FlutterSecureStorage _storage;
  final Connectivity _connectivity;
  final Logger _logger;

  ApiClient({
    FlutterSecureStorage? storage,
    Connectivity? connectivity,
    Logger? logger,
  })  : _storage      = storage      ?? const FlutterSecureStorage(),
        _connectivity = connectivity ?? Connectivity(),
        _logger       = logger       ?? Logger() {
    _dio = Dio(
      BaseOptions(
        baseUrl:        _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout:    const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept':       'application/json',
          'X-App-Version': '1.0.0',
          'X-Platform':   'flutter',
        },
      ),
    );
    _initInterceptors();
  }

  // ── Interceptors ────────────────────────────────────────────────────────────

  void _initInterceptors() {
    // Auth token injector
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );

    // Logging (debug only — disable in production)
    _dio.interceptors.add(
      LogInterceptor(
        requestHeader:  false,
        requestBody:    true,
        responseHeader: false,
        responseBody:   true,
        error:          true,
        logPrint: (obj) => _logger.d(obj),
      ),
    );
  }

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Check connectivity before every request
    final result = await _connectivity.checkConnectivity();
    if (result == ConnectivityResult.none) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.unknown,
          error: const NetworkException(),
        ),
      );
      return;
    }

    // Attach Bearer token
    final token = await _storage.read(key: _tokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  void _onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    if (error.response?.statusCode == 401) {
      // Token expired — try to refresh
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        // Retry original request with new token
        final token = await _storage.read(key: _tokenKey);
        final opts   = error.requestOptions;
        opts.headers['Authorization'] = 'Bearer $token';
        try {
          final response = await _dio.fetch(opts);
          handler.resolve(response);
          return;
        } catch (_) {}
      }
      // Refresh failed — clear tokens
      await clearTokens();
    }
    handler.next(error);
  }

  Future<bool> _tryRefreshToken() async {
    try {
      final refreshToken = await _storage.read(key: _refreshKey);
      if (refreshToken == null) return false;

      final response = await Dio().post(
        '$_baseUrl/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final newToken   = response.data['token']        as String?;
      final newRefresh = response.data['refreshToken'] as String?;

      if (newToken == null) return false;

      await _storage.write(key: _tokenKey,   value: newToken);
      if (newRefresh != null) {
        await _storage.write(key: _refreshKey, value: newRefresh);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Public HTTP methods ──────────────────────────────────────────────────────

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _execute(() => _dio.get<T>(path, queryParameters: queryParameters, options: options));

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _execute(() => _dio.post<T>(path, data: data, queryParameters: queryParameters, options: options));

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Options? options,
  }) =>
      _execute(() => _dio.put<T>(path, data: data, options: options));

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Options? options,
  }) =>
      _execute(() => _dio.patch<T>(path, data: data, options: options));

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Options? options,
  }) =>
      _execute(() => _dio.delete<T>(path, data: data, options: options));

  // ── Error mapping ────────────────────────────────────────────────────────────

  Future<Response<T>> _execute<T>(Future<Response<T>> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  AppException _mapDioError(DioException e) {
    if (e.error is AppException) return e.error as AppException;
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException('Verbindingstimeout. Controleer je internetverbinding');
      case DioExceptionType.badResponse:
        final status  = e.response?.statusCode;
        final message = _extractErrorMessage(e.response?.data) ?? 'Server fout ($status)';
        if (status == 401) return AuthException(message, code: 'unauthorized');
        if (status == 403) return AuthException(message, code: 'forbidden');
        if (status == 404) return ServerException(message, statusCode: status, code: 'not_found');
        if (status == 422) return ValidationException(message);
        return ServerException(message, statusCode: status);
      case DioExceptionType.cancel:
        return const AppException('Verzoek geannuleerd');
      default:
        return NetworkException('Netwerkfout', e.error);
    }
  }

  String? _extractErrorMessage(dynamic data) {
    if (data == null) return null;
    if (data is Map) {
      return data['message'] as String? ??
             data['error']   as String? ??
             data['detail']  as String?;
    }
    return data.toString();
  }

  // ── Token management ────────────────────────────────────────────────────────

  Future<void> saveTokens(String token, {String? refreshToken}) async {
    await _storage.write(key: _tokenKey, value: token);
    if (refreshToken != null) {
      await _storage.write(key: _refreshKey, value: refreshToken);
    }
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshKey);
  }

  Future<String?> getToken()        => _storage.read(key: _tokenKey);
  Future<String?> getRefreshToken() => _storage.read(key: _refreshKey);
  Future<bool>    isLoggedIn()      async => (await getToken()) != null;

  /// Direct Dio accessor for advanced use cases (file upload, etc.)
  Dio get dio => _dio;
}

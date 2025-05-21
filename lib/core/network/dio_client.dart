import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import '../config/env.dart';
import '../constants/app_constants.dart';
import '../storage/secure_storage_service.dart';

class DioClient {
  late final Dio _dio;
  final SecureStorageService _storage;
  bool _isRefreshing = false;
  final _queue = <Future Function()>[];

  DioClient(this._storage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: Env.dreamServer,
        connectTimeout: Duration(milliseconds: AppConstants.apiTimeout),
        receiveTimeout: Duration(milliseconds: AppConstants.apiTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(this),
      _ErrorInterceptor(),
      LogInterceptor(requestBody: true, responseBody: true),
    ]);
  }

  Dio get dio => _dio;

  Future<String?> getAccessToken() => _storage.getAccessToken();
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.saveAccessToken(accessToken);
    await _storage.saveRefreshToken(refreshToken);
  }
}

class _AuthInterceptor extends Interceptor {
  final DioClient _client;

  _AuthInterceptor(this._client);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isAuthEndpoint(options.path)) {
      final token = await _client.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 &&
        !_isAuthEndpoint(err.requestOptions.path)) {
      try {
        final response = await _refreshToken(err);
        if (response != null) {
          return handler.resolve(response);
        }
      } catch (e) {
        // If refresh fails, clear tokens and redirect to login
        await _client._storage.deleteTokens();
        getx.Get.offAllNamed('/login');
      }
    }
    super.onError(err, handler);
  }

  Future<Response<dynamic>?> _refreshToken(DioException err) async {
    if (_client._isRefreshing) {
      // If already refreshing, add to queue
      return Future.delayed(
        const Duration(milliseconds: 100),
        () => _refreshToken(err),
      );
    }

    _client._isRefreshing = true;
    try {
      final refreshToken = await _client._storage.getRefreshToken();
      if (refreshToken == null) throw Exception('No refresh token found');

      final response = await _client._dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      final newAccessToken = response.data['access_token'];
      final newRefreshToken = response.data['refresh_token'];
      await _client.saveTokens(newAccessToken, newRefreshToken);

      // Retry the original request
      final opts = Options(
        method: err.requestOptions.method,
        headers: err.requestOptions.headers,
      );
      opts.headers?['Authorization'] = 'Bearer $newAccessToken';

      return await _client._dio.request(
        err.requestOptions.path,
        options: opts,
        data: err.requestOptions.data,
        queryParameters: err.requestOptions.queryParameters,
      );
    } finally {
      _client._isRefreshing = false;
    }
  }

  bool _isAuthEndpoint(String path) {
    return path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/auth/refresh');
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.data != null && err.response?.data['message'] != null) {
      err = err.copyWith(error: err.response?.data['message']);
    }
    super.onError(err, handler);
  }
}

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:the_dream_solution/core/storage/secure_storage.dart';
import 'package:the_dream_solution/features/auth/api/auth_api.dart';

// 인증 인터셉터 클래스
// HTTP 요청에 인증 토큰을 추가하고 토큰 갱신을 처리.
class AuthInterceptor {
  final SecureStorage _secureStorage;
  AuthApi? _authApi;

  AuthInterceptor(this._secureStorage);

  // URL이 인증이 필요한 엔드포인트인지 확인.
  bool _needsAuthentication(String url) {
    return url.contains('/boards');
  }

  // 요청 헤더에 인증 토큰 추가.
  Map<String, String> _addAuthHeader(
    Map<String, String> headers,
    String accessToken,
  ) {
    final updatedHeaders = Map<String, String>.from(headers);
    updatedHeaders['Authorization'] = 'Bearer $accessToken';
    return updatedHeaders;
  }

  // 리프레시 토큰을 사용하여 액세스 토큰 갱신.
  Future<bool> _refreshAccessToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) {
        return false;
      }

      _authApi ??= AuthApi(secureStorage: _secureStorage);
      return await _authApi!.refreshToken(refreshToken);
    } catch (e) {
      return false;
    }
  }

  // HTTP 요청을 가로채서 인증 토큰을 추가하고 토큰 갱신을 처리.
  Future<http.Response> interceptRequest(
    Future<http.Response> Function() requestFunction,
    String url,
    Map<String, String> headers,
  ) async {
    if (!_needsAuthentication(url)) {
      return await requestFunction();
    }

    final accessToken = await _secureStorage.getAccessToken();
    if (accessToken == null) {
      await _secureStorage.logoutAndNavigateToLogin();
      throw Exception('인증이 필요합니다. 다시 로그인해주세요.');
    }

    try {
      final response = await requestFunction();

      if (response.statusCode == 401) {
        final refreshSuccess = await _refreshAccessToken();
        if (refreshSuccess) {
          return await requestFunction();
        } else {
          await _secureStorage.logoutAndNavigateToLogin();
          throw Exception('세션이 만료되었습니다. 다시 로그인해주세요.');
        }
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // 멀티파트 요청을 가로채서 인증 토큰을 추가하고 토큰 갱신을 처리.
  Future<http.Response> interceptMultipartRequest(
    http.MultipartRequest request,
  ) async {
    if (!_needsAuthentication(request.url.toString())) {
      final streamedResponse = await request.send();
      return await http.Response.fromStream(streamedResponse);
    }

    final accessToken = await _secureStorage.getAccessToken();
    if (accessToken == null) {
      await _secureStorage.logoutAndNavigateToLogin();
      throw Exception('인증이 필요합니다. 다시 로그인해주세요.');
    }

    request.headers['Authorization'] = 'Bearer $accessToken';

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 401) {
        final refreshSuccess = await _refreshAccessToken();
        if (refreshSuccess) {
          final newAccessToken = await _secureStorage.getAccessToken();
          final newRequest = http.MultipartRequest(request.method, request.url);

          newRequest.fields.addAll(request.fields);
          newRequest.files.addAll(request.files);
          newRequest.headers.addAll(request.headers);
          newRequest.headers['Authorization'] = 'Bearer $newAccessToken';

          final retryStreamedResponse = await newRequest.send();
          return await http.Response.fromStream(retryStreamedResponse);
        } else {
          await _secureStorage.logoutAndNavigateToLogin();
          throw Exception('세션이 만료되었습니다. 다시 로그인해주세요.');
        }
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // 인증이 필요한 요청에 대해 인증 헤더 추가.
  Future<Map<String, String>> getAuthenticatedHeaders(
    String url,
    Map<String, String> originalHeaders,
  ) async {
    if (!_needsAuthentication(url)) {
      return originalHeaders;
    }

    final accessToken = await _secureStorage.getAccessToken();
    if (accessToken == null) {
      await _secureStorage.logoutAndNavigateToLogin();
      throw Exception('인증이 필요합니다. 다시 로그인해주세요.');
    }

    return _addAuthHeader(originalHeaders, accessToken);
  }
}

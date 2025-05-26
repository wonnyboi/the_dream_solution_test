import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:the_dream_solution/core/storage/secure_storage.dart';
import 'package:the_dream_solution/features/auth/api/auth_api.dart';

class AuthInterceptor {
  final SecureStorage _secureStorage;
  AuthApi? _authApi;

  AuthInterceptor(this._secureStorage);

  // Check if the request needs authentication
  bool _needsAuthentication(String url) {
    return url.contains('/boards');
  }

  // Add authorization header to request headers
  Map<String, String> _addAuthHeader(
    Map<String, String> headers,
    String accessToken,
  ) {
    final updatedHeaders = Map<String, String>.from(headers);
    updatedHeaders['Authorization'] = 'Bearer $accessToken';
    return updatedHeaders;
  }

  // Refresh access token using refresh token
  Future<bool> _refreshAccessToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) {
        debugPrint('⚠️ No refresh token available');
        return false;
      }

      debugPrint(
        '🔄 Attempting to refresh access token with refresh token: ${refreshToken.substring(0, 20)}...',
      );

      // Create a simple AuthApi instance without circular dependency
      _authApi ??= AuthApi(secureStorage: _secureStorage);
      final success = await _authApi!.refreshToken(refreshToken);

      if (success) {
        debugPrint('✅ Access token refreshed successfully');
        return true;
      } else {
        debugPrint('❌ Failed to refresh access token');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error refreshing token: $e');
      return false;
    }
  }

  // Intercept regular HTTP requests with retry policy
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
      debugPrint('⚠️ No access token found for authenticated request to: $url');
      await _secureStorage
          .logoutAndNavigateToLogin(); // Clear any invalid state and navigate
      throw Exception('인증이 필요합니다. 다시 로그인해주세요.');
    }

    debugPrint('🔐 Adding Bearer token to request: $url');

    try {
      // First attempt with current token
      final response = await requestFunction();

      // If token is expired (401), try to refresh and retry
      if (response.statusCode == 401) {
        debugPrint('🔄 Token expired (401), attempting refresh and retry');

        final refreshSuccess = await _refreshAccessToken();
        if (refreshSuccess) {
          debugPrint('🔁 Retrying original request with new token');
          // Retry the original request with new token
          return await requestFunction();
        } else {
          debugPrint('❌ Token refresh failed, user needs to login again');
          await _secureStorage
              .logoutAndNavigateToLogin(); // Clear invalid tokens and navigate
          throw Exception('세션이 만료되었습니다. 다시 로그인해주세요.');
        }
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Intercept multipart requests with retry policy
  Future<http.Response> interceptMultipartRequest(
    http.MultipartRequest request,
  ) async {
    if (!_needsAuthentication(request.url.toString())) {
      // For non-authenticated requests, send as-is
      final streamedResponse = await request.send();
      return await http.Response.fromStream(streamedResponse);
    }

    final accessToken = await _secureStorage.getAccessToken();
    if (accessToken == null) {
      debugPrint(
        '⚠️ No access token found for authenticated multipart request to: ${request.url}',
      );
      await _secureStorage
          .logoutAndNavigateToLogin(); // Clear any invalid state and navigate
      throw Exception('인증이 필요합니다. 다시 로그인해주세요.');
    }

    debugPrint('🔐 Adding Bearer token to multipart request: ${request.url}');
    request.headers['Authorization'] = 'Bearer $accessToken';

    // Debug: Check what Content-Type is set
    debugPrint('🔍 Multipart request headers before send: ${request.headers}');

    // Don't manually set or remove Content-Type - let MultipartRequest handle it automatically
    // The MultipartRequest will set Content-Type to multipart/form-data with boundary

    try {
      // First attempt with current token
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // If token is expired (401), try to refresh and retry
      if (response.statusCode == 401) {
        debugPrint(
          '🔄 Token expired (401), attempting refresh and retry for multipart',
        );

        final refreshSuccess = await _refreshAccessToken();
        if (refreshSuccess) {
          debugPrint('🔁 Retrying multipart request with new token');

          // Create a new request with refreshed token
          final newAccessToken = await _secureStorage.getAccessToken();
          final newRequest = http.MultipartRequest(request.method, request.url);

          // Copy all fields and files from original request
          newRequest.fields.addAll(request.fields);
          newRequest.files.addAll(request.files);
          newRequest.headers.addAll(request.headers);
          newRequest.headers['Authorization'] = 'Bearer $newAccessToken';

          // Don't manually set or remove Content-Type for retry - let MultipartRequest handle it

          // Send the retry request
          final retryStreamedResponse = await newRequest.send();
          return await http.Response.fromStream(retryStreamedResponse);
        } else {
          debugPrint('❌ Token refresh failed, user needs to login again');
          await _secureStorage
              .logoutAndNavigateToLogin(); // Clear invalid tokens and navigate
          throw Exception('세션이 만료되었습니다. 다시 로그인해주세요.');
        }
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Get headers with auth token if needed
  Future<Map<String, String>> getAuthenticatedHeaders(
    String url,
    Map<String, String> originalHeaders,
  ) async {
    if (!_needsAuthentication(url)) {
      return originalHeaders;
    }

    final accessToken = await _secureStorage.getAccessToken();
    if (accessToken == null) {
      debugPrint('⚠️ No access token found for request to: $url');
      await _secureStorage
          .logoutAndNavigateToLogin(); // Clear any invalid state and navigate
      throw Exception('인증이 필요합니다. 다시 로그인해주세요.');
    }

    debugPrint('🔐 Adding Bearer token to headers for: $url');
    return _addAuthHeader(originalHeaders, accessToken);
  }
}

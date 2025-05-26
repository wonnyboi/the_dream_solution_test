import 'package:http/http.dart' as http;
import 'package:the_dream_solution/core/network/api_client.dart';
import 'package:the_dream_solution/core/storage/secure_storage.dart';
import 'dart:convert';

class AuthApi {
  final ApiClient? _apiClient;
  final SecureStorage _secureStorage;
  final http.Client _httpClient;

  AuthApi({ApiClient? apiClient, SecureStorage? secureStorage})
    : _apiClient = apiClient,
      _secureStorage = secureStorage ?? SecureStorage(),
      _httpClient = http.Client();

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    try {
      final http.Response response;

      if (_apiClient != null) {
        // Use ApiClient when available (normal flow)
        response = await _apiClient.post(
          '/auth/signin',
          body: {'username': username, 'password': password},
        );
      } else {
        // Use direct HTTP call when called from interceptor (avoid circular dependency)
        const String baseUrl = 'https://front-mission.bigs.or.kr';
        final url = Uri.parse('$baseUrl/auth/signin');
        response = await _httpClient.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: json.encode({'username': username, 'password': password}),
        );
      }

      if (response.statusCode == 200) {
        await _secureStorage.handleUserInfoSave(username);
        return await _secureStorage.handleTokenResponse(
          response.body,
          response.statusCode,
        );
      } else {
        try {
          final Map<String, dynamic> errorJson = json.decode(response.body);
          final String message = errorJson['message'] ?? '알 수 없는 오류가 발생했습니다.';
          throw message;
        } catch (_) {
          throw '알 수 없는 오류가 발생했습니다.';
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<http.Response> signup({
    required String username,
    required String name,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      if (_apiClient != null) {
        // Use ApiClient when available (normal flow)
        final response = await _apiClient.post(
          '/auth/signup',
          body: {
            'username': username,
            'name': name,
            'password': password,
            'confirmPassword': confirmPassword,
          },
        );
        return response;
      } else {
        // Use direct HTTP call when called from interceptor
        const String baseUrl = 'https://front-mission.bigs.or.kr';
        final url = Uri.parse('$baseUrl/auth/signup');
        final response = await _httpClient.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: json.encode({
            'username': username,
            'name': name,
            'password': password,
            'confirmPassword': confirmPassword,
          }),
        );
        return response;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> refreshToken(String refreshToken) async {
    try {
      final http.Response response;

      if (_apiClient != null) {
        // Use ApiClient when available (normal flow)
        response = await _apiClient.post(
          '/auth/refresh',
          body: {'refreshToken': refreshToken},
        );
      } else {
        // Use direct HTTP call when called from interceptor
        const String baseUrl = 'https://front-mission.bigs.or.kr';
        final url = Uri.parse('$baseUrl/auth/refresh');
        response = await _httpClient.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: json.encode({'refreshToken': refreshToken}),
        );
      }

      if (response.statusCode == 200) {
        return await _secureStorage.handleTokenResponse(
          response.body,
          response.statusCode,
        );
      } else {
        throw Exception('Failed to refresh token');
      }
    } catch (e) {
      rethrow;
    }
  }

  void dispose() {
    _apiClient?.dispose();
    _httpClient.close();
  }
}

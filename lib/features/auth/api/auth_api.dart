import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:the_dream_solution/core/network/api_client.dart';
import 'package:the_dream_solution/core/storage/secure_storage.dart';
import 'package:the_dream_solution/core/config/env.dart';
import 'dart:convert';

/// 인증 관련 API 처리
class AuthApi {
  final ApiClient? _apiClient;
  final SecureStorage _secureStorage;
  final http.Client _httpClient;

  AuthApi({ApiClient? apiClient, SecureStorage? secureStorage})
    : _apiClient = apiClient,
      _secureStorage = secureStorage ?? SecureStorage(),
      _httpClient = http.Client();

  /// 로그인 처리
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    try {
      final http.Response response;

      if (_apiClient != null) {
        response = await _apiClient.post(
          '/auth/signin',
          body: {'username': username, 'password': password},
        );
      } else {
        final url = Uri.parse('${Env.dreamServer}/auth/signin');
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
        return await _secureStorage.handleTokenResponse(
          response.body,
          response.statusCode,
          isLogin: true,
        );
      } else {
        try {
          final Map<String, dynamic> errorJson = json.decode(response.body);
          throw errorJson['message'] ?? '알 수 없는 오류가 발생했습니다.';
        } catch (_) {
          throw '알 수 없는 오류가 발생했습니다.';
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 회원가입 처리
  Future<http.Response> signup({
    required String username,
    required String name,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      if (_apiClient != null) {
        return await _apiClient.post(
          '/auth/signup',
          body: {
            'username': username,
            'name': name,
            'password': password,
            'confirmPassword': confirmPassword,
          },
        );
      } else {
        final url = Uri.parse('${Env.dreamServer}/auth/signup');
        return await _httpClient.post(
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
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 토큰 갱신
  Future<bool> refreshToken(String refreshToken) async {
    try {
      final http.Response response;

      if (_apiClient != null) {
        response = await _apiClient.post(
          '/auth/refresh',
          body: {'refreshToken': refreshToken},
        );
      } else {
        final url = Uri.parse('${Env.dreamServer}/auth/refresh');
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
        throw Exception('토큰 갱신에 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// HTTP 클라이언트 종료
  void dispose() {
    _apiClient?.dispose();
    _httpClient.close();
  }
}

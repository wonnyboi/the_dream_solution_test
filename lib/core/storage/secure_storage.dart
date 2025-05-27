import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

import 'package:the_dream_solution/features/auth/util/auth_validator.dart';
import 'package:the_dream_solution/core/services/navigation_service.dart';

/// 앱 민감 데이터 저장 및 관리
class SecureStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// 저장소 키
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _usernameKey = 'username';
  static const String _nameKey = 'name';
  static const String _savedEmailKey = 'saved_email';
  static const String _autoLoginKey = 'auto_login';

  /// 토큰 저장
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// 사용자 정보 저장
  Future<void> saveUsername(String username) async {
    await _storage.write(key: _usernameKey, value: username);
  }

  Future<String?> getUsername() async {
    return await _storage.read(key: _usernameKey);
  }

  Future<void> saveName(String name) async {
    await _storage.write(key: _nameKey, value: name);
  }

  Future<String?> getName() async {
    return await _storage.read(key: _nameKey);
  }

  /// 자동 로그인 설정
  Future<void> saveEmailForAutoLogin(String email) async {
    await _storage.write(key: _savedEmailKey, value: email);
  }

  Future<String?> getSavedEmail() async {
    return await _storage.read(key: _savedEmailKey);
  }

  Future<void> setAutoLogin(bool value) async {
    await _storage.write(key: _autoLoginKey, value: value.toString());
  }

  Future<bool> isAutoLoginEnabled() async {
    final value = await _storage.read(key: _autoLoginKey);
    return value == 'true';
  }

  /// 로그아웃 처리
  Future<void> _clearAuthData() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _usernameKey);
    await _storage.delete(key: _nameKey);
  }

  Future<void> logout() async {
    await _clearAuthData();
  }

  Future<void> logoutAndNavigateToLogin() async {
    await _clearAuthData();
    NavigationService.clearAllAndNavigateToLogin();
  }

  Future<bool> isLoggedIn() async {
    final accessToken = await getAccessToken();
    return accessToken != null;
  }

  /// JWT 토큰 디코딩
  Map<String, dynamic> decodeJwtPayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('잘못된 토큰 형식입니다');
    }

    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));

    return json.decode(decoded);
  }

  /// 토큰 응답 처리
  Future<bool> handleTokenResponse(
    String responseBody,
    int statusCode, {
    bool isLogin = false,
  }) async {
    if (statusCode == 200) {
      try {
        final Map<String, dynamic> response = json.decode(responseBody);
        final String accessToken = response['accessToken'];
        final String refreshToken = response['refreshToken'];

        if (accessToken.isEmpty || refreshToken.isEmpty) {
          throw Exception('유효하지 않은 토큰 데이터입니다');
        }

        if (isLogin) {
          final Map<String, dynamic> payload = decodeJwtPayload(accessToken);
          await handleUserInfoSave(payload['username'], payload['name']);
        }

        await saveAccessToken(accessToken);
        await saveRefreshToken(refreshToken);

        return true;
      } catch (e) {
        throw Exception('로그인 응답 처리 실패: $e');
      }
    } else if (statusCode == 400) {
      throw Exception(responseBody);
    } else {
      throw Exception('예기치 않은 오류가 발생했습니다');
    }
  }

  Future<void> handleUserInfoSave(String username, String name) async {
    await saveUsername(username);
    await saveName(name);
  }
}

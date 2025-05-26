import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

import 'package:the_dream_solution/features/auth/util/auth_validator.dart';
import 'package:the_dream_solution/core/services/navigation_service.dart';

class SecureStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Keys for storage
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _usernameKey = 'username';
  static const String _nameKey = 'name';

  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
    debugPrint('saveAccessToken: $token');
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
    debugPrint('saveRefreshToken: $token');
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<void> saveUsername(String username) async {
    await _storage.write(key: _usernameKey, value: username);
    debugPrint('saveUsername: $username');
  }

  Future<String?> getUsername() async {
    return await _storage.read(key: _usernameKey);
  }

  Future<void> saveName(String name) async {
    await _storage.write(key: _nameKey, value: name);
    debugPrint('saveName: $name');
  }

  Future<String?> getName() async {
    return await _storage.read(key: _nameKey);
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<void> logoutAndNavigateToLogin() async {
    debugPrint('🚪 Performing logout and navigating to login page');
    await _storage.deleteAll();
    NavigationService.clearAllAndNavigateToLogin();
  }

  Future<bool> isLoggedIn() async {
    final accessToken = await getAccessToken();
    return accessToken != null;
  }

  Future<bool> handleTokenResponse(String responseBody, int statusCode) async {
    if (statusCode == 200) {
      try {
        final Map<String, dynamic> response = json.decode(responseBody);
        final String accessToken = response['accessToken'];
        final String refreshToken = response['refreshToken'];

        if (accessToken.isEmpty || refreshToken.isEmpty) {
          throw Exception('Invalid token data received');
        }

        await saveAccessToken(accessToken);
        await saveRefreshToken(refreshToken);

        return true;
      } catch (e) {
        throw Exception('Failed to process login response: $e');
      }
    } else if (statusCode == 400) {
      throw Exception(responseBody);
    } else {
      throw Exception('Unexpected error occurred');
    }
  }

  Future<void> handleUserInfoSave(String username) async {
    await saveUsername(username);
    await saveName(AuthValidator.generateNickname(username));
  }
}

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_dream_solution/features/auth/api/auth_api.dart';
import 'package:the_dream_solution/features/auth/util/auth_validator.dart';
import 'package:the_dream_solution/core/storage/secure_storage.dart';
import 'package:the_dream_solution/core/network/api_client.dart';
import 'package:flutter/material.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(authApiProvider),
    ref.read(secureStorageProvider),
  );
});

final authApiProvider = Provider<AuthApi>(
  (ref) => AuthApi(
    apiClient: ApiClient(),
    secureStorage: ref.read(secureStorageProvider),
  ),
);
final secureStorageProvider = Provider<SecureStorage>((ref) => SecureStorage());

// 인증 상태
class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final bool isAuthenticated;
  final String email;
  final String name;
  final String password;
  final String confirmPassword;

  AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.isAuthenticated = false,
    this.email = '',
    this.name = '',
    this.password = '',
    this.confirmPassword = '',
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isAuthenticated,
    String? email,
    String? name,
    String? password,
    String? confirmPassword,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      email: email ?? this.email,
      name: name ?? this.name,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
    );
  }
}

// 인증 상태 관리
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthApi _authApi;
  final SecureStorage _secureStorage;

  AuthNotifier(this._authApi, this._secureStorage) : super(AuthState());

  // 로그인 처리
  Future<bool> loginWithCredentials({
    required String username,
    required String password,
    bool saveEmail = false,
    bool autoLogin = false,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final emailError = AuthValidator.validateEmail(username);
      final passwordError = AuthValidator.validatePassword(password);

      if (emailError != null || passwordError != null) {
        throw emailError ?? passwordError ?? '입력값이 올바르지 않습니다';
      }

      final success = await _authApi.login(
        username: username,
        password: password,
      );

      if (success) {
        state = state.copyWith(isAuthenticated: true);
        if (saveEmail) {
          await _secureStorage.saveEmailForAutoLogin(username);
        }
        await _secureStorage.setAutoLogin(autoLogin);
      }

      return success;
    } catch (e) {
      state = state.copyWith(errorMessage: e is String ? e : e.toString());
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // 회원가입 처리
  Future<bool> signupWithCredentials({
    required String username,
    required String name,
    required String password,
    required String confirmPassword,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final emailError = AuthValidator.validateEmail(username);
      final passwordError = AuthValidator.validatePassword(password);
      final confirmPasswordError = AuthValidator.validateConfirmPassword(
        confirmPassword,
        password,
      );

      if (emailError != null ||
          passwordError != null ||
          confirmPasswordError != null) {
        throw emailError ??
            passwordError ??
            confirmPasswordError ??
            '입력값이 올바르지 않습니다';
      }

      final response = await _authApi.signup(
        username: username,
        name: name,
        password: password,
        confirmPassword: confirmPassword,
      );

      return response.statusCode == 200;
    } catch (e) {
      state = state.copyWith(errorMessage: e is String ? e : e.toString());
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // 로그아웃 처리
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      await _secureStorage.logoutAndNavigateToLogin();
      state = state.copyWith(isAuthenticated: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e is String ? e : e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // 자동 로그인 확인
  Future<bool> checkAutoLogin() async {
    try {
      final savedEmail = await _secureStorage.getSavedEmail();
      final isAutoLoginEnabled = await _secureStorage.isAutoLoginEnabled();

      if (savedEmail != null && isAutoLoginEnabled) {
        return await loginWithCredentials(
          username: savedEmail,
          password: '',
          saveEmail: true,
          autoLogin: true,
        );
      }
      return false;
    } catch (e) {
      state = state.copyWith(errorMessage: e is String ? e : e.toString());
      return false;
    }
  }

  // 로그인 상태 확인
  Future<bool> checkLoginStatus() async {
    final isLoggedIn = await _secureStorage.isLoggedIn();
    state = state.copyWith(isAuthenticated: isLoggedIn);
    return isLoggedIn;
  }

  // 에러 초기화
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void updateEmail(String email) {
    state = state.copyWith(email: email);
  }

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password);
  }

  void updateConfirmPassword(String confirmPassword) {
    state = state.copyWith(confirmPassword: confirmPassword);
  }

  @override
  void dispose() {
    _authApi.dispose();
    super.dispose();
  }
}

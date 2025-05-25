import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_dream_solution/features/auth/api/auth_api.dart';
import 'package:the_dream_solution/features/auth/util/auth_validator.dart';
import 'package:the_dream_solution/core/storage/secure_storage.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(authApiProvider),
    ref.read(secureStorageProvider),
  );
});

final authApiProvider = Provider<AuthApi>((ref) => AuthApi());
final secureStorageProvider = Provider<SecureStorage>((ref) => SecureStorage());

class AuthState {
  final String email;
  final String password;
  final String confirmPassword;
  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;
  final String? errorMessage;
  final bool isLoading;
  final bool isAuthenticated;

  AuthState({
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.emailError,
    this.passwordError,
    this.confirmPasswordError,
    this.errorMessage,
    this.isLoading = false,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    String? email,
    String? password,
    String? confirmPassword,
    String? emailError,
    String? passwordError,
    String? confirmPasswordError,
    String? errorMessage,
    bool? isLoading,
    bool? isAuthenticated,
  }) {
    return AuthState(
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      emailError: emailError ?? this.emailError,
      passwordError: passwordError ?? this.passwordError,
      confirmPasswordError: confirmPasswordError ?? this.confirmPasswordError,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthApi _authApi;
  final SecureStorage _secureStorage;

  AuthNotifier(this._authApi, this._secureStorage) : super(AuthState());

  void updateEmail(String email) {
    state = state.copyWith(
      email: email,
      emailError: AuthValidator.validateEmail(email),
    );
  }

  void updatePassword(String password) {
    state = state.copyWith(
      password: password,
      passwordError: AuthValidator.validatePassword(password),
    );
  }

  void updateConfirmPassword(String confirmPassword) {
    state = state.copyWith(
      confirmPassword: confirmPassword,
      confirmPasswordError: AuthValidator.validateConfirmPassword(
        confirmPassword,
        state.password,
      ),
    );
  }

  Future<bool> login() async {
    if (state.emailError != null || state.passwordError != null) {
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final success = await _authApi.login(
        username: state.email,
        password: state.password,
      );

      if (success) {
        state = state.copyWith(isAuthenticated: true);
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(errorMessage: e is String ? e : e.toString());
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> signup() async {
    if (state.emailError != null ||
        state.passwordError != null ||
        state.confirmPasswordError != null) {
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _authApi.signup(
        username: state.email,
        name: AuthValidator.generateNickname(state.email),
        password: state.password,
        confirmPassword: state.confirmPassword,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final Map<String, dynamic> errorJson = json.decode(response.body);
        state = state.copyWith(
          errorMessage: errorJson['message'] ?? '알 수 없는 오류가 발생했습니다.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(errorMessage: e is String ? e : e.toString());
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> logout() async {
    await _secureStorage.logout();
    state = state.copyWith(isAuthenticated: false);
  }

  Future<bool> checkAuthStatus() async {
    final isLoggedIn = await _secureStorage.isLoggedIn();
    state = state.copyWith(isAuthenticated: isLoggedIn);
    return isLoggedIn;
  }

  Future<bool> loginWithCredentials(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final success = await _authApi.login(username: email, password: password);
      if (success) {
        state = state.copyWith(isAuthenticated: true);
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(errorMessage: e is String ? e : e.toString());
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> signupWithCredentials(
    String email,
    String password,
    String confirmPassword,
  ) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _authApi.signup(
        username: email,
        name: AuthValidator.generateNickname(email),
        password: password,
        confirmPassword: confirmPassword,
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        final Map<String, dynamic> errorJson = json.decode(response.body);
        state = state.copyWith(
          errorMessage: errorJson['message'] ?? '알 수 없는 오류가 발생했습니다.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(errorMessage: e is String ? e : e.toString());
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

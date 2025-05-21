import 'package:dio/dio.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;
  final SecureStorageService _storage;

  AuthRepositoryImpl(this._dio, this._storage);

  @override
  Future<UserModel> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'username': username, 'password': password},
      );

      final user = UserModel.fromJson(response.data['user']);
      await _storage.saveAccessToken(response.data['access_token']);
      await _storage.saveRefreshToken(response.data['refresh_token']);

      return user;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<UserModel> register(
    String email,
    String password,
    String username,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {'email': email, 'password': password, 'username': username},
      );

      final user = UserModel.fromJson(response.data['user']);
      await _storage.saveAccessToken(response.data['access_token']);
      await _storage.saveRefreshToken(response.data['refresh_token']);

      return user;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
      await _storage.deleteTokens();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final response = await _dio.get('/auth/me');
      return UserModel.fromJson(response.data['user']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return null;
      }
      throw _handleError(e);
    }
  }

  @override
  Future<void> refreshToken() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null) throw Exception('No refresh token found');

      final response = await _dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      await _storage.saveAccessToken(response.data['access_token']);
      await _storage.saveRefreshToken(response.data['refresh_token']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.response?.data != null && e.response?.data['message'] != null) {
      return Exception(e.response?.data['message']);
    }
    return Exception('An error occurred');
  }
}

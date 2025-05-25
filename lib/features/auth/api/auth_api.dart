import 'package:http/http.dart' as http;
import 'package:thedreamsolution/core/network/api_client.dart';

class AuthApi {
  final ApiClient _apiClient;

  AuthApi({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<http.Response> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/signin',
        body: {'username': username, 'password': password},
      );
      return response;
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
    } catch (e) {
      rethrow;
    }
  }

  void dispose() {
    _apiClient.dispose();
  }
}

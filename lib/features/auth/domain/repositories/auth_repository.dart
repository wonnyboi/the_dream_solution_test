import '../models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel> login(String username, String password);
  Future<UserModel> register(String username, String name, String password);
  Future<void> logout();
  Future<void> refreshToken();
}

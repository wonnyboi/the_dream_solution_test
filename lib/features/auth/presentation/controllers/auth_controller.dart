import 'package:get/get.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository;

  AuthController(this._authRepository);

  final _user = Rxn<UserModel>();
  final _isLoading = false.obs;
  final _error = RxnString();

  UserModel? get user => _user.value;
  bool get isLoading => _isLoading.value;
  String? get error => _error.value;
  bool get isAuthenticated => _user.value != null;

  Future<void> login(String email, String password) async {
    try {
      _isLoading.value = true;
      _error.value = null;
      _user.value = await _authRepository.login(email, password);
      Get.offAllNamed('/home');
    } catch (e) {
      _error.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> register(String username, String password, String name) async {
    try {
      _isLoading.value = true;
      _error.value = null;
      _user.value = await _authRepository.register(username, name, username);
      Get.offAllNamed('/home');
    } catch (e) {
      _error.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      _isLoading.value = true;
      _error.value = null;
      await _authRepository.logout();
      _user.value = null;
      Get.offAllNamed('/login');
    } catch (e) {
      _error.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }
}

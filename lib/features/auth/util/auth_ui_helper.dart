import 'package:the_dream_solution/features/auth/util/auth_validator.dart';

class AuthUiHelper {
  /// Trims and validates the email for UI usage
  static String? validateAndTrimEmail(String? email) {
    final trimmed = email?.trim() ?? '';
    return AuthValidator.validateEmail(trimmed);
  }

  /// Trims and validates the password for UI usage
  static String? validateAndTrimPassword(String? password) {
    final trimmed = password?.trim() ?? '';
    return AuthValidator.validatePassword(trimmed);
  }

  /// Trims and validates the confirm password for UI usage
  static String? validateAndTrimConfirmPassword(
    String? confirmPassword,
    String password,
  ) {
    final trimmed = confirmPassword?.trim() ?? '';
    return AuthValidator.validateConfirmPassword(trimmed, password.trim());
  }

  /// Returns trimmed email
  static String trimEmail(String? email) => email?.trim() ?? '';

  /// Returns trimmed password
  static String trimPassword(String? password) => password?.trim() ?? '';
}

class ValidationService {
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidUsername(String username) {
    return username.length >= 3;
  }

  static bool hasMinLength(String password) {
    return password.length >= 8;
  }

  static bool hasNumber(String password) {
    return RegExp(r'[0-9]').hasMatch(password);
  }

  static bool hasLetter(String password) {
    return RegExp(r'[a-zA-Z]').hasMatch(password);
  }

  static bool hasSpecialChar(String password) {
    return RegExp(r'[!%*#?&]').hasMatch(password);
  }

  static bool isPasswordValid(String password) {
    return hasMinLength(password) &&
        hasNumber(password) &&
        hasLetter(password) &&
        hasSpecialChar(password);
  }
}

class AuthValidator {
  // Email validation regex
  static final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$');

  // Password validation regex
  static final RegExp passwordRegex = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!%*#?&])[A-Za-z\d!%*#?&]{8,}$',
  );

  // Domain to number mapping for nickname generation
  static const Map<String, int> domainNumbers = {
    'gmail.com': 1,
    'google.com': 2,
    'naver.com': 3,
    'daum.net': 4,
    'kakao.com': 5,
    'outlook.com': 6,
    'hotmail.com': 7,
    'yahoo.com': 8,
  };

  /// Validates email format
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return '이메일을 입력해주세요';
    }
    if (!emailRegex.hasMatch(email)) {
      return '올바른 이메일 형식이 아닙니다';
    }
    return null;
  }

  /// Validates password complexity
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return '비밀번호를 입력해주세요';
    }
    if (!passwordRegex.hasMatch(password)) {
      return '비밀번호는 8자 이상, 숫자, 영문자, 특수문자(!%*#?&)를 포함해야 합니다';
    }
    return null;
  }

  /// Validates password confirmation
  static String? validateConfirmPassword(
    String? confirmPassword,
    String password,
  ) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return '비밀번호를 다시 입력해주세요';
    }
    if (confirmPassword != password) {
      return '비밀번호가 일치하지 않습니다';
    }
    return null;
  }

  static String generateNickname(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;

    final username = parts[0];
    final domain = parts[1].toLowerCase();

    final domainNumber =
        domainNumbers[domain] ?? (domain.hashCode % 1000).abs();

    return '$username$domainNumber';
  }
}

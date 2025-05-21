import 'package:flutter/material.dart';
import 'validation_service.dart';

class ValidationState extends ChangeNotifier {
  bool _isValidEmail = false;
  bool _isValidUsername = false;
  bool _hasMinLength = false;
  bool _hasNumber = false;
  bool _hasLetter = false;
  bool _hasSpecialChar = false;

  bool get isValidEmail => _isValidEmail;
  bool get isValidUsername => _isValidUsername;
  bool get hasMinLength => _hasMinLength;
  bool get hasNumber => _hasNumber;
  bool get hasLetter => _hasLetter;
  bool get hasSpecialChar => _hasSpecialChar;

  void validateEmail(String email) {
    _isValidEmail = ValidationService.isValidEmail(email);
    notifyListeners();
  }

  void validateUsername(String username) {
    _isValidUsername = ValidationService.isValidUsername(username);
    notifyListeners();
  }

  void validatePassword(String password) {
    _hasMinLength = ValidationService.hasMinLength(password);
    _hasNumber = ValidationService.hasNumber(password);
    _hasLetter = ValidationService.hasLetter(password);
    _hasSpecialChar = ValidationService.hasSpecialChar(password);
    notifyListeners();
  }
}

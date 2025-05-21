import 'package:flutter/material.dart';

class PasswordValidation extends StatelessWidget {
  final bool hasMinLength;
  final bool hasNumber;
  final bool hasLetter;
  final bool hasSpecialChar;
  final bool hasFocus;

  const PasswordValidation({
    super.key,
    required this.hasMinLength,
    required this.hasNumber,
    required this.hasLetter,
    required this.hasSpecialChar,
    required this.hasFocus,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasFocus && hasMinLength && hasNumber && hasLetter && hasSpecialChar) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '8자 이상의 비밀번호를 입력해주세요',
          style: TextStyle(
            color: hasMinLength ? Colors.green : Colors.red,
            fontSize: 12,
          ),
        ),
        Text(
          '숫자, 영문자, 특수문자(!%*#?&)를 포함해주세요',
          style: TextStyle(
            color:
                hasNumber && hasLetter && hasSpecialChar
                    ? Colors.green
                    : Colors.red,
            fontSize: 12,
          ),
        ),
        Text(
          '예: Password123!',
          style: TextStyle(
            color:
                hasMinLength && hasNumber && hasLetter && hasSpecialChar
                    ? Colors.green
                    : Colors.red,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class SignupForm extends StatelessWidget {
  final String email;
  final String password;
  final String confirmPassword;
  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;
  final String? errorMessage;
  final bool isLoading;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final ValueChanged<String> onConfirmPasswordChanged;
  final VoidCallback onSignup;
  final VoidCallback onLoginPressed;

  const SignupForm({
    super.key,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.emailError,
    required this.passwordError,
    required this.confirmPasswordError,
    required this.errorMessage,
    required this.isLoading,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onConfirmPasswordChanged,
    required this.onSignup,
    required this.onLoginPressed,
  });

  Widget _buildCheckIcon(bool isValid) {
    return isValid
        ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
        : const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEmailField(),
          const SizedBox(height: 24),
          _buildPasswordField(),
          const SizedBox(height: 24),
          _buildConfirmPasswordField(),
          const SizedBox(height: 24),
          _buildLoginLink(),
          if (errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ],
          const SizedBox(height: 24),
          _buildSignupButton(),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('이메일', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: email,
          onChanged: (value) => onEmailChanged(value.trim()),
          decoration: InputDecoration(
            hintText: '이메일을 입력해주세요',
            filled: true,
            fillColor: const Color(0xFFF1F5F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            errorText: emailError,
            suffixIcon: _buildCheckIcon(emailError == null && email.isNotEmpty),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('비밀번호', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: password,
          onChanged: onPasswordChanged,
          decoration: InputDecoration(
            hintText: '비밀번호를 입력해주세요',
            filled: true,
            fillColor: const Color(0xFFF1F5F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            errorText: passwordError,
            suffixIcon: _buildCheckIcon(
              passwordError == null && password.isNotEmpty,
            ),
          ),
          obscureText: true,
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('비밀번호 확인', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: confirmPassword,
          onChanged: onConfirmPasswordChanged,
          decoration: InputDecoration(
            hintText: '비밀번호를 다시 입력해주세요',
            filled: true,
            fillColor: const Color(0xFFF1F5F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            errorText: confirmPasswordError,
            suffixIcon: _buildCheckIcon(
              confirmPasswordError == null && confirmPassword.isNotEmpty,
            ),
          ),
          obscureText: true,
        ),
      ],
    );
  }

  Widget _buildLoginLink() {
    return Row(
      children: [
        const Spacer(),
        TextButton(
          onPressed: onLoginPressed,
          child: const Text(
            '이미 계정이 있으신가요?',
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }

  Widget _buildSignupButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onSignup,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child:
            isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('회원가입', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}

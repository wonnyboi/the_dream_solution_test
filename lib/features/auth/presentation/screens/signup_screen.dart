import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../../util/auth_ui_helper.dart';
import 'package:the_dream_solution/features/auth/util/auth_validator.dart';
import 'package:go_router/go_router.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _submitError;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateEmail(String value) {
    setState(() {
      _emailError = AuthValidator.validateEmail(value.trim());
    });
  }

  void _validatePassword(String value) {
    setState(() {
      _passwordError = AuthValidator.validatePassword(value.trim());
    });
  }

  void _validateConfirmPassword(String value) {
    setState(() {
      _confirmPasswordError = AuthValidator.validateConfirmPassword(
        value.trim(),
        _passwordController.text.trim(),
      );
    });
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    setState(() {
      _emailError = AuthValidator.validateEmail(email);
      _passwordError = AuthValidator.validatePassword(password);
      _confirmPasswordError = AuthValidator.validateConfirmPassword(
        confirmPassword,
        password,
      );
      _submitError = null;
    });
    if (_emailError != null ||
        _passwordError != null ||
        _confirmPasswordError != null)
      return;
    setState(() {
      _isLoading = true;
    });
    final controller = ref.read(authProvider.notifier);
    final success = await controller.signupWithCredentials(
      email,
      password,
      confirmPassword,
    );
    setState(() {
      _isLoading = false;
    });
    if (success) {
      if (context.mounted) {
        context.go('/login');
      }
    } else {
      setState(() {
        _submitError = ref.read(authProvider).errorMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width:
                MediaQuery.of(context).size.width > 900
                    ? 900
                    : MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    '더드림솔루션',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '이메일',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        onChanged: _validateEmail,
                        decoration: InputDecoration(
                          hintText: '이메일을 입력해주세요',
                          filled: true,
                          fillColor: const Color(0xFFF1F5F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          errorText: _emailError,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        '비밀번호',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        onChanged: _validatePassword,
                        decoration: InputDecoration(
                          hintText: '비밀번호를 입력해주세요',
                          filled: true,
                          fillColor: const Color(0xFFF1F5F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          errorText: _passwordError,
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        '비밀번호 확인',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _confirmPasswordController,
                        onChanged: _validateConfirmPassword,
                        decoration: InputDecoration(
                          hintText: '비밀번호를 다시 입력해주세요',
                          filled: true,
                          fillColor: const Color(0xFFF1F5F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          errorText: _confirmPasswordError,
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          const Spacer(),
                          TextButton(
                            onPressed: () => context.go('/login'),
                            child: const Text(
                              '이미 계정이 있으신가요?',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                      if (_submitError != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _submitError!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child:
                              _isLoading
                                  ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : const Text(
                                    '회원가입',
                                    style: TextStyle(fontSize: 16),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../util/auth_ui_helper.dart';
import 'signup_screen.dart';
import 'package:the_dream_solution/features/auth/util/auth_validator.dart';
import 'package:the_dream_solution/features/main/presentation/screens/main_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:the_dream_solution/core/storage/secure_storage.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final SecureStorage _secureStorage = SecureStorage();

  String? _emailError;
  String? _passwordError;
  String? _submitError;
  bool _isLoading = false;
  bool _saveEmail = false;
  bool _autoLogin = false;

  @override
  void initState() {
    super.initState();
    _loadSavedPreferences();
  }

  Future<void> _loadSavedPreferences() async {
    final savedEmail = await _secureStorage.getSavedEmail();
    final isAutoLoginEnabled = await _secureStorage.isAutoLoginEnabled();

    if (savedEmail != null) {
      setState(() {
        _emailController.text = savedEmail;
        _saveEmail = true;
      });
    }

    if (isAutoLoginEnabled) {
      setState(() {
        _autoLogin = true;
      });
      // If auto login is enabled, attempt to login automatically
      if (savedEmail != null) {
        _submit();
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    setState(() {
      _emailError = AuthValidator.validateEmail(email);
      _passwordError = AuthValidator.validatePassword(password);
      _submitError = null;
    });
    if (_emailError != null || _passwordError != null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('🔐 Starting login attempt for: $email');
      final controller = ref.read(authProvider.notifier);
      final success = await controller.loginWithCredentials(
        username: email,
        password: password,
      );

      debugPrint('🔐 Login result: $success');

      if (success) {
        // Save preferences if checked
        if (_saveEmail) {
          await _secureStorage.saveEmailForAutoLogin(email);
        } else {
          await _secureStorage.saveEmailForAutoLogin('');
        }
        await _secureStorage.setAutoLogin(_autoLogin);

        debugPrint('✅ Login successful, navigating to main');
        if (context.mounted) {
          context.go('/main');
        }
      } else {
        final errorMessage = ref.read(authProvider).errorMessage;
        debugPrint('❌ Login failed: $errorMessage');
        setState(() {
          _submitError = errorMessage ?? '로그인에 실패했습니다. 다시 시도해주세요.';
        });
      }
    } catch (e) {
      debugPrint('❌ Login exception: $e');
      setState(() {
        _submitError = '네트워크 오류가 발생했습니다. 다시 시도해주세요.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToSignup() {
    context.go('/signup');
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 24,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: Checkbox(
                                    visualDensity: VisualDensity.compact,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    value: _saveEmail,
                                    onChanged: (value) {
                                      setState(() {
                                        _saveEmail = value ?? false;
                                        if (!_saveEmail) {
                                          _autoLogin = false;
                                        }
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'ID 저장',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            height: 24,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: Checkbox(
                                    visualDensity: VisualDensity.compact,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    value: _autoLogin,
                                    onChanged: (value) {
                                      setState(() {
                                        _autoLogin = value ?? false;
                                        if (_autoLogin) {
                                          _saveEmail = true;
                                        }
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  '자동 로그인',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
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
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          const Spacer(),
                          TextButton(
                            onPressed: _navigateToSignup,
                            child: const Text(
                              '계정이 없으신가요?',
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
                                    '로그인',
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

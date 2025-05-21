import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../utils/validation_state.dart';
import '../widgets/validation_text_field.dart';
import '../widgets/password_validation.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _emailFocusNode = FocusNode();
  final _usernameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  late final ValidationState _validationState;

  @override
  void initState() {
    super.initState();
    _validationState = ValidationState();
    _emailController.addListener(
      () => _validationState.validateEmail(_emailController.text),
    );
    _usernameController.addListener(
      () => _validationState.validateUsername(_usernameController.text),
    );
    _passwordController.addListener(
      () => _validationState.validatePassword(_passwordController.text),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocusNode.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              ListenableBuilder(
                listenable: _validationState,
                builder:
                    (context, _) => ValidationTextField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      label: '이메일',
                      isValid: _validationState.isValidEmail,
                      validationMessage:
                          '이메일 형식으로 입력해주세요 (예: user@example.com)',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '이메일 형식의 아이디를 작성해주세요';
                        }
                        if (!_validationState.isValidEmail) {
                          return '이메일 형식의 아이디를 작성해주세요';
                        }
                        return null;
                      },
                    ),
              ),
              const SizedBox(height: 16),
              ListenableBuilder(
                listenable: _validationState,
                builder:
                    (context, _) => ValidationTextField(
                      controller: _usernameController,
                      focusNode: _usernameFocusNode,
                      label: '닉네임',
                      isValid: _validationState.isValidUsername,
                      validationMessage: '3글자 이상의 닉네임을 입력해주세요 (예: 홍길동)',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '닉네임을 작성해주세요.';
                        }
                        if (!_validationState.isValidUsername) {
                          return '닉네임은 3글자 이상이어야 합니다.';
                        }
                        return null;
                      },
                    ),
              ),
              const SizedBox(height: 16),
              ListenableBuilder(
                listenable: _validationState,
                builder:
                    (context, _) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          decoration: const InputDecoration(
                            labelText: '비밀번호',
                            border: OutlineInputBorder(),
                            helperText:
                                '8자 이상, 숫자, 영문자, 특수문자(!%*#?&) 1개 이상의 조합',
                            helperMaxLines: 4,
                            helperStyle: TextStyle(height: 1.5),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '비밀번호를 입력해주세요';
                            }
                            if (!_validationState.hasMinLength) {
                              return '비밀번호는 8자 이상이어야 합니다';
                            }
                            if (!_validationState.hasNumber) {
                              return '비밀번호에 숫자가 포함되어야 합니다';
                            }
                            if (!_validationState.hasLetter) {
                              return '비밀번호에 영문자가 포함되어야 합니다';
                            }
                            if (!_validationState.hasSpecialChar) {
                              return '비밀번호에 특수문자(!%*#?&)가 포함되어야 합니다';
                            }
                            return null;
                          },
                        ),
                        if (_passwordController.text.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          PasswordValidation(
                            hasMinLength: _validationState.hasMinLength,
                            hasNumber: _validationState.hasNumber,
                            hasLetter: _validationState.hasLetter,
                            hasSpecialChar: _validationState.hasSpecialChar,
                            hasFocus: _passwordFocusNode.hasFocus,
                          ),
                        ],
                      ],
                    ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                focusNode: _confirmPasswordFocusNode,
                decoration: const InputDecoration(
                  labelText: '비밀번호 확인',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 다시 입력해주세요';
                  }
                  if (value != _passwordController.text) {
                    return '비밀번호가 일치하지 않습니다.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Obx(() {
                if (authController.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Column(
                  children: [
                    if (authController.error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          authController.error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          authController.register(
                            _emailController.text,
                            _passwordController.text,
                            _usernameController.text,
                          );
                        }
                      },
                      child: const Text('회원가입'),
                    ),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('이미 계정이 있으신가요? 로그인'),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

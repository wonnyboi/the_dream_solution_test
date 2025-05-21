import 'package:flutter/material.dart';

class ValidationTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final bool isValid;
  final String validationMessage;
  final String? Function(String?) validator;
  final bool obscureText;
  final TextInputType? keyboardType;

  const ValidationTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.isValid,
    required this.validationMessage,
    required this.validator,
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            suffixIcon:
                controller.text.isNotEmpty
                    ? Icon(
                      isValid ? Icons.check_circle : Icons.cancel,
                      color: isValid ? Colors.green : Colors.red,
                    )
                    : null,
          ),
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
        ),
        if (controller.text.isNotEmpty && (focusNode.hasFocus || !isValid)) ...[
          const SizedBox(height: 8),
          Text(
            validationMessage,
            style: TextStyle(
              color: isValid ? Colors.green : Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}

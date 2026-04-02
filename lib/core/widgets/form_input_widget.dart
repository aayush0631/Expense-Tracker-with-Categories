import 'package:flutter/material.dart';

/// A reusable form input field widget.
///
/// This widget wraps [TextFormField] and standardizes:
/// - Input styling
/// - Label handling
/// - Icon usage
/// - Validation integration
///
/// Why use this?
/// - Reduces repetitive TextFormField code
/// - Ensures consistent UI across all forms
/// - Makes validation integration simple and reusable
///
/// Parameters:
/// - [controller]: Controls the text being edited
/// - [label]: Label text shown inside the field
/// - [icon]: Icon displayed at the start of the field
/// - [validator]: Validation function for form validation
/// - [keyboardType]: Optional input type (e.g., email, number)
///
/// Example usage:
/// ```dart
/// FormInputField(
///   controller: _emailController,
///   label: 'Email',
///   icon: Icons.email,
///   keyboardType: TextInputType.emailAddress,
///   validator: Validator.email,
/// )
/// ```
///
/// Notes:
/// - Must be used inside a [Form] widget
/// - Validation is triggered via FormState.validate()
/// - Works seamlessly with global validators
class FormInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?) validator;

  const FormInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      validator: validator,
    );
  }
}
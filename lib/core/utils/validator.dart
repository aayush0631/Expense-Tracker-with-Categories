/// A utility class for validating Expense Tracker form inputs.
///
/// Centralized validation ensures:
/// - Consistency across UI forms
/// - Clean ViewModels (no duplicate logic)
/// - Easy maintenance
class Validator {

  /// Base required field validator
  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// ----------------------------
  /// AMOUNT VALIDATION
  /// ----------------------------
  static String? amount(String? value) {
    final base = required(value, 'Amount');
    if (base != null) return base;

    final parsed = double.tryParse(value!.trim());

    if (parsed == null) {
      return 'Enter a valid number';
    }

    if (parsed <= 0) {
      return 'Amount must be greater than 0';
    }

    if (parsed > 1000000) {
      return 'Amount is too large';
    }

    return null;
  }

  /// ----------------------------
  /// DESCRIPTION VALIDATION
  /// ----------------------------
  static String? description(String? value) {
    final base = required(value, 'Description');
    if (base != null) return base;

    final text = value!.trim();

    if (text.length < 3) {
      return 'Description too short';
    }

    if (text.length > 200) {
      return 'Description too long';
    }

    return null;
  }

  /// ----------------------------
  /// NAME VALIDATION (optional reuse)
  /// ----------------------------
  static String? name(String? value) {
    final base = required(value, 'Name');
    if (base != null) return base;

    final trimmed = value!.trim();

    if (trimmed.length < 2) {
      return 'Must be at least 2 characters';
    }

    if (trimmed.length > 100) {
      return 'Must be less than 100 characters';
    }

    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(trimmed)) {
      return 'Only letters allowed';
    }

    return null;
  }

  /// ----------------------------
  /// CATEGORY VALIDATION (int-based)
  /// ----------------------------
  static String? category(int? value) {
    if (value == null) {
      return 'Please select a category';
    }
    return null;
  }

  /// ----------------------------
  /// DATE VALIDATION
  /// ----------------------------
  static String? date(DateTime? value) {
    if (value == null) {
      return 'Please select a date';
    }

    if (value.isAfter(DateTime.now().add(const Duration(days: 1)))) {
      return 'Date cannot be in the future';
    }

    return null;
  }

  /// ----------------------------
  /// EMAIL (optional reuse)
  /// ----------------------------
  static String? email(String? value) {
    final base = required(value, 'Email');
    if (base != null) return base;

    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._+%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    if (!emailRegex.hasMatch(value!.trim())) {
      return 'Invalid email format';
    }

    return null;
  }
}
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/local_storage/theme_preference.dart';

class ThemeViewmodel extends ChangeNotifier {
  final ThemePreference _themePreference = ThemePreference();
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _themePreference.setTheme(_isDarkMode);
    notifyListeners();
  }

  Future<void> loadTheme() async {
    _isDarkMode = await _themePreference.getTheme();
    notifyListeners();
  }
}
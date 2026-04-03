import 'package:flutter/material.dart';
import 'package:expense_tracker/core/local_storage/theme_preference.dart';

/// ThemeViewmodel handles the application's theme state (Dark/Light mode)
/// and persists the selected theme using local storage (ThemePreference).
///
/// It extends [ChangeNotifier] so UI widgets listening to it
/// will automatically rebuild when theme changes.
class ThemeViewmodel extends ChangeNotifier {
  /// Local storage helper for saving and retrieving theme preference
  final ThemePreference _themePreference = ThemePreference();

  /// Internal state to track whether dark mode is enabled
  bool _isDarkMode = false;

  /// Public getter to expose current theme state
  bool get isDarkMode => _isDarkMode;

  /// Toggles between dark and light theme.
  ///
  /// - Inverts the current theme state
  /// - Saves the updated value to local storage
  /// - Notifies listeners so UI can rebuild
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode; // switch theme state

    // Persist the updated theme preference
    await _themePreference.setTheme(_isDarkMode);

    // Notify UI about state change
    notifyListeners();
  }

  /// Loads the saved theme preference from local storage.
  ///
  /// This should typically be called during app startup
  /// to restore the user's last selected theme.
  Future<void> loadTheme() async {
    _isDarkMode = await _themePreference.getTheme();

    // Update UI after loading saved value
    notifyListeners();
  }
}
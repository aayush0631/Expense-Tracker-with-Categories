import 'package:shared_preferences/shared_preferences.dart';

/// ThemePreference is responsible for persisting and retrieving
/// the user's theme selection (Dark/Light mode) using SharedPreferences.
///
/// This class acts as a local storage helper for theme settings.
class ThemePreference {
  /// Key to store theme value in SharedPreferences
  static const String themeKey = "theme_preference";

  /// Returns an instance of SharedPreferences
  Future<SharedPreferences> get _refs async =>
      await SharedPreferences.getInstance();

  /// Ensures a default theme value is set if none exists.
  ///
  /// This prevents null theme values on first app launch.
  /// Default is set to `false` (Light mode).
  Future<void> checkAndSetDefault() async {
    final prefs = await _refs;

    // If theme is not already stored, set default value
    if (!prefs.containsKey(themeKey)) {
      await prefs.setBool(themeKey, false); // false = Light mode
    }
  }

  /// Saves the user's theme preference.
  ///
  /// [isDarkMode] = true → Dark mode enabled
  /// [isDarkMode] = false → Light mode enabled
  Future<void> setTheme(bool isDarkMode) async {
    final prefs = await _refs;

    // Store theme preference locally
    await prefs.setBool(themeKey, isDarkMode);
  }

  /// Retrieves the stored theme preference.
  ///
  /// Returns:
  /// - true → Dark mode enabled
  /// - false → Light mode or default
  Future<bool> getTheme() async {
    final prefs = await _refs;

    // Return stored value or default to Light mode (false)
    return prefs.getBool(themeKey) ?? false;
  }

  /// Clears the stored theme preference from local storage.
  ///
  /// After clearing, the app will behave as if it is freshly installed
  /// regarding theme settings.
  Future<void> clearTheme() async {
    final prefs = await _refs;

    // Remove saved theme value
    await prefs.remove(themeKey);
  }
}
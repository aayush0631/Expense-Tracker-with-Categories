import 'package:shared_preferences/shared_preferences.dart';

class ThemePreference {
  static const String themeKey = "theme_preference";
  Future<SharedPreferences> get _refs async => await SharedPreferences.getInstance();

  Future<void> checkAndSetDefault() async {
    final prefs = await _refs;
    if (!prefs.containsKey(themeKey)) {
      await prefs.setBool(themeKey, false); // Default to light mode
    }
  }

  Future<void> setTheme(bool isDarkMode) async {
    final prefs = await _refs;
    await prefs.setBool(themeKey, isDarkMode);
  }

  Future<bool> getTheme() async {
    final prefs = await _refs;
    return prefs.getBool(themeKey) ?? false; // Default to light mode
  }

  Future<void> clearTheme() async {
    final prefs = await _refs;
    await prefs.remove(themeKey);
  }
}
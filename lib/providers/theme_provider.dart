import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  static const String _themeModeKey = 'theme_mode';

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedThemeMode = prefs.getString(_themeModeKey) ?? 'dark';
    setThemeMode(savedThemeMode);
  }

  Future<void> setThemeMode(String mode) async {
    ThemeMode newMode;
    switch (mode) {
      case 'light':
        newMode = ThemeMode.light;
        break;
      case 'dark':
        newMode = ThemeMode.dark;
        break;
      case 'system':
        newMode = ThemeMode.system;
        break;
      default:
        newMode = ThemeMode.dark;
    }

    if (_themeMode != newMode) {
      _themeMode = newMode;
      notifyListeners();

      // Save to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, mode);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode {
  light,
  dark,
  system,
}

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'app_theme_mode';
  AppThemeMode _themeMode = AppThemeMode.system;

  AppThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    switch (_themeMode) {
      case AppThemeMode.dark:
        return true;
      case AppThemeMode.light:
        return false;
      case AppThemeMode.system:
        final brightness =
            WidgetsBinding.instance.platformDispatcher.platformBrightness;
        return brightness == Brightness.dark;
    }
  }

  ThemeMode get materialThemeMode {
    switch (_themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  String get currentThemeName {
    switch (_themeMode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'System Default';
    }
  }

  IconData get currentThemeIcon {
    switch (_themeMode) {
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
      case AppThemeMode.system:
        return Icons.settings_suggest;
    }
  }

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedIndex = prefs.getInt(_themeKey) ?? 2;
      _themeMode = AppThemeMode.values[savedIndex];
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme: $e');
      _themeMode = AppThemeMode.system;
    }
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, mode.index);
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
    notifyListeners();
  }

  void toggleTheme() {
    final newMode = isDarkMode ? AppThemeMode.light : AppThemeMode.dark;
    setThemeMode(newMode);
  }

  static ThemeProvider of(BuildContext context) {
    return Provider.of<ThemeProvider>(context, listen: false);
  }
}

extension ThemeProviderExtension on BuildContext {
  ThemeProvider get themeProvider => ThemeProvider.of(this);

  bool get isDarkMode {
    final provider = ThemeProvider.of(this);
    return provider.isDarkMode;
  }

  String get currentThemeName {
    final provider = ThemeProvider.of(this);
    return provider.currentThemeName;
  }

  IconData get currentThemeIcon {
    final provider = ThemeProvider.of(this);
    return provider.currentThemeIcon;
  }
}

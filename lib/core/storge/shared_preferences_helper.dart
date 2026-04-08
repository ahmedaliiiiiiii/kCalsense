// lib/core/storage/shared_preferences_helper.dart

import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static const String _keyIsFirstLaunch = 'is_first_launch';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyIsSetupCompleted = 'is_setup_completed';
  static const String _keyLanguageCode = 'language_code';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyIsNewUser = 'is_new_user';

  static Future<SharedPreferences> get _instance async =>
      await SharedPreferences.getInstance();

  static Future<bool> isFirstLaunch() async {
    final prefs = await _instance;
    return prefs.getBool(_keyIsFirstLaunch) ?? true;
  }

  static Future<void> setFirstLaunchCompleted() async {
    final prefs = await _instance;
    await prefs.setBool(_keyIsFirstLaunch, false);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await _instance;
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  static Future<void> setLoggedIn(bool value) async {
    final prefs = await _instance;
    await prefs.setBool(_keyIsLoggedIn, value);
  }

  static Future<bool> isSetupCompleted() async {
    final prefs = await _instance;
    return prefs.getBool(_keyIsSetupCompleted) ?? false;
  }

  static Future<void> setSetupCompleted(bool value) async {
    final prefs = await _instance;
    await prefs.setBool(_keyIsSetupCompleted, value);
  }

  static Future<bool> isNewUser() async {
    final prefs = await _instance;
    return prefs.getBool(_keyIsNewUser) ?? true;
  }

  static Future<void> setNewUserCompleted() async {
    final prefs = await _instance;
    await prefs.setBool(_keyIsNewUser, false);
  }

  static Future<void> saveLanguage(String code) async {
    final prefs = await _instance;
    await prefs.setString(_keyLanguageCode, code);
  }

  static Future<String?> getLanguage() async {
    final prefs = await _instance;
    return prefs.getString(_keyLanguageCode);
  }

  static Future<void> saveThemeMode(String mode) async {
    final prefs = await _instance;
    await prefs.setString(_keyThemeMode, mode);
  }

  static Future<String?> getThemeMode() async {
    final prefs = await _instance;
    return prefs.getString(_keyThemeMode);
  }

  static Future<void> clearAll() async {
    final prefs = await _instance;
    await prefs.clear();
  }
}

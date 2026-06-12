import 'package:shared_preferences/shared_preferences.dart';

class AppPrefs {
  static const _keyIsFirstLaunch = 'is_first_launch';
  static const _keyIsLoggedIn = 'is_logged_in';
  static const _keyIsSetupCompleted = 'is_setup_completed';
  static const _keyLanguageCode = 'language_code';
  static const _keyThemeMode = 'theme_mode';

  final SharedPreferences _prefs;
  AppPrefs(this._prefs);

  bool get isFirstLaunch => _prefs.getBool(_keyIsFirstLaunch) ?? true;
  Future<void> setFirstLaunchCompleted() =>
      _prefs.setBool(_keyIsFirstLaunch, false);

  bool get isLoggedIn => _prefs.getBool(_keyIsLoggedIn) ?? false;
  Future<void> setLoggedIn(bool value) => _prefs.setBool(_keyIsLoggedIn, value);

  bool get isSetupCompleted => _prefs.getBool(_keyIsSetupCompleted) ?? false;
  Future<void> setSetupCompleted(bool value) =>
      _prefs.setBool(_keyIsSetupCompleted, value);

  String? get languageCode => _prefs.getString(_keyLanguageCode);
  Future<void> saveLanguage(String code) =>
      _prefs.setString(_keyLanguageCode, code);

  String? get themeMode => _prefs.getString(_keyThemeMode);
  Future<void> saveThemeMode(String mode) =>
      _prefs.setString(_keyThemeMode, mode);

  Future<void> clearAll() => _prefs.clear();
}

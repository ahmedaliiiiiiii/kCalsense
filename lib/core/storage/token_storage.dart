import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _tokenKey = 'auth_token';
  static const _emailKey = 'user_email';
  static const _userNameKey = 'user_name';

  final SharedPreferences _prefs;
  TokenStorage(this._prefs);

  Future<void> saveAuth({
    required String token,
    required String email,
    required String userName,
  }) async {
    await _prefs.setString(_tokenKey, token);
    await _prefs.setString(_emailKey, email);
    await _prefs.setString(_userNameKey, userName);
  }

  String? getToken() => _prefs.getString(_tokenKey);
  String? getEmail() => _prefs.getString(_emailKey);
  String? getUserName() => _prefs.getString(_userNameKey);

  Future<void> clearToken() async {
    await _prefs.remove(_tokenKey);
  }

  Future<void> clear() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_emailKey);
    await _prefs.remove(_userNameKey);
  }
}

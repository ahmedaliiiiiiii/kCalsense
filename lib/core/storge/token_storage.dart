import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _kToken = "token";
  static const _kEmail = "email";
  static const _kUserName = "userName";

  Future<void> saveAuth({
    required String token,
    required String email,
    required String userName,
  }) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kToken, token);
    await sp.setString(_kEmail, email);
    await sp.setString(_kUserName, userName);
  }

  Future<String?> getToken() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kToken);
  }

  Future<String?> getUserName() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kUserName);
  }

  Future<String?> getEmail() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kEmail);
  }

  Future<bool> isLoggedIn() async {
    final sp = await SharedPreferences.getInstance();
    final token = sp.getString(_kToken);
    return token != null && token.isNotEmpty;
  }

  Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kToken);
    await sp.remove(_kEmail);
    await sp.remove(_kUserName);
  }
}

// lib/core/storge/token_storage.dart

// ignore_for_file: avoid_print

import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _tokenKey = 'auth_token';
  static const String _emailKey = 'user_email';
  static const String _userNameKey = 'user_name';

  Future<void> saveAuth({
    required String token,
    required String email,
    required String userName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_emailKey, email);
    await prefs.setString(_userNameKey, userName);

    print('✅ Token saved: $token');
    print('✅ Email saved: $email');
    print('✅ UserName saved: $userName');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    print('📖 Getting token: $token');
    return token;
  }

  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_userNameKey);
    print('✅ All auth data cleared');
  }
}

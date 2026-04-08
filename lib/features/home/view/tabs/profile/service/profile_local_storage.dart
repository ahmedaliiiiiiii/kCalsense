import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ProfileLocalStorage {
  static const _kProfileAll = "profile_all";

  Future<void> saveAll({
    required Map<String, dynamic> input,
    required Map<String, dynamic> setup,
  }) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(
      _kProfileAll,
      jsonEncode({
        "input": input,
        "setup": setup,
      }),
    );
  }

  Future<Map<String, dynamic>?> loadAll() async {
    final sp = await SharedPreferences.getInstance();
    final s = sp.getString(_kProfileAll);
    if (s == null || s.isEmpty) return null;

    final decoded = jsonDecode(s);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return null;
  }

  Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kProfileAll);
  }
}

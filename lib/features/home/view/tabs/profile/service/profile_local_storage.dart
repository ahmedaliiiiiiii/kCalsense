import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ProfileLocalStorage {
  static const _kProfileAll = "profile_all";
  final SharedPreferences _prefs;

  ProfileLocalStorage(this._prefs);

  Future<void> saveAll({
    required Map<String, dynamic> input,
    required Map<String, dynamic> setup,
  }) async {
    await _prefs.setString(
      _kProfileAll,
      jsonEncode({
        "input": input,
        "setup": setup,
      }),
    );
  }

  Future<Map<String, dynamic>?> loadAll() async {
    final s = _prefs.getString(_kProfileAll);
    if (s == null || s.isEmpty) return null;

    final decoded = jsonDecode(s);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return null;
  }

  Future<void> clear() async {
    await _prefs.remove(_kProfileAll);
  }
}

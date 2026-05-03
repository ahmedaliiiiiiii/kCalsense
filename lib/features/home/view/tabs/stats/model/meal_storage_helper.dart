import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MealStorage {
  static Future<void> saveMeal({
    required DateTime date,
    required String name,
    required int calories,
    required double protein,
    required double carbs,
    required double fats,
    String? imagePath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'meals_${DateFormat('yyyy-MM-dd').format(date)}';
    final mealJson = jsonEncode({
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'imagePath': imagePath ?? '',
      'timestamp': DateTime.now().toIso8601String(),
    });
    final List<String> existing = prefs.getStringList(key) ?? [];
    existing.add(mealJson);
    await prefs.setStringList(key, existing);
  }

  // ✅ حذف وجبة من مخزن الإحصائيات
  static Future<void> deleteMeal({
    required DateTime date,
    required String name,
    required int calories,
    required double protein,
    required double carbs,
    required double fats,
    String? imagePath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'meals_${DateFormat('yyyy-MM-dd').format(date)}';
    final List<String> mealsJson = prefs.getStringList(key) ?? [];

    // حذف أول وجبة تطابق الاسم والسعرات (قد يكون هناك أكثر من وجبة متطابقة، نستخدم أول تطابق)
    final indexToRemove = mealsJson.indexWhere((jsonStr) {
      try {
        final meal = jsonDecode(jsonStr) as Map<String, dynamic>;
        return meal['name'] == name && meal['calories'] == calories;
      } catch (_) {
        return false;
      }
    });

    if (indexToRemove != -1) {
      mealsJson.removeAt(indexToRemove);
      if (mealsJson.isEmpty) {
        await prefs.remove(key);
      } else {
        await prefs.setStringList(key, mealsJson);
      }
    }
  }
}

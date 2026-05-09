import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MealStorage {
  // ✅ دوال جديدة للتخزين المقسم بالتاريخ
  static const String _prefix = 'meals_';

  static String _getDateKey(DateTime date) {
    return '$_prefix${DateFormat('yyyy-MM-dd').format(date)}';
  }

  static Future<List<Map<String, dynamic>>> _getMealsForDate(
      DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getDateKey(date);
    final String? jsonString = prefs.getString(key);
    if (jsonString == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      debugPrint('Error loading meals for $key: $e');
      return [];
    }
  }

  static Future<void> _saveMealsForDate(
      DateTime date, List<Map<String, dynamic>> meals) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getDateKey(date);
    final jsonString = jsonEncode(meals);
    await prefs.setString(key, jsonString);
  }

  // Save a meal (with optional backend mealId)
  static Future<void> saveMeal({
    required DateTime date,
    required String name,
    required int calories,
    required double protein,
    required double carbs,
    required double fats,
    required String imagePath,
    dynamic mealId,
  }) async {
    final meals = await _getMealsForDate(date);
    
    // Check if meal already exists (same name and approximate time)
    final existingIndex = meals.indexWhere((m) {
      if (mealId != null && m['mealId'] == mealId) return true;
      final mDate = DateTime.tryParse(m['date'] ?? '');
      return m['name'] == name && 
             mDate != null && 
             mDate.difference(date).inSeconds.abs() < 10;
    });

    final mealData = {
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'imagePath': imagePath,
      'date': date.toIso8601String(),
      'time': _formatTime(date),
      if (mealId != null) 'mealId': mealId,
    };

    if (existingIndex != -1) {
      meals[existingIndex] = mealData;
    } else {
      meals.add(mealData);
    }
    
    await _saveMealsForDate(date, meals);
  }

  // ✅ حذف وجبة (بنفس التوقيع القديم)
  static Future<void> deleteMeal({
    required DateTime date,
    required String name,
    required int calories,
    required double protein,
    required double carbs,
    required double fats,
    required String imagePath,
  }) async {
    final meals = await _getMealsForDate(date);
    meals.removeWhere((meal) =>
        meal['name'] == name &&
        meal['calories'] == calories &&
        meal['protein'] == protein &&
        meal['carbs'] == carbs &&
        meal['fats'] == fats &&
        meal['imagePath'] == imagePath);
    if (meals.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_getDateKey(date));
    } else {
      await _saveMealsForDate(date, meals);
    }
  }

  // ✅ جلب وجبات يوم معين (للاستخدام في الإحصائيات)
  static Future<List<Map<String, dynamic>>> getMealsForDate(
      DateTime date) async {
    return await _getMealsForDate(date);
  }

  // ✅ حذف جميع وجبات يوم (لإعادة التعيين)
  static Future<void> clearMealsForDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_getDateKey(date));
  }

  static String _formatTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute;
    final period = hour >= 12 ? 'pm' : 'am';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  /// Get the backend mealId for a specific meal entry
  static Future<dynamic> getMealId({
    required DateTime date,
    required String name,
    required int calories,
  }) async {
    final meals = await _getMealsForDate(date);
    for (final meal in meals) {
      if (meal['name'] == name && meal['calories'] == calories) {
        return meal['mealId'];
      }
    }
    return null;
  }
}

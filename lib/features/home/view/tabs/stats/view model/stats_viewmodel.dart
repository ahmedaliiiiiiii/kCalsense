// lib/features/home/view/tabs/stats/view model/stats_viewmodel.dart

// ignore_for_file: empty_catches

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatsData {
  final int totalCalories;
  final int avgCalories;
  final int totalDays;
  final int streakDays;
  final Map<DateTime, int> caloriesPerDay;
  final Map<String, double> macrosAverage;
  final int dailyGoal;
  final int totalLoggedMeals;

  const StatsData({
    required this.totalCalories,
    required this.avgCalories,
    required this.totalDays,
    required this.streakDays,
    required this.caloriesPerDay,
    required this.macrosAverage,
    required this.dailyGoal,
    required this.totalLoggedMeals,
  });
}

class StatsViewModel extends ChangeNotifier {
  bool isLoading = false;
  StatsData? statsData;
  String selectedPeriod = 'This Week';

  final List<Map<String, dynamic>> periods = const [
    {'label': 'This Week', 'value': 'week', 'icon': Icons.calendar_view_week},
    {'label': 'This Month', 'value': 'month', 'icon': Icons.calendar_month},
    {'label': 'This Year', 'value': 'year', 'icon': Icons.calendar_today},
  ];

  Future<void> loadStats() async {
    // تجنب التحميل المتكرر أثناء التحميل أو إذا كانت البيانات نفسها
    if (isLoading) return;
    isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final allMeals = await _getAllMeals(prefs);
      final range = _getDateRange(selectedPeriod);
      final filtered = _filterMealsByRange(allMeals, range);
      final stats = _calculateStats(filtered, range, prefs);
      if (statsData == stats && statsData != null) {
        // نفس البيانات لا داعي للإشعار
        return;
      }
      statsData = stats;
    } catch (e) {
      debugPrint('Stats error: $e');
      statsData = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<DateTime, List<Map<String, dynamic>>>> _getAllMeals(
      SharedPreferences prefs) async {
    final mealsMap = <DateTime, List<Map<String, dynamic>>>{};
    final keys = prefs.getKeys();
    final dateFormat = DateFormat('yyyy-MM-dd');
    for (final key in keys) {
      if (key.startsWith('meals_')) {
        final dateStr = key.substring(6);
        try {
          final date = dateFormat.parse(dateStr);
          final mealsJson = prefs.getStringList(key) ?? [];
          final meals = mealsJson
              .map((json) => jsonDecode(json) as Map<String, dynamic>)
              .toList();
          if (meals.isNotEmpty) mealsMap[date] = meals;
        } catch (e) {}
      }
    }
    return mealsMap;
  }

  ({DateTime start, DateTime end}) _getDateRange(String period) {
    final today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    switch (period) {
      case 'This Week':
        final start = today.subtract(Duration(days: today.weekday - 1));
        return (start: start, end: today);
      case 'This Month':
        return (start: DateTime(today.year, today.month, 1), end: today);
      case 'This Year':
        return (start: DateTime(today.year, 1, 1), end: today);
      default:
        return (start: today, end: today);
    }
  }

  Map<DateTime, List<Map<String, dynamic>>> _filterMealsByRange(
      Map<DateTime, List<Map<String, dynamic>>> all,
      ({DateTime start, DateTime end}) range) {
    final filtered = <DateTime, List<Map<String, dynamic>>>{};
    for (final entry in all.entries) {
      if (entry.key.isAfter(range.start.subtract(const Duration(days: 1))) &&
          entry.key.isBefore(range.end.add(const Duration(days: 1)))) {
        filtered[entry.key] = entry.value;
      }
    }
    return filtered;
  }

  StatsData _calculateStats(Map<DateTime, List<Map<String, dynamic>>> meals,
      ({DateTime start, DateTime end}) range, SharedPreferences prefs) {
    int totalCalories = 0;
    int totalMealsCount = 0;
    final macroTotals = {'Protein': 0.0, 'Carbs': 0.0, 'Fat': 0.0};
    final caloriesPerDay = <DateTime, int>{};

    for (final entry in meals.entries) {
      int dayCal = 0;
      for (final meal in entry.value) {
        final cal = (meal['calories'] as num?)?.toInt() ?? 0;
        dayCal += cal;
        totalCalories += cal;
        totalMealsCount++;
        macroTotals['Protein'] = macroTotals['Protein']! +
            ((meal['protein'] as num?)?.toDouble() ?? 0);
        macroTotals['Carbs'] =
            macroTotals['Carbs']! + ((meal['carbs'] as num?)?.toDouble() ?? 0);
        macroTotals['Fat'] =
            macroTotals['Fat']! + ((meal['fats'] as num?)?.toDouble() ?? 0);
      }
      caloriesPerDay[entry.key] = dayCal;
    }

    final daysWithData = meals.length;
    final avgCal =
        daysWithData > 0 ? (totalCalories / daysWithData).round() : 0;
    final streak = _calculateStreak(meals);
    final macroAvg = {
      'Protein':
          daysWithData > 0 ? macroTotals['Protein']! / daysWithData : 0.0,
      'Carbs': daysWithData > 0 ? macroTotals['Carbs']! / daysWithData : 0.0,
      'Fat': daysWithData > 0 ? macroTotals['Fat']! / daysWithData : 0.0,
    };
    final dailyGoal = prefs.getInt('daily_calorie_goal') ?? 2200;

    return StatsData(
      totalCalories: totalCalories,
      avgCalories: avgCal,
      totalDays: daysWithData,
      streakDays: streak,
      caloriesPerDay: caloriesPerDay,
      macrosAverage: macroAvg,
      dailyGoal: dailyGoal,
      totalLoggedMeals: totalMealsCount,
    );
  }

  int _calculateStreak(Map<DateTime, List<Map<String, dynamic>>> meals) {
    if (meals.isEmpty) return 0;
    int streak = 0;
    DateTime checkDate = DateTime.now();
    while (meals.containsKey(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    return streak;
  }

  void setPeriod(String period) {
    if (selectedPeriod == period) return;
    selectedPeriod = period;
    loadStats();
  }
}

// lib/features/home/view/tabs/stats/view model/stats_viewmodel.dart

// ignore_for_file: empty_catches

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../../core/di/service_locator.dart';
import '../../../../../../core/services/meal_api_service.dart';
import '../../../../../../core/services/meal_event_bus.dart';
import '../model/meal_storage_helper.dart'; // ✅ استيراد MealStorage

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

  late final StreamSubscription _mealSubscription;
  late final MealApiService _mealApi;

  StatsViewModel() {
    _mealApi = sl<MealApiService>();
    _listenToMealChanges();
  }

  void _listenToMealChanges() {
    _mealSubscription = MealEventBus().onMealChanged.listen((_) {
      loadStats();
    });
  }

  @override
  void dispose() {
    _mealSubscription.cancel();
    super.dispose();
  }

  Future<void> loadStats() async {
    if (isLoading) return;
    isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final range = _getDateRange(selectedPeriod);

      // Try backend first
      StatsData? backendStats;
      try {
        backendStats = await _loadStatsFromBackend(range, prefs);
      } catch (e) {
        debugPrint('Backend stats failed, falling back to local: $e');
      }

      if (backendStats != null &&
          (backendStats.caloriesPerDay.isNotEmpty ||
              backendStats.totalLoggedMeals > 0)) {
        statsData = backendStats;
      } else {
        // Fallback to local storage using MealStorage
        final allMeals = await _getAllMealsLocal();
        final filtered = _filterMealsByRange(allMeals, range);
        statsData = _calculateStats(filtered, range, prefs);
      }
    } catch (e) {
      debugPrint('Stats error: $e');
      statsData = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// جلب جميع الوجبات من التخزين المحلي (MealStorage)
  Future<Map<DateTime, List<Map<String, dynamic>>>> _getAllMealsLocal() async {
    final mealsMap = <DateTime, List<Map<String, dynamic>>>{};
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final dateFormat = DateFormat('yyyy-MM-dd');

    for (final key in keys) {
      if (key.startsWith('meals_')) {
        final dateStr = key.substring(6); // after 'meals_'
        try {
          final date = dateFormat.parse(dateStr);
          // ✅ استخدام MealStorage.getMealsForDate (لكنه static، يمكن استدعاؤه مباشرة)
          final meals = await MealStorage.getMealsForDate(date);
          if (meals.isNotEmpty) {
            mealsMap[date] = meals;
          }
        } catch (e) {
          debugPrint('Error parsing date from key $key: $e');
        }
      }
    }
    return mealsMap;
  }

  /// Load stats from the backend API (يبقى كما هو)
  Future<StatsData> _loadStatsFromBackend(
    ({DateTime start, DateTime end}) range,
    SharedPreferences prefs,
  ) async {
    final meals = await _mealApi.getMealHistoryRange(
      start: range.start,
      end: range.end,
    );

    int totalCalories = 0;
    int totalMealsCount = 0;
    final macroTotals = {'Protein': 0.0, 'Carbs': 0.0, 'Fat': 0.0};
    final caloriesPerDay = <DateTime, int>{};

    for (final entry in meals.entries) {
      int dayCal = 0;
      for (final meal in entry.value) {
        final items = meal['items'] as List<dynamic>? ?? [];
        if (items.isNotEmpty) {
          for (final item in items) {
            final cal = (item['calories'] as num?)?.toInt() ?? 0;
            dayCal += cal;
            totalCalories += cal;
            totalMealsCount++;
            macroTotals['Protein'] = macroTotals['Protein']! +
                ((item['protein'] as num?)?.toDouble() ?? 0);
            macroTotals['Carbs'] = macroTotals['Carbs']! +
                ((item['carbs'] as num?)?.toDouble() ?? 0);
            macroTotals['Fat'] =
                macroTotals['Fat']! + ((item['fats'] as num?)?.toDouble() ?? 0);
          }
        } else {
          final cal =
              ((meal['totalCalories'] ?? meal['calories']) as num?)?.toInt() ??
                  0;
          dayCal += cal;
          totalCalories += cal;
          totalMealsCount++;
          macroTotals['Protein'] = macroTotals['Protein']! +
              ((meal['protein'] as num?)?.toDouble() ?? 0);
          macroTotals['Carbs'] = macroTotals['Carbs']! +
              ((meal['carbs'] as num?)?.toDouble() ?? 0);
          macroTotals['Fat'] = macroTotals['Fat']! +
              ((meal['fats'] ?? meal['fat'] as num?)?.toDouble() ?? 0);
        }
      }
      caloriesPerDay[entry.key] = dayCal;
    }

    final daysWithData = meals.length;
    final avgCal =
        daysWithData > 0 ? (totalCalories / daysWithData).round() : 0;
    final streak = _calculateStreakFromBackend(meals);
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

  int _calculateStreakFromBackend(
      Map<DateTime, List<Map<String, dynamic>>> meals) {
    if (meals.isEmpty) return 0;
    int streak = 0;
    DateTime checkDate = DateTime.now();
    checkDate = DateTime(checkDate.year, checkDate.month, checkDate.day);
    while (meals.containsKey(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    return streak;
  }

  // ─── Local helpers ───

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
    ({DateTime start, DateTime end}) range,
  ) {
    final filtered = <DateTime, List<Map<String, dynamic>>>{};
    for (final entry in all.entries) {
      if (entry.key.isAfter(range.start.subtract(const Duration(days: 1))) &&
          entry.key.isBefore(range.end.add(const Duration(days: 1)))) {
        filtered[entry.key] = entry.value;
      }
    }
    return filtered;
  }

  StatsData _calculateStats(
    Map<DateTime, List<Map<String, dynamic>>> meals,
    ({DateTime start, DateTime end}) range,
    SharedPreferences prefs,
  ) {
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

import 'package:flutter/foundation.dart';

import '../network/api_client.dart';
import '../network/api_endpoints.dart';

class MealApiService {
  final ApiClient _api;

  MealApiService(this._api);

  // ─── Get all available foods ───
  Future<List<Map<String, dynamic>>> getAllFoods() async {
    final response = await _api.get(ApiEndpoints.mealFoods);
    final data = response.data;
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // ─── Log a meal after food recognition ───
  /// Returns the full response including `mealId`.
  Future<Map<String, dynamic>> logMeal({
    required String mealType,
    required List<Map<String, dynamic>> items,
  }) async {
    final response = await _api.post(
      ApiEndpoints.mealLog,
      data: {
        'mealType': mealType,
        'items': items,
      },
    );
    if (response.data is Map) {
      return Map<String, dynamic>.from(response.data);
    }
    return {};
  }

  // ─── Get today's meals ───
  Future<List<Map<String, dynamic>>> getTodayMeals() async {
    final response = await _api.get(ApiEndpoints.mealToday);
    final data = response.data;
    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }

  // ─── Get daily summary (calories, macros for today) ───
  Future<Map<String, dynamic>> getDailySummary() async {
    final response = await _api.get(ApiEndpoints.mealDailySummary);
    if (response.data is Map) {
      return Map<String, dynamic>.from(response.data);
    }
    return {};
  }

  // ─── Get meal history for a specific date ───
  Future<List<Map<String, dynamic>>> getMealHistory(String date) async {
    final response = await _api.get(
      ApiEndpoints.mealHistory,
      queryParameters: {'date': date},
    );
    final data = response.data;
    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }

  // ─── Delete a meal ───
  Future<void> deleteMeal(dynamic mealId) async {
    await _api.delete('${ApiEndpoints.mealDelete}/$mealId');
  }

  // ─── Update meal type ───
  Future<void> updateMealType(dynamic mealId, String mealType) async {
    await _api.put(
      '${ApiEndpoints.mealUpdateType}/$mealId/type',
      data: {'mealType': mealType},
    );
  }

  // ─── Update meal items ───
  Future<void> updateMealItems(
      dynamic mealId, List<Map<String, dynamic>> items) async {
    await _api.put(
      '${ApiEndpoints.mealUpdateItems}/$mealId/items',
      data: {'items': items},
    );
  }

  // ─── Helper: determine meal type from time of day ───
  static String getMealTypeFromTime() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Breakfast';
    if (hour < 15) return 'Lunch';
    if (hour < 18) return 'Snack';
    return 'Dinner';
  }

  // ─── Get meal history for a date range (for Stats) ───
  Future<Map<DateTime, List<Map<String, dynamic>>>> getMealHistoryRange({
    required DateTime start,
    required DateTime end,
  }) async {
    final result = <DateTime, List<Map<String, dynamic>>>{};
    
    // Create a list of all dates to fetch
    List<DateTime> datesToFetch = [];
    DateTime current = start;
    while (!current.isAfter(end)) {
      datesToFetch.add(DateTime(current.year, current.month, current.day));
      current = current.add(const Duration(days: 1));
    }

    // Process in batches of 10 to avoid overwhelming the server
    const batchSize = 10;
    for (int i = 0; i < datesToFetch.length; i += batchSize) {
      final batch = datesToFetch.skip(i).take(batchSize);
      final futures = batch.map((date) async {
        final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        try {
          final meals = await getMealHistory(dateStr);
          if (meals.isNotEmpty) {
            return MapEntry(date, meals);
          }
        } catch (e) {
          debugPrint('Error fetching history for $dateStr: $e');
        }
        return null;
      });
      
      final results = await Future.wait(futures);
      for (final r in results) {
        if (r != null) {
          result[r.key] = r.value;
        }
      }
    }
    
    return result;
  }
}

// ignore_for_file: unused_field, await_only_futures

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/localization/notification_strings.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/meal_api_service.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/meal_event_bus.dart';
import '../../notifications/NotificationHelper.dart';
import '../model/home_models.dart';
import '../view/tabs/profile/service/profile_local_storage.dart';
import '../view/tabs/scan/api/food_recognition_api.dart';
import '../view/tabs/scan/model/food_recognition_result.dart';
import '../view/tabs/stats/model/meal_storage_helper.dart';

class HomeViewModel extends ChangeNotifier {
  final TokenStorage storage;
  final ProfileLocalStorage profileStorage = ProfileLocalStorage();
  late final FoodRecognitionApi _foodApi;
  late final MealApiService _mealApi;

  HomeViewModel({required this.storage}) {
    _foodApi = FoodRecognitionApi(
      dio: sl<ApiClient>().dio,
      tokenStorage: storage,
    );
    _mealApi = sl<MealApiService>();
  }

  bool isLoading = true;
  String? error;
  TodayProgressUiModel? progress;
  List<RecentFoodUiModel> _recentFoods = [];
  int selectedTab = 0;
  String userName = "";
  static const String _recentFoodsKey = 'recent_foods_list';

  List<RecentFoodUiModel> get recentFoods => _recentFoods;
  List<RecentFoodUiModel> get recentFoodsForHome =>
      _recentFoods.take(3).toList();

  Future<void> init() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      await NotificationStrings.loadLanguage();

      userName = (await storage.getUserName()) ?? "";
      final profileData = await profileStorage.loadAll();
      int savedGoal = 2000;
      if (profileData != null && profileData['setup'] != null) {
        savedGoal =
            (profileData['setup']['dailyCaloriesTarget'] as num).round();
      }
      final todayDate = DateFormat('EEEE, MMM d').format(DateTime.now());
      final today = DateTime.now();

      await _loadProgressFromLocal();
      await _checkAndResetProgress(savedGoal, todayDate, today);
      await _loadTodayMeals(today);
    } catch (e) {
      error = "Something went wrong";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _checkAndResetProgress(
      int defaultGoal, String todayDate, DateTime today) async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString('last_progress_date');
    final todayStr = DateFormat('yyyy-MM-dd').format(today);

    if (lastDate == null || lastDate != todayStr) {
      progress = TodayProgressUiModel(
        calories: 0,
        goal: defaultGoal,
        protein: 0,
        carbs: 0,
        fat: 0,
        dateLabel: todayDate,
      );
      await prefs.setString('last_progress_date', todayStr);
      await _saveProgressToLocal();
      _recentFoods.clear();
    } else if (progress == null) {
      progress = TodayProgressUiModel(
        calories: 0,
        goal: defaultGoal,
        protein: 0,
        carbs: 0,
        fat: 0,
        dateLabel: todayDate,
      );
      await _saveProgressToLocal();
    }
    notifyListeners();
  }

  Future<void> _loadTodayMeals(DateTime date) async {
    try {
      final backendMeals = await _mealApi.getTodayMeals();
      if (backendMeals.isNotEmpty) {
        _recentFoods = backendMeals.map((mealMap) {
          return _mapBackendMealToUiModel(mealMap);
        }).toList();
        await _syncDailySummaryFromBackend();
        notifyListeners();
        return;
      }
    } catch (e) {
      debugPrint('Backend getTodayMeals failed, falling back to local: $e');
    }

    final mealsData = await MealStorage.getMealsForDate(date);
    _recentFoods = mealsData.map((mealMap) {
      return RecentFoodUiModel(
        name: mealMap['name'],
        time: mealMap['time'] ?? _formatTime(DateTime.parse(mealMap['date'])),
        calories: mealMap['calories'],
        imagePath: mealMap['imagePath'],
        color: _getColorForFood(mealMap['name']),
        weight: "200 gr",
        description: "",
        nutrition: {
          'calories': '${mealMap['calories']} kcal',
          'protein': '${mealMap['protein']}g',
          'carbs': '${mealMap['carbs']}g',
          'fat': '${mealMap['fats']}g',
          'fiber': '0g',
          'sugar': '0g',
        },
        date: DateTime.parse(mealMap['date']),
        mealId: mealMap['mealId'],
      );
    }).toList();
    notifyListeners();
  }

  RecentFoodUiModel _mapBackendMealToUiModel(Map<String, dynamic> mealMap) {
    final items = mealMap['items'] as List<dynamic>? ?? [];
    final firstItem = items.isNotEmpty ? items.first : null;
    final name = firstItem?['foodName'] ??
        mealMap['foodName'] ??
        mealMap['name'] ??
        'Unknown';
    final calories =
        (mealMap['totalCalories'] ?? mealMap['calories'] ?? 0) as num;
    final protein = (firstItem?['protein'] ?? mealMap['protein'] ?? 0) as num;
    final carbs = (firstItem?['carbs'] ?? mealMap['carbs'] ?? 0) as num;
    final fats = (firstItem?['fats'] ?? mealMap['fats'] ?? 0) as num;
    final mealId = mealMap['mealId'] ?? mealMap['id'];

    final dateStr = mealMap['loggedAt'] ??
        mealMap['date'] ??
        DateTime.now().toIso8601String();
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(dateStr);
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return RecentFoodUiModel(
      name: name.toString(),
      time: _formatTime(parsedDate),
      calories: calories.toInt(),
      imagePath: mealMap['imagePath'] ?? '',
      color: _getColorForFood(name.toString()),
      weight: "${firstItem?['quantity'] ?? 200} gr",
      description: "Meal type: ${mealMap['mealType'] ?? 'N/A'}",
      nutrition: {
        'calories': '${calories.toInt()} kcal',
        'protein': '${protein}g',
        'carbs': '${carbs}g',
        'fat': '${fats}g',
        'fiber': '0g',
        'sugar': '0g',
      },
      date: parsedDate,
      mealId: mealId,
    );
  }

  Future<void> _syncDailySummaryFromBackend() async {
    try {
      final summary = await _mealApi.getDailySummary();
      if (summary.isNotEmpty && progress != null) {
        progress = TodayProgressUiModel(
          calories:
              (summary['totalCalories'] as num?)?.toInt() ?? progress!.calories,
          goal: progress!.goal,
          protein:
              (summary['totalProtein'] as num?)?.toInt() ?? progress!.protein,
          carbs: (summary['totalCarbs'] as num?)?.toInt() ?? progress!.carbs,
          fat: (summary['totalFats'] as num?)?.toInt() ?? progress!.fat,
          dateLabel: progress!.dateLabel,
        );
        await _saveProgressToLocal();
      }
    } catch (e) {
      debugPrint('Failed to sync daily summary from backend: $e');
    }
  }

  Future<void> _loadProgressFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('today_progress');
    if (jsonString == null) return;
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      progress = TodayProgressUiModel(
        calories: data['calories'] as int,
        goal: data['goal'] as int,
        protein: data['protein'] as int,
        carbs: data['carbs'] as int,
        fat: data['fat'] as int,
        dateLabel: data['dateLabel'] as String,
      );
    } catch (e) {
      debugPrint('Error loading progress: $e');
    }
  }

  Future<void> _saveProgressToLocal() async {
    if (progress == null) return;
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'calories': progress!.calories,
      'goal': progress!.goal,
      'protein': progress!.protein,
      'carbs': progress!.carbs,
      'fat': progress!.fat,
      'dateLabel': progress!.dateLabel,
    };
    await prefs.setString('today_progress', jsonEncode(data));
  }

  void addRecentFoods(List<FoodRecognitionResult> results) {
    for (var result in results) {
      addRecentFood(result);
    }
  }

  void addRecentFood(FoodRecognitionResult result) {
    final now = DateTime.now();
    final newFood = RecentFoodUiModel(
      name: result.foodName,
      time: _formatTime(now),
      calories: result.totalcalories.toInt(),
      imagePath: result.imagePath.isNotEmpty
          ? result.imagePath
          : _getImageForFood(result.foodName),
      color: _getColorForFood(result.foodName),
      weight: "200 gr",
      description: "Analyzed from your scan - ${result.foodName}",
      nutrition: {
        'calories': '${result.totalcalories.toInt()} kcal',
        'protein': '${result.totalprotein}g',
        'carbs': '${result.totalcarbs}g',
        'fat': '${result.totalfats}g',
        'fiber': '0g',
        'sugar': '0g',
      },
      date: now,
    );
    _recentFoods.insert(0, newFood);
    if (_recentFoods.length > 10) _recentFoods.removeLast();

    MealStorage.saveMeal(
      date: now,
      name: result.foodName,
      calories: result.totalcalories.toInt(),
      protein: result.totalprotein,
      carbs: result.totalcarbs,
      fats: result.totalfats,
      imagePath: result.imagePath,
    );

    _logMealToBackend(result, now);

    addCaloriesToProgress(result.totalcalories.toInt(),
        mealName: result.foodName);
    addMacrosToProgress(
        result.totalprotein, result.totalcarbs, result.totalfats);
    notifyListeners();
    MealEventBus().notifyMealChanged();
  }

  Future<void> _logMealToBackend(
      FoodRecognitionResult result, DateTime date) async {
    try {
      final mealType = MealApiService.getMealTypeFromTime();
      final items = <Map<String, dynamic>>[
        {'foodId': 1, 'quantity': 200}
      ];
      final response = await _mealApi.logMeal(
        mealType: mealType,
        items: items,
      );
      final mealId = response['mealId'] ?? response['id'];
      if (mealId != null) {
        final idx = _recentFoods.indexWhere((f) =>
            f.name == result.foodName &&
            f.date.difference(date).inSeconds.abs() < 5);
        if (idx != -1) {
          _recentFoods[idx] = _recentFoods[idx].copyWith(mealId: mealId);
        }
        await MealStorage.saveMeal(
          date: date,
          name: result.foodName,
          calories: result.totalcalories.toInt(),
          protein: result.totalprotein,
          carbs: result.totalcarbs,
          fats: result.totalfats,
          imagePath: result.imagePath,
          mealId: mealId,
        );
      }
      debugPrint('✅ Meal logged to backend: $mealType, mealId: $mealId');
    } catch (e) {
      debugPrint('⚠️ Failed to log meal to backend (kept locally): $e');
    }
  }

  Future<void> deleteMeal(RecentFoodUiModel meal) async {
    _recentFoods.removeWhere(
        (item) => item.name == meal.name && item.time == meal.time);
    if (meal.mealId != null) {
      try {
        await _mealApi.deleteMeal(meal.mealId);
        debugPrint('✅ Meal deleted from backend: ${meal.mealId}');
      } catch (e) {
        debugPrint('⚠️ Failed to delete meal from backend: $e');
      }
    }
    await MealStorage.deleteMeal(
      date: meal.date,
      name: meal.name,
      calories: meal.calories,
      protein: double.tryParse(
              meal.nutrition['protein']?.replaceAll('g', '') ?? '0') ??
          0,
      carbs: double.tryParse(
              meal.nutrition['carbs']?.replaceAll('g', '') ?? '0') ??
          0,
      fats:
          double.tryParse(meal.nutrition['fat']?.replaceAll('g', '') ?? '0') ??
              0,
      imagePath: meal.imagePath,
    );

    final now = DateTime.now();
    final isSameDay = meal.date.year == now.year &&
        meal.date.month == now.month &&
        meal.date.day == now.day;

    if (isSameDay && progress != null) {
      final proteinValue = double.tryParse(
              meal.nutrition['protein']?.replaceAll('g', '') ?? '0') ??
          0;
      final carbsValue = double.tryParse(
              meal.nutrition['carbs']?.replaceAll('g', '') ?? '0') ??
          0;
      final fatValue =
          double.tryParse(meal.nutrition['fat']?.replaceAll('g', '') ?? '0') ??
              0;

      progress = TodayProgressUiModel(
        calories: (progress!.calories - meal.calories).clamp(0, progress!.goal),
        goal: progress!.goal,
        protein:
            (progress!.protein - proteinValue.toInt()).clamp(0, progress!.goal),
        carbs: (progress!.carbs - carbsValue.toInt()).clamp(0, progress!.goal),
        fat: (progress!.fat - fatValue.toInt()).clamp(0, progress!.goal),
        dateLabel: progress!.dateLabel,
      );
      await _saveProgressToLocal();

      // ✅ إشعار بحذف الوجبة (الأسلوب الجديد)
      await NotificationHelper.showNotificationFromEvent(
        eventType: 'meal_deleted',
        params: {'mealName': meal.name},
      );
    }

    notifyListeners();
    MealEventBus().notifyMealChanged();
  }

  Future<void> addMacrosToProgress(
      double protein, double carbs, double fat) async {
    if (progress == null) return;
    progress = TodayProgressUiModel(
      calories: progress!.calories,
      goal: progress!.goal,
      protein: progress!.protein + protein.toInt(),
      carbs: progress!.carbs + carbs.toInt(),
      fat: progress!.fat + fat.toInt(),
      dateLabel: progress!.dateLabel,
    );
    await _saveProgressToLocal();
    notifyListeners();
  }

  Future<void> addCaloriesToProgress(int calories, {String? mealName}) async {
    if (progress == null) return;
    progress = TodayProgressUiModel(
      calories: progress!.calories + calories,
      goal: progress!.goal,
      protein: progress!.protein,
      carbs: progress!.carbs,
      fat: progress!.fat,
      dateLabel: progress!.dateLabel,
    );
    await _saveProgressToLocal();
    notifyListeners();
    await _checkAndSendGoalNotification(progress!.calories, progress!.goal);
    if (mealName != null) {
      // ✅ إشعار بإضافة الوجبة (الأسلوب الجديد)
      await NotificationHelper.showNotificationFromEvent(
        eventType: 'meal_added',
        params: {'mealName': mealName, 'calories': calories},
      );
    }
  }

  Future<void> _checkAndSendGoalNotification(int current, int goal) async {
    double percentage = current / goal;
    if (percentage >= 0.9 && percentage < 1.0) {
      await NotificationHelper.showNotificationFromEvent(
        eventType: 'goal_almost',
      );
    } else if (percentage >= 1.0) {
      await NotificationHelper.showNotificationFromEvent(
        eventType: 'goal_reached',
      );
    } else if (current > goal) {
      await NotificationHelper.showNotificationFromEvent(
        eventType: 'goal_over',
      );
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute;
    final period = hour >= 12 ? 'pm' : 'am';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  String _getImageForFood(String foodName) {
    final name = foodName.toLowerCase();
    if (name.contains('apple')) return 'assets/pictures/apple.png';
    if (name.contains('pizza')) return 'assets/pictures/pizza.png';
    if (name.contains('burger')) return 'assets/pictures/burger.png';
    if (name.contains('rice')) return 'assets/pictures/rice.png';
    if (name.contains('chicken')) return 'assets/pictures/chicken.png';
    if (name.contains('salad')) return 'assets/pictures/salad.png';
    return 'assets/pictures/apple.png';
  }

  Color _getColorForFood(String foodName) {
    final name = foodName.toLowerCase();
    if (name.contains('apple')) return const Color(0xFFFF6B6B);
    if (name.contains('pizza')) return const Color(0xFFFFD166);
    if (name.contains('burger')) return const Color(0xFF4ECDC4);
    if (name.contains('rice')) return const Color(0xFF9D4EDD);
    if (name.contains('chicken')) return const Color(0xFF4ECDC4);
    if (name.contains('salad')) return const Color(0xFF42E87F);
    return const Color(0xFF42E87F);
  }

  void changeTab(int index) {
    selectedTab = index;
    notifyListeners();
  }
}

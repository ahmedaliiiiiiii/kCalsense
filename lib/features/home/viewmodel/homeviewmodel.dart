// ignore_for_file: avoid_print, unused_element, unused_field

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/storge/token_storage.dart';
import '../../../core/diauth/service_locator.dart';
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

  HomeViewModel({required this.storage}) {
    _foodApi = FoodRecognitionApi(
      dio: sl<ApiClient>().dio,
      tokenStorage: storage,
    );
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

  // ==================== INIT ====================
  Future<void> init() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      userName = (await storage.getUserName()) ?? "";

      final profileData = await profileStorage.loadAll();
      int savedGoal = 2000;
      if (profileData != null && profileData['setup'] != null) {
        savedGoal =
            (profileData['setup']['dailyCaloriesTarget'] as num).round();
      }

      final String todayDate = DateFormat('EEEE, MMM d').format(DateTime.now());

      await _loadProgressFromLocal();
      await _checkAndResetProgress(savedGoal, todayDate);
      await _loadRecentFoodsFromPrefs();
    } catch (e) {
      error = "Something went wrong";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ==================== PROGRESS ====================
  Future<void> _checkAndResetProgress(int defaultGoal, String todayDate) async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString('last_progress_date');
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (lastDate == null || lastDate != today) {
      progress = TodayProgressUiModel(
        calories: 0,
        goal: defaultGoal,
        protein: 0,
        carbs: 0,
        fat: 0,
        dateLabel: todayDate,
      );
      await prefs.setString('last_progress_date', today);
      await _saveProgressToLocal();
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
      print('Error loading progress: $e');
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

  // ==================== ADD MEAL ====================
  void addRecentFood(FoodRecognitionResult result) {
    final now = DateTime.now();
    final newFood = RecentFoodUiModel(
      name: result.foodName,
      time: _formatTime(now),
      calories: result.calories.toInt(),
      imagePath: result.imagePath.isNotEmpty
          ? result.imagePath
          : _getImageForFood(result.foodName),
      color: _getColorForFood(result.foodName),
      weight: "200 gr",
      description: "Analyzed from your scan - ${result.foodName}",
      nutrition: {
        'calories': '${result.calories.toInt()} kcal',
        'protein': '${result.protein}g',
        'carbs': '${result.carbs}g',
        'fat': '${result.fats}g',
        'fiber': '0g',
        'sugar': '0g',
      },
      date: now,
    );

    _recentFoods.insert(0, newFood);
    if (_recentFoods.length > 10) _recentFoods.removeLast();
    _saveRecentFoodsToPrefs();

    MealStorage.saveMeal(
      date: now,
      name: result.foodName,
      calories: result.calories.toInt(),
      protein: result.protein,
      carbs: result.carbs,
      fats: result.fats,
      imagePath: result.imagePath,
    );

    addCaloriesToProgress(result.calories.toInt(), mealName: result.foodName);
    addMacrosToProgress(result.protein, result.carbs, result.fats);
    notifyListeners();
  }

  // ==================== DELETE MEAL ====================
  Future<void> deleteMeal(RecentFoodUiModel meal) async {
    // 1. إزالة من القائمة المحلية وحفظ في SharedPreferences
    _recentFoods.removeWhere(
        (item) => item.name == meal.name && item.time == meal.time);
    await _saveRecentFoodsToPrefs();

    // 2. إذا كانت الوجبة من اليوم الحالي، قم بخصمها من التقدم اليومي
    final today = DateTime.now();
    final isSameDay = meal.date.year == today.year &&
        meal.date.month == today.month &&
        meal.date.day == today.day;

    if (isSameDay && progress != null) {
      // استخراج قيم الماكروز من nutrition (تفترض أن القيم بصيغة "15g")
      final proteinValue = double.tryParse(
              meal.nutrition['protein']?.replaceAll('g', '') ?? '0') ??
          0;
      final carbsValue = double.tryParse(
              meal.nutrition['carbs']?.replaceAll('g', '') ?? '0') ??
          0;
      final fatValue =
          double.tryParse(meal.nutrition['fat']?.replaceAll('g', '') ?? '0') ??
              0;

      final newCalories =
          (progress!.calories - meal.calories).clamp(0, progress!.goal);
      final newProtein =
          (progress!.protein - proteinValue.toInt()).clamp(0, progress!.goal);
      final newCarbs =
          (progress!.carbs - carbsValue.toInt()).clamp(0, progress!.goal);
      final newFat =
          (progress!.fat - fatValue.toInt()).clamp(0, progress!.goal);

      progress = TodayProgressUiModel(
        calories: newCalories,
        goal: progress!.goal,
        protein: newProtein,
        carbs: newCarbs,
        fat: newFat,
        dateLabel: progress!.dateLabel,
      );
      await _saveProgressToLocal();

      await NotificationHelper.showNotification(
        title: 'Meal Deleted',
        body: '${meal.name} has been removed from today\'s progress.',
      );
    }

    // 3. حذف الوجبة من مخزن الإحصائيات (MealStorage)
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

    notifyListeners();
  }

  // ==================== MACROS & CALORIES HELPERS ====================
  Future<void> addMacrosToProgress(
      double protein, double carbs, double fat) async {
    if (progress == null) return;
    final updatedProgress = TodayProgressUiModel(
      calories: progress!.calories,
      goal: progress!.goal,
      protein: progress!.protein + protein.toInt(),
      carbs: progress!.carbs + carbs.toInt(),
      fat: progress!.fat + fat.toInt(),
      dateLabel: progress!.dateLabel,
    );
    progress = updatedProgress;
    await _saveProgressToLocal();
    notifyListeners();
  }

  Future<void> addCaloriesToProgress(int calories, {String? mealName}) async {
    if (progress == null) return;
    final newCalories = progress!.calories + calories;
    final updatedProgress = TodayProgressUiModel(
      calories: newCalories,
      goal: progress!.goal,
      protein: progress!.protein,
      carbs: progress!.carbs,
      fat: progress!.fat,
      dateLabel: progress!.dateLabel,
    );
    progress = updatedProgress;
    await _saveProgressToLocal();
    notifyListeners();

    await _checkAndSendGoalNotification(newCalories, progress!.goal);

    if (mealName != null) {
      await NotificationHelper.showNotification(
        title: 'Meal Added',
        body: 'Successfully added $mealName ($calories kcal)',
      );
    }
  }

  Future<void> _checkAndSendGoalNotification(int current, int goal) async {
    double percentage = current / goal;
    if (percentage >= 0.9 && percentage < 1.0) {
      await NotificationHelper.showNotification(
        title: 'Almost there!',
        body: "You're almost at your daily calorie goal. Keep going!",
      );
    } else if (percentage >= 1.0) {
      await NotificationHelper.showNotification(
        title: 'Goal Reached!',
        body: "Congratulations! You've reached your daily calorie goal.",
      );
    } else if (current > goal) {
      await NotificationHelper.showNotification(
        title: 'Over your goal!',
        body: "You've exceeded your daily calorie goal. Time to adjust.",
      );
    }
  }

  // ==================== RECENT FOODS (SharedPreferences) ====================
  Future<void> _loadRecentFoodsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_recentFoodsKey);
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonString);
        _recentFoods = decoded
            .map((item) =>
                RecentFoodUiModel.fromJson(item as Map<String, dynamic>))
            .toList();
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading recent foods from prefs: $e');
      }
    }
  }

  Future<void> _saveRecentFoodsToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonList =
        _recentFoods.map((food) => food.toJson()).toList();
    await prefs.setString(_recentFoodsKey, jsonEncode(jsonList));
  }

  // ==================== UTILITIES ====================
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

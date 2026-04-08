// lib/features/home/viewmodel/homeviewmodel.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/storge/token_storage.dart';
import '../model/home_models.dart';
import '../view/tabs/profile/service/profile_local_storage.dart';

class HomeViewModel extends ChangeNotifier {
  final TokenStorage storage;
  final ProfileLocalStorage profileStorage = ProfileLocalStorage();

  HomeViewModel({required this.storage});

  bool isLoading = true;
  String? error;
  TodayProgressUiModel? progress;
  List<RecentFoodUiModel> recentFoods = [];
  int selectedTab = 0;
  String userName = "";

  Future<void> init() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      userName = (await storage.getUserName()) ?? "";

      final profileData = await profileStorage.loadAll();

      int savedGoal = 3000;
      if (profileData != null && profileData['setup'] != null) {
        savedGoal =
            (profileData['setup']['dailyCaloriesTarget'] as num).round();
      }

      final String todayDate = DateFormat('EEEE, MMM d').format(DateTime.now());

      progress = TodayProgressUiModel(
        calories: 2000,
        goal: savedGoal,
        protein: 0,
        carbs: 0,
        fat: 0,
        dateLabel: todayDate,
      );

      // ✅ بيانات كاملة لكل طعام مع الـ description و nutrition
      recentFoods = [
        RecentFoodUiModel(
          name: "Apple",
          time: "9:30 pm",
          calories: 80,
          imageAsset: "assets/pictures/apple.png",
          color: const Color(0xFFFF6B6B),
          imagePath: "assets/pictures/apple.png",
          weight: "800 gr",
          description:
              'An apple is a popular, healthy, low-calorie fruit, rich in fiber and essential vitamins like Vitamin C.',
          nutrition: {
            'calories': '80 kcal',
            'protein': '0.4g',
            'carbs': '22g',
            'fat': '0.2g',
            'fiber': '4g',
            'sugar': '17g',
          },
        ),
        RecentFoodUiModel(
          name: "Pizza",
          time: "11:00 pm",
          calories: 380,
          imageAsset: "assets/pictures/pizza.png",
          color: const Color(0xFFFFD166),
          imagePath: "assets/pictures/pizza.png",
          weight: "1100 gr",
          description:
              'Pizza is a popular dish of Italian origin consisting of a flat, round base of dough baked with various toppings.',
          nutrition: {
            'calories': '380 kcal',
            'protein': '15g',
            'carbs': '40g',
            'fat': '14g',
            'fiber': '3g',
            'sugar': '5g',
          },
        ),
      ];
    } catch (e) {
      error = "Something went wrong";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void changeTab(int index) {
    selectedTab = index;
    notifyListeners();
  }

  // ✅ دالة لجلب بيانات التفاصيل للطعام
  FoodDetailData getFoodDetailData(RecentFoodUiModel food) {
    return FoodDetailData(
      name: food.name,
      time: food.time,
      calories: '${food.calories} cal',
      color: food.color,
      imagePath: food.imagePath,
      description: food.description.isNotEmpty
          ? food.description
          : 'Delicious and nutritious ${food.name}.',
      nutrition: food.nutrition.isNotEmpty
          ? food.nutrition
          : {
              'calories': '${food.calories} kcal',
              'protein': '0g',
              'carbs': '0g',
              'fat': '0g',
              'fiber': '0g',
              'sugar': '0g',
            },
      weight: food.weight,
    );
  }
}

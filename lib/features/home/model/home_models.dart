// lib/features/home/model/home_models.dart

import 'dart:ui';

class TodayProgressUiModel {
  final int calories, goal, protein, carbs, fat;
  final String dateLabel;

  const TodayProgressUiModel({
    required this.calories,
    required this.goal,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.dateLabel,
  });
}

class RecentFoodUiModel {
  final String name;
  final String time;
  final int calories;
  final String? imageAsset;
  final Color color;
  final String imagePath;
  final String weight;
  final String description;
  final Map<String, String> nutrition;

  const RecentFoodUiModel({
    required this.name,
    required this.time,
    required this.calories,
    this.imageAsset,
    this.color = const Color(0xFFFF6B6B),
    this.imagePath = "assets/pictures/apple.png",
    this.weight = "100 gr",
    this.description = "",
    this.nutrition = const {},
  });
}

// بيانات إضافية للتفاصيل
class FoodDetailData {
  final String name;
  final String time;
  final String calories;
  final Color color;
  final String imagePath;
  final String description;
  final Map<String, String> nutrition;
  final String weight;

  const FoodDetailData({
    required this.name,
    required this.time,
    required this.calories,
    required this.color,
    required this.imagePath,
    required this.description,
    required this.nutrition,
    this.weight = "100 gr",
  });
}

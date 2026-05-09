// ignore_for_file: unused_element, unnecessary_this

import 'dart:developer';

class FoodRecognitionResult {
  final String foodName;
  final double totalcalories;
  final double totalcarbs;
  final double totalprotein;
  final double totalfats;
  final String imagePath;

  const FoodRecognitionResult({
    required this.foodName,
    required this.totalcalories,
    required this.totalcarbs,
    required this.totalprotein,
    required this.totalfats,
    this.imagePath = '',
  });

  FoodRecognitionResult copyWith({
    String? foodName,
    double? calories,
    double? carbs,
    double? protein,
    double? fats,
    String? imagePath,
  }) {
    return FoodRecognitionResult(
      foodName: foodName ?? this.foodName,
      totalcalories: calories ?? this.totalcalories,
      totalcarbs: carbs ?? this.totalcarbs,
      totalprotein: protein ?? this.totalprotein,
      totalfats: fats ?? this.totalfats,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  /// محاولة استخراج قيمة عددية من key مع محاولات متعددة
  static double _extractDouble(Map<String, dynamic> json, List<String> keys) {
    for (var key in keys) {
      if (json.containsKey(key)) {
        var value = json[key];
        if (value != null) {
          if (value is num) return value.toDouble();
          if (value is String) {
            var parsed = double.tryParse(value);
            if (parsed != null) return parsed;
          }
        }
      }
    }
    return 0.0;
  }

  static String _extractString(Map<String, dynamic> json, List<String> keys) {
    for (var key in keys) {
      if (json.containsKey(key) && json[key] != null) {
        return json[key].toString();
      }
    }
    return '';
  }

  factory FoodRecognitionResult.fromJson(Map<String, dynamic> json) {
    log("🔍 Raw JSON: $json");

    // دالة مساعدة لتجربة عدة مفاتيح
    double getNumber(List<String> keys) {
      for (var key in keys) {
        if (json.containsKey(key)) {
          var val = json[key];
          if (val is num) return val.toDouble();
          if (val is String) return double.tryParse(val) ?? 0.0;
        }
      }
      return 0.0;
    }

    String getString(List<String> keys) {
      for (var key in keys) {
        if (json.containsKey(key) && json[key] != null) {
          return json[key].toString();
        }
      }
      return '';
    }

    final name = getString(['foodName', 'FoodName', 'name', 'title']);
    final calories =
        getNumber(['calories', 'Calories', 'totalCalories', 'kcal', 'energy']);
    final protein =
        getNumber(['protein', 'Protein', 'totalProtein', 'protien']);
    final carbs =
        getNumber(['carbs', 'Carbs', 'totalCarbs', 'carbohydrates', 'carbon']);
    final fats = getNumber(['fats', 'Fats', 'totalFats', 'fat', 'lipids']);

    log("✅ Extracted: name=$name, cal=$calories, protein=$protein, carbs=$carbs, fats=$fats");

    return FoodRecognitionResult(
      foodName: name,
      totalcalories: calories,
      totalcarbs: carbs,
      totalprotein: protein,
      totalfats: fats,
    );
  }
}

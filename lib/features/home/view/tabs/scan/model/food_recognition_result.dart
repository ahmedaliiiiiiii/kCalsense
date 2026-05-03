// lib/features/home/view/tabs/scan/model/food_recognition_result.dart

class FoodRecognitionResult {
  final String foodName;
  final double calories;
  final double carbs;
  final double protein;
  final double fats;
  final String categoryName;
  final double confidenceScore;
  final String imagePath;

  const FoodRecognitionResult({
    required this.foodName,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fats,
    required this.categoryName,
    required this.confidenceScore,
    this.imagePath = '',
  });

  FoodRecognitionResult copyWith({
    String? foodName,
    double? calories,
    double? carbs,
    double? protein,
    double? fats,
    String? categoryName,
    double? confidenceScore,
    String? imagePath,
  }) {
    return FoodRecognitionResult(
      foodName: foodName ?? this.foodName,
      calories: calories ?? this.calories,
      carbs: carbs ?? this.carbs,
      protein: protein ?? this.protein,
      fats: fats ?? this.fats,
      categoryName: categoryName ?? this.categoryName,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static String _toStringSafe(dynamic v) => (v ?? '').toString();

  static dynamic _pick(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      if (json.containsKey(k)) return json[k];
    }
    return null;
  }

  factory FoodRecognitionResult.fromJson(Map<String, dynamic> json) {
    double confidence =
        _toDouble(_pick(json, ['confidenceScore', 'Confidence_Score']));

    // ✅ لو الـ API مجابش confidence، استخدم قيمة وهمية
    if (confidence == 0) {
      confidence = 0.85;
    }

    return FoodRecognitionResult(
      foodName: _toStringSafe(_pick(json, ['foodName', 'FoodName'])),
      calories: _toDouble(_pick(json, ['calories', 'Calories'])),
      carbs: _toDouble(_pick(json, ['carbs', 'Carbs'])),
      protein: _toDouble(_pick(json, ['protein', 'Protein', 'protien'])),
      fats: _toDouble(_pick(json, ['fats', 'Fats'])),
      categoryName:
          _toStringSafe(_pick(json, ['categoryName', 'CategoryName'])),
      confidenceScore: confidence,
    );
  }
}

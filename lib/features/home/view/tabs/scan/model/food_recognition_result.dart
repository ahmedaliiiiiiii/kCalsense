class FoodRecognitionResult {
  final String foodName;
  final double calories;
  final double carbs;
  final double protien;
  final double fats;
  final String categoryName;
  final double confidenceScore;

  const FoodRecognitionResult({
    required this.foodName,
    required this.calories,
    required this.carbs,
    required this.protien,
    required this.fats,
    required this.categoryName,
    required this.confidenceScore,
  });

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static String _toStringSafe(dynamic v) => (v ?? '').toString();

  factory FoodRecognitionResult.fromJson(Map<String, dynamic> json) {
    dynamic pick(List<String> keys) {
      for (final k in keys) {
        if (json.containsKey(k)) return json[k];
      }
      return null;
    }

    return FoodRecognitionResult(
      foodName: _toStringSafe(pick(['foodName', 'FoodName'])),
      calories: _toDouble(pick(['calories', 'Calories'])),
      carbs: _toDouble(pick(['carbs', 'Carbs'])),
      protien: _toDouble(pick(['protien', 'Protien', 'Protien'])),
      fats: _toDouble(pick(['fats', 'Fats'])),
      categoryName: _toStringSafe(pick(['categoryName', 'CategoryName'])),
      confidenceScore: _toDouble(
          pick(['confidenceScore', 'Confidence_Score', 'confidence_Score'])),
    );
  }
}

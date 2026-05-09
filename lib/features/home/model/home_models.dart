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
  final Color color;
  final String imagePath;
  final String weight;
  final String description;
  final Map<String, String> nutrition;
  final DateTime date;
  final dynamic mealId; // Backend meal ID for API operations

  const RecentFoodUiModel({
    required this.name,
    required this.time,
    required this.calories,
    required this.imagePath,
    required this.color,
    required this.weight,
    required this.description,
    required this.nutrition,
    required this.date,
    this.mealId,
  });

  RecentFoodUiModel copyWith({
    String? name,
    String? time,
    int? calories,
    Color? color,
    String? imagePath,
    String? weight,
    String? description,
    Map<String, String>? nutrition,
    DateTime? date,
    dynamic mealId,
  }) {
    return RecentFoodUiModel(
      name: name ?? this.name,
      time: time ?? this.time,
      calories: calories ?? this.calories,
      color: color ?? this.color,
      imagePath: imagePath ?? this.imagePath,
      weight: weight ?? this.weight,
      description: description ?? this.description,
      nutrition: nutrition ?? this.nutrition,
      date: date ?? this.date,
      mealId: mealId ?? this.mealId,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'time': time,
        'calories': calories,
        'imagePath': imagePath,
        'colorValue': color.value,
        'weight': weight,
        'description': description,
        'nutrition': nutrition,
        'date': date.toIso8601String(),
        if (mealId != null) 'mealId': mealId,
      };

  factory RecentFoodUiModel.fromJson(Map<String, dynamic> json) {
    return RecentFoodUiModel(
      name: json['name'] as String,
      time: json['time'] as String,
      calories: json['calories'] as int,
      imagePath: json['imagePath'] as String,
      color: Color(json['colorValue'] as int),
      weight: json['weight'] as String,
      description: json['description'] as String,
      nutrition: Map<String, String>.from(json['nutrition']),
      date: DateTime.parse(json['date'] as String),
      mealId: json['mealId'],
    );
  }
}

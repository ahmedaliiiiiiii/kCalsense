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
  final DateTime date; // ✅ تاريخ الوجبة (اليوم الذي أضيفت فيه)

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
  });

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
    );
  }
}

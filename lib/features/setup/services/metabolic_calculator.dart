// lib/features/setup/services/metabolic_calculator.dart

import '../model/setup_models.dart';

class MetabolicResult {
  final int maintenance;
  final int goalCalories;
  final int dailyTarget;

  const MetabolicResult({
    required this.maintenance,
    required this.goalCalories,
    required this.dailyTarget,
  });
}

class MetabolicCalculator {
  static double _activityFactor(ActivityLevel a) {
    switch (a) {
      case ActivityLevel.sedentary:
        return 1.2;
      case ActivityLevel.lightlyActive:
        return 1.375;
      case ActivityLevel.moderatelyActive:
        return 1.55;
      case ActivityLevel.highlyActive:
        return 1.725;
    }
  }

  static int _goalDelta(WeightGoal g) {
    switch (g) {
      case WeightGoal.weightLoss:
        return -500;
      case WeightGoal.weightGain:
        return 500;
      case WeightGoal.maintain:
        return 0;
    }
  }

  static MetabolicResult calculate({
    required Gender gender,
    required int age,
    required double heightCm,
    required double weightKg,
    required ActivityLevel activity,
    required WeightGoal goal,
  }) {
    // Mifflin-St Jeor Equation
    final base = (10 * weightKg) + (6.25 * heightCm) - (5 * age);
    final bmr = gender == Gender.male ? (base + 5) : (base - 161);

    final tdee = bmr * _activityFactor(activity);
    final maintenance = tdee.round();

    final goalCalories =
        (maintenance + _goalDelta(goal)).clamp(1200, 4000).round();
    final dailyTarget = goalCalories;

    return MetabolicResult(
      maintenance: maintenance,
      goalCalories: goalCalories,
      dailyTarget: dailyTarget,
    );
  }
}

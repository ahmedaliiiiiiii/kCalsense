enum Gender { male, female }

enum ActivityLevel { sedentary, lightlyActive, moderatelyActive, highlyActive }

enum WeightGoal { weightGain, maintain, weightLoss }

class SetupData {
  Gender? gender;
  int? age;
  double? height;
  double? weight;
  ActivityLevel? activity;
  WeightGoal? goal;

  int? maintenanceCalories;
  int? goalCalories;
  int? dailyTarget;
}

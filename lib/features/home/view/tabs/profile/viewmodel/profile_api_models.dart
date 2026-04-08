import '../../../../../setup/model/setup_models.dart';

class ProfileSetupRequest {
  final int age;
  final double weight;
  final int height;
  final Gender gender;
  final ActivityLevel activityLevel;
  final WeightGoal goalType;

  const ProfileSetupRequest({
    required this.age,
    required this.weight,
    required this.height,
    required this.gender,
    required this.activityLevel,
    required this.goalType,
  });

  Map<String, dynamic> toJson() => {
        "age": age,
        "weight": weight,
        "height": height,
        "gender": gender.toApi(),
        "activityLevel": activityLevel.toApi(),
        "goalType": goalType.toApi(),
      };
}

class ProfileSetupResponse {
  final double amr;
  final double bmr;
  final double dailyCaloriesTarget;

  const ProfileSetupResponse({
    required this.amr,
    required this.bmr,
    required this.dailyCaloriesTarget,
  });

  factory ProfileSetupResponse.fromJson(Map<String, dynamic> json) {
    double d(dynamic v) {
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return ProfileSetupResponse(
      amr: d(json["amr"]),
      bmr: d(json["bmr"]),
      dailyCaloriesTarget: d(json["dailyCaloriesTarget"]),
    );
  }
}

extension GenderApi on Gender {
  String toApi() => this == Gender.male ? "Male" : "Female";
}

extension ActivityApi on ActivityLevel {
  String toApi() {
    switch (this) {
      case ActivityLevel.sedentary:
        return "Sedentary";
      case ActivityLevel.lightlyActive:
        return "LightlyActive";
      case ActivityLevel.moderatelyActive:
        return "ModeratelyActive";
      case ActivityLevel.highlyActive:
        return "HighlyActive";
    }
  }
}

extension GoalApi on WeightGoal {
  String toApi() {
    switch (this) {
      case WeightGoal.weightLoss:
        return "LoseWeight";
      case WeightGoal.maintain:
        return "MaintainWeight";
      case WeightGoal.weightGain:
        return "GainWeight";
    }
  }
}

extension GenderApiParser on String {
  Gender toGenderEnum() {
    switch (trim()) {
      case "Male":
        return Gender.male;
      case "Female":
        return Gender.female;
      default:
        return Gender.male;
    }
  }

  ActivityLevel toActivityEnum() {
    switch (trim()) {
      case "Sedentary":
        return ActivityLevel.sedentary;
      case "LightlyActive":
        return ActivityLevel.lightlyActive;
      case "ModeratelyActive":
        return ActivityLevel.moderatelyActive;
      case "HighlyActive":
        return ActivityLevel.highlyActive;
      default:
        return ActivityLevel.sedentary;
    }
  }

  WeightGoal toGoalEnum() {
    switch (trim()) {
      case "LoseWeight":
        return WeightGoal.weightLoss;
      case "MaintainWeight":
        return WeightGoal.maintain;
      case "GainWeight":
        return WeightGoal.weightGain;
      default:
        return WeightGoal.maintain;
    }
  }
}

import 'package:flutter/foundation.dart';

import '../../../../../../core/storge/token_storage.dart';
import '../service/profile_local_storage.dart';
import 'profile_api_models.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileLocalStorage _local;
  final TokenStorage _tokenStorage;

  ProfileViewModel({
    required TokenStorage tokenStorage,
    ProfileLocalStorage? local,
  })  : _tokenStorage = tokenStorage,
        _local = local ?? ProfileLocalStorage();

  bool isLoading = true;
  String? error;
  ProfileUiModel? data;

  Future<void> init() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final userName = (await _tokenStorage.getUserName()) ?? "User";
      final email = (await _tokenStorage.getEmail()) ?? "user@mail.com";

      final all = await _local.loadAll();
      if (all == null) {
        data = ProfileUiModel.empty(name: userName, email: email);
        return;
      }

      final inputRaw = all["input"];
      final setupRaw = all["setup"];

      if (inputRaw is! Map || setupRaw is! Map) {
        data = ProfileUiModel.empty(name: userName, email: email);
        return;
      }

      final input = inputRaw.cast<String, dynamic>();
      final setupJson = setupRaw.cast<String, dynamic>();
      final setup = ProfileSetupResponse.fromJson(setupJson);

      String goalTextFromApi(String v) {
        switch (v) {
          case "LoseWeight":
            return "Lose Weight";
          case "GainWeight":
            return "Gain Weight";
          default:
            return "Maintain Weight";
        }
      }

      String activityTextFromApi(String v) {
        switch (v) {
          case "LightlyActive":
            return "Lightly Active";
          case "ModeratelyActive":
            return "Moderately Active";
          case "HighlyActive":
            return "Highly Active";
          default:
            return "Sedentary";
        }
      }

      final age = (input["age"] as num?)?.toInt() ?? 18;
      final height = (input["height"] as num?)?.toInt() ?? 170;
      final weight = (input["weight"] as num?)?.toDouble() ?? 70.0;

      data = ProfileUiModel.fromSetupResponse(
        name: userName,
        email: email,
        age: age,
        heightCm: height,
        weightKg: weight,
        genderText: (input["gender"]?.toString() ?? "Male"),
        activityText: activityTextFromApi(
          input["activityLevel"]?.toString() ?? "Sedentary",
        ),
        goalText: goalTextFromApi(
          input["goalType"]?.toString() ?? "MaintainWeight",
        ),
        setup: setup,
      );
    } catch (e) {
      error = e.toString();
      data ??= ProfileUiModel.empty();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

class ProfileUiModel {
  final String name;
  final String email;
  final int age;
  final int heightCm;
  final double weightKg;
  final double bmi;
  final String goalText;
  final String activityText;
  final String genderText;
  final double dailyCaloriesTarget;
  final double bmr;
  final double amr;

  const ProfileUiModel({
    required this.name,
    required this.email,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.bmi,
    required this.goalText,
    required this.activityText,
    required this.genderText,
    required this.dailyCaloriesTarget,
    required this.bmr,
    required this.amr,
  });

  String get goalTitle => goalText;
  String get goalSubtitle => "Based on your body data and activity level.";

  factory ProfileUiModel.empty({
    String name = "User",
    String email = "user@mail.com",
  }) {
    return ProfileUiModel(
      name: name,
      email: email,
      age: 18,
      heightCm: 170,
      weightKg: 70,
      bmi: 24.2,
      goalText: "Maintain Weight",
      activityText: "Sedentary",
      genderText: "Male",
      dailyCaloriesTarget: 2000,
      bmr: 1500,
      amr: 2000,
    );
  }

  factory ProfileUiModel.fromSetupResponse({
    required String name,
    required String email,
    required int age,
    required int heightCm,
    required double weightKg,
    required String genderText,
    required String activityText,
    required String goalText,
    required ProfileSetupResponse setup,
  }) {
    final hM = heightCm / 100.0;
    final bmi = hM > 0 ? (weightKg / (hM * hM)) : 0.0;

    return ProfileUiModel(
      name: name,
      email: email,
      age: age,
      heightCm: heightCm,
      weightKg: weightKg,
      bmi: bmi,
      goalText: goalText,
      activityText: activityText,
      genderText: genderText,
      dailyCaloriesTarget: setup.dailyCaloriesTarget,
      bmr: setup.bmr,
      amr: setup.amr,
    );
  }
}

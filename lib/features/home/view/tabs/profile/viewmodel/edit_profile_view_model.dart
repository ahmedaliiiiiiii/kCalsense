import 'package:flutter/material.dart';
import 'package:kcalsense/features/home/view/tabs/profile/viewmodel/profile_api_models.dart';

import '../../../../../../core/di/service_locator.dart';
import '../../../../../setup/model/setup_models.dart';
import '../../../../../setup/services/metabolic_calculator.dart';
import '../service/profile_api_service.dart';
import '../service/profile_local_storage.dart';

class EditProfileViewModel extends ChangeNotifier {
  final ProfileApiService _api = ProfileApiService();
  final ProfileLocalStorage _local = sl<ProfileLocalStorage>();

  final ageC = TextEditingController();
  final heightC = TextEditingController();
  final weightC = TextEditingController();

  Gender? gender;
  ActivityLevel? activity;
  WeightGoal? goal;

  bool isSaving = false;
  String? error;

  void fillDefaults({
    required int age,
    required int heightCm,
    required double weightKg,
    required Gender initialGender,
    required ActivityLevel initialActivity,
    required WeightGoal initialGoal,
  }) {
    ageC.text = age.toString();
    heightC.text = heightCm.toString();
    weightC.text = weightKg.toStringAsFixed(1);

    gender = initialGender;
    activity = initialActivity;
    goal = initialGoal;
  }

  bool get canSave {
    final a = int.tryParse(ageC.text) ?? 0;
    final h = double.tryParse(heightC.text) ?? 0;
    final w = double.tryParse(weightC.text) ?? 0;

    return a > 5 &&
        h > 50 &&
        w > 10 &&
        gender != null &&
        activity != null &&
        goal != null;
  }

  Future<bool> save() async {
    if (!canSave || isSaving) return false;

    try {
      isSaving = true;
      error = null;
      notifyListeners();

      final req = ProfileSetupRequest(
        age: int.parse(ageC.text.trim()),
        weight: double.parse(weightC.text.trim()),
        height: double.parse(heightC.text.trim()).round(),
        gender: gender!,
        activityLevel: activity!,
        goalType: goal!,
      );

      await _api.update(req);

      final calc = MetabolicCalculator.calculate(
        gender: req.gender,
        age: req.age,
        heightCm: req.height.toDouble(),
        weightKg: req.weight,
        activity: req.activityLevel,
        goal: req.goalType,
      );

      await _local.saveAll(
        input: {
          "age": req.age,
          "weight": req.weight,
          "height": req.height,
          "gender": req.gender.toApi(),
          "activityLevel": req.activityLevel.toApi(),
          "goalType": req.goalType.toApi(),
        },
        setup: {
          "bmr": calc.maintenance.toDouble(),
          "amr": calc.maintenance.toDouble(),
          "dailyCaloriesTarget": calc.dailyTarget.toDouble(),
        },
      );

      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    ageC.dispose();
    heightC.dispose();
    weightC.dispose();
    super.dispose();
  }
}

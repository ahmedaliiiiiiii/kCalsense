import 'package:flutter/material.dart';

import '../../../../../setup/model/setup_models.dart';
import '../../../../../setup/services/metabolic_calculator.dart';
import '../service/profile_api_service.dart';
import '../service/profile_local_storage.dart';
import '../viewmodel/profile_api_models.dart';

class EditProfileViewModel extends ChangeNotifier {
  final ProfileApiService _api = ProfileApiService();
  final ProfileLocalStorage _local = ProfileLocalStorage();

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
  }) {
    ageC.text = age.toString();
    heightC.text = heightCm.toString();
    weightC.text = weightKg.toStringAsFixed(1);
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
        age: int.parse(ageC.text),
        weight: double.parse(weightC.text),
        height: double.parse(heightC.text).round(),
        gender: gender!,
        activityLevel: activity!,
        goalType: goal!,
      );

      // ✅ 1) Update على السيرفر
      await _api.update(req);

      // ✅ 2) احفظ input + setup result في profile_all
      //
      // IMPORTANT:
      // ما نناديش POST /Profile/setup هنا لتجنب 500 (لأنه غالبًا Insert).
      // بدل كده نحسب محليًا نفس الأرقام التقريبية (عندك MetabolicCalculator بالفعل).
      final calc = MetabolicCalculator.calculate(
        gender: req.gender,
        age: req.age,
        heightCm: req.height.toDouble(),
        weightKg: req.weight,
        activity: req.activityLevel,
        goal: req.goalType,
      );

      // فهنحط bmr = 0 مؤقتًا أو نقرأ القديم ونحافظ عليه.
      final old = await _local.loadAll();
      final oldSetup = (old?["setup"] as Map?)?.cast<String, dynamic>();

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
          // نحافظ على bmr القديم لو موجود، وإلا 0
          "bmr": (oldSetup?["bmr"] is num)
              ? (oldSetup!["bmr"] as num).toDouble()
              : 0.0,
          // maintenance ≈ AMR
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

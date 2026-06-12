// lib/features/setup/viewmodel/setup_viewmodel.dart

// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

import '../../../core/di/service_locator.dart';
import '../../home/view/tabs/profile/service/profile_api_service.dart';
import '../../home/view/tabs/profile/service/profile_local_storage.dart';
import '../../home/view/tabs/profile/viewmodel/profile_api_models.dart';
import '../model/setup_models.dart';
import '../services/metabolic_calculator.dart';

class SetupViewModel extends ChangeNotifier {
  final data = SetupData();
  final pageController = PageController();
  int step = 0;

  final ProfileApiService _api = ProfileApiService();
  final ProfileLocalStorage _local = sl<ProfileLocalStorage>();

  bool isLoading = false;
  String? error;

  void setGender(Gender v) {
    data.gender = v;
    notifyListeners();
  }

  void setAge(String v) {
    data.age = int.tryParse(v);
    notifyListeners();
  }

  void setHeight(String v) {
    data.height = double.tryParse(v);
    notifyListeners();
  }

  void setWeight(String v) {
    data.weight = double.tryParse(v);
    notifyListeners();
  }

  void setActivity(ActivityLevel v) {
    data.activity = v;
    notifyListeners();
  }

  void setGoal(WeightGoal v) {
    data.goal = v;
    notifyListeners();
  }

  bool get canGoNext {
    switch (step) {
      case 0:
        return data.gender != null;
      case 1:
        return (data.age ?? 0) > 5;
      case 2:
        return (data.height ?? 0) > 50;
      case 3:
        return (data.weight ?? 0) > 10;
      case 4:
        return data.activity != null;
      case 5:
        return data.goal != null;
      default:
        return true;
    }
  }

  Future<void> next() async {
    if (!canGoNext || isLoading) return;

    error = null;

    if (step == 5) {
      step++;
      notifyListeners();

      await pageController.nextPage(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
      );

      await _callSetupApiAndSaveAll();
      return;
    }

    step++;
    await pageController.nextPage(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
    );
    notifyListeners();
  }

  Future<void> retryCalculation() async {
    await _callSetupApiAndSaveAll();
  }

  Future<void> _callSetupApiAndSaveAll() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final req = ProfileSetupRequest(
        age: data.age!,
        weight: data.weight!,
        height: data.height!.round(),
        gender: data.gender!,
        activityLevel: data.activity!,
        goalType: data.goal!,
      );

      // ✅ حساب محلي أولاً (في حالة فشل API)
      final localCalc = MetabolicCalculator.calculate(
        gender: req.gender,
        age: req.age,
        heightCm: req.height.toDouble(),
        weightKg: req.weight,
        activity: req.activityLevel,
        goal: req.goalType,
      );

      bool apiSuccess = false;
      ProfileSetupResponse? res;

      // ✅ محاولة الاتصال بالسيرفر
      try {
        res = await _api.setup(req);
        apiSuccess = true;
      } catch (apiError) {
        print('API Error (500): $apiError - using local calculation');
        apiSuccess = false;
      }

      if (apiSuccess && res != null) {
        // ✅ استخدام البيانات من API
        data.maintenanceCalories = res.amr.round();
        data.goalCalories = res.dailyCaloriesTarget.round();
        data.dailyTarget = res.dailyCaloriesTarget.round();

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
            "amr": res.amr,
            "bmr": res.bmr,
            "dailyCaloriesTarget": res.dailyCaloriesTarget,
          },
        );
      } else {
        // ✅ استخدام الحساب المحلي
        data.maintenanceCalories = localCalc.maintenance;
        data.goalCalories = localCalc.dailyTarget;
        data.dailyTarget = localCalc.dailyTarget;

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
            "amr": localCalc.maintenance.toDouble(),
            "bmr": localCalc.maintenance.toDouble(),
            "dailyCaloriesTarget": localCalc.dailyTarget.toDouble(),
          },
        );
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void back() {
    if (step > 0) {
      step--;
      notifyListeners();
      pageController.previousPage(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}

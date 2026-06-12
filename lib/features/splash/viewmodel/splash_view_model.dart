// lib/features/splash/viewmodel/splash_view_model.dart

import 'package:flutter/material.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/router/app_router.dart';
import '../../../core/storage/app_prefs.dart';

class SplashViewModel extends ChangeNotifier {
  bool goNext = false;
  String nextRoute = AppRouter.splash;

  Future<void> init() async {
    // انتظار انتهاء الأنيميشن الخاص بالـ Splash
    await Future.delayed(const Duration(milliseconds: 2500));

    final appPrefs = sl<AppPrefs>();
    final isFirstLaunch = appPrefs.isFirstLaunch;
    final isLoggedIn = appPrefs.isLoggedIn;
    final isSetupCompleted = appPrefs.isSetupCompleted;

    if (isFirstLaunch) {
      nextRoute = AppRouter.start;
    } else if (!isLoggedIn) {
      nextRoute = AppRouter.login;
    } else if (!isSetupCompleted) {
      nextRoute = AppRouter.setup;
    } else {
      nextRoute = AppRouter.home;
    }

    goNext = true;
    notifyListeners();
  }
}

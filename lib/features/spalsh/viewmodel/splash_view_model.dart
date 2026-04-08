// lib/features/splash/viewmodel/splash_view_model.dart

import 'package:flutter/material.dart';

import '../../../core/storge/shared_preferences_helper.dart';
import '../../../core/storge/token_storage.dart';
import '../../home/view/tabs/home tab/home_tab.dart';
import '../../onboarding/onboarding_screen.dart';
import '../../setup/view/setup_flow_page.dart';
import '../../start screen/start_screen.dart';

class SplashViewModel extends ChangeNotifier {
  bool goNext = false;
  String nextRoute = '/';

  Future<void> init() async {
    await Future.delayed(const Duration(milliseconds: 2000));

    // 1. هل هي أول مرة يفتح التطبيق؟
    final isFirstLaunch = await SharedPreferencesHelper.isFirstLaunch();

    if (isFirstLaunch) {
      nextRoute = SettingsScreen.routeName;
      goNext = true;
      notifyListeners();
      return;
    }

    // 2. هل فيه توكن مخزّن؟ (يعني المستخدم مسجل دخول قبل كده)
    final tokenStorage = TokenStorage();
    final token = await tokenStorage.getToken();
    final isLoggedIn = token != null && token.isNotEmpty;

    if (!isLoggedIn) {
      nextRoute = OnBoardingScreen.routeName;
      goNext = true;
      notifyListeners();
      return;
    }

    // 3. مسجل دخول → هل أكمل الـ Setup؟
    final isSetupCompleted = await SharedPreferencesHelper.isSetupCompleted();

    if (!isSetupCompleted) {
      nextRoute = SetupFlowPage.routeName;
      goNext = true;
      notifyListeners();
      return;
    }

    // 4. كل حاجة تمام → Home
    nextRoute = HomePage.routeName;
    goNext = true;
    notifyListeners();
  }
}

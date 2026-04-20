// lib/main.dart

// ignore_for_file: unused_element, avoid_print

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'core/diauth/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/auth/presention/cubit/authcubit_cubit.dart';
import 'features/auth/presention/forget_password_page.dart';
import 'features/auth/presention/login_page.dart';
import 'features/home/view/tabs/home tab/home_tab.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/setup/view/setup_flow_page.dart';
import 'features/spalsh/view/spash_page.dart';
import 'features/start screen/start_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  setupServiceLocator();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        BlocProvider<AuthCubit>(create: (_) => sl<AuthCubit>()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'KCalsense',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.materialThemeMode,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: const SplashPage(),
            routes: {
              SettingsScreen.routeName: (context) => const SettingsScreen(),
              OnBoardingScreen.routeName: (context) => const OnBoardingScreen(),
              HomePage.routeName: (context) => const HomePage(),
              LoginPage.routeName: (context) => const LoginPage(),
              ForgotPasswordPage.routeName: (context) =>
                  const ForgotPasswordPage(),
              SetupFlowPage.routeName: (context) => const SetupFlowPage(),
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/register_page.dart';
import '../../features/auth/presentation/reset password/forget_password_page.dart';
import '../../features/auth/presentation/reset password/otp_verification_page.dart';
import '../../features/auth/presentation/reset password/reset_password_page.dart';
import '../../features/home/view/tabs/home_tab/home_tab.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/setup/view/setup_flow_page.dart';
import '../../features/splash/view/spash_page.dart';
import '../../features/start_screen/start_screen.dart';
import '../di/service_locator.dart';
import '../storage/app_prefs.dart';

class AppRouter {
  AppRouter._();

  static const String splash = '/splash';
  static const String start = '/start';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String otpVerification = '/otp-verification';
  static const String resetPassword = '/reset-password';
  static const String setup = '/setup';
  static const String home = '/home';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final appPrefs = sl<AppPrefs>();
      final isFirstLaunch = appPrefs.isFirstLaunch;
      final isLoggedIn = appPrefs.isLoggedIn;
      final isSetupCompleted = appPrefs.isSetupCompleted;
      final location = state.matchedLocation;

      if (location == splash) return null;

      if (isFirstLaunch) {
        if (location != start && location != onboarding) {
          return start;
        }
        return null;
      }

      if (!isLoggedIn) {
        const authRoutes = [
          login,
          register,
          forgotPassword,
          otpVerification,
          resetPassword
        ];
        bool isAuthRoute =
            authRoutes.any((route) => location.startsWith(route));

        if (!isAuthRoute) {
          return login;
        }
        return null;
      }

      if (!isSetupCompleted && location != setup) {
        return setup;
      }

      if (isLoggedIn &&
          (location == login ||
              location == register ||
              location == onboarding ||
              location == start)) {
        return isSetupCompleted ? home : setup;
      }

      return null;
    },
    routes: [
      // All routes use the same slide transition (from right)
      GoRoute(
        path: splash,
        pageBuilder: (context, state) => _slideTransitionPage(
          child: const SplashPage(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: start,
        pageBuilder: (context, state) => _slideTransitionPage(
          child: const StartScreen(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: onboarding,
        pageBuilder: (context, state) => _slideTransitionPage(
          child: const OnBoardingScreen(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: login,
        pageBuilder: (context, state) => _slideTransitionPage(
          duration: Duration(milliseconds: 400),
          child: const LoginPage(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: register,
        pageBuilder: (context, state) => _slideTransitionPage(
          child: const RegisterPage(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: forgotPassword,
        pageBuilder: (context, state) => _slideTransitionPage(
          child: const ForgotPasswordPage(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: '$otpVerification/:email',
        pageBuilder: (context, state) => _slideTransitionPage(
          child: OtpVerificationPage(email: state.pathParameters['email']!),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: '$resetPassword/:email/:otp',
        pageBuilder: (context, state) => _slideTransitionPage(
          child: ResetPasswordPage(
            email: state.pathParameters['email']!,
            otp: state.pathParameters['otp']!,
          ),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: setup,
        pageBuilder: (context, state) => _slideTransitionPage(
          child: const SetupFlowPage(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: home,
        pageBuilder: (context, state) => _slideTransitionPage(
          child: const HomePage(),
          key: state.pageKey,
        ),
      ),
    ],
  );

  // Unified slide transition (from right)
  static Page<void> _slideTransitionPage({
    required Widget child,
    LocalKey? key,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return CustomTransitionPage<void>(
      key: key,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0), // start from right
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      },
      transitionDuration: duration,
      reverseTransitionDuration: duration,
    );
  }
}

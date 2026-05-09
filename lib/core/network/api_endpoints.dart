import '../config/app_config.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static String get baseUrl => AppConfig.baseUrl;

  // Auth
  static const String login = '/Auth/login';
  static const String register = '/Auth/register';
  static const String forgotPassword = '/Auth/forgot-password';
  static const String verifyOtp = '/Auth/verifyotp';
  static const String resetPassword = '/Auth/resetpassword';

  // Food Recognition
  static const String recentFoods = '/foodrecognition/recent';
  static const String recognizeFood = '/foodrecognition/recognize';

  // Profile
  static const String profile = '/Profile';
  static const String profileSetup = '/Profile/setup';
  static const String profileUpdate = '/Profile/update';

  // Meal
  static const String mealFoods = '/Meal/foods';
  static const String mealLog = '/Meal/log';
  static const String mealToday = '/Meal/today';
  static const String mealDailySummary = '/Meal/daily-summary';
  static const String mealHistory = '/Meal/history';
  static const String mealDelete = '/Meal';
  static const String mealUpdateType = '/Meal';
  static const String mealUpdateItems = '/Meal';
}

import '../config/app_config.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static String get baseUrl => AppConfig.baseUrl;

  // Auth
  static const login = '/Auth/login';
  static const register = '/Auth/register';

  // Food Recognition
  static const recentFoods = '/foodrecognition/recent';
  static const recognizeFood = '/foodrecognition/recognize';

  // Profile
  static const profileSetup = '/Profile/setup';
  static const profileUpdate = '/Profile/update';

  // Meal
  static const mealFoods = '/Meal/foods';
  static const mealLog = '/Meal/log';
  static const mealToday = '/Meal/today';
  static const mealDailySummary = '/Meal/daily-summary';
  static const mealHistory = '/Meal/history';
  /// Usage: '${ApiEndpoints.mealDelete}/$mealId'
  static const mealDelete = '/Meal';
  /// Usage: '${ApiEndpoints.mealUpdateType}/$mealId/type'
  static const mealUpdateType = '/Meal';
  /// Usage: '${ApiEndpoints.mealUpdateItems}/$mealId/items'
  static const mealUpdateItems = '/Meal';
}

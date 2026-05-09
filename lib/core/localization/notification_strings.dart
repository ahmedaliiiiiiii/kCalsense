import 'package:shared_preferences/shared_preferences.dart';

class NotificationStrings {
  // اللغة الحالية – يتم تحميلها من SharedPreferences
  static String _currentLanguage = 'ar'; // افتراضي عربي

  static Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('app_language') ?? 'ar';
  }

  static void setLanguage(String lang) {
    _currentLanguage = lang;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('app_language', lang);
    });
  }

  static String get _lang => _currentLanguage;

  // نصوص الإشعارات
  static String get mealDeletedTitle =>
      _lang == 'ar' ? 'تم حذف الوجبة' : 'Meal Deleted';

  static String mealDeletedBody(String mealName) => _lang == 'ar'
      ? 'تم حذف $mealName من تقدم اليوم'
      : '$mealName has been removed from today\'s progress.';

  static String get mealAddedTitle =>
      _lang == 'ar' ? 'تم إضافة الوجبة' : 'Meal Added';

  static String mealAddedBody(String mealName, int calories) => _lang == 'ar'
      ? 'تم إضافة $mealName بنجاح ($calories سعرة)'
      : 'Successfully added $mealName ($calories kcal)';

  static String get almostThereTitle =>
      _lang == 'ar' ? 'قاربنا على الهدف' : 'Almost there!';

  static String get almostThereBody => _lang == 'ar'
      ? 'أنت على وشك الوصول إلى هدفك اليومي. استمر!'
      : "You're almost at your daily calorie goal. Keep going!";

  static String get goalReachedTitle =>
      _lang == 'ar' ? 'تم الوصول للهدف' : 'Goal Reached!';

  static String get goalReachedBody => _lang == 'ar'
      ? 'تهانينا! لقد وصلت إلى هدفك اليومي من السعرات.'
      : "Congratulations! You've reached your daily calorie goal.";

  static String get overGoalTitle =>
      _lang == 'ar' ? 'تجاوزت الهدف' : 'Over your goal!';

  static String get overGoalBody => _lang == 'ar'
      ? 'لقد تجاوزت هدفك اليومي. حان وقت التعديل.'
      : "You've exceeded your daily calorie goal. Time to adjust.";
}

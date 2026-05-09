import 'package:shared_preferences/shared_preferences.dart';

class NotificationStrings {
  static Future<String> _getLang() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('app_language') ?? 'en';
  }

  static Future<String> get mealDeletedTitle async =>
      (await _getLang()) == 'ar' ? 'تم حذف الوجبة' : 'Meal Deleted';

  static Future<String> mealDeletedBody(String mealName) async =>
      (await _getLang()) == 'ar'
          ? 'تم حذف $mealName من تقدم اليوم'
          : '$mealName has been removed from today\'s progress.';

  static Future<String> get mealAddedTitle async =>
      (await _getLang()) == 'ar' ? 'تم إضافة الوجبة' : 'Meal Added';

  static Future<String> mealAddedBody(String mealName, int calories) async =>
      (await _getLang()) == 'ar'
          ? 'تم إضافة $mealName بنجاح ($calories سعرة)'
          : 'Successfully added $mealName ($calories kcal)';

  static Future<String> get almostThereTitle async =>
      (await _getLang()) == 'ar' ? 'قاربنا على الهدف' : 'Almost there!';

  static Future<String> get almostThereBody async => (await _getLang()) == 'ar'
      ? 'أنت على وشك الوصول إلى هدفك اليومي. استمر!'
      : "You're almost at your daily calorie goal. Keep going!";

  static Future<String> get goalReachedTitle async =>
      (await _getLang()) == 'ar' ? 'تم الوصول للهدف' : 'Goal Reached!';

  static Future<String> get goalReachedBody async => (await _getLang()) == 'ar'
      ? 'تهانينا! لقد وصلت إلى هدفك اليومي من السعرات.'
      : "Congratulations! You've reached your daily calorie goal.";

  static Future<String> get overGoalTitle async =>
      (await _getLang()) == 'ar' ? 'تجاوزت الهدف' : 'Over your goal!';

  static Future<String> get overGoalBody async => (await _getLang()) == 'ar'
      ? 'لقد تجاوزت هدفك اليومي. حان وقت التعديل.'
      : "You've exceeded your daily calorie goal. Time to adjust.";
}

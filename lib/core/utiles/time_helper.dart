import 'package:easy_localization/easy_localization.dart';

class TimeHelper {
  static String getGreeting() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 5 && hour < 12) {
      return 'home.greeting.morning'.tr();
    } else if (hour >= 12 && hour < 17) {
      return 'home.greeting.afternoon'.tr();
    } else if (hour >= 17 && hour < 22) {
      return 'home.greeting.evening'.tr();
    } else {
      return 'home.greeting.night'.tr();
    }
  }

  static String getFormattedTime() {
    return DateFormat('h:mm a').format(DateTime.now());
  }

  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${"notifications.minutes_ago".tr()}';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? "notifications.hour_ago".tr() : "notifications.hours_ago".tr()}';
    } else if (difference.inDays == 1) {
      return "notifications.yesterday".tr();
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }
}

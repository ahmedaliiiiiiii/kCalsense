// ignore_for_file: file_names, empty_catches

import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _notifications.initialize(settings);
  }

  // عرض إشعار بناءً على نوع الحدث ومعاملات
  static Future<void> showNotificationFromEvent({
    required String eventType,
    Map<String, dynamic>? params,
  }) async {
    final lang = await _getCurrentLanguage();
    final title =
        _getTranslation(lang, 'notification_${eventType}_title', params);
    final body =
        _getTranslation(lang, 'notification_${eventType}_body', params);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'calorie_alert_channel',
      'Calorie Alerts',
      importance: Importance.high,
      priority: Priority.high,
    );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _notifications.show(0, title, body, details);

    // حفظ الحدث فقط (بدون نصوص مترجمة)
    await _saveNotificationEvent(eventType, params);
  }

  static Future<String> _getCurrentLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('app_language') ?? 'en';
  }

  static String _getTranslation(
      String lang, String key, Map<String, dynamic>? params) {
    // خرائط الترجمة الثنائية (عربي/إنجليزي)
    final Map<String, Map<String, String>> strings = {
      'en': {
        'notification_meal_deleted_title': 'Meal Deleted',
        'notification_meal_deleted_body':
            '{mealName} has been removed from today\'s progress.',
        'notification_meal_added_title': 'Meal Added',
        'notification_meal_added_body':
            'Successfully added {mealName} ({calories} kcal)',
        'notification_goal_almost_title': 'Almost there!',
        'notification_goal_almost_body':
            'You\'re almost at your daily calorie goal. Keep going!',
        'notification_goal_reached_title': 'Goal Reached!',
        'notification_goal_reached_body':
            'Congratulations! You\'ve reached your daily calorie goal.',
        'notification_goal_over_title': 'Over your goal!',
        'notification_goal_over_body':
            'You\'ve exceeded your daily calorie goal. Time to adjust.',
      },
      'ar': {
        'notification_meal_deleted_title': 'تم حذف الوجبة',
        'notification_meal_deleted_body': 'تم حذف {mealName} من تقدم اليوم',
        'notification_meal_added_title': 'تم إضافة الوجبة',
        'notification_meal_added_body':
            'تم إضافة {mealName} بنجاح ({calories} سعرة)',
        'notification_goal_almost_title': 'قاربنا على الهدف',
        'notification_goal_almost_body':
            'أنت على وشك الوصول إلى هدفك اليومي. استمر!',
        'notification_goal_reached_title': 'تم الوصول للهدف',
        'notification_goal_reached_body':
            'تهانينا! لقد وصلت إلى هدفك اليومي من السعرات.',
        'notification_goal_over_title': 'تجاوزت الهدف',
        'notification_goal_over_body':
            'لقد تجاوزت هدفك اليومي. حان وقت التعديل.',
      }
    };

    String text = strings[lang]?[key] ?? strings['en']![key] ?? key;
    // استبدال المعاملات
    if (params != null) {
      params.forEach((k, v) {
        text = text.replaceAll('{$k}', v.toString());
      });
    }
    return text;
  }

  static Future<void> _saveNotificationEvent(
      String eventType, Map<String, dynamic>? params) async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> notifications = [];

    final String? existing = prefs.getString('notifications_history');
    if (existing != null && existing.isNotEmpty) {
      try {
        notifications = List<Map<String, dynamic>>.from(jsonDecode(existing));
      } catch (e) {}
    }

    notifications.insert(0, {
      'eventType': eventType,
      'params': params ?? {},
      'timestamp': DateTime.now().toIso8601String(),
      'isRead': false,
    });

    if (notifications.length > 50) notifications.removeLast();
    await prefs.setString('notifications_history', jsonEncode(notifications));
  }

  // جلب الإشعارات المترجمة (لصفحة الإشعارات)
  static Future<List<Map<String, dynamic>>> getTranslatedNotifications() async {
    final rawNotifications = await getNotifications();
    final lang = await _getCurrentLanguage();
    final List<Map<String, dynamic>> translated = [];
    for (var notif in rawNotifications) {
      if (notif.containsKey('title') &&
          notif.containsKey('body') &&
          !notif.containsKey('eventType')) {
        // إشعار قديم – نرجعه كما هو
        translated.add({
          'title': notif['title'],
          'body': notif['body'],
          'timestamp': notif['timestamp'],
          'isRead': notif['isRead'],
        });
      } else {
        final eventType = notif['eventType'] as String;
        final params = notif['params'] as Map<String, dynamic>?;
        translated.add({
          'title':
              _getTranslation(lang, 'notification_${eventType}_title', params),
          'body':
              _getTranslation(lang, 'notification_${eventType}_body', params),
          'timestamp': notif['timestamp'],
          'isRead': notif['isRead'],
        });
      }
    }
    return translated;
  }

  // الدوال القديمة (للتوافق)
  static Future<void> showNotification(
      {required String title, required String body}) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'calorie_alert_channel',
      'Calorie Alerts',
      importance: Importance.high,
      priority: Priority.high,
    );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _notifications.show(0, title, body, details);
    await _saveNotification(title, body);
  }

  static Future<void> _saveNotification(String title, String body) async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> notifications = [];
    final String? existing = prefs.getString('notifications_history');
    if (existing != null && existing.isNotEmpty) {
      try {
        notifications = List<Map<String, dynamic>>.from(jsonDecode(existing));
      } catch (e) {}
    }
    notifications.insert(0, {
      'title': title,
      'body': body,
      'timestamp': DateTime.now().toIso8601String(),
      'isRead': false,
    });
    if (notifications.length > 50) notifications.removeLast();
    await prefs.setString('notifications_history', jsonEncode(notifications));
  }

  static Future<List<Map<String, dynamic>>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('notifications_history');
    if (data == null || data.isEmpty) return [];
    try {
      return List<Map<String, dynamic>>.from(jsonDecode(data));
    } catch (e) {
      return [];
    }
  }

  static Future<void> markAllAsRead() async {
    final notifications = await getNotifications();
    for (var notif in notifications) {
      notif['isRead'] = true;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notifications_history', jsonEncode(notifications));
  }

  static Future<int> getUnreadCount() async {
    final notifications = await getNotifications();
    return notifications.where((n) => n['isRead'] == false).length;
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notifications_history');
  }
}

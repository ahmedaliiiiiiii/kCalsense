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

  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    // 1. عرض الإشعار على الجهاز
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

    // 2. حفظ الإشعار في السجل المخزن
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

    // الاحتفاظ بآخر 50 إشعار
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

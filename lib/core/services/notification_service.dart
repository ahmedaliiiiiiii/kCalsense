import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    // 1. تهيئة المناطق الزمنية
    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Africa/Cairo'));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    // 2. تهيئة الإعدادات الأساسية
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: android, iOS: iOS);
    await _notifications.initialize(settings);

    // 3. إنشاء القنوات (مهم جداً لأندرويد 8+)
    await _createNotificationChannels();

    _isInitialized = true;
  }

  Future<void> _createNotificationChannels() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      // قناة الإشعارات الفورية
      const instantChannel = AndroidNotificationChannel(
        'instant_channel',
        'Instant Notifications',
        description: 'Notifications for meal additions and goal alerts',
        importance: Importance.high,
        playSound: true,
      );
      await androidPlugin.createNotificationChannel(instantChannel);

      // قناة التذكير اليومي
      const reminderChannel = AndroidNotificationChannel(
        'reminder_channel',
        'Reminders',
        description: 'Daily reminders to log your meals',
        importance: Importance.high,
        playSound: true,
      );
      await androidPlugin.createNotificationChannel(reminderChannel);
    }
  }

  Future<bool> requestAndroidNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      final status = await Permission.notification.request();
      return status.isGranted;
    }
    return await Permission.notification.isGranted;
  }

  Future<void> requestIOSPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'instant_channel', // نفس اسم القناة التي أنشأناها
      'Instant Notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );
    const iOSDetails = DarwinNotificationDetails();
    const details =
        NotificationDetails(android: androidDetails, iOS: iOSDetails);
    await _notifications.show(id, title, body, details, payload: payload);
  }

  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    if (!_isInitialized) await init();

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'reminder_channel', // نفس اسم القناة
      'Reminders',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );
    const iOSDetails = DarwinNotificationDetails();
    const details =
        NotificationDetails(android: androidDetails, iOS: iOSDetails);

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}

// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kcalsense/core/utils/color_manager.dart';
import 'package:kcalsense/features/notifications/notification_helper.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationsAndMarkRead();
  }

  Future<void> _loadNotificationsAndMarkRead() async {
    setState(() => _isLoading = true);
    await NotificationHelper.markAllAsRead();
    final rawNotifications = await NotificationHelper.getNotifications();

    // تصفية الإشعارات القديمة (بدون eventType) لتجنب النصوص غير المترجمة
    final validNotifications =
        rawNotifications.where((n) => n.containsKey('eventType')).toList();

    setState(() {
      _notifications = validNotifications;
      _isLoading = false;
    });
  }

  Future<void> _clearAll() async {
    await NotificationHelper.clearAll();
    await _loadNotificationsAndMarkRead();
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    final isArabic = context.locale.languageCode == 'ar';

    if (diff.inSeconds < 60) {
      return isArabic ? "الآن" : "Just now";
    } else if (diff.inMinutes < 60) {
      final minutes = diff.inMinutes;
      if (isArabic) {
        return minutes == 1 ? "منذ دقيقة واحدة" : "منذ $minutes دقائق";
      } else {
        return minutes == 1 ? "1 minute ago" : "$minutes minutes ago";
      }
    } else if (diff.inHours < 24) {
      final hours = diff.inHours;
      if (isArabic) {
        return hours == 1 ? "منذ ساعة واحدة" : "منذ $hours ساعات";
      } else {
        return hours == 1 ? "1 hour ago" : "$hours hours ago";
      }
    } else if (diff.inDays < 7) {
      final days = diff.inDays;
      if (isArabic) {
        return days == 1 ? "منذ يوم واحد" : "منذ $days أيام";
      } else {
        return days == 1 ? "1 day ago" : "$days days ago";
      }
    } else if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      if (isArabic) {
        return weeks == 1 ? "منذ أسبوع واحد" : "منذ $weeks أسابيع";
      } else {
        return weeks == 1 ? "1 week ago" : "$weeks weeks ago";
      }
    } else {
      // أكثر من شهر: عرض التاريخ
      return DateFormat('dd/MM/yyyy', context.locale.languageCode)
          .format(timestamp);
    }
  }

  String _getTitleForEvent(String eventType, Map<String, dynamic>? params) {
    switch (eventType) {
      case 'meal_deleted':
        return 'notification.meal_deleted_title'.tr();
      case 'meal_added':
        return 'notification.meal_added_title'.tr();
      case 'goal_almost':
        return 'notification.almost_there_title'.tr();
      case 'goal_reached':
        return 'notification.goal_reached_title'.tr();
      case 'goal_over':
        return 'notification.over_goal_title'.tr();
      default:
        return '';
    }
  }

  // ترجمة نص الإشعار حسب نوع الحدث مع استبدال المعاملات
  String _getBodyForEvent(String eventType, Map<String, dynamic>? params) {
    String body;
    switch (eventType) {
      case 'meal_deleted':
        body = 'notification.meal_deleted_body'.tr();
        break;
      case 'meal_added':
        body = 'notification.meal_added_body'.tr();
        break;
      case 'goal_almost':
        body = 'notification.almost_there_body'.tr();
        break;
      case 'goal_reached':
        body = 'notification.goal_reached_body'.tr();
        break;
      case 'goal_over':
        body = 'notification.over_goal_body'.tr();
        break;
      default:
        return '';
    }
    // استبدال المعاملات (مثل {mealName}, {calories})
    if (params != null) {
      params.forEach((key, value) {
        body = body.replaceAll('{$key}', value.toString());
      });
    }
    return body;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: context.iconColor, size: w * 0.05),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("notification.title".tr(),
            style: TextStyle(
                color: context.textColor,
                fontSize: w * 0.05,
                fontWeight: FontWeight.w700)),
        centerTitle: true,
        actions: [
          if (_notifications.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_outline, color: context.lightGrey),
              onPressed: _clearAll,
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: context.primaryColor))
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none,
                          size: 80, color: context.lightGrey),
                      const SizedBox(height: 16),
                      Text("notifications.no_notifications".tr(),
                          style: TextStyle(
                              color: context.lightGrey, fontSize: 16)),
                    ],
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.all(w * 0.04),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notif = _notifications[index];
                    final eventType = notif['eventType'] as String;
                    final params = notif['params'] as Map<String, dynamic>?;
                    final timestamp = DateTime.parse(notif['timestamp']);
                    final timeAgo = _getTimeAgo(timestamp);
                    final title = _getTitleForEvent(eventType, params);
                    final body = _getBodyForEvent(eventType, params);

                    return _buildNotificationItem(
                      context,
                      title: title,
                      message: body,
                      time: timeAgo,
                    );
                  },
                ),
    );
  }

  Widget _buildNotificationItem(BuildContext context,
      {required String title, required String message, required String time}) {
    final w = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(w * 0.03),
      decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(w * 0.03),
          border: Border.all(color: context.dividerColor)),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                color: context.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(w * 0.03)),
            child: Icon(Icons.notifications_active,
                color: context.primaryColor, size: w * 0.06),
          ),
          SizedBox(width: w * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: w * 0.04,
                        fontWeight: FontWeight.w700,
                        color: context.textColor)),
                const SizedBox(height: 4),
                Text(message,
                    style: TextStyle(
                        fontSize: w * 0.035,
                        color: context.textSecondaryColor)),
                const SizedBox(height: 4),
                Text(time,
                    style: TextStyle(
                        fontSize: w * 0.03, color: context.lightGrey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

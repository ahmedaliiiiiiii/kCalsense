import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kcalsense/core/utiles/color_manager.dart';
import 'package:kcalsense/features/notifications/NotificationHelper.dart';

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

    // تعليم جميع الإشعارات كمقروءة
    await NotificationHelper.markAllAsRead();

    // تحميل الإشعارات
    final notifications = await NotificationHelper.getNotifications();

    setState(() {
      _notifications = notifications;
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

    if (diff.inSeconds < 60) return "الآن";
    if (diff.inMinutes < 60) return "${diff.inMinutes} دقيقة مضت";
    if (diff.inHours < 24) return "${diff.inHours} ساعة مضت";
    if (diff.inDays < 7) return "${diff.inDays} يوم مضت";
    if (diff.inDays < 30) return "${(diff.inDays / 7).floor()} أسبوع مضت";
    return DateFormat('dd/MM/yyyy').format(timestamp);
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
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: context.iconColor,
            size: w * 0.05,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "notifications.title".tr(),
          style: TextStyle(
            color: context.textColor,
            fontSize: w * 0.05,
            fontWeight: FontWeight.w700,
          ),
        ),
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
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none,
                          size: 80, color: context.lightGrey),
                      SizedBox(height: 16),
                      Text(
                        "notifications.no_notifications".tr(),
                        style:
                            TextStyle(color: context.lightGrey, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.all(w * 0.04),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    final timestamp = DateTime.parse(notification['timestamp']);
                    final timeAgo = _getTimeAgo(timestamp);
                    // جميع الإشعارات مقروءة الآن، لذا isNew = false
                    return _buildNotificationItem(
                      context,
                      title: notification['title'],
                      message: notification['body'],
                      time: timeAgo,
                    );
                  },
                ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context, {
    required String title,
    required String message,
    required String time,
  }) {
    final w = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(w * 0.03),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(w * 0.03),
        border: Border.all(color: context.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: context.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(w * 0.03),
            ),
            child: Icon(
              Icons.notifications_active,
              color: context.primaryColor,
              size: w * 0.06,
            ),
          ),
          SizedBox(width: w * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: w * 0.04,
                    fontWeight: FontWeight.w700,
                    color: context.textColor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: w * 0.035,
                    color: context.textSecondaryColor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: w * 0.03,
                    color: context.lightGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

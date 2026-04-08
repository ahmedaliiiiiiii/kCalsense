import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kcalsense/core/utiles/color_manager.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

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
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(w * 0.04),
        children: [
          _buildNotificationItem(
            context,
            icon: Icons.fastfood,
            title: "notifications.meal_logged".tr(),
            message:
                "${"notifications.meal_logged_message".tr()} 2,350 ${"home.calories".tr()}",
            time: "2 ${"notifications.minutes_ago".tr()}",
            isNew: true,
          ),
          _buildNotificationItem(
            context,
            icon: Icons.emoji_events,
            title: "notifications.goal_achieved".tr(),
            message: "notifications.goal_achieved_message".tr(),
            time: "1 ${"notifications.hour_ago".tr()}",
            isNew: true,
          ),
          _buildNotificationItem(
            context,
            icon: Icons.info_outline,
            title: "notifications.reminder".tr(),
            message: "notifications.reminder_message".tr(),
            time: "3 ${"notifications.hours_ago".tr()}",
            isNew: false,
          ),
          _buildNotificationItem(
            context,
            icon: Icons.tips_and_updates,
            title: "notifications.health_tip".tr(),
            message: "notifications.health_tip_message".tr(),
            time: "notifications.yesterday".tr(),
            isNew: false,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
    required String time,
    required bool isNew,
  }) {
    final w = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(w * 0.03),
      decoration: BoxDecoration(
        color: isNew
            ? context.primaryColor.withOpacity(0.05)
            : context.surfaceColor,
        borderRadius: BorderRadius.circular(w * 0.03),
        border: Border.all(
          color: isNew
              ? context.primaryColor.withOpacity(0.3)
              : context.dividerColor,
        ),
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
              icon,
              color: context.primaryColor,
              size: w * 0.06,
            ),
          ),
          SizedBox(width: w * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: w * 0.04,
                        fontWeight: FontWeight.w700,
                        color: context.textColor,
                      ),
                    ),
                    if (isNew) ...[
                      SizedBox(width: w * 0.02),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
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

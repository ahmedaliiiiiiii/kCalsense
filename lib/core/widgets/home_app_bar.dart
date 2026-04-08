import 'package:flutter/material.dart';

import '../../../../../core/utiles/color_manager.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final VoidCallback onNotificationTap;

  const HomeAppBar({
    super.key,
    required this.userName,
    required this.onNotificationTap,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good morning";
    } else if (hour < 17) {
      return "Good afternoon";
    } else {
      return "Good evening";
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final greeting = _getGreeting();

    return AppBar(
      centerTitle: false,
      automaticallyImplyLeading: false,
      backgroundColor: context.surfaceColor,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$greeting${userName.isEmpty ? '' : ' $userName'} 👋",
            style: TextStyle(
              fontSize: w * 0.045,
              fontWeight: FontWeight.w600,
              color: context.textColor,
            ),
          ),
          Text(
            "Let's track your nutrition today",
            style: TextStyle(
              fontSize: w * 0.035,
              color: context.textSecondaryColor,
            ),
          ),
        ],
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                size: w * 0.06,
                color: context.iconColor,
              ),
              onPressed: onNotificationTap,
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        SizedBox(width: w * 0.02),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}

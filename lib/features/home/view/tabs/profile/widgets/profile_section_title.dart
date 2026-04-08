// lib/features/home/tabs/profile/widgets/profile_section_title.dart

import 'package:flutter/material.dart';
import 'package:kcalsense/core/utiles/color_manager.dart';

import '../../../../../../core/utiles/responsive_manager.dart';

class ProfileSectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const ProfileSectionTitle({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    ResponsiveManager.init(context);

    return Row(
      children: [
        Icon(
          icon,
          size: ResponsiveManager.iconMedium,
          color: context.lightGrey,
        ),
        SizedBox(width: ResponsiveManager.spacingSmall),
        Text(
          title,
          style: TextStyle(
            fontSize: ResponsiveManager.bodyMedium,
            fontWeight: FontWeight.w800,
            color: context.textColor,
          ),
        ),
      ],
    );
  }
}

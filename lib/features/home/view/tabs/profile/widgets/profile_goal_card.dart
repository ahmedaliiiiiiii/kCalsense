import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kcalsense/core/utils/color_manager.dart';

import '../../../../../../core/utils/responsive_manager.dart';

class ProfileGoalCard extends StatelessWidget {
  final dynamic model;
  const ProfileGoalCard({super.key, required this.model});

  String _getTranslatedGoal(String goalText) {
    switch (goalText) {
      case "Lose Weight":
        return "profile.goal.lose".tr();
      case "Maintain Weight":
        return "profile.goal.maintain".tr();
      case "Gain Weight":
        return "profile.goal.gain".tr();
      default:
        return goalText;
    }
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveManager.init(context);

    return Container(
      padding: EdgeInsets.all(ResponsiveManager.spacingLarge),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(ResponsiveManager.radiusLarge),
        border: Border.all(color: context.dividerColor),
        boxShadow: [
          BoxShadow(
            color: context.cardShadow,
            blurRadius: ResponsiveManager.spacingLarge,
            offset: Offset(0, ResponsiveManager.spacingSmall),
          ),
        ],
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveManager.spacingLarge,
          vertical: ResponsiveManager.spacingMedium,
        ),
        decoration: BoxDecoration(
          color: context.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(ResponsiveManager.radiusLarge),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getTranslatedGoal(model.goalTitle),
              style: TextStyle(
                fontSize: ResponsiveManager.bodyLarge,
                fontWeight: FontWeight.w900,
                color: context.textColor,
              ),
            ),
            SizedBox(height: ResponsiveManager.spacingXSmall),
            Text(
              "profile.goal_subtitle".tr(),
              style: TextStyle(
                fontSize: ResponsiveManager.bodySmall,
                color: context.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

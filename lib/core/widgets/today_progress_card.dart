import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../features/home/model/home_models.dart';
import '../utils/color_manager.dart';
import '../utils/responsive_manager.dart';

class TodayProgressCard extends StatelessWidget {
  final TodayProgressUiModel progress;

  const TodayProgressCard({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    ResponsiveManager.init(context);
    final ratio = (progress.goal == 0)
        ? 0.0
        : (progress.calories / progress.goal).clamp(0.0, 1.0);

    return Container(
      padding: EdgeInsets.all(ResponsiveManager.spacingLarge),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(ResponsiveManager.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: context.cardShadow,
            blurRadius: ResponsiveManager.spacingLarge,
            offset: Offset(0, ResponsiveManager.spacingSmall),
          ),
        ],
        border: Border.all(color: context.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "home.greeting.today_progress".tr(),
                style: TextStyle(
                  fontSize: ResponsiveManager.bodyLarge,
                  fontWeight: FontWeight.w700,
                  color: context.textColor,
                ),
              ),
              Text(
                progress.dateLabel,
                style: TextStyle(
                  fontSize: ResponsiveManager.bodySmall,
                  color: context.textSecondaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveManager.spacingMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "home.calories".tr(),
                style: TextStyle(
                  fontSize: ResponsiveManager.bodySmall,
                  fontWeight: FontWeight.w600,
                  color: context.lightGrey,
                ),
              ),
              Text(
                "${progress.calories}/${progress.goal}",
                style: TextStyle(
                  fontSize: ResponsiveManager.bodyMedium,
                  fontWeight: FontWeight.w700,
                  color: context.textColor,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveManager.spacingSmall),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8.h,
              backgroundColor: context.dividerColor,
              valueColor: AlwaysStoppedAnimation(context.primaryColor),
            ),
          ),
          SizedBox(height: ResponsiveManager.spacingLarge),
          Row(
            children: [
              _Macro(
                context: context,
                label: "scan.protein".tr(),
                value: "${progress.protein}g",
              ),
              SizedBox(width: ResponsiveManager.spacingSmall),
              _Macro(
                context: context,
                label: "scan.carbs".tr(),
                value: "${progress.carbs}g",
              ),
              SizedBox(width: ResponsiveManager.spacingSmall),
              _Macro(
                context: context,
                label: "scan.fat".tr(),
                value: "${progress.fat}g",
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Macro extends StatelessWidget {
  final BuildContext context;
  final String label;
  final String value;

  const _Macro({
    required this.context,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    ResponsiveManager.init(context);

    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveManager.spacingMedium,
        ),
        decoration: BoxDecoration(
          color: context.dividerColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(ResponsiveManager.radiusMedium),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: ResponsiveManager.bodyMedium,
                fontWeight: FontWeight.w800,
                color: context.textColor,
              ),
            ),
            SizedBox(height: ResponsiveManager.spacingXSmall),
            Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveManager.caption,
                color: context.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

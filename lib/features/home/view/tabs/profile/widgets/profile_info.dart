import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kcalsense/core/utiles/color_manager.dart';

import '../../../../../../core/utiles/responsive_manager.dart';
import '../viewmodel/profile_view_model.dart';

class ProfileBasicInfoGrid extends StatelessWidget {
  final ProfileUiModel model;
  const ProfileBasicInfoGrid({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    ResponsiveManager.init(context);

    return Container(
      padding: EdgeInsets.all(ResponsiveManager.spacingMedium),
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
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  context: context,
                  value: "${model.age}",
                  unit: "profile.years_old".tr(),
                ),
              ),
              SizedBox(width: ResponsiveManager.spacingMedium),
              Expanded(
                child: _InfoTile(
                  context: context,
                  value: "${model.heightCm}",
                  unit: "profile.cm_tall".tr(),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveManager.spacingMedium),
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  context: context,
                  value: model.weightKg.toStringAsFixed(0),
                  unit: "profile.kg_weight".tr(),
                ),
              ),
              SizedBox(width: ResponsiveManager.spacingMedium),
              Expanded(
                child: _InfoTile(
                  context: context,
                  value: model.bmi.toStringAsFixed(1),
                  unit: "profile.bmi".tr(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final BuildContext context;
  final String value;
  final String unit;

  const _InfoTile({
    required this.context,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    ResponsiveManager.init(context);

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveManager.spacingMedium,
      ),
      decoration: BoxDecoration(
        color: context.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ResponsiveManager.radiusLarge),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveManager.heading4,
              fontWeight: FontWeight.w900,
              color: context.textColor,
            ),
          ),
          SizedBox(height: ResponsiveManager.spacingXSmall),
          Text(
            unit,
            style: TextStyle(
              fontSize: ResponsiveManager.bodySmall,
              fontWeight: FontWeight.w600,
              color: context.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

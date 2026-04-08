// lib/features/setup/view/steps/amr_step.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utiles/color_manager.dart';
import '../../../../core/utiles/responsive_manager.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/step_scaffold.dart';
import '../../model/setup_models.dart';
import '../../viewmodel/setup_viewmodel.dart';

class AmrStep extends StatelessWidget {
  const AmrStep({super.key});

  Widget _buildActivityButton({
    required BuildContext context,
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: ResponsiveManager.buttonHeight,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor:
              selected ? context.primaryColor : context.surfaceColor,
          foregroundColor: selected ? Colors.white : context.textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ResponsiveManager.radiusMedium),
          ),
        ),
        onPressed: onTap,
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: ResponsiveManager.bodyMedium,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveManager.init(context);
    final vm = context.watch<SetupViewModel>();

    return StepScaffold(
      title: "setup.activity.title".tr(),
      subtitle: "setup.activity.subtitle".tr(),
      onBack: vm.step > 0 ? () => vm.back() : null,
      bottom: AppButton(
        text: "setup.common.next".tr(),
        onPressed: vm.canGoNext ? () => vm.next() : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildActivityButton(
            context: context,
            title: "setup.activity.sedentary".tr(),
            selected: vm.data.activity == ActivityLevel.sedentary,
            onTap: () => vm.setActivity(ActivityLevel.sedentary),
          ),
          SizedBox(height: ResponsiveManager.spacingMedium),
          _buildActivityButton(
            context: context,
            title: "setup.activity.lightly_active".tr(),
            selected: vm.data.activity == ActivityLevel.lightlyActive,
            onTap: () => vm.setActivity(ActivityLevel.lightlyActive),
          ),
          SizedBox(height: ResponsiveManager.spacingMedium),
          _buildActivityButton(
            context: context,
            title: "setup.activity.moderately_active".tr(),
            selected: vm.data.activity == ActivityLevel.moderatelyActive,
            onTap: () => vm.setActivity(ActivityLevel.moderatelyActive),
          ),
          SizedBox(height: ResponsiveManager.spacingMedium),
          _buildActivityButton(
            context: context,
            title: "setup.activity.highly_active".tr(),
            selected: vm.data.activity == ActivityLevel.highlyActive,
            onTap: () => vm.setActivity(ActivityLevel.highlyActive),
          ),
        ],
      ),
    );
  }
}

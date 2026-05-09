// lib/features/setup/view/steps/metabolic_step.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/color_manager.dart';
import '../../../../core/utils/responsive_manager.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/step_scaffold.dart';
import '../../viewmodel/setup_viewmodel.dart';

class MetabolicStep extends StatelessWidget {
  const MetabolicStep({super.key});

  @override
  Widget build(BuildContext context) {
    ResponsiveManager.init(context);
    final vm = context.watch<SetupViewModel>();
    final d = vm.data;
    final err = vm.error;

    if (vm.isLoading) {
      return StepScaffold(
        title: "setup.metabolic.title".tr(),
        subtitle: "setup.metabolic.subtitle".tr(),
        onBack: vm.step > 0 ? () => vm.back() : null,
        bottom: AppButton(
          text: "setup.common.continue".tr(),
          onPressed: null,
        ),
        child: Center(
          child: CircularProgressIndicator(
            color: context.primaryColor,
          ),
        ),
      );
    }

    if (err != null && err.isNotEmpty) {
      return StepScaffold(
        title: "setup.metabolic.title".tr(),
        subtitle: "setup.metabolic.subtitle".tr(),
        onBack: vm.step > 0 ? () => vm.back() : null,
        bottom: AppButton(
          text: "setup.common.try_again".tr(),
          onPressed: () => vm.retryCalculation(),
        ),
        child: Center(
          child: Text(
            err,
            style: TextStyle(color: context.errorColor),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return StepScaffold(
      title: "setup.metabolic.title".tr(),
      subtitle: "setup.metabolic.subtitle".tr(),
      bottom: AppButton(
        text: "setup.common.continue".tr(),
        onPressed: () => vm.next(),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "setup.metabolic.maintenance".tr(),
            style: TextStyle(
              color: context.textColor,
              fontWeight: FontWeight.w800,
              fontSize: ResponsiveManager.bodyMedium,
            ),
          ),
          SizedBox(height: ResponsiveManager.spacingSmall),
          Container(
            width: double.infinity,
            padding:
                EdgeInsets.symmetric(vertical: ResponsiveManager.spacingMedium),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius:
                  BorderRadius.circular(ResponsiveManager.radiusLarge),
              border: Border.all(color: context.dividerColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  (d.maintenanceCalories ?? 0).toString(),
                  style: TextStyle(
                    color: context.textColor,
                    fontSize: ResponsiveManager.heading3,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(width: ResponsiveManager.spacingSmall),
                Text(
                  "setup.metabolic.cal".tr(),
                  style: TextStyle(
                    color: context.textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: ResponsiveManager.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: ResponsiveManager.spacingXLarge),
          Text(
            "setup.metabolic.daily_target".tr(),
            style: TextStyle(
              color: context.textColor,
              fontWeight: FontWeight.w900,
              fontSize: ResponsiveManager.bodyLarge,
            ),
          ),
          SizedBox(height: ResponsiveManager.spacingSmall),
          Container(
            width: double.infinity,
            padding:
                EdgeInsets.symmetric(vertical: ResponsiveManager.spacingLarge),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius:
                  BorderRadius.circular(ResponsiveManager.radiusLarge),
              border: Border.all(
                color: context.primaryColor,
                width: 3,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  (d.dailyTarget ?? 0).toString(),
                  style: TextStyle(
                    color: context.textColor,
                    fontSize: ResponsiveManager.heading2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(width: ResponsiveManager.spacingSmall),
                Text(
                  "setup.metabolic.cal".tr(),
                  style: TextStyle(
                    color: context.textColor,
                    fontWeight: FontWeight.w800,
                    fontSize: ResponsiveManager.bodyLarge,
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

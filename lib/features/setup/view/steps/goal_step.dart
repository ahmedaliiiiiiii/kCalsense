// lib/features/setup/view/steps/goal_step.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/color_manager.dart';
import '../../../../core/utils/responsive_manager.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/step_scaffold.dart';
import '../../model/setup_models.dart';
import '../../viewmodel/setup_viewmodel.dart';

class GoalStep extends StatelessWidget {
  const GoalStep({super.key});

  Widget _buildGoalButton({
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
      title: "setup.goal.title".tr(),
      subtitle: "setup.goal.subtitle".tr(),
      onBack: vm.step > 0 ? () => vm.back() : null,
      bottom: AppButton(
        text: "setup.common.next".tr(),
        onPressed: vm.canGoNext ? () => vm.next() : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildGoalButton(
            context: context,
            title: "setup.goal.lose".tr(),
            selected: vm.data.goal == WeightGoal.weightLoss,
            onTap: () => vm.setGoal(WeightGoal.weightLoss),
          ),
          SizedBox(height: ResponsiveManager.spacingMedium),
          _buildGoalButton(
            context: context,
            title: "setup.goal.maintain".tr(),
            selected: vm.data.goal == WeightGoal.maintain,
            onTap: () => vm.setGoal(WeightGoal.maintain),
          ),
          SizedBox(height: ResponsiveManager.spacingMedium),
          _buildGoalButton(
            context: context,
            title: "setup.goal.gain".tr(),
            selected: vm.data.goal == WeightGoal.weightGain,
            onTap: () => vm.setGoal(WeightGoal.weightGain),
          ),
        ],
      ),
    );
  }
}

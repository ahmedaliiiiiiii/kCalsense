// lib/features/setup/view/steps/gender_step.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/color_manager.dart';
import '../../../../core/utils/responsive_manager.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/step_scaffold.dart';
import '../../model/setup_models.dart';
import '../../viewmodel/setup_viewmodel.dart';

class GenderStep extends StatelessWidget {
  const GenderStep({super.key});

  Widget _buildGenderButton({
    required BuildContext context,
    required String text,
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
          text,
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
      title: "setup.gender.title".tr(),
      subtitle: "setup.gender.subtitle".tr(),
      onBack: vm.step > 0 ? () => vm.back() : null,
      bottom: AppButton(
        text: "setup.common.next".tr(),
        onPressed: vm.canGoNext ? () => vm.next() : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildGenderButton(
            context: context,
            text: "setup.gender.male".tr(),
            selected: vm.data.gender == Gender.male,
            onTap: () => vm.setGender(Gender.male),
          ),
          SizedBox(height: ResponsiveManager.spacingMedium),
          _buildGenderButton(
            context: context,
            text: "setup.gender.female".tr(),
            selected: vm.data.gender == Gender.female,
            onTap: () => vm.setGender(Gender.female),
          ),
        ],
      ),
    );
  }
}

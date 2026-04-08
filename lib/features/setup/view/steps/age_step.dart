// lib/features/setup/view/steps/age_step.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utiles/responsive_manager.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/step_scaffold.dart';
import '../../viewmodel/setup_viewmodel.dart';

class AgeStep extends StatefulWidget {
  const AgeStep({super.key});

  @override
  State<AgeStep> createState() => _AgeStepState();
}

class _AgeStepState extends State<AgeStep> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveManager.init(context);
    final vm = context.watch<SetupViewModel>();

    if (_controller.text.isEmpty && vm.data.age != null) {
      _controller.text = vm.data.age.toString();
    }

    return StepScaffold(
      title: "setup.age.title".tr(),
      subtitle: "setup.age.subtitle".tr(),
      onBack: vm.step > 0 ? () => vm.back() : null,
      bottom: AppButton(
        text: "setup.common.next".tr(),
        onPressed: vm.canGoNext ? () => vm.next() : null,
      ),
      child: SizedBox(
        width: ResponsiveManager.textFieldWidth,
        child: AppTextField(
          hint: "setup.age.hint".tr(),
          controller: _controller,
          keyboardType: TextInputType.number,
          onChanged: vm.setAge,
        ),
      ),
    );
  }
}

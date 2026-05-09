// lib/features/setup/view/steps/weight_step.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/responsive_manager.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/step_scaffold.dart';
import '../../viewmodel/setup_viewmodel.dart';

class WeightStep extends StatefulWidget {
  const WeightStep({super.key});

  @override
  State<WeightStep> createState() => _WeightStepState();
}

class _WeightStepState extends State<WeightStep> {
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

    if (_controller.text.isEmpty && vm.data.weight != null) {
      _controller.text = vm.data.weight.toString();
    }

    return StepScaffold(
      title: "setup.weight.title".tr(),
      subtitle: "setup.weight.subtitle".tr(),
      onBack: vm.step > 0 ? () => vm.back() : null,
      bottom: AppButton(
        text: "setup.common.next".tr(),
        onPressed: vm.canGoNext ? () => vm.next() : null,
      ),
      child: SizedBox(
        width: ResponsiveManager.textFieldWidth,
        child: AppTextField(
          hint: "setup.weight.hint".tr(),
          controller: _controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: vm.setWeight,
        ),
      ),
    );
  }
}

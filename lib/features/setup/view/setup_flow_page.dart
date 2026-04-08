import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodel/setup_viewmodel.dart';
import 'steps/age_step.dart';
import 'steps/amr_step.dart';
import 'steps/done_step.dart';
import 'steps/gender_step.dart';
import 'steps/goal_step.dart';
import 'steps/height_step.dart';
import 'steps/metabolic_step.dart';
import 'steps/weight_step.dart';

class SetupFlowPage extends StatelessWidget {
  const SetupFlowPage({super.key});
  static const String routeName = "/setup";

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SetupViewModel(),
      child: Consumer<SetupViewModel>(
        builder: (context, vm, _) {
          return PageView(
            controller: vm.pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              GenderStep(),
              AgeStep(),
              HeightStep(),
              WeightStep(),
              AmrStep(),
              GoalStep(),
              MetabolicStep(),
              DoneStep(),
            ],
          );
        },
      ),
    );
  }
}

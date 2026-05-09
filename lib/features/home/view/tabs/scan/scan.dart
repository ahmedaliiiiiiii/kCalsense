import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kcalsense/core/utils/color_manager.dart';
import 'package:provider/provider.dart';

import '../../../viewmodel/homeviewmodel.dart';
import 'cubit/reco_cubit.dart';
import 'cubit/reco_state.dart';
import 'model/food_recognition_result.dart';
import 'widgets/analysis_results_sheet.dart'; // ✅ الاسم الصحيح
import 'widgets/scan_actions.dart';
import 'widgets/scan_preview.dart';
import 'widgets/scan_texts.dart';

class ScanTab extends StatelessWidget {
  const ScanTab({super.key});

  void _showSnack(BuildContext context, String message,
      {required bool success}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
        duration: Duration(seconds: success ? 2 : 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return ScanCubit();
      },
      child: BlocConsumer<ScanCubit, ScanState>(
        listenWhen: (previous, current) =>
            previous.effect != current.effect ||
            (previous.result == null && current.result != null),
        listener: (context, state) async {
          final cubit = context.read<ScanCubit>();
          if (state.effect != null) {
            _showSnack(context, state.effect!.message,
                success: state.effect!.success);
            cubit.clearEffect();
          }
          if (state.result != null &&
              context.mounted &&
              cubit.canShowBottomSheet()) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  enableDrag: true,
                  isDismissible: true,
                  backgroundColor: Colors.transparent,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(25)),
                  ),
                  builder: (_) => AnalysisResultsSheet(
                    results: state.result!,
                    onDone: () {
                      // Save the data to the view models
                      final homeVm = Provider.of<HomeViewModel>(context, listen: false);
                      homeVm.addRecentFoods(state.result!);
                      
                      // Close the sheet and clear scan
                      Navigator.pop(context);
                      cubit.clearImage();
                      
                      // Jump directly to Stats tab (index 2) to see the updated dashboards
                      homeVm.changeTab(2);
                    },
                  ),
                );
              }
            });
          }
        },
        builder: (context, state) {
          final width = MediaQuery.of(context).size.width;
          final height = MediaQuery.of(context).size.height;
          final padding = (width * 0.04).clamp(14.0, 20.0);
          final previewSize = (width * 0.55).clamp(150.0, 220.0);

          return Scaffold(
            backgroundColor: context.backgroundColor,
            body: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(padding),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: height - padding * 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ScanPreview(
                        image: state.image,
                        size: previewSize,
                        onClear: () => context.read<ScanCubit>().clearImage(),
                      ),
                      SizedBox(height: (height * 0.05).clamp(20.0, 40.0)),
                      ScanTexts(hasImage: state.image != null, width: width),
                      SizedBox(height: (height * 0.07).clamp(26.0, 60.0)),
                      ScanActions(
                        isLoading: state.isLoading,
                        hasImage: state.image != null,
                        onTakePhoto: () =>
                            context.read<ScanCubit>().takePhoto(),
                        onPickGallery: () =>
                            context.read<ScanCubit>().pickFromGallery(),
                        onAnalyze: () => context.read<ScanCubit>().analyze(),
                        onChooseDifferent: () =>
                            context.read<ScanCubit>().clearImage(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

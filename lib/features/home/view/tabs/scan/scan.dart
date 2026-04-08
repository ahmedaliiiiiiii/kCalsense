import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kcalsense/features/home/view/tabs/scan/widgets/nalysis_results_sheet.dart';

import '../../../../../core/utiles/color_manager.dart';
import 'cubit/reco_cubit.dart';
import 'cubit/reco_state.dart';
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
        backgroundColor: success ? context.successColor : context.errorColor,
        duration: Duration(seconds: success ? 2 : 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ScanCubit(),
      child: BlocConsumer<ScanCubit, ScanState>(
        listenWhen: (previous, current) {
          if (previous.effect != current.effect) {
            return true;
          }
          if (previous.result == null && current.result != null) {
            return true;
          }
          return false;
        },
        listener: (context, state) async {
          final cubit = context.read<ScanCubit>();

          final effect = state.effect;
          if (effect != null) {
            _showSnack(context, effect.message, success: effect.success);
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
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(25),
                    ),
                  ),
                  builder: (_) => AnalysisResultsSheet(
                    result: state.result!,
                    onDone: () {
                      Navigator.pop(context);
                      cubit.clearImage();
                    },
                  ),
                );
              }
            });
          }
        },
        builder: (context, state) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;

              final padding = (width * 0.04).clamp(14.0, 20.0);
              final previewSize = (width * 0.55).clamp(150.0, 220.0);

              return Scaffold(
                backgroundColor: context.backgroundColor,
                body: SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.all(padding),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: height - padding * 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ScanPreview(
                            image: state.image,
                            size: previewSize,
                            onClear: () =>
                                context.read<ScanCubit>().clearImage(),
                          ),
                          SizedBox(height: (height * 0.05).clamp(20.0, 40.0)),
                          ScanTexts(
                            hasImage: state.image != null,
                            width: width,
                          ),
                          SizedBox(height: (height * 0.07).clamp(26.0, 60.0)),
                          ScanActions(
                            isLoading: state.isLoading,
                            hasImage: state.image != null,
                            onTakePhoto: () =>
                                context.read<ScanCubit>().takePhoto(),
                            onPickGallery: () =>
                                context.read<ScanCubit>().pickFromGallery(),
                            onAnalyze: () =>
                                context.read<ScanCubit>().analyze(),
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
          );
        },
      ),
    );
  }
}

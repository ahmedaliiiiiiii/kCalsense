// lib/features/home/tabs/scan/widgets/scan_texts.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../../core/utiles/color_manager.dart';

class ScanTexts extends StatelessWidget {
  final bool hasImage;
  final double width;

  const ScanTexts({
    super.key,
    required this.hasImage,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final titleSize = (width * 0.075).clamp(20.0, 28.0);
    final descSize = (width * 0.04).clamp(13.0, 16.0);

    return Column(
      children: [
        Text(
          hasImage ? "scan.image_selected".tr() : "scan.title".tr(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.w700,
            color: ColorManager.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding:
              EdgeInsets.symmetric(horizontal: (width * 0.06).clamp(16, 28)),
          child: Text(
            hasImage ? "scan.ready_to_analyze".tr() : "scan.subtitle".tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: descSize,
              color: Colors.grey,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

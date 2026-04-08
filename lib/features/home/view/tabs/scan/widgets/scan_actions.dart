// lib/features/home/tabs/scan/widgets/scan_actions.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../../core/utiles/color_manager.dart';

class ScanActions extends StatelessWidget {
  final bool isLoading;
  final bool hasImage;
  final VoidCallback onTakePhoto;
  final VoidCallback onPickGallery;
  final VoidCallback onAnalyze;
  final VoidCallback onChooseDifferent;

  const ScanActions({
    super.key,
    required this.isLoading,
    required this.hasImage,
    required this.onTakePhoto,
    required this.onPickGallery,
    required this.onAnalyze,
    required this.onChooseDifferent,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const CircularProgressIndicator(color: ColorManager.primaryColor);
    }

    if (hasImage) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAnalyze,
              icon: const Icon(Icons.analytics_outlined, size: 24),
              label: Text(
                "scan.analyze".tr(),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorManager.primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(33),
                ),
                elevation: 3,
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: onChooseDifferent,
            child: Text(
              "scan.choose_different".tr(),
              style: TextStyle(fontSize: 16, color: context.lightGrey),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onTakePhoto,
            icon: const Icon(Icons.camera_alt, size: 24),
            label: Text(
              "scan.take_photo".tr(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorManager.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(33),
              ),
              elevation: 3,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Divider(color: context.dividerColor, thickness: 1),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "scan.or".tr(),
                style: TextStyle(
                  color: context.lightGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Divider(color: context.dividerColor, thickness: 1),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onPickGallery,
            icon: const Icon(Icons.photo_library_outlined, size: 24),
            label: Text(
              "scan.upload_gallery".tr(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: context.textColor, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(33),
              ),
              foregroundColor: context.textColor,
            ),
          ),
        ),
      ],
    );
  }
}

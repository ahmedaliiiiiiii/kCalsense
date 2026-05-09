import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../../../core/utils/color_manager.dart';

class ScanPreview extends StatelessWidget {
  final File? image;
  final double size;
  final VoidCallback onClear;

  const ScanPreview({
    super.key,
    required this.image,
    required this.size,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (image == null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: ColorManager.primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.camera_alt_outlined,
          size: 80,
          color: Color(0xFF42E87F),
        ),
      );
    }

    final r = (size * 0.12).clamp(14.0, 22.0);

    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular((size * 0.12).clamp(18.0, 26.0)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(image!, fit: BoxFit.cover),
            Positioned(
              top: 10,
              right: 10,
              child: InkWell(
                onTap: onClear,
                borderRadius: BorderRadius.circular(r),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

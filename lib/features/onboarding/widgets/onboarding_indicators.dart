// lib/features/onboarding/widgets/onboarding_indicators.dart

import 'package:flutter/material.dart';

import '../../../core/utiles/color_manager.dart';
import '../../../core/utiles/responsive_manager.dart';

class OnboardingIndicators extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const OnboardingIndicators({
    super.key,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    ResponsiveManager.init(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        totalPages,
        (index) => _buildIndicator(context, index),
      ),
    );
  }

  Widget _buildIndicator(BuildContext context, int index) {
    final isActive = currentPage == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      margin:
          EdgeInsets.symmetric(horizontal: ResponsiveManager.spacingXSmall / 2),
      width: isActive
          ? ResponsiveManager.spacingMedium
          : ResponsiveManager.spacingSmall,
      height: isActive
          ? ResponsiveManager.spacingMedium
          : ResponsiveManager.spacingSmall,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive
            ? context.primaryColor
            : context.lightGrey, // ✅ استخدام context
      ),
    );
  }
}

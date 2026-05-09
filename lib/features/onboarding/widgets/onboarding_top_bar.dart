// lib/features/onboarding/widgets/onboarding_top_bar.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/color_manager.dart';
import '../../../core/utils/responsive_manager.dart';

class OnboardingTopBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  const OnboardingTopBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onBack,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    ResponsiveManager.init(context);

    final bool canBack = currentPage > 0;
    final bool canSkip = currentPage < totalPages - 1;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveManager.spacingLarge,
        vertical: ResponsiveManager.spacingMedium,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          canBack
              ? _BackButton(onBack: onBack, context: context)
              : _Placeholder(),
          const Spacer(),
          canSkip
              ? _SkipButton(onSkip: onSkip, context: context)
              : _Placeholder(),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onBack;
  final BuildContext context;

  const _BackButton({required this.onBack, required this.context});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.primaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onBack,
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: ResponsiveManager.iconMedium,
          color: context.primaryColor,
        ),
        splashRadius: ResponsiveManager.iconLarge,
        tooltip: 'onboarding.back'.tr(),
      ),
    );
  }
}

class _SkipButton extends StatelessWidget {
  final VoidCallback onSkip;
  final BuildContext context;

  const _SkipButton({required this.onSkip, required this.context});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSkip,
      borderRadius: BorderRadius.circular(ResponsiveManager.radiusXLarge),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveManager.spacingMedium,
          vertical: ResponsiveManager.spacingSmall,
        ),
        decoration: BoxDecoration(
          color: context.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(ResponsiveManager.radiusXLarge),
          border: Border.all(
            color: context.primaryColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'onboarding.skip'.tr(),
              style: TextStyle(
                fontSize: ResponsiveManager.bodySmall,
                fontWeight: FontWeight.w600,
                color: context.primaryColor,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(width: ResponsiveManager.spacingXSmall),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: ResponsiveManager.iconSmall,
              color: context.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 40,
      height: 40,
    );
  }
}

// lib/features/onboarding/widgets/onboarding_page.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/utiles/color_manager.dart';
import '../../../core/utiles/responsive_manager.dart';
import '../models/onboarding_item.dart';

class OnboardingPage extends StatelessWidget {
  final OnboardingItem item;
  final bool isActive;

  const OnboardingPage({
    super.key,
    required this.item,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    ResponsiveManager.init(context);

    return SingleChildScrollView(
      physics: isActive
          ? const BouncingScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      child: SizedBox(
        height: ResponsiveManager.screenHeight * 0.72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'onboarding_${item.titleKey}',
              child: _OnboardingImage(item: item),
            ),
            SizedBox(height: ResponsiveManager.spacingXXLarge),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: _OnboardingTitle(item: item, context: context),
            ),
            SizedBox(height: ResponsiveManager.spacingLarge),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: _OnboardingDescription(item: item, context: context),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingImage extends StatelessWidget {
  final OnboardingItem item;

  const _OnboardingImage({required this.item});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ResponsiveManager.screenHeight * 0.28,
      width: double.infinity,
      child: Image.asset(
        item.imagePath,
        fit: BoxFit.contain,
        cacheWidth: 500,
        cacheHeight: 500,
        errorBuilder: (context, error, stackTrace) {
          return _FallbackImage(item: item, context: context);
        },
      ),
    );
  }
}

class _FallbackImage extends StatelessWidget {
  final OnboardingItem item;
  final BuildContext context;

  const _FallbackImage({required this.item, required this.context});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fastfood,
            size: ResponsiveManager.screenWidth * 0.18,
            color: context.primaryColor.withOpacity(0.3),
          ),
          SizedBox(height: ResponsiveManager.spacingSmall),
          Text(
            item.titleKey.tr(),
            style: TextStyle(
              color: context.textSecondaryColor,
              fontSize: ResponsiveManager.bodyMedium,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingTitle extends StatelessWidget {
  final OnboardingItem item;
  final BuildContext context;

  const _OnboardingTitle({required this.item, required this.context});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: ResponsiveManager.spacingXXLarge),
      child: Text(
        item.titleKey.tr(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: ResponsiveManager.heading1,
          fontWeight: FontWeight.w700,
          color: context.primaryColor,
          height: 1.2,
        ),
      ),
    );
  }
}

class _OnboardingDescription extends StatelessWidget {
  final OnboardingItem item;
  final BuildContext context;

  const _OnboardingDescription({required this.item, required this.context});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: ResponsiveManager.spacingXXLarge),
      child: Text(
        item.descriptionKey.tr(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: ResponsiveManager.bodyLarge,
          fontWeight: FontWeight.w400,
          color: context.textSecondaryColor,
          height: 1.6,
        ),
      ),
    );
  }
}

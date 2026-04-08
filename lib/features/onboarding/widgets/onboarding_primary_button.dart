// lib/features/onboarding/widgets/onboarding_primary_button.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/utiles/color_manager.dart';
import '../../../core/utiles/responsive_manager.dart';

class OnboardingPrimaryButton extends StatefulWidget {
  final bool isLast;
  final VoidCallback onPressed;
  final bool isLoading;

  const OnboardingPrimaryButton({
    super.key,
    required this.isLast,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  State<OnboardingPrimaryButton> createState() =>
      _OnboardingPrimaryButtonState();
}

class _OnboardingPrimaryButtonState extends State<OnboardingPrimaryButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveManager.init(context);

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1 + (_pulseController.value * 0.02),
          child: child,
        );
      },
      child: SizedBox(
        width: double.infinity,
        height: ResponsiveManager.buttonHeight,
        child: ElevatedButton(
          onPressed: widget.isLoading ? null : widget.onPressed,
          style: _buttonStyle(context),
          child: _buildButtonContent(context),
        ),
      ),
    );
  }

  ButtonStyle _buttonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: context.primaryColor,
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(vertical: ResponsiveManager.spacingMedium),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveManager.radiusXXLarge),
      ),
      elevation: widget.isLoading ? 0 : 4,
      shadowColor: context.primaryColor.withOpacity(0.3),
    );
  }

  Widget _buildButtonContent(BuildContext context) {
    if (widget.isLoading) {
      return SizedBox(
        height: 24,
        width: 24,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.isLast
              ? 'onboarding.get_started'.tr()
              : 'onboarding.next'.tr(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        if (!widget.isLast) ...[
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_forward_rounded,
            size: 20,
            color: Colors.white,
          ),
        ],
      ],
    );
  }
}

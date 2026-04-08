// lib/features/setup/view/steps/done_step.dart

import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/navigation/page_transitions.dart';
import '../../../../core/storge/shared_preferences_helper.dart';
import '../../../../core/utiles/color_manager.dart';
import '../../../../core/utiles/responsive_manager.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/step_scaffold.dart';
import '../../../home/view/tabs/home tab/home_tab.dart';

class DoneStep extends StatefulWidget {
  const DoneStep({super.key});

  @override
  State<DoneStep> createState() => _DoneStepState();
}

class _DoneStepState extends State<DoneStep>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _rotationAnimation = Tween<double>(begin: -0.5, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _completeSetup() async {
    // ✅ تم إكمال الـ Setup
    await SharedPreferencesHelper.setSetupCompleted(true);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      CustomPageTransitions.fastSlideTransition(const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveManager.init(context);
    final circleSize = (math.min(
              ResponsiveManager.screenWidth,
              ResponsiveManager.screenHeight,
            ) *
            0.35)
        .clamp(140.0, 220.0);
    final iconSize = (circleSize * 0.55).clamp(70.0, 130.0);

    return StepScaffold(
      title: "setup.done.title".tr(),
      subtitle: "setup.done.subtitle".tr(),
      bottom: AppButton(
        text: "setup.done.button".tr(),
        onPressed: _completeSetup,
      ),
      child: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: Container(
                    width: circleSize,
                    height: circleSize,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          context.primaryColor,
                          context.primaryColor.withOpacity(0.7),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: context.primaryColor.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.check,
                      size: iconSize,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

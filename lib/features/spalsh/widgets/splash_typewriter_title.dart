import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

class SplashTypewriterTitle extends StatelessWidget {
  final double fontSize;
  const SplashTypewriterTitle({super.key, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.6,
      ),
      child: AnimatedTextKit(
        animatedTexts: [
          TypewriterAnimatedText(
            'KcalSense',
            speed: const Duration(milliseconds: 90),
          ),
        ],
        totalRepeatCount: 1,
        isRepeatingAnimation: false,
      ),
    );
  }
}

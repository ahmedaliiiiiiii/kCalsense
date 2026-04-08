import 'package:flutter/material.dart';

class SplashShineBg extends StatelessWidget {
  final Animation<double> shine;
  const SplashShineBg({super.key, required this.shine});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return AnimatedBuilder(
      animation: shine,
      builder: (_, __) {
        return Opacity(
          opacity: 0.22,
          child: Transform.translate(
            offset: Offset(shine.value * w * 0.35, 0),
            child: Transform.rotate(
              angle: 0.35,
              child: Container(
                width: w * 0.7,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.0),
                      Colors.white.withValues(alpha: 0.22),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

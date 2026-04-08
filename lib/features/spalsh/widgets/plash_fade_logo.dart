import 'package:flutter/material.dart';

class SplashFadeLogo extends StatelessWidget {
  final Animation<double> fade;
  final Animation<double> scale;

  const SplashFadeLogo({
    super.key,
    required this.fade,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final logoSize = (w * 0.26).clamp(84.0, 120.0);

    return FadeTransition(
      opacity: fade,
      child: ScaleTransition(
        scale: scale,
        child: Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Image.asset(
              'assets/pictures/image.png',
              width: logoSize * 0.62,
              height: logoSize * 0.62,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

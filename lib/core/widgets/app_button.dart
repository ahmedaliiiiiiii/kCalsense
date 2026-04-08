import 'package:flutter/material.dart';

import '../../../core/utiles/color_manager.dart';
import '../../../core/utiles/responsive_manager.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    ResponsiveManager.init(context);
    final enabled = onPressed != null;

    return SizedBox(
      height: ResponsiveManager.buttonHeight,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor:
              enabled ? context.primaryColor : context.disabledColor,
          foregroundColor: enabled ? Colors.white : context.textSecondaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveManager.buttonRadius,
            ),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: enabled ? Colors.white : context.textSecondaryColor,
            fontWeight: FontWeight.w800,
            fontSize: ResponsiveManager.bodyLarge,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

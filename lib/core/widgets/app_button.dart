import 'package:flutter/material.dart';

import '../../../core/utils/color_manager.dart';
import '../../../core/utils/responsive_manager.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    ResponsiveManager.init(context);
    final enabled = onPressed != null && !isLoading;

    return SizedBox(
      height: ResponsiveManager.buttonHeight,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
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
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
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

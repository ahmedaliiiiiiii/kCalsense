import 'package:flutter/material.dart';

class ColorManager {
  ColorManager._();

  static const Color primaryColor = Color(0xFF42E87F);
  static const Color primaryColorLight = Color(0xFF8CF2B3);
  static const Color primaryColorDark = Color(0xFF2BA35A);

  static const Color error = Color(0xFFE74C3C);
  static const Color errorLight = Color(0xFFFF6B6B);
  static const Color success = Color(0xFF2ECC71);
  static const Color successLight = Color(0xFF4CD964);
  static const Color warning = Color(0xFFF39C12);
  static const Color info = Color(0xFF3498DB);

  static const Color darkColor = Color(0xFF202020);
  static const Color darkerColor = Color(0xFF1A1A1A);
  static const Color cardDark = Color(0xFF2D2D2D);

  static Color get backgroundColor => const Color(0xFFF8F9FA);
  static Color get darkBackground => const Color(0xFF202020);

  static Color get textColor => const Color(0xFF1E1E1E);
  static Color get darkTextColor => Colors.white;

  static Color get lightGrey => const Color(0xFF9E9E9E);
  static Color get darkLightGrey => const Color(0xFF7A7A7A);

  static Color get textHint => const Color(0xFF9E9E9E);
  static Color get darkTextHint => const Color(0xFF808080);

  static Color get cardShadow => Colors.black.withValues(alpha: 0.05);
  static Color get darkCardShadow => Colors.black.withValues(alpha: 0.3);

  static Color get disabled => const Color(0xFFE0E0E0);
  static Color get darkDisabled => const Color(0xFF404040);
}

extension ThemeColors on BuildContext {
  bool get isDarkMode {
    return Theme.of(this).brightness == Brightness.dark;
  }

  Color get backgroundColor =>
      isDarkMode ? ColorManager.darkBackground : ColorManager.backgroundColor;

  Color get surfaceColor => isDarkMode ? ColorManager.cardDark : Colors.white;

  Color get textColor =>
      isDarkMode ? ColorManager.darkTextColor : ColorManager.textColor;

  Color get textSecondaryColor =>
      isDarkMode ? const Color(0xFFB0B0B0) : const Color(0xFF757575);

  Color get textHintColor =>
      isDarkMode ? ColorManager.darkTextHint : ColorManager.textHint;

  Color get lightGrey =>
      isDarkMode ? ColorManager.darkLightGrey : ColorManager.lightGrey;

  Color get cardShadow =>
      isDarkMode ? ColorManager.darkCardShadow : ColorManager.cardShadow;

  Color get dividerColor =>
      isDarkMode ? const Color(0xFF404040) : const Color(0xFFE0E0E0);

  Color get iconColor => isDarkMode ? Colors.white : ColorManager.textColor;

  Color get primaryColor => ColorManager.primaryColor;
  Color get primaryColorLight => ColorManager.primaryColorLight;

  Color get errorColor =>
      isDarkMode ? ColorManager.errorLight : ColorManager.error;

  Color get successColor =>
      isDarkMode ? ColorManager.successLight : ColorManager.success;

  Color get disabledColor =>
      isDarkMode ? ColorManager.darkDisabled : ColorManager.disabled;
}

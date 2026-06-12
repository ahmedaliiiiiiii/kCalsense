import 'package:flutter/material.dart';

class ResponsiveManager {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late Orientation orientation;

  static const double designWidth = 375;
  static const double designHeight = 812;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    orientation = _mediaQueryData.orientation;
  }

  static bool get isSmallScreen => screenWidth < 375;
  static bool get isMediumScreen => screenWidth >= 375 && screenWidth < 600;
  static bool get isLargeScreen => screenWidth >= 600;
  static bool get isTablet => screenWidth >= 600;

  static double get scaleFactor => (screenWidth / designWidth).clamp(0.8, 1.2);
  static double get verticalScaleFactor =>
      (screenHeight / designHeight).clamp(0.8, 1.2);

  static double scale(
    double size, {
    double min = 0,
    double max = double.infinity,
  }) {
    return (size * scaleFactor).clamp(min, max);
  }

  static double verticalScale(
    double size, {
    double min = 0,
    double max = double.infinity,
  }) {
    return (size * verticalScaleFactor).clamp(min, max);
  }

  static double get heading1 => scale(32, min: 24, max: 40);
  static double get heading2 => scale(28, min: 22, max: 36);
  static double get heading3 => scale(24, min: 20, max: 32);
  static double get heading4 => scale(20, min: 18, max: 28);
  static double get bodyLarge => scale(18, min: 16, max: 24);
  static double get bodyMedium => scale(16, min: 14, max: 20);
  static double get bodySmall => scale(14, min: 12, max: 18);
  static double get caption => scale(12, min: 10, max: 16);

  static double get iconSmall => scale(16, min: 14, max: 18);
  static double get iconMedium => scale(20, min: 18, max: 22);
  static double get iconLarge => scale(24, min: 22, max: 28);
  static double get iconXLarge => scale(28, min: 24, max: 32);
  static double get iconXXLarge => scale(32, min: 28, max: 36);

  static double get avatarSmall => scale(32, min: 28, max: 36);
  static double get avatarMedium => scale(40, min: 36, max: 44);
  static double get avatarLarge => scale(48, min: 44, max: 52);
  static double get avatarXLarge => scale(56, min: 52, max: 64);

  static double get imageSmall => verticalScale(60, min: 50, max: 80);
  static double get imageMedium => verticalScale(80, min: 70, max: 100);
  static double get imageLarge => verticalScale(120, min: 100, max: 150);
  static double get imageXLarge => verticalScale(150, min: 130, max: 180);

  static double get spacingXSmall => scale(4, min: 4, max: 6);
  static double get spacingSmall => scale(8, min: 8, max: 10);
  static double get spacingMedium => scale(12, min: 12, max: 16);
  static double get spacingLarge => scale(16, min: 16, max: 20);
  static double get spacingXLarge => scale(24, min: 24, max: 28);
  static double get spacingXXLarge => scale(32, min: 32, max: 36);
  static double get spacingXXXLarge => scale(40, min: 40, max: 44);

  static EdgeInsets get screenPadding => EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      );

  static EdgeInsets get cardPadding =>
      EdgeInsets.all(isSmallScreen ? spacingMedium : spacingLarge);

  static double get horizontalPadding =>
      isSmallScreen ? spacingMedium : spacingLarge;
  static double get verticalPadding => spacingMedium;

  static double get radiusTiny => scale(4, min: 4, max: 6);
  static double get radiusSmall => scale(8, min: 8, max: 10);
  static double get radiusMedium => scale(12, min: 12, max: 14);
  static double get radiusLarge => scale(16, min: 16, max: 18);
  static double get radiusXLarge => scale(24, min: 24, max: 26);
  static double get radiusXXLarge => scale(32, min: 32, max: 34);
  static double get radiusCircular => 1000;

  static double get cardRadius => radiusLarge;
  static double get buttonRadius => radiusXLarge;
  static double get bottomSheetRadius => radiusXLarge;

  static double get bottomSheetHeight => verticalScale(500, min: 400, max: 600);
  static double get bottomSheetMinHeight =>
      verticalScale(300, min: 250, max: 350);
  static double get bottomSheetMaxHeight => screenHeight * 0.9;

  static double get gridSpacing => spacingMedium;
  static int get gridCrossAxisCount => isSmallScreen ? 2 : (isTablet ? 4 : 3);

  static double get buttonHeight => verticalScale(48, min: 44, max: 52);
  static double get buttonWidth => screenWidth * (isSmallScreen ? 0.9 : 0.5);
  static double get smallButtonHeight => verticalScale(36, min: 32, max: 40);
  static double get largeButtonHeight => verticalScale(56, min: 52, max: 60);

  static double get textFieldHeight => verticalScale(48, min: 44, max: 52);
  static double get textFieldWidth => screenWidth * 0.9;

  static double get dividerThickness => scale(1, min: 1, max: 2);
  static double get dividerIndent => spacingLarge;

  static double widthPercent(double percent) => screenWidth * percent / 100;
  static double heightPercent(double percent) => screenHeight * percent / 100;
}

extension ResponsiveExtension on num {
  double get w => ResponsiveManager.scale(toDouble());
  double get h => ResponsiveManager.verticalScale(toDouble());
  double get sp => ResponsiveManager.scale(toDouble(), min: 8, max: 40);
}

extension BuildContextResponsive on BuildContext {
  BuildContext get responsive {
    ResponsiveManager.init(this);
    return this;
  }

  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  bool get isSmallScreen => screenWidth < 375;
  bool get isTablet => screenWidth >= 600;
}

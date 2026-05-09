import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:kcalsense/core/utils/color_manager.dart';

class AnimatedToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData leftIcon;
  final IconData rightIcon;
  final String leftText;
  final String rightText;
  final Color indicatorColor;
  final Color backgroundColor;
  final Color borderColor;

  const AnimatedToggle({
    super.key,
    required this.value,
    required this.onChanged,
    required this.leftIcon,
    required this.rightIcon,
    required this.leftText,
    required this.rightText,
    required this.indicatorColor,
    required this.backgroundColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // ✅ الاعتماد المباشر على لون نصوص الثيم الحالي لضمان تغيرها مع الوضع الداكن/الفاتح
    final defaultTextColor = theme.textTheme.bodyLarge?.color ?? Colors.black87;

    final inactiveTextColor = defaultTextColor;
    final activeTextColor = isDark ? Colors.white : Colors.black87;
    final inactiveIconColor = defaultTextColor.withOpacity(0.8);
    final activeIconColor = Colors.white;

    return SizedBox(
      width: 110, // عرض كافٍ للنصوص الطويلة "العربية" و "English"
      height: 44,
      child: AnimatedToggleSwitch<bool>.dual(
        current: value,
        first: false,
        second: true,
        spacing: 12.0,
        onChanged: onChanged,
        style: ToggleStyle(
          indicatorColor: indicatorColor,
          borderColor: ColorManager.primaryColor,
          borderRadius: BorderRadius.circular(22),
          indicatorBoxShadow: [
            BoxShadow(
              color: ColorManager.primaryColor,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        iconBuilder: (val) {
          final isActive = val == value;
          return Icon(
            val ? rightIcon : leftIcon,
            size: 18,
            color: isActive ? activeIconColor : inactiveIconColor,
          );
        },
        textBuilder: (val) {
          final isActive = val == value;
          return FittedBox(
            fit: BoxFit.scaleDown,
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 40),
              style: (theme.textTheme.bodyMedium ?? const TextStyle()).copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isActive ? activeTextColor : inactiveTextColor,
              ),
              child: Text(val ? rightText : leftText),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../../../core/utils/color_manager.dart';
import '../../../../../../core/utils/responsive_manager.dart';

class PeriodChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const PeriodChip({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ResponsiveManager.radiusCircular),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveManager.spacingLarge,
            vertical: ResponsiveManager.spacingSmall,
          ),
          decoration: BoxDecoration(
            gradient: isSelected && !context.isDarkMode
                ? LinearGradient(colors: [
                    context.primaryColor,
                    context.primaryColor.withAlpha(200)
                  ])
                : isSelected && context.isDarkMode
                    ? LinearGradient(
                        colors: [context.primaryColor, context.primaryColor])
                    : null,
            color: isSelected ? null : context.surfaceColor,
            borderRadius:
                BorderRadius.circular(ResponsiveManager.radiusCircular),
            border: Border.all(
                color: isSelected ? Colors.transparent : context.dividerColor,
                width: 1.2),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: context.primaryColor.withAlpha(60),
                        blurRadius: 10,
                        offset: const Offset(0, 3))
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: ResponsiveManager.iconSmall,
                  color: isSelected ? Colors.white : context.lightGrey),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                   label,
                  style: TextStyle(
                    fontSize: ResponsiveManager.bodySmall,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? Colors.white : context.textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

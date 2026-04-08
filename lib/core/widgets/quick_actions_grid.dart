import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../features/askai/askai_page.dart';
import '../navigation/page_transitions.dart';
import '../utiles/color_manager.dart';
import '../utiles/responsive_manager.dart';

class QuickActionsGrid extends StatelessWidget {
  final VoidCallback onScan;
  final VoidCallback onAskAi;
  final VoidCallback onStats;
  final VoidCallback onManual;

  const QuickActionsGrid({
    super.key,
    required this.onScan,
    required this.onAskAi,
    required this.onStats,
    required this.onManual,
  });

  @override
  Widget build(BuildContext context) {
    ResponsiveManager.init(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final crossAxisCount = isTablet ? 4 : 2;

    return Container(
      padding: EdgeInsets.all(ResponsiveManager.spacingMedium),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(ResponsiveManager.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: context.cardShadow,
            blurRadius: ResponsiveManager.spacingLarge,
            offset: Offset(0, ResponsiveManager.spacingSmall),
          ),
        ],
        border: Border.all(color: context.dividerColor),
      ),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: ResponsiveManager.spacingMedium,
        mainAxisSpacing: ResponsiveManager.spacingMedium,
        childAspectRatio: isTablet ? 1.2 : 1.5,
        children: [
          _ActionTile(
            title: "home.scan_food".tr(),
            icon: Icons.camera_alt_outlined,
            bg: context.primaryColor.withValues(alpha: 0.1),
            onTap: onScan,
            isTablet: isTablet,
          ),
          _ActionTile(
            title: "home.ask_ai".tr(),
            icon: Icons.psychology_alt_outlined,
            bg: context.primaryColor.withValues(alpha: 0.1),
            onTap: () {
              context.pushWithTransition(
                const AskAiPage(),
                type: TransitionType.fast,
              );
            },
            isTablet: isTablet,
          ),
          _ActionTile(
            title: "home.view_stats".tr(),
            icon: Icons.show_chart,
            bg: context.dividerColor.withValues(alpha: 0.5),
            onTap: onStats,
            isTablet: isTablet,
          ),
          _ActionTile(
            title: "home.manual_entry".tr(),
            icon: Icons.add,
            bg: context.dividerColor.withValues(alpha: 0.5),
            onTap: onManual,
            isTablet: isTablet,
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color bg;
  final VoidCallback onTap;
  final bool isTablet;

  const _ActionTile({
    required this.title,
    required this.icon,
    required this.bg,
    required this.onTap,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    ResponsiveManager.init(context);

    final iconSize =
        isTablet ? ResponsiveManager.iconLarge : ResponsiveManager.iconMedium;
    final fontSize =
        isTablet ? ResponsiveManager.bodyMedium : ResponsiveManager.bodySmall;
    final tileHeight = isTablet
        ? ResponsiveManager.buttonHeight * 1.2
        : ResponsiveManager.buttonHeight * 0.9;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(ResponsiveManager.radiusMedium),
      child: InkWell(
        borderRadius: BorderRadius.circular(ResponsiveManager.radiusMedium),
        onTap: onTap,
        child: Container(
          height: tileHeight,
          padding:
              EdgeInsets.symmetric(horizontal: ResponsiveManager.spacingSmall),
          child: isTablet
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: context.textColor, size: iconSize),
                    SizedBox(height: ResponsiveManager.spacingSmall),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w700,
                        color: context.textColor,
                        height: 1.2,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(icon, color: context.textColor, size: iconSize),
                    SizedBox(width: ResponsiveManager.spacingSmall),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w700,
                          color: context.textColor,
                          height: 1.2,
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
